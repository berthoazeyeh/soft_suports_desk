import 'package:soft_support_decktop/models/attendances.dart';

class SynchronisationDataUiModel {
  final MyPosition? position;
  final double time;
  final bool isSynchronisedUp;
  final bool isSynchronisedDown;
  final bool isSyncing;
  final String bannerMessage;
  final DevisePosition? devisePosition;

  const SynchronisationDataUiModel({
    this.position,
    required this.time,
    required this.isSynchronisedUp,
    required this.isSynchronisedDown,
    required this.isSyncing,
    required this.bannerMessage,
    this.devisePosition,
  });

  factory SynchronisationDataUiModel.fromJson(Map<String, dynamic> json) {
    return SynchronisationDataUiModel(
      position: json['position'] != null
          ? MyPosition.fromJson(json['position'])
          : null,
      devisePosition: json['devisePosition'] != null
          ? DevisePosition.fromJson(json['devisePosition'])
          : null,
      time: (json['time'] as num).toDouble(),
      isSynchronisedUp: json['isSynchronisedUp'],
      isSynchronisedDown: json['isSynchronisedDown'],
      isSyncing: json['isSyncing'],
      bannerMessage: json['bannerMessage'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'position': position?.toJson(),
      'devisePosition': devisePosition?.toJson(),
      'time': time,
      'isSynchronisedUp': isSynchronisedUp,
      'isSynchronisedDown': isSynchronisedDown,
      'isSyncing': isSyncing,
      'bannerMessage': bannerMessage,
    };
  }

  SynchronisationDataUiModel copyWith({
    MyPosition? position,
    double? time,
    bool? isSynchronisedUp,
    bool? isSynchronisedDown,
    bool? isSyncing,
    String? bannerMessage,
    DevisePosition? devisePosition,
  }) {
    return SynchronisationDataUiModel(
      position: position ?? this.position,
      devisePosition: devisePosition ?? this.devisePosition,
      time: time ?? this.time,
      isSynchronisedUp: isSynchronisedUp ?? this.isSynchronisedUp,
      isSynchronisedDown: isSynchronisedDown ?? this.isSynchronisedDown,
      isSyncing: isSyncing ?? this.isSyncing,
      bannerMessage: bannerMessage ?? this.bannerMessage,
    );
  }
}

class DevisePosition {
  final String deviceId;
  final String positionName;

  DevisePosition({required this.deviceId, required this.positionName});

  factory DevisePosition.fromJson(Map<String, dynamic> json) {
    return DevisePosition(
      deviceId: json['deviceId'],
      positionName: json['positionName'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'deviceId': deviceId,
      'positionName': positionName,
    };
  }

  DevisePosition copyWith({
    String? deviceId,
    String? positionName,
  }) {
    return DevisePosition(
      deviceId: deviceId ?? this.deviceId,
      positionName: positionName ?? this.positionName,
    );
  }
}
