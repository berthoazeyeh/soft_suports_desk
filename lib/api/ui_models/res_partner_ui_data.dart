import 'package:soft_support_decktop/models/res_partner.dart';

class ResPartnerUiData {
  final bool success;
  final List<ResPartner> resPartners;

  ResPartnerUiData({required this.success, required this.resPartners});

  // Méthode pour convertir une carte (map) en objet ResPartner
  factory ResPartnerUiData.fromJson(Map<String, dynamic> json) {
    return ResPartnerUiData(
      success: json['success'],
      resPartners: (json['data'] as List? ?? [])
          .map((item) => ResPartner.fromJson(item))
          .toList(),
    );
  }

  // Méthode pour convertir l'objet ResPartner en une carte (map)
  Map<String, dynamic> toJson() {
    return {
      'success': success,
      'resPartners': resPartners,
    };
  }
}
