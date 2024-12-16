import 'dart:developer';

import 'package:hydrated_bloc/hydrated_bloc.dart';

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
  void setIsSynchronisedUp(bool value) =>
      emit(state.copyWith(isSynchronisedUp: value));
  void setPosition(Position value) => emit(state.copyWith(position: value));
  Future<void> getTimes() async {
    try {
      final data = await APIClient().getTimes();
      emit(state.copyWith(time: 10));

      if (data['success']) {
        log(data);
      }
    } catch (e) {}
  }

  @override
  Map<String, dynamic>? toJson(SynchronisationDataUiModel state) =>
      state.toJson();
}
