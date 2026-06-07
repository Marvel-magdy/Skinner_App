import 'dart:async';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:skinner/theme/theme_provider.dart';
import 'package:skinner/authuntication/signin.dart';
import 'package:skinner/l10n/app_translations.dart';
import 'package:skinner/screens/chatbot.dart';
import 'package:skinner/screens/doctor/pending_screen.dart';
import 'package:skinner/screens/doctor/finished_screen.dart';
import 'package:skinner/screens/doctor/schedule_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:skinner/services/auth_service.dart';

class DoctorPortalScreen extends StatefulWidget {
  const DoctorPortalScreen({super.key});

  @override
  State<DoctorPortalScreen> createState() => _DoctorPortalScreenState();
}

class _DoctorPortalScreenState extends State<DoctorPortalScreen> {
  int _activeTabIndex = 0;

  // Stats
  int _pendingCount  = 0;
  int _reviewedToday = 0;
  int _totalPatients = 0;
  bool _statsLoading = true;

  // Polling — mirrors the frontend's socket `appointment_booked` listener
  Timer? _pollTimer;
  int _lastKnownPending = 0;
  int _pendingScreenKey = 0;

  @override
  void initState() {
    super.initState();
    _loadStats();
    _startPolling();
  }

  @override
  void dispose() {
    _pollTimer?.cancel();
    super.dispose();
  }

  // ── Polling ───────────────────────────────────────────────

  void _startPolling() {
    _pollTimer = Timer.periodic(const Duration(seconds: 10), (_) {
      _pollPendingCases();
    });
  }

  Future<String> _resolveToken() async {
    if (adminToken != null && adminToken!.isNotEmpty) return adminToken!;
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('token') ?? '';
  }

  Future<void> _pollPendingCases() async {
    try {
      final token = await _resolveToken();
      if (token.isEmpty) return;
      final response = await AuthService().getPendingCases(token: token);
      final list  = response.data['data'] as List? ?? [];
      final count = list.length;

      if (!mounted) return;

      if (count > _lastKnownPending && _lastKnownPending != 0) {
        final newCount = count - _lastKnownPending;
        _showNewCaseNotification(newCount);
        setState(() {
          _pendingScreenKey++;
          _pendingCount = count;
        });
      } else if (count != _pendingCount) {
        setState(() => _pendingCount = count);
      }

      _lastKnownPending = count;
    } catch (_) {}
  }

