
import 'package:flutter/material.dart';
import '../services/payment_service.dart';

class PaymentConfirmationSender extends StatefulWidget {
  const PaymentConfirmationSender({
    super.key,
    required this.transactionId,
    required this.amount,
    this.appointmentId,
    this.onSuccess,
    this.onError,
    this.apiKey,
  });

  final String transactionId;
  final double amount;
  final String? appointmentId;
  final void Function(dynamic response)? onSuccess;
  final void Function(dynamic error)? onError;
  final String? apiKey;

  @override
  State<PaymentConfirmationSender> createState() => _PaymentConfirmationSenderState();
}

class _PaymentConfirmationSenderState extends State<PaymentConfirmationSender> {
  bool _loading = false;
  String? _statusMessage;

  final _service = PaymentService();

  @override
  void initState() {
    super.initState();
    _sendConfirmation();
  }

  Future<void> _sendConfirmation() async {
    setState(() {
      _loading = true;
      _statusMessage = null;
    });

    final result = await _service.sendPaymentConfirmation(
      transactionId: widget.transactionId,
      amount: widget.amount,
      appointmentId: widget.appointmentId,
      apiKey: widget.apiKey,
    );

    setState(() {
      _loading = false;
      if (result.ok) {
        _statusMessage = 'Payment confirmed';
      } else {
        _statusMessage = 'Confirmation failed';
      }
    });

    if (result.ok) {
      widget.onSuccess?.call(result.data);
    } else {
      widget.onError?.call(result.error);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (!_loading && _statusMessage == null) {
      // briefly before first request completes
      return const SizedBox.shrink();
    }

    return Padding(
      padding: const EdgeInsets.only(top: 12),
      child: Row(
        children: [
          if (_loading) const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2)),
          if (!_loading && _statusMessage != null)
            Icon(
              _statusMessage == 'Payment confirmed' ? Icons.check_circle : Icons.error_outline,
              color: _statusMessage == 'Payment confirmed' ? Colors.green : Colors.red,
            ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              _loading ? 'Confirming payment...' : (_statusMessage ?? ''),
              style: const TextStyle(fontSize: 14),
            ),
          ),
        ],
      ),
    );
  }
}
