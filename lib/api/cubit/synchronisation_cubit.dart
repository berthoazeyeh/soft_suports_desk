import 'dart:developer';

import 'package:flutter/foundation.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:hydrated_bloc/hydrated_bloc.dart';
import 'package:intl/intl.dart';
import 'package:soft_support_decktop/models/attendances.dart';
import 'package:soft_support_decktop/services/rfid_service.dart';

import '../api_client.dart';
import '../state/synchronisation_data_ui_model.dart';

class SynchronisationCubit extends HydratedCubit<SynchronisationDataUiModel> {
  SynchronisationCubit()
      : super(
          const SynchronisationDataUiModel(
              time: 2,
              isSynchronisedUp: false,
              isSynchronisedDown: false,
              isSyncing: false,
              devisePosition: null,
              bannerMessage: 'Synchronisation des données en cours...'),
        );

  @override
  SynchronisationDataUiModel? fromJson(Map<String, dynamic> json) {
    return SynchronisationDataUiModel.fromJson(json);
  }

  void setBannerMessage(String value) =>
      emit(state.copyWith(bannerMessage: value));

  void setIsSyncing(bool value) => emit(state.copyWith(isSyncing: value));

  void setTime(double value) => emit(state.copyWith(time: value));

  void setIsSynchronisedDown(bool value) =>
      emit(state.copyWith(isSynchronisedDown: value));
  void setDevicePosition(DevisePosition? value) =>
      emit(state.copyWith(devisePosition: value));
  void setIsSynchronisedUp(bool value) =>
      emit(state.copyWith(isSynchronisedUp: value));
  void setPosition(MyPosition value) => emit(state.copyWith(position: value));
  Future<void> getAllOnLineData() async {
    emit(state.copyWith(isSyncing: true));
    await getAllPartner();
    await getTimes();
    await getLastAttendances();
    final data1 = await RFIDService().getAllLocalUserData();
    if (kDebugMode) {
      print(data1);
    }
    emit(state.copyWith(isSyncing: false));
  }

  Future<void> getTimes() async {
    emit(state.copyWith(
        bannerMessage: 'Recuperation du temps d\'attente entre deux badging '));
    try {
      final data = await APIClient().getTimes();
      if (data.success) {
        emit(state.copyWith(time: (data.time.timingBadging / 60)));
        EasyLoading.showSuccess(
            'Recuperation du temps d\'attente entre deux badging reussi');
      }
    } catch (e) {
      EasyLoading.showError('Failed with Error $e');
    }
  }

  Future<void> getAllPartner() async {
    emit(state.copyWith(
        bannerMessage: 'Synchronisation des employees et students en cours..'));

    try {
      final data = await APIClient().getAllPartner();
      if (data.success) {
        await RFIDService().syncAllPartners(data.resPartners);
        EasyLoading.showSuccess('Recuperation des employees reussi');
      }
    } catch (e) {
      EasyLoading.showError('Failed with Error $e');
    }
  }

  Future<void> getLastAttendances() async {
    emit(state.copyWith(
        bannerMessage: 'Synchronisation des derniere Attendances en cours..'));
    try {
      final unSynAttandance = await RFIDService().getUnSyncAttendance();
      log(unSynAttandance.data.toString());
      if (unSynAttandance.success && unSynAttandance.data.isNotEmpty) {
        insertMultipleRequests(unSynAttandance.data);
        return;
      }
      final data = await APIClient().getLastAttendences();
      if (data.success) {
        await RFIDService().upsertAttendance(data.attendances);
        EasyLoading.showSuccess('Recuperation des derniere Attendances reussi');
      }
    } catch (e) {
      EasyLoading.showError('Failed with Error $e');
    }
  }

  Future<void> synDataUpToServer() async {
    final unSynAttandance = await RFIDService().getUnSyncAttendance();
    if (unSynAttandance.success && unSynAttandance.data.isNotEmpty) {
      insertMultipleRequests(unSynAttandance.data);
      return;
    }
  }

  Future<void> insertMultipleRequests(List<AttendanceRecord> dataList) async {
    emit(
      state.copyWith(
        bannerMessage: 'Démarrage de l\'insertion sur le serveur',
        isSyncing: true,
      ),
    );

    int total = dataList.length;
    int completed = 0;

    for (int i = 0; i < total; i++) {
      Map<String, dynamic> dataSup = {
        'partner_id': dataList[i].partner.id,
      };

      dataSup['check_in'] =
          DateFormat("yyyy-MM-dd HH:mm:ss").format(dataList[i].checkIn);

      if (dataList[i].checkOut != null) {
        dataSup['check_out'] =
            DateFormat("yyyy-MM-dd HH:mm:ss").format(dataList[i].checkOut!);
      }
      if (dataList[i].makeAttendanceId != null) {
        dataSup['make_attendance_id'] = dataList[i].makeAttendanceId;
      }
      if (dataList[i].longitude != null) {
        dataSup['longitude'] = dataList[i].longitude;
      }
      if (dataList[i].latitude != null) {
        dataSup['latitude'] = dataList[i].latitude;
      }

      if (kDebugMode) {
        print("........dataSup: $dataSup");
      }

      try {
        // Appel de la fonction réseau pour insérer l'attendance
        final res = await APIClient().insertTime(dataSup); // À implémenter
        emit(
          state.copyWith(
            bannerMessage: 'Démarrage de l\'insertion sur le serveur',
            isSyncing: true,
          ),
        );
        if (res.success) {
          // Mise à jour locale
          final upRes = await RFIDService()
              .updateAttendanceLocal(dataList[i].id); // À implémenter
          if (kDebugMode) {
            print(upRes);
          }
          completed++;

          if (kDebugMode) {
            print("Insertion $completed/$total");
          }
          emit(
            state.copyWith(
              bannerMessage: "Progress Insertion $completed/$total",
              isSyncing: true,
            ),
          );

          if (completed == total) {
            emit(
              state.copyWith(
                bannerMessage: 'insertion sur le serveur reussi',
                isSyncing: false,
              ),
            );
            if (kDebugMode) {
              print("All requests inserted");
            }
          }
        } else {
          if (kDebugMode) {
            print("Échec d'insertion pour l'élément ${i + 1}: ${res.message}");
          }
          return;
        }
      } catch (error) {
        if (kDebugMode) {
          print("Error inserting request: $error");
        }

        EasyLoading.showError('Insertion failed at request ${i + 1}');

        emit(
          state.copyWith(
            isSyncing: false,
          ),
        );
        return;
      }
    }
  }

  @override
  Map<String, dynamic>? toJson(SynchronisationDataUiModel state) =>
      state.toJson();
}
