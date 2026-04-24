import 'package:flutter/material.dart';
import 'package:skinner/authuntication/signin.dart'; // تأكدي من صحة المسار
import 'package:skinner/screens/chat_screens.dart';  // تأكدي من صحة المسار

class DoctorPortalScreen extends StatefulWidget {
  const DoctorPortalScreen({super.key});

  @override
  State<DoctorPortalScreen> createState() => _DoctorPortalScreenState();
}

class _DoctorPortalScreenState extends State<DoctorPortalScreen> {
  // متغير للتحكم في التابة النشطة (0: Pending, 1: Finished, 2: Schedule)
  int _activeTabIndex = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF6F7FB),
      appBar: _buildAppBar(context),
      floatingActionButton: FloatingActionButton(
        backgroundColor: const Color(0xFF2C67FF),
        child: const Icon(Icons.smart_toy, color: Colors.white),
        onPressed: () {
          Navigator.push(context, MaterialPageRoute(builder: (_) => const ChatScreen()));
        },
      ),
      body: LayoutBuilder(
        builder: (context, constraints) {
          double width = constraints.maxWidth;
          bool isSmall = width < 360;

          return Column(
            children: [
              const SizedBox(height: 10),
              // --- Tabs Section ---
              _buildTabsSection(isSmall),
              
              const SizedBox(height: 12),

              // --- Dynamic Content Section ---
              Expanded(
                child: _activeTabIndex == 1 
                    ? _buildFinishedSection(isSmall) // الجزء الجديد
                    : _activeTabIndex == 0 
                        ? _buildPendingSection(isSmall, width) // الجزء القديم
                        : const Center(child: Text("Schedule Section")), // تابة الجدول
              ),
            ],
          );
        },
      ),
    );
  }

  // --- 1. الـ AppBar مع زرار الـ Logout ---
  PreferredSizeWidget _buildAppBar(BuildContext context) {
    return AppBar(
      backgroundColor: Colors.transparent,
      elevation: 0,
      title: const Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text("Skinner", style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
          Text("Doctor Portal", style: TextStyle(color: Colors.grey, fontSize: 12)),
        ],
      ),
      actions: [
        Padding(
          padding: const EdgeInsets.only(right: 12),
          child: OutlinedButton.icon(
            onPressed: () {
              Navigator.pushAndRemoveUntil(
                context,
                MaterialPageRoute(builder: (_) => const SignIn()),
                (route) => false,
              );
            },
            icon: const Icon(Icons.logout, size: 18),
            label: const Text("Logout"),
          ),
        )
      ],
    );
  }

  // --- 2. جزء التابات ---
  Widget _buildTabsSection(bool isSmall) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: isSmall ? 12 : 16),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: [
            _tabItem("Pending Cases (2)", 0),
            const SizedBox(width: 8),
            _tabItem("Finished Cases", 1),
            const SizedBox(width: 8),
            _tabItem("Schedule", 2),
          ],
        ),
      ),
    );
  }

  Widget _tabItem(String title, int index) {
    bool isActive = _activeTabIndex == index;
    return GestureDetector(
      onTap: () => setState(() => _activeTabIndex = index),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        decoration: BoxDecoration(
          color: isActive ? Colors.black : Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: Colors.grey.shade300),
        ),
        child: Text(
          title,
          style: TextStyle(
            color: isActive ? Colors.white : Colors.black,
            fontWeight: FontWeight.w500,
          ),
        ),
      ),
    );
  }

  // --- 3. جزء الـ Finished Cases (التصميم الجديد) ---
  Widget _buildFinishedSection(bool isSmall) {
    return ListView.builder(
      padding: EdgeInsets.all(isSmall ? 12 : 16),
      itemCount: 4,
      itemBuilder: (context, index) {
        return Container(
          margin: const EdgeInsets.only(bottom: 12),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: const Color(0xFFE9ECEF), width: 1),
          ),
          child: Row(
            children: [
              Container(
                height: 80, width: 80,
                decoration: BoxDecoration(
                  color: const Color(0xFFEBE3D5),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(Icons.medical_services_outlined, color: Colors.brown, size: 30),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Mike R.', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                    const Text('Contact Dermatitis', style: TextStyle(color: Colors.grey, fontSize: 14)),
                    const SizedBox(height: 10),
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                          decoration: BoxDecoration(color: const Color(0xFFD1FAE5), borderRadius: BorderRadius.circular(6)),
                          child: const Text('Reviewed', style: TextStyle(color: Color(0xFF059669), fontSize: 12, fontWeight: FontWeight.bold)),
                        ),
                        const SizedBox(width: 8),
                        Text('12/17/2024', style: TextStyle(color: Colors.grey[600], fontSize: 12)),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  // --- 4. جزء الـ Pending Cases (كودك الأصلي) ---
  Widget _buildPendingSection(bool isSmall, double width) {
    return ListView.builder(
      padding: EdgeInsets.all(isSmall ? 12 : 16),
      itemCount: 2,
      itemBuilder: (context, index) {
        return Padding(
          padding: const EdgeInsets.only(bottom: 16),
          child: Container(
            padding: EdgeInsets.all(isSmall ? 12 : 16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(18),
              boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 8)],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(14),
                  child: Image.asset(
                    "assets/Container.png",
                    height: isSmall ? width * 0.45 : width * 0.35,
                    width: double.infinity,
                    fit: BoxFit.cover,
                  ),
                ),
                const SizedBox(height: 10),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text("John D. • 34 yrs • Male", style: TextStyle(fontWeight: FontWeight.w600)),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(color: Colors.orange[100], borderRadius: BorderRadius.circular(12)),
                      child: const Text("pending"),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.black,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                    ),
                    onPressed: () {},
                    child: const Text("Review Case", style: TextStyle(color: Colors.white)),
                  ),
                )
              ],
            ),
          ),
        );
      },
    );
  }
}