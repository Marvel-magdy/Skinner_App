import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:skinner/screens/otp_verification_screen.dart';

// ── Card-type detection ───────────────────────────────────────────────────────
enum _CardType { unknown, visa, mastercard, amex }

_CardType _detectCardType(String digits) {
  if (digits.startsWith('4')) return _CardType.visa;
  final n = int.tryParse(digits.length >= 2 ? digits.substring(0, 2) : '') ?? 0;
  if (n >= 51 && n <= 55) return _CardType.mastercard;
  final n6 = int.tryParse(digits.length >= 6 ? digits.substring(0, 6) : '') ?? 0;
  if (n6 >= 222100 && n6 <= 272099) return _CardType.mastercard;
  if (digits.startsWith('34') || digits.startsWith('37')) return _CardType.amex;
  return _CardType.unknown;
}

// ── Luhn algorithm ────────────────────────────────────────────────────────────
bool _luhn(String digits) {
  if (digits.length < 13) return false;
  int sum = 0;
  bool alternate = false;
  for (int i = digits.length - 1; i >= 0; i--) {
    int n = int.parse(digits[i]);
    if (alternate) {
      n *= 2;
      if (n > 9) n -= 9;
    }
    sum += n;
    alternate = !alternate;
  }
  return sum % 10 == 0;
}

// ── Card number formatter (groups of 4, except Amex: 4-6-5) ──────────────────
class _CardNumberFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
      TextEditingValue oldValue, TextEditingValue newValue) {
    final digits = newValue.text.replaceAll(RegExp(r'\D'), '');
    final isAmex = digits.startsWith('34') || digits.startsWith('37');
    final maxLen = isAmex ? 15 : 16;
    final capped = digits.length > maxLen ? digits.substring(0, maxLen) : digits;

    final buffer = StringBuffer();
    if (isAmex) {
      // 4-6-5
      for (int i = 0; i < capped.length; i++) {
        if (i == 4 || i == 10) buffer.write(' ');
        buffer.write(capped[i]);
      }
    } else {
      // 4-4-4-4
      for (int i = 0; i < capped.length; i++) {
        if (i > 0 && i % 4 == 0) buffer.write(' ');
        buffer.write(capped[i]);
      }
    }

    final formatted = buffer.toString();
    return TextEditingValue(
      text: formatted,
      selection: TextSelection.collapsed(offset: formatted.length),
    );
  }
}

