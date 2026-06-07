import 'dart:async';
import 'dart:io';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:dio/dio.dart';
import '../services/chat_service.dart';
import 'doctor/medical_report_screen.dart';

class ChatScreen extends StatefulWidget {
  final String chatId;
  final String title;
  /// Optional case data — when provided the "Write Report" button is shown
  /// and the "Report Submitted" card appears after submission.
  final Map? caseData;

  const ChatScreen({
    super.key,
    required this.chatId,
    this.title = 'Chat',
    this.caseData,
  });

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final TextEditingController _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final ChatService _chatService = ChatService();
  final ImagePicker _imagePicker = ImagePicker();
  List<dynamic> _messages = [];
  bool _isLoading = false;
  bool _isSending = false;
  String _chatStatus = 'active'; // 'active' or 'locked'
  Timer? _pollTimer;
  File? _selectedFile;

  String? _myId;
  String? _myRole;

  /// Resolved case data — starts with widget.caseData, enriched from API if sparse
  Map<String, dynamic>? _resolvedCaseData;

  /// Stores the latest submitted report text (shown in the "Report Submitted" card)
  String? _submittedReport;

  @override
  void initState() {
    super.initState();
    // Seed with whatever was passed in
    if (widget.caseData != null) {
      _resolvedCaseData = Map<String, dynamic>.from(widget.caseData!);
    }
    _loadUserIdentity().then((_) {
      _fetchMessages();
      _markAsRead();
    });
    _fetchCaseSummary(); // enrich case data from API
    // Poll for new messages every 2 seconds
    _pollTimer = Timer.periodic(const Duration(seconds: 2), (_) {
      _fetchMessages(showLoading: false);
      _markAsRead();
    });
  }

  /// Fetch the linked case/analysis summary for this chat and merge into state.
  Future<void> _fetchCaseSummary() async {
    if (widget.chatId.isEmpty) return;
    try {
      final summary = await _chatService.getCaseSummary(chatId: widget.chatId);
      if (summary != null && summary.isNotEmpty && mounted) {
        setState(() {
          // Merge: API data takes priority for analysis fields,
          // but keep existing fields like doctor_name / patient_name
          final merged = <String, dynamic>{};
          if (_resolvedCaseData != null) merged.addAll(_resolvedCaseData!);
          merged.addAll(summary);
          _resolvedCaseData = merged;
        });
      }
    } catch (_) {
      // Silent — card just won't show if data unavailable
    }
  }

  /// Notify backend that the user has seen all messages in this chat.
  Future<void> _markAsRead() async {
    try {
      await _chatService.markAsRead(chatId: widget.chatId);
    } catch (_) {}
  }

