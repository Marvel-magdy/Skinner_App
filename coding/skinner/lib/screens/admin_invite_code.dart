import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:dio/dio.dart';
import 'package:skinner/services/auth_service.dart';

class InviteCodesScreen extends StatefulWidget {
  const InviteCodesScreen({super.key});

  @override
  State<InviteCodesScreen> createState() => _InviteCodesScreenState();
}

class _InviteCodesScreenState extends State<InviteCodesScreen> {
  bool isLoading = false;
  bool hasActiveCode = false;
  bool showGreenBanner = false; // متحكم ظهور البانر الأخضر
Timer? activeCodeTimer;
  String inviteCode = "";
  String expiresAt = "";

  // عداد تنازلي تفاعلي حي
  Timer? countdownTimer;
  String remainingTimeText = "";

  @override
void initState() {
  super.initState();

  getActiveInviteCode();

  activeCodeTimer = Timer.periodic(
    const Duration(seconds: 5),
    (_) {
      getActiveInviteCode();
    },
  );
}

  // جلب الكود النشط الحالي
  Future<void> getActiveInviteCode() async {
    try {
      Response response = await AuthService().getActiveInviteCode(
        token: adminToken!,
      );

      if (response.data["data"] != null) {
        setState(() {
          hasActiveCode = true;
          inviteCode = response.data["data"]["invite_code"];
          expiresAt = response.data["data"]["expires_at"];
          showGreenBanner = true; 
        });
        _startCountdownTimer();
      } else {

  countdownTimer?.cancel();

  setState(() {

    hasActiveCode = false;

    inviteCode = "";

    expiresAt = "";

    remainingTimeText = "";

    showGreenBanner = false;

  });
  Future.delayed(
  const Duration(seconds: 1),
  () {

    if (mounted) {

      setState(() {

if (!showGreenBanner) {
  showGreenBanner = true;

  Future.delayed(
    const Duration(seconds: 5),
    () {
      if (mounted) {
        setState(() {
          showGreenBanner = false;
        });
      }
    },
  );
}
      });

    }

  },
);

      }
    } catch (e) {
      print(e);
    }
  }

  // توليد كود جديد
  Future<void> generateCode() async {
    try {
      setState(() {
        isLoading = true;
        showGreenBanner = false; // إخفاء البانر الأخضر فوراً عند توليد كود جديد
      });

      // استدعاء السيرفر لإنشاء الكود
      await AuthService().generateAdminCode(
        token: adminToken!,
      );

      // جلب الكود الجديد من السيرفر
      Response response = await AuthService().getActiveInviteCode(
        token: adminToken!,
      );

      if (response.data["data"] != null) {
        setState(() {
          hasActiveCode = true;
          inviteCode = response.data["data"]["invite_code"];
          expiresAt = response.data["data"]["expires_at"];
          // يظل showGreenBanner رمزه false حتى لا يظهر البانر الأخضر مع الكود المولد حديثاً
        });
        _startCountdownTimer();
      }

      setState(() {
        isLoading = false;
      });
    } catch (e) {
      print(e);
      setState(() {
        isLoading = false;
      });
    }
  }

