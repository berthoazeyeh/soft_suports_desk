class UserModel {
  final int id;
  final String rfidCode;
  final String rfidNum;
  final String name;
  final String? image; // Peut être null
  final DateTime timestamp;

  UserModel({
    required this.id,
    required this.rfidCode,
    required this.rfidNum,
    required this.name,
    this.image,
    required this.timestamp,
  });

  // Méthode de conversion à partir d'un Map
  factory UserModel.fromJson(Map<String, dynamic> map) {
    return UserModel(
      id: map['id'] as int,
      rfidNum: map['rfidcode'],
      rfidCode: map['rfidcode'] ?? '', // Valeur par défaut si null
      name: map['name'] ?? '', // Valeur par défaut si null
      image: map['image'], // Peut rester null
      timestamp: map['timestamp'] != null
          ? DateTime.parse(map['timestamp'])
          : DateTime.now(), // Valeur par défaut si null
    );
  }

  // Convertir l'objet en Map
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'rfidcode': rfidCode,
      'rfid_num': rfidCode,
      'name': name,
      'image': image,
      'timestamp': timestamp.toIso8601String(),
    };
  }
}
