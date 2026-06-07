import 'package:flutter/material.dart';
import '../services/chat_service.dart';
import 'chat_screens.dart';

class ChatListScreen extends StatefulWidget {
  const ChatListScreen({super.key});
  @override
  State<ChatListScreen> createState() => _ChatListScreenState();
}

class _ChatListScreenState extends State<ChatListScreen> {
  final ChatService _chatService = ChatService();
  List<dynamic> _chats = [];
  bool _isLoading = false;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _fetchChats();
  }

  Future<void> _fetchChats() async {
    setState(() { _isLoading = true; _errorMessage = null; });
    try {
      final response = await _chatService.getMyChats();
      if (response.statusCode == 200) {
        setState(() { _chats = response.data['data'] ?? []; });
      }
    } catch (e) {
      debugPrint("Failed to fetch chats: $e");
      setState(() { _errorMessage = 'Failed to load chats. Pull down to retry.'; });
    } finally {
      setState(() => _isLoading = false);
    }
  }

  String _getChatTitle(Map<String, dynamic> chat) =>
      chat['doctor_name'] ?? chat['patient_name'] ?? chat['other_party_name'] ?? 'Chat';

  String _getLastMessagePreview(Map<String, dynamic> chat) {
    final lastMsg = chat['last_message'];
    if (lastMsg == null) return 'No messages yet';
    if (lastMsg is String) return lastMsg;
    if (lastMsg is Map) return lastMsg['message_text'] ?? lastMsg['message'] ?? lastMsg['text'] ?? 'Attachment';
    return 'No messages yet';
  }

  String _formatLastTime(Map<String, dynamic> chat) {
    final lastMsg = chat['last_message'];
    String? dateStr;
    if (lastMsg is Map) dateStr = lastMsg['created_at']?.toString() ?? lastMsg['createdAt']?.toString();
    if (dateStr == null) return '';
    try {
      final dt = DateTime.parse(dateStr);
      final now = DateTime.now();
      if (dt.year == now.year && dt.month == now.month && dt.day == now.day) {
        return '${dt.hour.toString().padLeft(2, '0')}:${dt.minute.toString().padLeft(2, '0')}';
      }
      return '${dt.day}/${dt.month}/${dt.year}';
    } catch (_) { return ''; }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('My Chats'),
        actions: [IconButton(icon: const Icon(Icons.refresh), onPressed: _fetchChats)],
      ),
      body: RefreshIndicator(onRefresh: _fetchChats, child: _buildBody()),
    );
  }

  Widget _buildBody() {
    if (_isLoading && _chats.isEmpty) return const Center(child: CircularProgressIndicator());
    if (_errorMessage != null && _chats.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(mainAxisSize: MainAxisSize.min, children: [
            const Icon(Icons.error_outline, size: 48, color: Colors.grey),
            const SizedBox(height: 16),
            Text(_errorMessage!, textAlign: TextAlign.center, style: const TextStyle(color: Colors.grey)),
            const SizedBox(height: 16),
            ElevatedButton(onPressed: _fetchChats, child: const Text('Retry')),
          ]),
        ),
      );
    }
    if (_chats.isEmpty) {
      return const Center(
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          Icon(Icons.chat_bubble_outline, size: 64, color: Colors.grey),
          SizedBox(height: 16),
          Text('No chats yet', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w500, color: Colors.grey)),
          SizedBox(height: 8),
          Text('Book an appointment and pay to start\nchatting with your doctor.',
              textAlign: TextAlign.center, style: TextStyle(color: Colors.grey)),
        ]),
      );
    }
    return ListView.separated(
      padding: const EdgeInsets.symmetric(vertical: 8),
      itemCount: _chats.length,
      separatorBuilder: (_, __) => const Divider(height: 1, indent: 72),
      itemBuilder: (context, index) {
        final chat = Map<String, dynamic>.from(_chats[index]);
        final chatId = chat['chat_id']?.toString() ?? '';
        final title = _getChatTitle(chat);
        final preview = _getLastMessagePreview(chat);
        final time = _formatLastTime(chat);
        final isLocked = (chat['status'] ?? 'active') == 'locked';
        final unread = (chat['unread_count'] ?? chat['unreadCount'] ?? 0) as int;

        return ListTile(
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          leading: Stack(
            children: [
              CircleAvatar(
                radius: 24,
                backgroundColor: isLocked ? Colors.grey.shade400 : const Color(0xFF2C67FF),
                child: Text(title.isNotEmpty ? title[0].toUpperCase() : '?',
                    style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 18)),
              ),
              if (unread > 0)
                Positioned(
                  right: 0, top: 0,
                  child: Container(
                    width: 16, height: 16,
                    decoration: const BoxDecoration(color: Color(0xFFEF4444), shape: BoxShape.circle),
                    child: Center(
                      child: Text(unread > 9 ? '9+' : '$unread',
                          style: const TextStyle(color: Colors.white, fontSize: 9, fontWeight: FontWeight.bold)),
                    ),
                  ),
                ),
            ],
          ),
          title: Row(children: [
            Expanded(child: Text(title,
                style: const TextStyle(fontWeight: FontWeight.w600), overflow: TextOverflow.ellipsis)),
            if (time.isNotEmpty)
              Text(time, style: TextStyle(fontSize: 12, color: Colors.grey.shade500)),
          ]),
          subtitle: Row(children: [
            Expanded(child: Text(preview, maxLines: 1, overflow: TextOverflow.ellipsis,
                style: TextStyle(color: Colors.grey.shade600))),
            if (isLocked)
              Container(
                margin: const EdgeInsets.only(left: 8),
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(color: Colors.red.shade100, borderRadius: BorderRadius.circular(8)),
                child: Row(mainAxisSize: MainAxisSize.min, children: [
                  Icon(Icons.lock, size: 10, color: Colors.red.shade700),
                  const SizedBox(width: 2),
                  Text('Locked', style: TextStyle(fontSize: 10, color: Colors.red.shade700, fontWeight: FontWeight.w500)),
                ]),
              ),
          ]),
          onTap: () => Navigator.push(context,
              MaterialPageRoute(builder: (_) => ChatScreen(
                chatId: chatId, title: title, caseData: chat))),
        );
      },
    );
  }
}
