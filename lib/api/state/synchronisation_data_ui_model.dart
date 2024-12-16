class SynchronisationDataUiModel {
  final Position? position;
  final double time;
  final bool isSynchronisedUp;
  final bool isSynchronisedDown;
  final bool isSyncing;
  final String bannerMessage;

  const SynchronisationDataUiModel({
    this.position,
    required this.time,
    required this.isSynchronisedUp,
    required this.isSynchronisedDown,
    required this.isSyncing,
    required this.bannerMessage,
  });

  factory SynchronisationDataUiModel.fromJson(Map<String, dynamic> json) {
    return SynchronisationDataUiModel(
      position:
          json['position'] != null ? Position.fromJson(json['position']) : null,
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
      'time': time,
      'isSynchronisedUp': isSynchronisedUp,
      'isSynchronisedDown': isSynchronisedDown,
      'isSyncing': isSyncing,
      'bannerMessage': bannerMessage,
    };
  }

  SynchronisationDataUiModel copyWith({
    Position? position,
    double? time,
    bool? isSynchronisedUp,
    bool? isSynchronisedDown,
    bool? isSyncing,
    String? bannerMessage,
  }) {
    return SynchronisationDataUiModel(
      position: position ?? this.position,
      time: time ?? this.time,
      isSynchronisedUp: isSynchronisedUp ?? this.isSynchronisedUp,
      isSynchronisedDown: isSynchronisedDown ?? this.isSynchronisedDown,
      isSyncing: isSyncing ?? this.isSyncing,
      bannerMessage: bannerMessage ?? this.bannerMessage,
    );
  }
}

class Position {
  final String latitude;
  final String longitude;

  Position({required this.latitude, required this.longitude});

  factory Position.fromJson(Map<String, dynamic> json) {
    return Position(
      latitude: json['latitude'],
      longitude: json['longitude'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'latitude': latitude,
      'longitude': longitude,
    };
  }

  Position copyWith({
    String? latitude,
    String? longitude,
  }) {
    return Position(
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
    );
  }
}
