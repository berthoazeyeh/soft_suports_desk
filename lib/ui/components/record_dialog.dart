import 'package:flutter/material.dart';
import 'package:flutter_datetime_picker_plus/flutter_datetime_picker_plus.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:intl/intl.dart';

class RecordDialog extends StatefulWidget {
  final Function(DateTimeRange? selectedDate) onConfirm;

  const RecordDialog({
    super.key,
    required this.onConfirm,
  });

  @override
  State<RecordDialog> createState() => _RecordDialogState();
}

class _RecordDialogState extends State<RecordDialog> {
  DateTime? selectedStartDate;
  DateTime? selectedEndDate;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 350,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Header
            Wrap(
              alignment: WrapAlignment.spaceBetween,
              children: [
                const Text(
                  'Sélectionner la période',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                GestureDetector(
                  onTap: () => Navigator.pop(context),
                  child: CircleAvatar(
                    radius: 10,
                    backgroundColor: Theme.of(context).primaryColor,
                    child: const Icon(
                      Icons.close,
                      color: Colors.white,
                      size: 16,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),

            // Date de début
            ListTile(
              leading: const Icon(Icons.calendar_today_outlined),
              title: Text(
                selectedStartDate != null
                    ? 'Début: ${DateFormat('dd MMM yyyy HH:mm:ss').format(selectedStartDate!)}'
                    : 'Sélectionner une date de début',
              ),
              onTap: () {
                DatePicker.showDateTimePicker(context,
                    showTitleActions: true,
                    minTime: DateTime(2018, 3, 5),
                    maxTime: DateTime.now(), onChanged: (date) {
                  setState(() {
                    selectedStartDate = date;
                  });
                }, onConfirm: (date) {
                  setState(() {
                    selectedStartDate = date;
                  });
                }, currentTime: DateTime.now(), locale: LocaleType.fr);
              },
            ),
            const SizedBox(height: 10),

            const Divider(),
            const SizedBox(height: 10),

            // Date de fin
            ListTile(
              leading: const Icon(Icons.calendar_today_outlined),
              title: Text(
                selectedEndDate != null
                    ? 'Fin: ${DateFormat('dd MMM yyyy HH:mm:ss').format(selectedEndDate!)}'
                    : 'Sélectionner une date de fin',
              ),
              onTap: () {
                DatePicker.showDateTimePicker(context,
                    showTitleActions: true,
                    minTime: DateTime(2018, 3, 5),
                    maxTime: DateTime.now(), onChanged: (date) {
                  setState(() {
                    selectedEndDate = date;
                  });
                }, onConfirm: (date) {
                  setState(() {
                    selectedEndDate = date;
                  });
                }, currentTime: DateTime.now(), locale: LocaleType.fr);
              },
            ),
            const SizedBox(height: 10),

            const Divider(),
            const SizedBox(height: 20),

            // Bouton confirmer
            ElevatedButton(
              onPressed: () {
                if (selectedStartDate == null || selectedEndDate == null) {
                  EasyLoading.showError(
                      'Veuillez sélectionner les dates de début et de fin');
                  return;
                }

                widget.onConfirm(DateTimeRange(
                    end: selectedEndDate!, start: selectedStartDate!));
                Navigator.pop(context);
              },
              child: const Text('Confirmer'),
            ),
          ],
        ),
      ),
    );
  }
}