  @override
  void dispose() {
    _pollTimer?.cancel();
    _messageController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> _fetchMessages({bool showLoading = true}) async {
    if (showLoading) {
      setState(() => _isLoading = true);
    }
    try {
      // Adjust token key if needed
      final response = await _chatService.getChatMessages(
        chatId: widget.chatId,
      );

      if (response.statusCode == 200) {
        final data = response.data;
        final newMessages = data['data'] ?? data['messages'] ?? [];
        final newStatus = data['chat_status'] ?? _chatStatus;
        if (mounted) {
          // Detect any change: different count OR different last-message id/timestamp
          final bool hasNewMessages = _hasMessagesChanged(newMessages);
          setState(() {
            _messages = List.from(newMessages);
            _chatStatus = newStatus;
          });
          if (hasNewMessages) _scrollToBottom();
        }
      }
    } catch (e) {
      debugPrint("Failed to fetch messages: $e");
    } finally {
      if (showLoading && mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  /// Returns true if [incoming] differs from the current message list
  /// by count, last-message id, or last-message timestamp.
  bool _hasMessagesChanged(List<dynamic> incoming) {
    if (incoming.length != _messages.length) return true;
    if (incoming.isEmpty) return false;
    final last = incoming.last;
    final current = _messages.last;
    if (last is Map && current is Map) {
      // Compare by id first
      final inId = last['id']?.toString() ?? last['_id']?.toString();
      final curId = current['id']?.toString() ?? current['_id']?.toString();
      if (inId != null && curId != null) return inId != curId;
      // Fall back to timestamp
      final inTs = last['created_at']?.toString() ?? last['createdAt']?.toString();
      final curTs = current['created_at']?.toString() ?? current['createdAt']?.toString();
      return inTs != curTs;
    }
    return false;
  }

  Future<void> _sendMessage() async {
    final text = _messageController.text.trim();
    if (text.isEmpty && _selectedFile == null) return;
    if (_chatStatus == 'locked') return;
    _messageController.clear();
    final fileToSend = _selectedFile;
    setState(() {
      _isSending = true;
      _selectedFile = null;
    });
    // Optimistically add message to UI
    final optimisticMsg = {
      "sender_role": "self",
      "_optimistic": true,
      "message_text": text,
      "created_at": DateTime.now().toIso8601String(),
      if (fileToSend != null)
        "file_name": fileToSend.path.split(Platform.pathSeparator).last,
    };
    setState(() {
      _messages.add(optimisticMsg);
    });
    _scrollToBottom();
    try {
      await _chatService.sendMessage(
        chatId: widget.chatId,
        messageText: text.isNotEmpty ? text : null,
        file: fileToSend,
      );
      // Refresh messages from server to get the real message object
      await _fetchMessages(showLoading: false);
    } catch (e) {
      debugPrint("Failed to send message: $e");

      if (mounted) {
        // Remove optimistic message on failure
        setState(() {
          _messages.removeWhere((m) => m['_optimistic'] == true);
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              e.toString().contains('403')
                  ? 'Chat is locked. Book a new appointment to continue.'
                  : 'Failed to send message. Please try again.',
            ),
            backgroundColor: Colors.red.shade400,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isSending = false);
      }
    }
  }

  Future<void> _pickFile() async {
    final picked = await _imagePicker.pickImage(source: ImageSource.gallery);
    if (picked != null && mounted) {
      setState(() {
        _selectedFile = File(picked.path);
      });
    }
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  Future<void> _loadUserIdentity() async {
    final prefs = await SharedPreferences.getInstance();

    // 1. Read api_role saved at login — instant, no network needed
    //    api_role is lowercase: 'patient' | 'doctor' | 'admin'
    final savedApiRole = prefs.getString('api_role') ?? '';
    if (savedApiRole.isNotEmpty) {
      _myRole = savedApiRole;
    }

    // 2. Try decoding JWT to get the user ID
    try {
      final token = prefs.getString('token') ?? '';
      if (token.isNotEmpty) {
        final payload = _decodeJwt(token);
        final id =
            payload['id']?.toString() ??
            payload['userId']?.toString() ??
            payload['user_id']?.toString() ??
            payload['sub']?.toString();
        if (id != null && id.isNotEmpty) {
          _myId = id;
        }
        // Also pick up role from JWT if api_role wasn't saved
        if (_myRole == null || _myRole!.isEmpty) {
          _myRole =
              (payload['role']?.toString() ??
               payload['user_role']?.toString() ?? '')
              .toLowerCase();
        }
      }
    } catch (e) {
      debugPrint("JWT decode failed: $e");
    }

    // 3. Fallback: fetch profile if we still don't have an ID
    if (_myId == null || _myId!.isEmpty) {
      try {
        final token = prefs.getString('token') ?? '';
        final dio = Dio(BaseOptions(baseUrl: 'https://api.skinnerai.site'));
        final response = await dio.get(
          '/api/profile/me',
          options: Options(headers: {'Authorization': 'Bearer $token'}),
        );
        if (response.statusCode == 200) {
          final data = response.data['data'] ?? response.data;
          _myId =
              data['id']?.toString() ??
              data['user_id']?.toString() ??
              data['_id']?.toString();
          if (_myRole == null || _myRole!.isEmpty) {
            _myRole = (data['role']?.toString() ?? '').toLowerCase();
          }
        }
      } catch (e) {
        debugPrint("Failed to fetch profile: $e");
      }
    }

    if (mounted) setState(() {});
  }

  Map<String, dynamic> _decodeJwt(String token) {
    try {
      final parts = token.split('.');
      if (parts.length < 2) return {};
      final normalized = base64Url.normalize(parts[1]);
      final resp = utf8.decode(base64Url.decode(normalized));
      return jsonDecode(resp) as Map<String, dynamic>;
    } catch (e) {
      debugPrint("Error decoding JWT: $e");
      return {};
    }
  }

  /// Determine if the current user sent this message.
  /// Priority:  optimistic flag → is_mine flag → sender_id vs _myId → sender_role vs _myRole
  bool _isMyMessage(Map<String, dynamic> msg) {
    // 1. Messages we added optimistically are always ours
    if (msg['_optimistic'] == true) return true;

    // 2. Backend explicit flag
    if (msg['is_mine'] == true) return true;
    if (msg['sender'] == 'me') return true;

    // 3. ID comparison — most reliable when available
    if (_myId != null && _myId!.isNotEmpty) {
      final senderId =
          msg['sender_id']?.toString() ??
          msg['senderId']?.toString() ??
          msg['user_id']?.toString() ??
          msg['userId']?.toString();
      if (senderId != null && senderId.isNotEmpty) {
        return senderId == _myId;
      }
    }

    // 4. Role comparison — fallback when IDs are unavailable.
    //    _myRole is always lowercase ('patient' | 'doctor' | 'admin')
    if (_myRole != null && _myRole!.isNotEmpty) {
      final senderRole = (msg['sender_role']?.toString() ??
              msg['senderRole']?.toString() ??
              msg['role']?.toString() ??
              msg['sender_type']?.toString() ??
              '')
          .toLowerCase();
      if (senderRole.isNotEmpty) {
        return senderRole == _myRole;
      }
    }

    return false;
  }

  String _getMessageText(Map<String, dynamic> msg) {
    return msg['message_text'] ?? msg['message'] ?? msg['text'] ?? '';
  }

  String? _getFileUrl(Map<String, dynamic> msg) {
    return msg['file_url'] ?? msg['chat_file'] ?? msg['attachment_url'];
  }

  /// Check if a message has been read/seen by the other party.
  bool _isMessageRead(Map<String, dynamic> msg) {
    // Check various possible field names from the backend
    return msg['is_read'] == true ||
        msg['read'] == true ||
        msg['seen'] == true ||
        msg['is_seen'] == true ||
        msg['status'] == 'read' ||
        msg['status'] == 'seen';
  }

  String _formatTime(String? dateStr) {
    if (dateStr == null) return '';
    try {
      final dt = DateTime.parse(dateStr).toLocal();
      final hour = dt.hour.toString().padLeft(2, '0');
      final min = dt.minute.toString().padLeft(2, '0');
      return '$hour:$min';
    } catch (_) {
      return '';
    }
  }

  @override
  Widget build(BuildContext context) {
    final bool isLocked = _chatStatus == 'locked';
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    // Build initials for avatar
    final parts = widget.title.trim().split(' ');
    final initials = parts.length >= 2
        ? '${parts[0][0]}${parts[1][0]}'.toUpperCase()
        : widget.title.isNotEmpty
            ? widget.title[0].toUpperCase()
            : '?';

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: theme.appBarTheme.backgroundColor,
        elevation: 0,
        leading: BackButton(color: theme.iconTheme.color),
        titleSpacing: 0,
        title: Row(
          children: [
            CircleAvatar(
              radius: 18,
              backgroundColor: const Color(0xFFDBEAFE),
              child: Text(initials,
                  style: const TextStyle(
                      color: Color(0xFF2563EB),
                      fontWeight: FontWeight.bold,
                      fontSize: 13)),
            ),
            const SizedBox(width: 10),
            Text(widget.title,
                style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    color: theme.textTheme.bodyLarge?.color)),
          ],
        ),
        actions: [
          // ── Write Report button in AppBar ─────────────────
          TextButton.icon(
            onPressed: () {
              final caseData = _resolvedCaseData;
              final appointmentId =
                  (caseData?['appointment_id'] ?? '').toString();
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => MedicalReportScreen(
                    appointmentId: appointmentId,
                    initialText: _submittedReport,
                    onSubmitted: (text) {
                      if (mounted) setState(() => _submittedReport = text);
                    },
                  ),
                ),
              );
            },
            style: TextButton.styleFrom(
              foregroundColor: theme.textTheme.bodyLarge?.color,
              padding: const EdgeInsets.symmetric(horizontal: 8),
            ),
            icon: const Icon(Icons.edit_note_rounded, size: 18),
            label: const Text('Report',
                style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600)),
          ),
          // ── Secure / Locked badge ─────────────────────────
          Container(
            margin: const EdgeInsets.only(right: 12),
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
            decoration: BoxDecoration(
              border: Border.all(
                  color: isLocked
                      ? const Color(0xFFFCA5A5)
                      : const Color(0xFF86EFAC)),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  isLocked ? Icons.lock_outline : Icons.shield_outlined,
                  size: 13,
                  color: isLocked
                      ? const Color(0xFFEF4444)
                      : const Color(0xFF16A34A),
                ),
                const SizedBox(width: 4),
                Text(
                  isLocked ? 'Locked' : 'Secure',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                    color: isLocked
                        ? const Color(0xFFEF4444)
                        : const Color(0xFF16A34A),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
      body: Column(
        children: [
          // ── Encryption banner ──────────────────────────────
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 7),
            color: isDark ? const Color(0xFF1E3A5F) : Colors.blue.shade50,
            child: Row(
              children: [
                Icon(Icons.lock_outline_rounded,
                    size: 14,
                    color: isDark ? Colors.blue.shade200 : Colors.blue.shade700),
                const SizedBox(width: 6),
                Expanded(
                  child: Text(
                    'End-to-end encrypted conversation. Your privacy is protected.',
                    style: TextStyle(
                        fontSize: 11,
                        color: isDark ? Colors.blue.shade200 : Colors.blue.shade700),
                  ),
                ),
              ],
            ),
          ),

          // ── Clinical Summary (pinned, always visible) ──────
          _buildClinicalSummary(isDark, theme),

          // ── Messages list ──────────────────────────────────
          Expanded(
            child: _isLoading && _messages.isEmpty
                ? const Center(child: CircularProgressIndicator())
                : ListView.builder(
                    controller: _scrollController,
                    padding: const EdgeInsets.fromLTRB(16, 4, 16, 12),
                    itemCount: _messages.length,
                    itemBuilder: (context, index) {
                      final msg = Map<String, dynamic>.from(
                          _messages[index]);
                      final messageText = _getMessageText(msg);
                      final fileUrl     = _getFileUrl(msg);
                      final time        = _formatTime(
                          msg['created_at']?.toString() ??
                              msg['createdAt']?.toString());
                      final isMe        = _isMyMessage(msg);
                      final isOptimistic = msg['_optimistic'] == true;
                      final isRead      = _isMessageRead(msg);

                          return Align(
                            alignment: isMe
                                ? Alignment.centerRight
                                : Alignment.centerLeft,
                            child: ConstrainedBox(
                              constraints: BoxConstraints(
                                  maxWidth:
                                      MediaQuery.of(context).size.width *
                                          0.78),
                              child: Column(
                                crossAxisAlignment: isMe
                                    ? CrossAxisAlignment.end
                                    : CrossAxisAlignment.start,
                                children: [
                                  // Sender label (only for received messages)
                                  if (!isMe)
                                    Padding(
                                      padding: const EdgeInsets.only(
                                          left: 4, bottom: 2),
                                      child: Text(
                                        _myRole == 'patient'
                                            ? 'Doctor'
                                            : 'Patient',
                                        style: TextStyle(
                                          fontSize: 11,
                                          fontWeight: FontWeight.w600,
                                          color: isDark
                                              ? const Color(0xFF93C5FD)
                                              : const Color(0xFF2563EB),
                                        ),
                                      ),
                                    ),
                                  // Bubble
                                  Container(
                                    margin: const EdgeInsets.only(top: 4),
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 14, vertical: 10),
                                    decoration: BoxDecoration(
                                      color: isMe
                                          ? const Color(0xFF2563EB)
                                          : (isDark ? const Color(0xFF1E293B) : Colors.white),
                                      borderRadius: BorderRadius.only(
                                        topLeft:
                                            const Radius.circular(16),
                                        topRight:
                                            const Radius.circular(16),
                                        bottomLeft:
                                            Radius.circular(isMe ? 16 : 4),
                                        bottomRight:
                                            Radius.circular(isMe ? 4 : 16),
                                      ),
                                      boxShadow: [
                                        BoxShadow(
                                          color: Colors.black
                                              .withOpacity(0.05),
                                          blurRadius: 4,
                                          offset: const Offset(0, 1),
                                        ),
                                      ],
                                    ),
                                    child: Column(
                                      crossAxisAlignment: isMe
                                          ? CrossAxisAlignment.end
                                          : CrossAxisAlignment.start,
                                      children: [
                                        if (fileUrl != null &&
                                            fileUrl.isNotEmpty)
                                          _fileChip(isMe),
                                        if (msg['file_name'] != null &&
                                            fileUrl == null)
                                          _fileChip(isMe,
                                              name: msg['file_name']),
                                        if (messageText.isNotEmpty)
                                          Text(
                                            messageText,
                                            style: TextStyle(
                                              color: isMe
                                                  ? Colors.white
                                                  : (isDark ? const Color(0xFFE2E8F0) : const Color(0xFF0F172A)),
                                              fontSize: 14,
                                              height: 1.4,
                                            ),
                                          ),
                                      ],
                                    ),
                                  ),

                                  // Timestamp + read indicator
                                  Padding(
                                    padding: const EdgeInsets.only(
                                        top: 3,
                                        bottom: 6,
                                        left: 4,
                                        right: 4),
                                    child: Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Text(
                                          time.isNotEmpty
                                              ? time
                                              : _formatTime(DateTime.now()
                                                  .toIso8601String()),
                                          style: TextStyle(
                                              fontSize: 10,
                                              color: Colors.grey.shade500),
                                        ),
                                        if (isMe) ...[
                                          const SizedBox(width: 4),
                                          if (isOptimistic)
                                            Icon(Icons.access_time_rounded,
                                                size: 12,
                                                color: Colors.grey.shade400)
                                          else if (isRead)
                                            const Icon(Icons.done_all,
                                                size: 12,
                                                color: Color(0xFF2563EB))
                                          else
                                            Icon(Icons.done_all,
                                                size: 12,
                                                color: Colors.grey.shade400),
                                        ],
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
          ),

          // Locked footer text
          if (isLocked)
            Container(
              padding: const EdgeInsets.symmetric(
                  horizontal: 16, vertical: 8),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.lock_outline,
                      size: 12, color: Colors.grey.shade500),
                  const SizedBox(width: 6),
                  Text(
                    'This chat is locked because the case has been completed.',
                    style: TextStyle(
                        fontSize: 11, color: Colors.grey.shade500),
                  ),
                ],
              ),
            ),

          // ── Selected file preview ──────────────────────────
          if (_selectedFile != null)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              color: isDark ? const Color(0xFF1E293B) : Colors.grey.shade100,
              child: Row(
                children: [
                  const Icon(Icons.attach_file,
                      size: 16, color: Colors.grey),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      _selectedFile!.path
                          .split(Platform.pathSeparator)
                          .last,
                      style: const TextStyle(fontSize: 13),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close, size: 18),
                    onPressed: () =>
                        setState(() => _selectedFile = null),
                  ),
                ],
              ),
            ),

          // ── Input bar ──────────────────────────────────────
          Container(
            padding: const EdgeInsets.fromLTRB(12, 10, 12, 8),
            decoration: BoxDecoration(
              color: theme.appBarTheme.backgroundColor ?? theme.cardColor,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 4,
                  offset: const Offset(0, -2),
                ),
              ],
            ),
            child: SafeArea(
              top: false,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Container(
                          height: 48,
                          decoration: BoxDecoration(
                            color: isDark ? const Color(0xFF334155) : const Color(0xFFF8F9FA),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                                color: isDark ? const Color(0xFF475569) : const Color(0xFFE5E7EB)),
                          ),
                          child: Row(
                            children: [
                              Expanded(
                                child: TextField(
                                  controller: _messageController,
                                  enabled: !isLocked,
                                  onSubmitted: (_) => _sendMessage(),
                                  style: const TextStyle(fontSize: 14),
                                  decoration: InputDecoration(
                                    hintText: isLocked
                                        ? 'Chat is locked…'
                                        : 'Type your message...',
                                    hintStyle: const TextStyle(
                                        color: Color(0xFFD1D5DB),
                                        fontSize: 14),
                                    border: InputBorder.none,
                                    contentPadding:
                                        const EdgeInsets.symmetric(
                                            horizontal: 14, vertical: 14),
                                  ),
                                ),
                              ),
                              // Attachment button inside field
                              if (!isLocked)
                                IconButton(
                                  icon: const Icon(Icons.attach_file,
                                      color: Color(0xFF9CA3AF), size: 20),
                                  onPressed: _pickFile,
                                ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      // Send button
                      GestureDetector(
                        onTap: isLocked || _isSending ? null : _sendMessage,
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 200),
                          width: 48,
                          height: 48,
                          decoration: BoxDecoration(
                            color: isLocked
                                ? const Color(0xFFD1D5DB)
                                : const Color(0xFF2563EB),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Center(
                            child: _isSending
                                ? const SizedBox(
                                    width: 20,
                                    height: 20,
                                    child: CircularProgressIndicator(
                                        strokeWidth: 2,
                                        color: Colors.white))
                                : const Icon(Icons.send_rounded,
                                    color: Colors.white, size: 20),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Text(
                    'Messages are monitored for quality assurance and training purposes',
                    style: TextStyle(
                        fontSize: 10, color: Colors.grey.shade400),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
          ),

          // ── Report Submitted card (shown after doctor submits) ──
          if (_submittedReport != null)
            Container(
              margin: const EdgeInsets.fromLTRB(12, 0, 12, 10),
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: const Color(0xFFE5E7EB)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Header
                  Row(
                    children: const [
                      Icon(Icons.description_outlined,
                          size: 18, color: Color(0xFF16A34A)),
                      SizedBox(width: 6),
                      Text(
                        'Report Submitted',
                        style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF16A34A)),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Text(
                    _submittedReport!,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                        fontSize: 12, color: Color(0xFF16A34A)),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      // Download Report
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed: () {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                  content: Text('Report download coming soon')),
                            );
                          },
                          icon: const Icon(Icons.download_outlined,
                              size: 16, color: Color(0xFF2563EB)),
                          label: const Text('Download Report',
                              style: TextStyle(
                                  fontSize: 12, color: Color(0xFF2563EB))),
                          style: OutlinedButton.styleFrom(
                            side: const BorderSide(color: Color(0xFF2563EB)),
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10)),
                            padding: const EdgeInsets.symmetric(vertical: 10),
                          ),
                        ),
                      ),
                      const SizedBox(width: 10),
                      // Edit Report
                      Expanded(
                        child: ElevatedButton(
                          onPressed: () {
                            final caseData = _resolvedCaseData;
                            final appointmentId =
                                (caseData?['appointment_id'] ?? '').toString();
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => MedicalReportScreen(
                                  appointmentId: appointmentId,
                                  initialText: _submittedReport,
                                  onSubmitted: (text) {
                                    if (mounted) {
                                      setState(() => _submittedReport = text);
                                    }
                                  },
                                ),
                              ),
                            );
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF0F172A),
                            foregroundColor: Colors.white,
                            elevation: 0,
                            padding: const EdgeInsets.symmetric(vertical: 10),
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10)),
                          ),
                          child: const Text('Edit Report',
                              style: TextStyle(fontSize: 12)),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }

  Widget _fileChip(bool isPatient, {String? name}) => Padding(
        padding: const EdgeInsets.only(bottom: 4),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(name != null ? Icons.upload_file : Icons.attach_file,
                size: 13,
                color: isPatient ? Colors.white70 : Colors.black54),
            const SizedBox(width: 4),
            Flexible(
              child: Text(
                name ?? 'Attachment',
                style: TextStyle(
                  fontSize: 12,
                  color: isPatient ? Colors.white70 : Colors.black54,
                  decoration:
                      name == null ? TextDecoration.underline : null,
                ),
              ),
            ),
          ],
        ),
      );