  void _showNewCaseNotification(int newCount) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        behavior: SnackBarBehavior.floating,
        margin: const EdgeInsets.fromLTRB(16, 0, 16, 16),
        backgroundColor: const Color(0xFF1E3A5F),
        duration: const Duration(seconds: 5),
        content: Row(
          children: [
            const Icon(Icons.notifications_active_outlined,
                color: Colors.white, size: 20),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                newCount == 1
                    ? 'New patient case arrived — review it now'
                    : '$newCount new patient cases arrived',
                style: const TextStyle(color: Colors.white, fontSize: 13),
              ),
            ),
          ],
        ),
        action: SnackBarAction(
          label: 'View',
          textColor: const Color(0xFF93C5FD),
          onPressed: () => setState(() => _activeTabIndex = 0),
        ),
      ),
    );
  }

  // ── Stats ─────────────────────────────────────────────────

  Future<void> _loadStats() async {
    try {
      final token = await _resolveToken();
      if (token.isEmpty) {
        if (mounted) setState(() => _statsLoading = false);
        return;
      }

      final pending  = await AuthService().getPendingCases(token: token);
      final reviewed = await AuthService().getReviewedCases(token: token);

      final pendingList  = pending.data['data']  as List? ?? [];
      final reviewedList = reviewed.data['data'] as List? ?? [];

      final today = DateTime.now().toIso8601String().substring(0, 10);
      final todayCount = reviewedList
          .where((c) => (c['reviewed_at'] ?? '').toString().startsWith(today))
          .length;

      final allNames = {
        ...pendingList.map((c)  => c['patient_name'] ?? ''),
        ...reviewedList.map((c) => c['patient_name'] ?? ''),
      };

      if (mounted) {
        setState(() {
          _pendingCount     = pendingList.length;
          _lastKnownPending = pendingList.length;
          _reviewedToday    = todayCount;
          _totalPatients    = allNames.length;
          _statsLoading     = false;
        });
      }
    } catch (_) {
      if (mounted) setState(() => _statsLoading = false);
    }
  }

  // ── Build ──────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    // Rebuild whenever locale changes
    return Consumer<LocaleProvider>(
      builder: (context, localeProvider, _) {
        final t = (String key) => AppL10n.of(context, key);
        final isRtl = localeProvider.locale.languageCode == 'ar';

        return Directionality(
          textDirection: isRtl ? TextDirection.rtl : TextDirection.ltr,
          child: Scaffold(
            backgroundColor: Theme.of(context).scaffoldBackgroundColor,
            appBar: _buildAppBar(context, localeProvider, t),
            floatingActionButton: FloatingActionButton(
              heroTag: 'chatbot',
              backgroundColor: const Color(0xFF2C67FF),
              tooltip: 'AI Chatbot',
              onPressed: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const ChatBotScreen()),
              ),
              child: const Icon(Icons.smart_toy_outlined, color: Colors.white),
            ),
            body: Column(
              children: [
                const SizedBox(height: 12),

                // ── Tab bar ──────────────────────────────────
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: _buildTabs(context, t),
                ),

                const SizedBox(height: 12),

                // ── Content ──────────────────────────────────
                Expanded(child: _buildBody()),

                // ── Stats row ─────────────────────────────────
                if (_activeTabIndex == 0) _buildStatsRow(context, t),
              ],
            ),
          ),
        );
      },
    );
  }

  // ── AppBar ────────────────────────────────────────────────

  PreferredSizeWidget _buildAppBar(
    BuildContext context,
    LocaleProvider localeProvider,
    String Function(String) t,
  ) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final currentCode = localeProvider.locale.languageCode;
    final currentLang = LocaleProvider.supportedLanguages.firstWhere(
      (l) => l['code'] == currentCode,
      orElse: () => LocaleProvider.supportedLanguages.first,
    );

    return AppBar(
      backgroundColor: Colors.transparent,
      elevation: 0,
      title: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            t(AppStrings.appName),
            style: TextStyle(
              color: isDark ? Colors.white : Colors.black,
              fontWeight: FontWeight.bold,
            ),
          ),
          Text(
            t(AppStrings.doctorPortal),
            style: TextStyle(
              color: isDark ? Colors.grey.shade400 : Colors.grey,
              fontSize: 12,
            ),
          ),
        ],
      ),
      actions: [
        // Theme toggle
        Consumer<ThemeProvider>(
          builder: (context, themeProvider, _) => IconButton(
            onPressed: themeProvider.toggleTheme,
            icon: Icon(
              themeProvider.isDark
                  ? Icons.light_mode_outlined
                  : Icons.dark_mode_outlined,
              size: 20,
            ),
            tooltip: themeProvider.isDark
                ? t(AppStrings.lightMode)
                : t(AppStrings.darkMode),
          ),
        ),

        // Language picker
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 8),
          child: GestureDetector(
            onTap: () async {
              final selected = await showDialog<Locale>(
                context: context,
                builder: (_) => const LanguagePickerDialog(),
              );
              if (selected != null) localeProvider.setLocale(selected);
            },
            child: Container(
              padding:
                  const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                border:
                    Border.all(color: Colors.grey.withOpacity(0.3)),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(currentLang['flag']!,
                      style: const TextStyle(fontSize: 16)),
                  const SizedBox(width: 4),
                  Text(
                    currentCode.toUpperCase(),
                    style: const TextStyle(
                        fontSize: 12, color: Colors.grey),
                  ),
                  const Icon(Icons.arrow_drop_down,
                      size: 16, color: Colors.grey),
                ],
              ),
            ),
          ),
        ),
        const SizedBox(width: 4),

        // Logout
        Padding(
          padding: const EdgeInsets.only(right: 12),
          child: OutlinedButton.icon(
            onPressed: () {
              _pollTimer?.cancel();
              // Clear persisted session on logout
              SharedPreferences.getInstance().then((p) {
                p.remove('token');
                p.remove('role');
              });
              adminToken = null;
              Navigator.pushAndRemoveUntil(
                context,
                MaterialPageRoute(builder: (_) => const SignIn()),
                (route) => false,
              );
            },
            icon: const Icon(Icons.logout, size: 18),
            label: Text(t(AppStrings.logout)),
          ),
        ),
      ],
    );
  }

  // ── Tabs ──────────────────────────────────────────────────

  Widget _buildTabs(BuildContext context, String Function(String) t) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: [
          _tabItem(
            context: context,
            icon: Icons.access_time_rounded,
            title:
                '${t(AppStrings.pendingCases)}${_pendingCount > 0 ? ' ($_pendingCount)' : ''}',
            index: 0,
          ),
          const SizedBox(width: 8),
          _tabItem(
            context: context,
            icon: Icons.description_outlined,
            title: t(AppStrings.reviewedCases),
            index: 1,
          ),
          const SizedBox(width: 8),
          _tabItem(
            context: context,
            icon: Icons.calendar_today_outlined,
            title: t(AppStrings.schedule),
            index: 2,
          ),
        ],
      ),
    );
  }

  Widget _tabItem({
    required BuildContext context,
    required IconData icon,
    required String title,
    required int index,
  }) {
    final bool isActive = _activeTabIndex == index;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return GestureDetector(
      onTap: () => setState(() => _activeTabIndex = index),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 9),
        decoration: BoxDecoration(
          color: isActive
              ? (isDark ? Colors.white : Colors.black)
              : (isDark ? const Color(0xFF1E293B) : Colors.white),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isActive
                ? (isDark ? Colors.white : Colors.black)
                : (isDark
                    ? const Color(0xFF334155)
                    : Colors.grey.shade300),
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon,
                size: 14,
                color: isActive
                    ? (isDark ? Colors.black : Colors.white)
                    : (isDark ? Colors.white70 : Colors.black87)),
            const SizedBox(width: 6),
            Text(
              title,
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w500,
                color: isActive
                    ? (isDark ? Colors.black : Colors.white)
                    : (isDark ? Colors.white70 : Colors.black87),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBody() {
    if (_activeTabIndex == 0) {
      return PendingScreen(key: ValueKey(_pendingScreenKey));
    }
    if (_activeTabIndex == 1) return const FinishedScreen();
    return const ScheduleScreen();
  }

  // ── Stats row ──────────────────────────────────────────────

  Widget _buildStatsRow(BuildContext context, String Function(String) t) {
    if (_statsLoading) return const SizedBox(height: 8);
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
      child: Row(
        children: [
          Expanded(
            child: _statCard(
              context: context,
              label: t(AppStrings.pendingReviews),
              value: '$_pendingCount',
              sub: t(AppStrings.casesAwaiting),
              iconColor: Colors.orange,
              icon: Icons.pending_actions_rounded,
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: _statCard(
              context: context,
              label: t(AppStrings.reviewedToday),
              value: '$_reviewedToday',
              sub: t(AppStrings.casesCompleted),
              iconColor: Colors.green,
              icon: Icons.check_circle_outline_rounded,
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: _statCard(
              context: context,
              label: t(AppStrings.totalPatients),
              value: '$_totalPatients',
              sub: t(AppStrings.activePatients),
              iconColor: const Color(0xFF2563EB),
              icon: Icons.people_outline_rounded,
            ),
          ),
        ],
      ),
    );
  }

  Widget _statCard({
    required BuildContext context,
    required String label,
    required String value,
    required String sub,
    required Color iconColor,
    required IconData icon,
  }) {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: theme.cardColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: theme.dividerColor),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Flexible(
                child: Text(label,
                    style: const TextStyle(
                        fontSize: 11, color: Color(0xFF6B7280))),
              ),
              Icon(icon, size: 16, color: iconColor),
            ],
          ),
          const SizedBox(height: 4),
          Text(value,
              style: const TextStyle(
                  fontSize: 22, fontWeight: FontWeight.bold)),
          Text(sub,
              style: const TextStyle(
                  fontSize: 10, color: Color(0xFF9CA3AF))),
        ],
      ),
    );
  }
}
