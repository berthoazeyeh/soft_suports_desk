import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:soft_support_decktop/api/cubit/synchronisation_cubit.dart';
import 'package:soft_support_decktop/models/manuel_attendance.dart';
import 'package:soft_support_decktop/ui/components/custom_dialog.dart'; // Pour formater les dates

class UserItem extends StatefulWidget {
  final ManuelAttendance attendance;
  final bool isStudent;
  final void Function() onRefrech;

  const UserItem(
      {super.key,
      required this.attendance,
      this.isStudent = false,
      required this.onRefrech});

  @override
  State<UserItem> createState() => _UserItemState();
}

class _UserItemState extends State<UserItem> {
  bool isLoading = false;
  bool showModal = false;
  DateTime? selectedDateTime;
  bool showDatePicker = false;
  bool showTimePicker = false;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final attendance = widget.attendance;
    final isStudent = widget.isStudent;
    final synCubit = BlocProvider.of<SynchronisationCubit>(context);

    return Container(
      margin: const EdgeInsets.symmetric(vertical: 15, horizontal: 10),
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 5,
            offset: const Offset(1, 1),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // User Info Row
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  attendance.resPartner.displayName,
                  style: theme.textTheme.bodyLarge
                      ?.copyWith(fontWeight: FontWeight.bold),
                ),
              ),
              if (selectedDateTime == null)
                ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: theme.primaryColor,
                    padding:
                        const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(15),
                    ),
                  ),
                  onPressed: () {
                    showDialog(
                        context: context,
                        builder: (BuildContext context) {
                          return Dialog(
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(5)),
                              child: CustomDialog(
                                manuelAttendance: attendance,
                                onSuccess: () {
                                  Navigator.of(context).pop();
                                  widget.onRefrech();
                                  synCubit.synDataUpToServer();
                                },
                              ));
                        });
                  },
                  icon: isLoading
                      ? CircularProgressIndicator(
                          color: theme.colorScheme.secondary,
                        )
                      : Icon(
                          (attendance.attendanceRecord != null) &&
                                  (attendance.attendanceRecord?.checkOut ==
                                      null)
                              ? Icons.logout
                              : Icons.login,
                          size: 14,
                          color: theme.colorScheme.secondary,
                        ),
                  label: Text(
                    (attendance.attendanceRecord != null) &&
                            (attendance.attendanceRecord?.checkOut == null)
                        ? 'Checkout'
                        : 'Checkin',
                    style: TextStyle(color: theme.colorScheme.secondary),
                  ),
                ),
              if (selectedDateTime != null)
                IconButton(
                  onPressed: () => setState(() => selectedDateTime = null),
                  icon: const Icon(Icons.close, color: Colors.red),
                ),
            ],
          ),
          const SizedBox(height: 10),

          // Info Row
          Row(
            children: [
              Expanded(
                child: Text(
                  (attendance.attendanceRecord != null) &&
                          (attendance.attendanceRecord?.checkOut == null)
                      ? "Dernière activité: Entrée"
                      : (attendance.attendanceRecord?.checkOut != null)
                          ? "Dernière activité: Sortie"
                          : "Pas d'activité pour ${isStudent ? 'cet étudiant' : 'cet employé'}",
                  style: theme.textTheme.bodyMedium,
                ),
              ),
            ],
          ),
          const SizedBox(height: 5),

          // Last Action
          if (selectedDateTime == null)
            Text(
              'Dernière action : ${(attendance.attendanceRecord) != null ? formatDate(attendance.attendanceRecord?.checkOut ?? attendance.attendanceRecord!.checkIn) : "Aucune donnée"}',
              style: theme.textTheme.bodySmall
                  ?.copyWith(color: theme.colorScheme.primary),
            ),
          Center(
            child: Text(
              'RFID : ${attendance.resPartner.rfidNum} -  ${attendance.resPartner.rfidCode}',
              style: theme.textTheme.bodySmall
                  ?.copyWith(color: theme.colorScheme.primary),
            ),
          ),

          // Date and Time Pickers
        ],
      ),
    );
  }

  // Format Date Utility
  String formatDate(DateTime? date) {
    if (date == null) return "Aucune donnée";
    return DateFormat('dd/MM/yyyy HH:mm').format(date);
  }
}
