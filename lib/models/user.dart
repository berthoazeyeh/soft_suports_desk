class UserModel {
  final int id;
  final int partnerId;
  final String email;
  final String phone;
  final String role;
  final String name; // Peut être null

  UserModel({
    required this.id,
    required this.partnerId,
    required this.phone,
    required this.name,
    required this.role,
    required this.email,
  });

  // Méthode de conversion à partir d'un Map
  factory UserModel.fromJson(Map<String, dynamic> map) {
    return UserModel(
        id: map['id'] as int,
        email: map['email'],
        partnerId: map['partner_id'] as int? ?? 0, // Valeur par défaut si null
        name: map['name'] ?? '', // Valeur par défaut si null
        role: map['role'] ?? "", // Peut rester null
        phone: map['phone'] ?? '');
  }
  // Méthode de conversion à partir d'un Map
  factory UserModel.fromLocalJson(Map<String, dynamic> map) {
    return UserModel(
        id: map['id'] as int,
        email: map['email']?.toString() ?? '',
        partnerId: int.tryParse(map['partner_id'] ?? 0) ??
            0, // Valeur par défaut si null
        name: map['name']?.toString() ?? '', // Valeur par défaut si null
        role: map['role']?.toString() ?? "", // Peut rester null
        phone: map['phone']?.toString() ?? '');
  }

  // Convertir l'objet en Map
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'phone': phone,
      'email': email,
      'name': name,
      'role': role,
      'partner_id': partnerId,
    };
  }
}
