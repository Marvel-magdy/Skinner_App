import 'package:flutter/material.dart';

// --- دالة لعرض الـ Edit Dialog ---
void showEditDoctorDialog(BuildContext context) {
  // بنستخدم TextEditingControllers عشان نقدر نغير في البيانات
  // يفضل تخلي البيانات دي (الديفولت) بتيجي من الـ Schedule Screen
  final TextEditingController nameController =
      TextEditingController(text: "Dr John Doe");
  final TextEditingController emailController =
      TextEditingController(text: "name@example.com");
  final TextEditingController phoneController =
      TextEditingController(text: "+1 (555) 000-0000");
  final TextEditingController addressController =
      TextEditingController(text: "add");
  final TextEditingController feeController =
      TextEditingController(text: "150");

  showDialog(
    context: context,
    // عشان المستخدم ميقدرش يقفل الـ Dialog بالضغط برة الكارت
    barrierDismissible: false,
    builder: (context) {
      return Dialog(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20), // كارت بزوائد دائرية
        ),
        // عشان نشيل الـ padding الديفولت بتاع الـ Dialog
        insetPadding: const EdgeInsets.all(20),
        child: IntrinsicHeight( // بيخلي ارتفاع الـ Column يتظبط على قد محتواه
          child: Column(
            children: [
              // --- 1. الـ Header (الأيقونة، العنوان، زر الإغلاق) ---
              Padding(
                padding:
                    const EdgeInsets.only(top: 20, left: 20, right: 20, bottom: 10),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        Icon(Icons.edit_outlined,
                            size: 20, color: Colors.grey.shade600),
                        const SizedBox(width: 8),
                        const Text(
                          "Doctor Information",
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Colors.black,
                          ),
                        ),
                      ],
                    ),
                    GestureDetector(
                      onLongPress: () {
                        Navigator.pop(context); // قفل الـ Dialog
                      },
                      child: Container(
                        padding: const EdgeInsets.all(5),
                        decoration: BoxDecoration(
                          color: Colors.red.withOpacity(0.1),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(Icons.close,
                            size: 16, color: Colors.red),
                      ),
                    ),
                  ],
                ),
              ),
              const Divider(color: Color(0xFFF0F0F0), thickness: 1), // خط فاصل خفيف

              // --- 2. محتوى الـ Dialog (الحقول) ---
              Flexible( // بنستخدم Flexible عشان يسمح بالـ Scrolling لو الشاشة صغيرة
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildDialogField("Full Name", nameController,
                          hint: "Your Full Name"),
                      const SizedBox(height: 15),
                      _buildDialogField("Email", emailController,
                          hint: "Your Email Address",
                          keyboardType: TextInputType.emailAddress),
                      const SizedBox(height: 15),
                      _buildDialogField("Phone Number", phoneController,
                          hint: "+1 (555) 000-0000",
                          keyboardType: TextInputType.phone),
                      const SizedBox(height: 15),
                      _buildDialogField("Clinic address", addressController,
                          hint: "Address here"),
                      const SizedBox(height: 15),
                      _buildDialogField("Consultation Fee", feeController,
                          hint: "150",
                          keyboardType: TextInputType.number,
                          prefixIcon: Icons.money),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 10),

              // --- 3. الأزرار (Save & Cancel) ---
              Padding(
                padding:
                    const EdgeInsets.only(left: 20, right: 20, bottom: 20),
                child: Row(
                  children: [
                    // زرار "Save Changes" (الأزرق)
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () {
                          // هنا هتضيف اللوجيك بتاع حفظ التغييرات
                          Navigator.pop(context); // قفل الـ Dialog بعد الحفظ
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF2C67FF),
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          elevation: 0,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                        child: const Text(
                          "Save Changes",
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 15),
                    // زرار "Cancel" (الأبيض)
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () {
                          Navigator.pop(context); // قفل الـ Dialog
                        },
                        style: OutlinedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          side: BorderSide(color: Colors.grey.shade300),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                        child: Text(
                          "Cancel",
                          style: TextStyle(
                            color: Colors.grey.shade600,
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      );
    },
  );
}

// --- ويدجت مساعدة لتصميم حقل الإدخال ---
Widget _buildDialogField(String label, TextEditingController controller,
    {String hint = "",
    TextInputType keyboardType = TextInputType.text,
    IconData? prefixIcon}) {
  return Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Text(
        label,
        style: const TextStyle(
          fontSize: 12,
          color: Colors.grey,
          fontWeight: FontWeight.w500,
        ),
      ),
      const SizedBox(height: 6),
      TextField(
        controller: controller,
        keyboardType: keyboardType,
        decoration: InputDecoration(
          hintText: hint,
          prefixIcon: prefixIcon != null
              ? Icon(prefixIcon, size: 20, color: Colors.grey)
              : null,
          filled: true,
          fillColor: const Color(0xFFFBFBFB), // لون خلفية الحقل خفيف جداً زي الصورة
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: BorderSide.none, // بدون حدود
          ),
          contentPadding: const EdgeInsets.all(12),
          hintStyle: const TextStyle(color: Colors.grey),
        ),
      ),
    ],
  );
}