  // ── Clinical Summary card shown at the top of the chat ───────────────────
  Widget _buildClinicalSummary(bool isDark, ThemeData theme) {
    final caseData = _resolvedCaseData;
    if (caseData == null) return const SizedBox.shrink();

    // Extract fields
    final patientName = caseData['patient_name']?.toString() ?? '';
    final gender = caseData['gender']?.toString() ?? caseData['patient_gender']?.toString() ?? '';
    final age = caseData['age']?.toString() ?? caseData['patient_age']?.toString() ?? '';
    final prediction = caseData['skin_disease_classification']?.toString() ??
        caseData['ai_diagnosis']?.toString() ?? '';
    final rawConf = caseData['confidence'] ?? caseData['ai_confidence'] ?? 0;
    final confidence = (rawConf is num) ? rawConf.toDouble() : 0.0;
    final rawDate = caseData['created_at']?.toString() ??
        caseData['analysis_date']?.toString() ?? '';
    final skinImageUrl = caseData['skin_image_upload']?.toString() ??
        caseData['image_url']?.toString() ?? '';

    // Build date string
    String dateStr = '';
    if (rawDate.isNotEmpty) {
      try {
        final dt = DateTime.parse(rawDate).toLocal();
        const months = ['Jan','Feb','Mar','Apr','May','Jun',
                        'Jul','Aug','Sep','Oct','Nov','Dec'];
        dateStr = '${months[dt.month - 1]} ${dt.day}, ${dt.year}';
      } catch (_) {
        dateStr = rawDate.length >= 10 ? rawDate.substring(0, 10) : rawDate;
      }
    }

    // Patient display
    String patientDisplay = patientName.isNotEmpty ? patientName : 'Patient';
    if (gender.isNotEmpty && age.isNotEmpty) {
      final g = gender[0].toUpperCase() + gender.substring(1).toLowerCase();
      patientDisplay += ' ($g, $age)';
    }

    // Confidence badge
    String confLabel;
    Color confColor;
    if (confidence >= 0.85) {
      confLabel = 'HIGH CONFIDENCE';
      confColor = const Color(0xFFEF4444);
    } else if (confidence >= 0.60) {
      confLabel = 'MEDIUM CONFIDENCE';
      confColor = const Color(0xFFF59E0B);
    } else {
      confLabel = 'LOW CONFIDENCE';
      confColor = const Color(0xFF10B981);
    }

    // Hide card if no meaningful data
    if (prediction.isEmpty && patientName.isEmpty) return const SizedBox.shrink();

    return Container(
      margin: const EdgeInsets.fromLTRB(16, 12, 16, 4),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme.cardColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: theme.dividerColor),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: const Color(0xFF2C67FF).withOpacity(0.12),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(Icons.description_outlined,
                    color: Color(0xFF2C67FF), size: 18),
              ),
              const SizedBox(width: 10),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Clinical Summary',
                      style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.bold,
                          color: theme.textTheme.bodyLarge?.color)),
                  const Text('AI-Powered',
                      style: TextStyle(fontSize: 11, color: Colors.grey)),
                ],
              ),
            ],
          ),

          Divider(height: 24, color: theme.dividerColor),

          // Patient + Date row
          Row(
            children: [
              Expanded(
                child: _summaryField('Patient', patientDisplay, theme),
              ),
              if (dateStr.isNotEmpty)
                Expanded(
                  child: _summaryField('Analysis Date', dateStr, theme),
                ),
            ],
          ),

          const SizedBox(height: 16),

          // AI Prediction + Confidence row
          if (prediction.isNotEmpty)
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('AI Prediction',
                          style: TextStyle(
                              fontSize: 12, color: Colors.grey.shade500)),
                      const SizedBox(height: 4),
                      Text(prediction,
                          style: const TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF2C67FF))),
                    ],
                  ),
                ),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('confidence',
                          style: TextStyle(
                              fontSize: 12, color: Colors.grey.shade500)),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          Text(
                            '${(confidence * 100).toStringAsFixed(0)}%',
                            style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.bold,
                                color: theme.textTheme.bodyLarge?.color),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(4),
                              child: LinearProgressIndicator(
                                value: confidence,
                                minHeight: 6,
                                backgroundColor: isDark
                                    ? const Color(0xFF334155)
                                    : const Color(0xFFE5E7EB),
                                valueColor:
                                    const AlwaysStoppedAnimation<Color>(
                                        Color(0xFF2C67FF)),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),

          const SizedBox(height: 16),

          // Confidence Level badge
          if (prediction.isNotEmpty) ...[
            Text('Confidence Level',
                style: TextStyle(
                    fontSize: 12, color: Colors.grey.shade500)),
            const SizedBox(height: 6),
            Container(
              padding:
                  const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: confColor, width: 1.5),
              ),
              child: Text(
                confLabel,
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  color: confColor,
                  letterSpacing: 0.5,
                ),
              ),
            ),
          ],

          // ── View Skin Scan button ─────────────────────────
          const SizedBox(height: 16),
          Divider(color: theme.dividerColor, height: 1),
          const SizedBox(height: 12),
          SizedBox(
            width: double.infinity,
            height: 46,
            child: ElevatedButton.icon(
              onPressed: skinImageUrl.isNotEmpty
                  ? () => _showSkinScan(context, skinImageUrl)
                  : null,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF2C67FF),
                foregroundColor: Colors.white,
                disabledBackgroundColor: Colors.grey.shade400,
                elevation: 0,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12)),
              ),
              icon: const Icon(Icons.description_outlined, size: 18),
              label: const Text('View Skin Scan',
                  style: TextStyle(
                      fontSize: 14, fontWeight: FontWeight.w600)),
            ),
          ),
        ],
      ),
    );
  }

  Widget _summaryField(String label, String value, ThemeData theme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label,
            style: TextStyle(fontSize: 12, color: Colors.grey.shade500)),
        const SizedBox(height: 4),
        Text(value,
            style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: theme.textTheme.bodyLarge?.color)),
      ],
    );
  }

  void _showSkinScan(BuildContext context, String imageUrl) {
    final fullUrl = imageUrl.startsWith('http')
        ? imageUrl
        : 'http://187.127.227.63$imageUrl';
    showDialog(
      context: context,
      builder: (_) => Dialog(
        backgroundColor: Colors.black,
        insetPadding: const EdgeInsets.all(16),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(12),
          child: Image.network(
            fullUrl,
            fit: BoxFit.contain,
            errorBuilder: (_, __, ___) => const Padding(
              padding: EdgeInsets.all(32),
              child: Icon(Icons.broken_image_outlined,
                  color: Colors.grey, size: 64),
            ),
          ),
        ),
      ),
    );
  }
}
