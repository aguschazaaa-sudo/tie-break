import 'package:flutter/material.dart';
import 'package:padel_punilla/domain/enums/reservation_enums.dart';
import 'package:padel_punilla/domain/models/court_model.dart';

class BlockCourtDialog extends StatefulWidget {
  final DateTime initialDate;
  final String? initialCourtId;
  final Function(
    String courtId,
    DateTime date,
    int duration,
    ReservationType type,
    String? description,
  )
  onBlock;
  final List<CourtModel> courts;

  const BlockCourtDialog({
    super.key,
    required this.initialDate,
    required this.onBlock,
    required this.courts,
    this.initialCourtId,
  });

  @override
  State<BlockCourtDialog> createState() => _BlockCourtDialogState();
}

class _BlockCourtDialogState extends State<BlockCourtDialog> {
  late DateTime _selectedDate;
  late TimeOfDay _selectedTime;
  String? _selectedCourtId;
  int _durationMinutes = 60;
  ReservationType _type = ReservationType.maintenance;
  final TextEditingController _descriptionController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _selectedDate = widget.initialDate;
    _selectedTime = TimeOfDay.fromDateTime(widget.initialDate);
    _selectedCourtId =
        widget.initialCourtId ??
        (widget.courts.isNotEmpty ? widget.courts.first.id : null);
  }

  @override
  void dispose() {
    _descriptionController.dispose();
    super.dispose();
  }

  Future<void> _selectDate(BuildContext context) async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime.now().subtract(const Duration(days: 365)),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );
    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
      });
    }
  }

  Future<void> _selectTime(BuildContext context) async {
    final picked = await showTimePicker(
      context: context,
      initialTime: _selectedTime,
    );
    if (picked != null && picked != _selectedTime) {
      setState(() {
        _selectedTime = picked;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (widget.courts.isEmpty) {
      return const AlertDialog(
        content: Text('No hay canchas disponibles para bloquear.'),
      );
    }

    return AlertDialog(
      title: const Text('Bloquear Cancha'),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Selección de Cancha
            DropdownButtonFormField<String>(
              value: _selectedCourtId,
              decoration: const InputDecoration(
                labelText: 'Cancha',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.sports_tennis),
              ),
              items:
                  widget.courts.map((court) {
                    return DropdownMenuItem(
                      value: court.id,
                      child: Text(court.name),
                    );
                  }).toList(),
              onChanged: (value) => setState(() => _selectedCourtId = value),
            ),
            const SizedBox(height: 16),

            // Selección de Fecha y Hora
            Row(
              children: [
                Expanded(
                  child: InkWell(
                    onTap: () => _selectDate(context),
                    child: InputDecorator(
                      decoration: const InputDecoration(
                        labelText: 'Fecha',
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(Icons.calendar_today),
                      ),
                      child: Text(
                        '${_selectedDate.day}/${_selectedDate.month}/${_selectedDate.year}',
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: InkWell(
                    onTap: () => _selectTime(context),
                    child: InputDecorator(
                      decoration: const InputDecoration(
                        labelText: 'Hora',
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(Icons.access_time),
                      ),
                      child: Text(_selectedTime.format(context)),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Duración
            DropdownButtonFormField<int>(
              value: _durationMinutes,
              decoration: const InputDecoration(
                labelText: 'Duración',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.timer),
              ),
              items:
                  [30, 60, 90, 120, 180, 240, 480].map((minutes) {
                    final label =
                        minutes >= 60
                            ? '${minutes ~/ 60} h ${minutes % 60 > 0 ? '${minutes % 60} m' : ''}'
                            : '$minutes min';
                    return DropdownMenuItem(value: minutes, child: Text(label));
                  }).toList(),
              onChanged: (value) {
                if (value != null) setState(() => _durationMinutes = value);
              },
            ),
            const SizedBox(height: 16),

            // Tipo de Bloqueo
            DropdownButtonFormField<ReservationType>(
              value: _type,
              decoration: const InputDecoration(
                labelText: 'Tipo de Bloqueo',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.category),
              ),
              items: const [
                DropdownMenuItem(
                  value: ReservationType.maintenance,
                  child: Text('Mantenimiento'),
                ),
                DropdownMenuItem(
                  value: ReservationType.coaching,
                  child: Text('Clase / Entrenamiento'),
                ),
              ],
              onChanged: (value) {
                if (value != null) setState(() => _type = value);
              },
            ),
            const SizedBox(height: 16),

            // Descripción
            TextField(
              controller: _descriptionController,
              decoration: const InputDecoration(
                labelText: 'Descripción / Nota (Opcional)',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.notes),
              ),
              maxLines: 2,
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
            if (_selectedCourtId == null) return;

            final dateTime = DateTime(
              _selectedDate.year,
              _selectedDate.month,
              _selectedDate.day,
              _selectedTime.hour,
              _selectedTime.minute,
            );

            widget.onBlock(
              _selectedCourtId!,
              dateTime,
              _durationMinutes,
              _type,
              _descriptionController.text,
            );
            Navigator.of(context).pop();
          },
          child: const Text('Bloquear'),
        ),
      ],
    );
  }
}
