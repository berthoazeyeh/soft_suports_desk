class ResPartner {
  final int id;
  final String displayName;
  final String rfidCode;
  final String rfidNum;
  final String personType;
  final String avatar;

  ResPartner({
    required this.id,
    required this.displayName,
    required this.rfidCode,
    required this.rfidNum,
    required this.personType,
    required this.avatar,
  });

  // Méthode pour convertir une carte (map) en objet ResPartner
  factory ResPartner.fromJson(Map<String, dynamic> json) {
    return ResPartner(
      id: json['id'],
      displayName: json['display_name'] ?? '',
      rfidCode: json['rfid_code'] ?? '',
      rfidNum: json['rfid_num'] ?? '', // S'assure que rfid_num peut être vide
      personType: json['person_type'] ?? '',
      avatar: json['avatar'] ?? '',
    );
  }

  // Méthode pour convertir l'objet ResPartner en une carte (map)
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'display_name': displayName,
      'rfid_code': rfidCode,
      'rfid_num': rfidNum,
      'person_type': personType,
      'avatar': avatar,
    };
  }
}