  // تشغيل العداد التنازلي الحي
  void _startCountdownTimer() {
    countdownTimer?.cancel();
    if (expiresAt.isEmpty) return;

    try {
      DateTime expiresDateTime = DateTime.parse(expiresAt).toLocal();
      countdownTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
        final now = DateTime.now();
        if (now.isAfter(expiresDateTime)) {
          timer.cancel();
          setState(() {
            remainingTimeText = "Expired";
          });
        } else {
          final difference = expiresDateTime.difference(now);
          final minutes = difference.inMinutes;
          final seconds = difference.inSeconds % 60;
          setState(() {
           remainingTimeText =
    "${minutes}m ${seconds}s";
          });
        }
      });
    } catch (e) {
      print(e);
    }
  }

  @override
  Widget build(BuildContext context) {
  return SingleChildScrollView(   
    //   body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(24),
            border: Border.all(
              color: const Color(0xFFEFF1F9),
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // الهيدر والأيقونة
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: const BoxDecoration(
                      color: Color(0xFFF1F0FF),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.vpn_key_outlined,
                      color: Color(0xFF6366F1),
                      size: 28,
                    ),
                  ),
                  const SizedBox(width: 16),
                  const Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "Generate Admin Invite Code",
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF1E293B),
                          ),
                        ),
                        SizedBox(height: 8),
                        Text(
                          "Generate a one-time invite code that can be used to register a new admin account. Each code can only be used once.",
                          style: TextStyle(
                            fontSize: 13,
                            color: Color(0xFF64748B),
                            height: 1.4,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 24),

              // زر التوليد
              SizedBox(
                width: double.infinity,
                height: 52,
                child: ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF1E293B),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    elevation: 0,
                  ),
                  onPressed: isLoading ? null : generateCode,
                  icon: isLoading
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                        )
                      : const Icon(Icons.grid_view_rounded, color: Colors.white),
                  label: Text(
                    isLoading ? "Generating..." : "Generate New Code",
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 15,
                    ),
                  ),
                ),
              ),

              // البانر الأخضر (يظهر فقط عند showGreenBanner = true)
              if (hasActiveCode && showGreenBanner) ...[
                const SizedBox(height: 20),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                  decoration: BoxDecoration(
                    color: const Color(0xFFE6F4EA),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: const Color(0xFFD1FAE5),
                    ),
                  ),
                  child: const Row(
                    children: [
                      Icon(
                        Icons.check_circle_outline,
                        color: Color(0xFF065F46),
                        size: 20,
                      ),
                      SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          "Active admin invite code retrieved successfully",
                          style: TextStyle(
                            color: Color(0xFF065F46),
                            fontWeight: FontWeight.w600,
                            fontSize: 13,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],

              // كارد الكود والعداد التنازلي
              if (hasActiveCode) ...[
                const SizedBox(height: 20),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: const Color(0xFFFAF9FF),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: const Color(0xFFEEF2F6),
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            "Generated\nInvite Code",
                            style: TextStyle(
                              color: Color(0xFF6366F1),
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                              height: 1.2,
                            ),
                          ),
                          Row(
                            children: [
                              const Icon(
                                Icons.access_time,
                                size: 14,
                                color: Colors.orange,
                              ),
                              const SizedBox(width: 4),
                              Text(
                                remainingTimeText,
                                style: const TextStyle(
                                  color: Colors.orange,
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),

                      // صندوق الكود وزر النسخ
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: const Color(0xFFEEF2F6),
                          ),
                        ),
                        child: Row(
                          children: [
                            Expanded(
                              child: Text(
                                inviteCode,
                                style: const TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                  letterSpacing: 1.5,
                                  color: Color(0xFF1E293B),
                                ),
                              ),
                            ),
                            ElevatedButton.icon(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xFFF1F5F9),
                                elevation: 0,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                              ),
                              onPressed: () {
                                Clipboard.setData(ClipboardData(text: inviteCode));
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text("Invite code copied to clipboard!"),
                                    duration: Duration(seconds: 2),
                                  ),
                                );
                              },
                              icon: const Icon(Icons.copy, size: 14, color: Color(0xFF64748B)),
                              label: const Text(
                                "Copy",
                                style: TextStyle(
                                  color: Color(0xFF64748B),
                                  fontSize: 13,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 16),

                      const Text(
                        "Share this code with the new admin. It can only be used once for a single registration.",
                        style: TextStyle(
                          color: Color(0xFF818CF8),
                          fontSize: 12,
                          height: 1.4,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ],
          
        
      
          ),
          ),
          );
  }

  @override
void dispose() {

  countdownTimer?.cancel();

  activeCodeTimer?.cancel();

  super.dispose();

  }
}