// ── Expiry formatter MM/YY ────────────────────────────────────────────────────
class _ExpiryFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
      TextEditingValue oldValue, TextEditingValue newValue) {
    final digits = newValue.text.replaceAll(RegExp(r'\D'), '');
    final capped = digits.length > 4 ? digits.substring(0, 4) : digits;

    String formatted = capped;
    if (capped.length >= 3) {
      formatted = '${capped.substring(0, 2)}/${capped.substring(2)}';
    } else if (capped.length == 2 && oldValue.text.length == 1) {
      formatted = '$capped/';
    }

    return TextEditingValue(
      text: formatted,
      selection: TextSelection.collapsed(offset: formatted.length),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────

class PaymentScreen extends StatefulWidget {
  final String appointmentId;
  final String doctorName;
  final double consultationFee;
  final String appointmentDate;

  const PaymentScreen({
    super.key,
    required this.appointmentId,
    required this.doctorName,
    required this.consultationFee,
    required this.appointmentDate,
  });

  @override
  State<PaymentScreen> createState() => _PaymentScreenState();
}

class _PaymentScreenState extends State<PaymentScreen> {
  final _formKey = GlobalKey<FormState>();

  final _cardNumberCtrl  = TextEditingController();
  final _cardHolderCtrl  = TextEditingController();
  final _expiryCtrl      = TextEditingController();
  final _cvvCtrl         = TextEditingController();

  bool _saveCard     = false;
  bool _cvvObscured  = true;
  _CardType _cardType = _CardType.unknown;

  @override
  void initState() {
    super.initState();
    _cardNumberCtrl.addListener(() {
      final digits = _cardNumberCtrl.text.replaceAll(' ', '');
      final detected = _detectCardType(digits);
      if (detected != _cardType) setState(() => _cardType = detected);
    });
  }

  @override
  void dispose() {
    _cardNumberCtrl.dispose();
    _cardHolderCtrl.dispose();
    _expiryCtrl.dispose();
    _cvvCtrl.dispose();
    super.dispose();
  }

  // ── Validators ──────────────────────────────────────────────────────────────

  String? _validateCardNumber(String? value) {
    final digits = (value ?? '').replaceAll(' ', '');
    if (digits.isEmpty) return 'Card number is required';
    if (!RegExp(r'^\d+$').hasMatch(digits)) return 'Numbers only';

    final type = _detectCardType(digits);
    final expectedLen = (type == _CardType.amex) ? 15 : 16;
    if (digits.length != expectedLen) {
      return 'Must be $expectedLen digits';
    }
    if (!_luhn(digits)) return 'Invalid card number';
    if (type == _CardType.unknown) return 'Unsupported card type (Visa / Mastercard / Amex)';
    return null;
  }

  String? _validateCardHolder(String? value) {
    final v = (value ?? '').trim();
    if (v.isEmpty) return 'Cardholder name is required';
    if (v.length < 2) return 'Name too short';
    if (!RegExp(r"^[a-zA-Z\s\-']+$").hasMatch(v)) return 'Letters only';
    if (!v.contains(' ')) return 'Enter first and last name';
    return null;
  }

  String? _validateExpiry(String? value) {
    final v = (value ?? '').trim();
    if (v.isEmpty) return 'Expiry date is required';
    if (!RegExp(r'^\d{2}/\d{2}$').hasMatch(v)) return 'Use MM/YY format';

    final parts = v.split('/');
    final month = int.parse(parts[0]);
    final year  = int.parse('20${parts[1]}');

    if (month < 1 || month > 12) return 'Invalid month (01–12)';

    final now   = DateTime.now();
    final expiry = DateTime(year, month + 1);
    if (expiry.isBefore(DateTime(now.year, now.month))) {
      return 'Card has expired';
    }
    return null;
  }

  String? _validateCvv(String? value) {
    final v = (value ?? '').trim();
    if (v.isEmpty) return 'CVV is required';
    final expectedLen = (_cardType == _CardType.amex) ? 4 : 3;
    if (!RegExp(r'^\d+$').hasMatch(v)) return 'Numbers only';
    if (v.length != expectedLen) return '$expectedLen digits required';
    return null;
  }

  // ── Submit ──────────────────────────────────────────────────────────────────

  void _onConfirm() {
    if (!_formKey.currentState!.validate()) return;

    final digits    = _cardNumberCtrl.text.replaceAll(' ', '');
    final cardLast4 = digits.substring(digits.length - 4);
    final cardHolder = _cardHolderCtrl.text.trim();

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => OtpVerificationScreen(
          appointmentId:   widget.appointmentId,
          doctorName:      widget.doctorName,
          consultationFee: widget.consultationFee,
          cardHolderName:  cardHolder,
          cardLast4:       cardLast4,
          appointmentDate: widget.appointmentDate,
        ),
      ),
    );
  }

  // ── Helpers ─────────────────────────────────────────────────────────────────

  Widget _cardTypeIcon() {
    switch (_cardType) {
      case _CardType.visa:
        return _CardBadge(label: 'VISA', color: const Color(0xFF1A1F71));
      case _CardType.mastercard:
        return _CardBadge(label: 'MC', color: const Color(0xFFEB001B),
            secondColor: const Color(0xFFF79E1B));
      case _CardType.amex:
        return _CardBadge(label: 'AMEX', color: const Color(0xFF007BC1));
      default:
        return const SizedBox.shrink();
    }
  }

  InputDecoration _fieldDecoration({
    required String hint,
    required Color fill,
    String? errorText,
    Widget? suffix,
    Widget? prefix,
  }) {
    return InputDecoration(
      hintText: hint,
      filled: true,
      fillColor: fill,
      errorText: errorText,
      suffixIcon: suffix,
      prefixIcon: prefix,
      contentPadding:
          const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none),
      enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Color(0xFFE5E7EB))),
      focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide:
              const BorderSide(color: Color(0xFF2C67FF), width: 1.5)),
      errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Colors.red, width: 1.5)),
      focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Colors.red, width: 1.5)),
    );
  }

  // ── Build ────────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    final theme      = Theme.of(context);
    final isDark     = theme.brightness == Brightness.dark;
    final cardColor  = theme.cardColor;
    final borderColor = theme.dividerColor;
    final fieldFill  = isDark ? const Color(0xFF334155) : const Color(0xFFF3F4F6);
    final labelColor = isDark ? const Color(0xFFE2E8F0) : Colors.black87;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Form(
            key: _formKey,
            child: Column(
              children: [
                // ── Back row ────────────────────────────────────
                Align(
                  alignment: Alignment.centerLeft,
                  child: Row(
                    children: [
                      IconButton(
                        onPressed: () => Navigator.pop(context),
                        icon: const Icon(Icons.arrow_back),
                      ),
                      const Text("Back to Appointment Selection",
                          style: TextStyle(fontSize: 15)),
                    ],
                  ),
                ),

                const SizedBox(height: 20),

                // ── Main card ────────────────────────────────────
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: cardColor,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: borderColor),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Header
                      const Row(
                        children: [
                          Icon(Icons.lock_outline, color: Colors.green),
                          SizedBox(width: 10),
                          Text("Secure Payment",
                              style: TextStyle(
                                  fontSize: 26,
                                  fontWeight: FontWeight.bold)),
                        ],
                      ),
                      const SizedBox(height: 8),
                      const Text(
                          "Your payment information is encrypted and secure",
                          style:
                              TextStyle(color: Colors.grey, fontSize: 14)),
                      const SizedBox(height: 20),

                      // PCI badge
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: isDark
                              ? const Color(0xFF052E16)
                              : const Color(0xFFF0FDF4),
                          borderRadius: BorderRadius.circular(12),
                          border:
                              Border.all(color: const Color(0xFF86EFAC)),
                        ),
                        child: const Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Icon(Icons.shield_outlined,
                                color: Colors.green, size: 20),
                            SizedBox(width: 10),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text("PCI DSS Compliant",
                                      style: TextStyle(
                                          color: Colors.green,
                                          fontWeight: FontWeight.bold,
                                          fontSize: 13)),
                                  SizedBox(height: 4),
                                  Text(
                                    "All transactions are encrypted using 256-bit SSL encryption. Your card details are never stored on our servers.",
                                    style: TextStyle(
                                        color: Colors.green,
                                        fontSize: 12),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 24),

                      // ── Card Number ──────────────────────────
                      Text("Card Number",
                          style: TextStyle(
                              fontWeight: FontWeight.w600,
                              color: labelColor)),
                      const SizedBox(height: 8),
                      TextFormField(
                        controller: _cardNumberCtrl,
                        keyboardType: TextInputType.number,
                        inputFormatters: [
                          FilteringTextInputFormatter.digitsOnly,
                          _CardNumberFormatter(),
                        ],
                        validator: _validateCardNumber,
                        decoration: _fieldDecoration(
                          hint: '1234 5678 9012 3456',
                          fill: fieldFill,
                          suffix: Padding(
                            padding: const EdgeInsets.all(8),
                            child: _cardTypeIcon(),
                          ),
                        ),
                      ),

                      const SizedBox(height: 18),

                      // ── Cardholder Name ──────────────────────
                      Text("Cardholder Name",
                          style: TextStyle(
                              fontWeight: FontWeight.w600,
                              color: labelColor)),
                      const SizedBox(height: 8),
                      TextFormField(
                        controller: _cardHolderCtrl,
                        keyboardType: TextInputType.name,
                        textCapitalization: TextCapitalization.characters,
                        validator: _validateCardHolder,
                        decoration: _fieldDecoration(
                          hint: 'JOHN DOE',
                          fill: fieldFill,
                        ),
                      ),

                      const SizedBox(height: 18),

                      // ── Expiry + CVV row ─────────────────────
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Expiry
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text("Expiry Date",
                                    style: TextStyle(
                                        fontWeight: FontWeight.w600,
                                        color: labelColor)),
                                const SizedBox(height: 8),
                                TextFormField(
                                  controller: _expiryCtrl,
                                  keyboardType: TextInputType.number,
                                  inputFormatters: [
                                    FilteringTextInputFormatter.allow(
                                        RegExp(r'[\d/]')),
                                    _ExpiryFormatter(),
                                  ],
                                  validator: _validateExpiry,
                                  decoration: _fieldDecoration(
                                    hint: 'MM/YY',
                                    fill: fieldFill,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 12),

                          // CVV
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Text("CVV",
                                        style: TextStyle(
                                            fontWeight: FontWeight.w600,
                                            color: labelColor)),
                                    const SizedBox(width: 4),
                                    Tooltip(
                                      message: _cardType == _CardType.amex
                                          ? '4-digit code on the front'
                                          : '3-digit code on the back',
                                      child: Icon(
                                          Icons.info_outline_rounded,
                                          size: 14,
                                          color: Colors.grey.shade400),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 8),
                                TextFormField(
                                  controller: _cvvCtrl,
                                  keyboardType: TextInputType.number,
                                  obscureText: _cvvObscured,
                                  inputFormatters: [
                                    FilteringTextInputFormatter.digitsOnly,
                                    LengthLimitingTextInputFormatter(
                                        _cardType == _CardType.amex ? 4 : 3),
                                  ],
                                  validator: _validateCvv,
                                  decoration: _fieldDecoration(
                                    hint: _cardType == _CardType.amex
                                        ? '1234'
                                        : '123',
                                    fill: fieldFill,
                                    suffix: IconButton(
                                      icon: Icon(
                                        _cvvObscured
                                            ? Icons.visibility_off_outlined
                                            : Icons.visibility_outlined,
                                        size: 18,
                                        color: Colors.grey,
                                      ),
                                      onPressed: () => setState(
                                          () => _cvvObscured = !_cvvObscured),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 20),

                      // ── Save card checkbox ───────────────────
                      CheckboxListTile(
                        value: _saveCard,
                        contentPadding: EdgeInsets.zero,
                        title: const Text(
                            "Securely save this card for future appointments",
                            style: TextStyle(fontSize: 13)),
                        onChanged: (v) =>
                            setState(() => _saveCard = v ?? false),
                      ),

                      const Divider(height: 35),

                      // ── Confirm button ───────────────────────
                      SizedBox(
                        width: double.infinity,
                        height: 55,
                        child: ElevatedButton.icon(
                          onPressed: _onConfirm,
                          icon: const Icon(Icons.lock,
                              color: Colors.white, size: 18),
                          label: Text(
                            "Confirm Payment — EGP ${widget.consultationFee.toStringAsFixed(0)}",
                            style: const TextStyle(
                                color: Colors.white,
                                fontSize: 15,
                                fontWeight: FontWeight.w600),
                          ),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF020617),
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12)),
                          ),
                        ),
                      ),

                      const SizedBox(height: 16),

                      const Center(
                        child: Text(
                          "By confirming this payment, you agree to our Terms of Service and Privacy Policy.",
                          textAlign: TextAlign.center,
                          style: TextStyle(
                              color: Colors.grey, fontSize: 12),
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 20),

                // ── We accept ────────────────────────────────────
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: cardColor,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: borderColor),
                  ),
                  child: Row(
                    children: [
                      Text("We accept:",
                          style: TextStyle(color: labelColor)),
                      const SizedBox(width: 12),
                      _CardBadge(
                          label: 'VISA',
                          color: const Color(0xFF1A1F71)),
                      const SizedBox(width: 8),
                      _CardBadge(
                          label: 'MC',
                          color: const Color(0xFFEB001B),
                          secondColor: const Color(0xFFF79E1B)),
                      const SizedBox(width: 8),
                      _CardBadge(
                          label: 'AMEX',
                          color: const Color(0xFF007BC1)),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// ── Card brand badge widget ───────────────────────────────────────────────────
class _CardBadge extends StatelessWidget {
  final String label;
  final Color color;
  final Color? secondColor;

  const _CardBadge({
    required this.label,
    required this.color,
    this.secondColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        gradient: secondColor != null
            ? LinearGradient(colors: [color, secondColor!])
            : null,
        color: secondColor == null ? color : null,
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(
        label,
        style: const TextStyle(
            color: Colors.white,
            fontSize: 11,
            fontWeight: FontWeight.bold,
            letterSpacing: 0.5),
      ),
    );
  }
}
