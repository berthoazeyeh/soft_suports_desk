import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_datetime_picker_plus/flutter_datetime_picker_plus.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:intl/intl.dart';
import 'package:soft_support_decktop/api/cubit/synchronisation_cubit.dart';
import 'package:soft_support_decktop/api/cubit/user_cubit.dart';
import 'package:soft_support_decktop/api/state/synchronisation_data_ui_model.dart';
import 'package:soft_support_decktop/models/manuel_attendance.dart';
import 'package:soft_support_decktop/services/rfid_service.dart';

class CustomDialog extends StatefulWidget {
  final ManuelAttendance manuelAttendance;
  final void Function() onSuccess;

  const CustomDialog({
    super.key,
    required this.manuelAttendance,
    required this.onSuccess,
  });

  @override
  State<CustomDialog> createState() => _CustomDialogState();
}

class _CustomDialogState extends State<CustomDialog> {
  bool isLoading = false;

  @override
  void initState() {
    super.initState();
  }

  final RFIDService _rfidService = RFIDService();

  Future<void> handlePressConfirm(
      {required int makeAttendanceId,
      required DateTime selectedDate,
      required SynchronisationDataUiModel synCubit}) async {
    try {
      final handleCreateRes = await _rfidService.handleCreateAttendanceCorrect(
        idUser: widget.manuelAttendance.resPartner.id,
        userName: widget.manuelAttendance.resPartner.displayName,
        rfidCode: widget.manuelAttendance.resPartner.rfidCode,
        makeAttendanceId: null,
        timing: 0, // Temps de badgé en minutes
        checkTime: selectedDate,
        coords: synCubit.position,
      );

      if (handleCreateRes.success) {
        widget.onSuccess();
        EasyLoading.showSuccess("Operation reussi: ${handleCreateRes.message}");
      } else {
        EasyLoading.showError("Echec d'operation: ${handleCreateRes.message}");
      }
    } catch (e) {
      if (kDebugMode) {
        print(e);
      }
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  DateTime? selectedDateTime;
  @override
  Widget build(BuildContext context) {
    String formattedTime =
        DateFormat('HH:mm:ss').format(selectedDateTime ?? DateTime.now());
    String formattedDate = DateFormat('EEEE, d MMMM yyyy', 'fr_FR')
        .format(selectedDateTime ?? DateTime.now());
    final authUser = BlocProvider.of<AuthCubit>(context).getSignedInUser;
    final synCubit = BlocProvider.of<SynchronisationCubit>(context).state;

    return SizedBox(
      width: 400,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          mainAxisSize: MainAxisSize.min,
          children: [
            Align(
              alignment: Alignment.topRight,
              child: GestureDetector(
                onTap: () => Navigator.of(context).pop(),
                child: CircleAvatar(
                  radius: 12,
                  backgroundColor: Theme.of(context).primaryColor,
                  child: const Icon(Icons.close, color: Colors.white, size: 20),
                ),
              ),
            ),
            const SizedBox(height: 10),
            Text(
              'Veuillez confirmer la date',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 18,
                color: Theme.of(context).primaryColor,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 20),
            Center(
              child: CircleAvatar(
                radius: 40,
                backgroundImage: NetworkImage(
                  widget.manuelAttendance.resPartner.avatar,
                ),
                onBackgroundImageError: (exception, stackTrace) {},
              ),
            ),
            const SizedBox(height: 10),
            Text(
              widget.manuelAttendance.resPartner.displayName,
              style: TextStyle(
                fontSize: 18,
                color: Theme.of(context).primaryColorDark,
              ),
              textAlign: TextAlign.center,
            ),
            const Divider(
              color: Colors.grey,
            ),
            const SizedBox(height: 10),
            Column(
              children: [
                Text(
                  formattedTime,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.blue,
                  ),
                ),
                Text(
                  formattedDate,
                  style: TextStyle(
                    fontSize: 16,
                    color: Theme.of(context).primaryColorDark,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 15),
            Center(
              child: Text.rich(
                TextSpan(
                  text: 'Action : ',
                  style: const TextStyle(
                      fontWeight: FontWeight.bold, fontSize: 16),
                  children: [
                    TextSpan(
                      text: (widget.manuelAttendance.attendanceRecord != null &&
                              widget.manuelAttendance.attendanceRecord
                                      ?.checkOut !=
                                  null)
                          ? 'checkout'
                          : 'checkin',
                      style: const TextStyle(fontWeight: FontWeight.normal),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 20),
            Wrap(
              alignment: WrapAlignment.spaceEvenly,
              children: [
                ElevatedButton.icon(
                  onPressed: () {
                    DatePicker.showDateTimePicker(context,
                        currentTime: selectedDateTime ?? DateTime.now(),
                        onConfirm: (date) {
                      setState(() {
                        selectedDateTime = date;
                      });
                    });
                  },
                  icon: const Icon(Icons.calendar_today, size: 14),
                  label: const Text('Modifier'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Theme.of(context).primaryColor,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 15,
                    ),
                  ),
                ),
                ElevatedButton.icon(
                  onPressed: () async {
                    handlePressConfirm(
                        makeAttendanceId: authUser?.id ?? 0,
                        selectedDate: selectedDateTime ?? DateTime.now(),
                        synCubit: synCubit);
                  },
                  icon: isLoading
                      ? const SizedBox(
                          width: 14,
                          height: 14,
                          child: CircularProgressIndicator(
                            color: Colors.white,
                            strokeWidth: 2,
                          ),
                        )
                      : const Icon(Icons.check_circle_outline, size: 14),
                  label: const Text('Confirmer'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 15,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
