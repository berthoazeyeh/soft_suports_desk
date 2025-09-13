import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:soft_support_decktop/services/rfid_service.dart';

class BadgingDialog extends StatelessWidget {
  const BadgingDialog({
    super.key,
    required this.data,
    required this.rfid,
  });
  final GetUserByRfidCodeType data;
  final String rfid;
  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 400,
      child: Container(
        padding: const EdgeInsets.all(16.0),
        decoration: BoxDecoration(
          border: Border.all(
              color: data.success ? Colors.green : Colors.redAccent, width: 3),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(height: 15),
            if (data.success || data.data != null)
              Center(
                child: Container(
                  padding: const EdgeInsets.all(9),
                  decoration: BoxDecoration(
                      border: Border.all(color: Colors.grey, width: 1),
                      color: data.success ? Colors.green : Colors.redAccent),
                  child: CachedNetworkImage(
                    imageUrl: data.data?.avatar ?? '',
                    fit: BoxFit.fill,
                    width: 200,
                    height: 200,
                    placeholder: (context, url) => const Center(
                      child: CircularProgressIndicator.adaptive(
                        backgroundColor: Colors.white,
                      ), // Affiche un spinner pendant le chargement
                    ),
                    errorWidget: (context, error, stackTrace) {
                      return Image.asset(
                        'assets/images/avatar.png',
                        width: 130,
                        height: 130,
                      );
                    },
                  ),
                ),
              )
            else
              Center(
                child: Container(
                  padding: const EdgeInsets.all(9),
                  decoration: BoxDecoration(
                      border: Border.all(color: Colors.grey, width: 1)),
                  child: Image.asset(
                    'assets/images/oops.jpg',
                    width: 200,
                    height: 200,
                  ),
                ),
              ),
            const SizedBox(height: 15),
            if (data.success || data.data != null)
              Text(
                data.message,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                ),
              )
            else
              const Text(
                'Nous avons du mal à vous reconnaître, veuillez réessayer s\'il vous plaît.',
                textAlign: TextAlign.center,
                style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    letterSpacing: 1.01),
              ),
            const SizedBox(height: 10),
            Text(
              'RFID: $rfid',
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 10),
          ],
        ),
      ),
    );
  }
}
