import 'package:flutter/material.dart';

import 'package:skinner/authuntication/signin.dart';
import 'package:skinner/screens/chat_list_screen.dart';
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
  int _pendingCount   = 0;
  int _reviewedToday  = 0;
  int _totalPatients  = 0;
  bool _statsLoading  = true;

  @override
  void initState() {
    super.initState();
    _loadStats();
  }

  Future<void> _loadStats() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('token') ?? '';

      final pending  = await AuthService().getPendingCases(token: token);
      final reviewed = await AuthService().getReviewedCases(token: token);

      final pendingList  = pending.data['data']  as List? ?? [];
      final reviewedList = reviewed.data['data'] as List? ?? [];

      // "reviewed today" = cases where reviewed_at starts with today's date
      final today = DateTime.now().toIso8601String().substring(0, 10);
      final todayCount = reviewedList
          .where((c) =>
              (c['reviewed_at'] ?? '').toString().startsWith(today))
          .length;

      // "total patients" — unique patient names as a proxy
      final allNames = {
        ...pendingList.map((c)  => c['patient_name'] ?? ''),
        ...reviewedList.map((c) => c['patient_name'] ?? ''),
      };

      if (mounted) {
        setState(() {
          _pendingCount  = pendingList.length;
          _reviewedToday = todayCount;
          _totalPatients = allNames.length;
          _statsLoading  = false;
        });
      }
    } catch (_) {
      if (mounted) setState(() => _statsLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF6F7FB),
      appBar: _buildAppBar(context),
      floatingActionButton: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // ── AI Chatbot FAB ────────────────────────────────
          FloatingActionButton(
            heroTag: 'chatbot',
            backgroundColor: const Color(0xFF2C67FF),
            tooltip: 'AI Chatbot',
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const ChatBotScreen()),
            ),
            child: const Icon(Icons.smart_toy_outlined, color: Colors.white),
          ),
          const SizedBox(height: 12),
          // ── Patient Chats FAB ─────────────────────────────
          FloatingActionButton(
            heroTag: 'patientChat',
            backgroundColor: Colors.white,
            foregroundColor: const Color(0xFF2C67FF),
            elevation: 3,
            tooltip: 'Patient Chats',
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const ChatListScreen()),
            ),
            child: const Icon(Icons.chat_bubble_outline_rounded),
          ),
        ],
      ),
      body: Column(
        children: [
          const SizedBox(height: 12),

          // ── Tab bar ───────────────────────────────────────────
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: _buildTabs(),
          ),

          const SizedBox(height: 12),

          // ── Content ───────────────────────────────────────────
          Expanded(child: _buildBody()),

          // ── Stats row (visible on Home/Pending tab) ───────────
          if (_activeTabIndex == 0) _buildStatsRow(),
        ],
      ),
    );
  }

  PreferredSizeWidget _buildAppBar(BuildContext context) {
    return AppBar(
      backgroundColor: Colors.transparent,
      elevation: 0,
      title: const Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Skinner',
              style: TextStyle(
                  color: Colors.black, fontWeight: FontWeight.bold)),
          Text('Doctor Portal',
              style: TextStyle(color: Colors.grey, fontSize: 12)),
        ],
      ),
      actions: [
        Padding(
          padding: const EdgeInsets.only(right: 12),
          child: OutlinedButton.icon(
            onPressed: () => Navigator.pushAndRemoveUntil(
              context,
              MaterialPageRoute(builder: (_) => const SignIn()),
              (route) => false,
            ),
            icon: const Icon(Icons.logout, size: 18),
            label: const Text('Logout'),
          ),
        ),
      ],
    );
  }

  Widget _buildTabs() {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: [
          _tabItem(
            icon: Icons.access_time_rounded,
            title: 'Pending Cases${_pendingCount > 0 ? ' ($_pendingCount)' : ''}',
            index: 0,
          ),
          const SizedBox(width: 8),
          _tabItem(
            icon: Icons.description_outlined,
            title: 'Reviewed Cases',
            index: 1,
          ),
          const SizedBox(width: 8),
          _tabItem(
            icon: Icons.calendar_today_outlined,
            title: 'Schedule',
            index: 2,
          ),
        ],
      ),
    );
  }

  Widget _tabItem({
    required IconData icon,
    required String title,
    required int index,
  }) {
    final bool isActive = _activeTabIndex == index;
    return GestureDetector(
      onTap: () => setState(() => _activeTabIndex = index),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 9),
        decoration: BoxDecoration(
          color: isActive ? Colors.black : Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isActive ? Colors.black : Colors.grey.shade300,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon,
                size: 14,
                color: isActive ? Colors.white : Colors.black87),
            const SizedBox(width: 6),
            Text(
              title,
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w500,
                color: isActive ? Colors.white : Colors.black87,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBody() {
    if (_activeTabIndex == 0) return const PendingScreen();
    if (_activeTabIndex == 1) return const FinishedScreen();
    return const ScheduleScreen();
  }

  Widget _buildStatsRow() {
    if (_statsLoading) return const SizedBox(height: 8);
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
      child: Row(
        children: [
          Expanded(
            child: _statCard(
              label: 'Pending Reviews',
              value: '$_pendingCount',
              sub: 'Cases awaiting review',
              iconColor: Colors.orange,
              icon: Icons.pending_actions_rounded,
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: _statCard(
              label: 'Reviewed Today',
              value: '$_reviewedToday',
              sub: 'Cases completed',
              iconColor: Colors.green,
              icon: Icons.check_circle_outline_rounded,
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: _statCard(
              label: 'Total Patients',
              value: '$_totalPatients',
              sub: 'Active patients',
              iconColor: const Color(0xFF2563EB),
              icon: Icons.people_outline_rounded,
            ),
          ),
        ],
      ),
    );
  }

  Widget _statCard({
    required String label,
    required String value,
    required String sub,
    required Color iconColor,
    required IconData icon,
  }) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFE5E7EB)),
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