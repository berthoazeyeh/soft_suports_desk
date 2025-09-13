class TimeUiData {
  final bool success;
  final TimingBadgingUI time;

  TimeUiData({required this.success, required this.time});

  factory TimeUiData.fromJson(Map<String, dynamic> json) {
    return TimeUiData(
      success: json['success'],
      time: (TimingBadgingUI.fromJson(json['data'])),
    );
  }

  // Méthode pour convertir l'objet ResPartner en une carte (map)
  Map<String, dynamic> toJson() {
    return {
      'success': success,
      'time': time,
    };
  }
}

class TimingBadgingUI {
  final double timingBadging;

  TimingBadgingUI({required this.timingBadging});

  factory TimingBadgingUI.fromJson(Map<String, dynamic> json) {
    return TimingBadgingUI(
      timingBadging: double.tryParse(json['timing_badging']) ?? 0,
    );
  }

  // Méthode pour convertir l'objet ResPartner en une carte (map)
  Map<String, dynamic> toJson() {
    return {
      'timing_badging': timingBadging,
    };
  }
}

class LoginResponse {
  final bool success;
  final String? message;
  final Map<String, dynamic>? data;

  LoginResponse({
    required this.success,
    this.message,
    this.data,
  });

  factory LoginResponse.fromJson(Map<String, dynamic> json) {
    return LoginResponse(
      success: json['success'],
      message: json['message'],
      data: json['data'],
    );
  }
}
