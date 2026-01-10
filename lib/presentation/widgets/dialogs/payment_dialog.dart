import 'package:flutter/material.dart';
import 'package:padel_punilla/domain/enums/reservation_enums.dart';
import 'package:padel_punilla/domain/models/reservation_model.dart';

class PaymentDialog extends StatefulWidget {
  final ReservationModel reservation;
  final Function(double, PaymentStatus) onUpdate;

  const PaymentDialog({
    super.key,
    required this.reservation,
    required this.onUpdate,
  });

  @override
  State<PaymentDialog> createState() => _PaymentDialogState();
}

class _PaymentDialogState extends State<PaymentDialog> {
  late double _paidAmount;
  late PaymentStatus _paymentStatus;
  final TextEditingController _amountController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _paidAmount = widget.reservation.paidAmount;
    _paymentStatus = widget.reservation.paymentStatus;
    _amountController.text = _paidAmount.toStringAsFixed(2);
  }

  @override
  void dispose() {
    _amountController.dispose();
    super.dispose();
  }

  void _updateAmount(String value) {
    final amount = double.tryParse(value);
    if (amount != null) {
      setState(() {
        _paidAmount = amount;
        // Auto-update status suggestion
        if (_paidAmount >= widget.reservation.price) {
          _paymentStatus = PaymentStatus.paid;
        } else if (_paidAmount > 0) {
          _paymentStatus = PaymentStatus.partial;
        } else {
          _paymentStatus = PaymentStatus.pending;
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Gestionar Pago'),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Precio Total: \$${widget.reservation.price.toStringAsFixed(2)}',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 8),
            Text(
              'Restante: \$${(widget.reservation.price - _paidAmount).toStringAsFixed(2)}',
              style: TextStyle(
                color:
                    (widget.reservation.price - _paidAmount) > 0
                        ? Colors.red
                        : Colors.green,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _amountController,
              keyboardType: const TextInputType.numberWithOptions(
                decimal: true,
              ),
              decoration: const InputDecoration(
                labelText: 'Monto Abonado',
                prefixText: '\$ ',
                border: OutlineInputBorder(),
              ),
              onChanged: _updateAmount,
            ),
            const SizedBox(height: 16),
            DropdownButtonFormField<PaymentStatus>(
              value: _paymentStatus,
              decoration: const InputDecoration(
                labelText: 'Estado del Pago',
                border: OutlineInputBorder(),
              ),
              items:
                  PaymentStatus.values.map((status) {
                    return DropdownMenuItem(
                      value: status,
                      child: Text(status.displayName),
                    );
                  }).toList(),
              onChanged: (value) {
                if (value != null) {
                  setState(() => _paymentStatus = value);
                }
              },
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancelar'),
        ),
        FilledButton(
          onPressed: () {
            final amount =
                double.tryParse(_amountController.text) ?? _paidAmount;
            widget.onUpdate(amount, _paymentStatus);
            Navigator.of(context).pop();
          },
          child: const Text('Guardar'),
        ),
      ],
    );
  }
}
