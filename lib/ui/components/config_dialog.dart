import 'package:flutter/material.dart';
import 'package:soft_support_decktop/ui/screens/login_screen.dart';

class ConfigDialog extends StatelessWidget {
  const ConfigDialog({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 400,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Wrap(
              alignment: WrapAlignment.center,
              crossAxisAlignment: WrapCrossAlignment.center,
              children: [
                Text(
                  'Aucune configuration trouvée',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            Center(
              child: Image.asset(
                'assets/images/alert.png',
                width: 130,
                height: 130,
              ),
            ),
            const Text(
              'Veuillez configurer votre équipement pour continuer. Cette configuration nécessite une authentification.',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w300,
              ),
            ),
            const SizedBox(height: 30),
            const Divider(
              color: Colors.grey,
            ),
            const SizedBox(height: 7),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green[900],
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(100),
                ),
                padding: const EdgeInsets.symmetric(
                  horizontal: 35,
                  vertical: 15,
                ),
              ),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => const LoginScreen(
                            isForDevicePosition: true,
                          )),
                ).then((_) {
                  if (context.mounted) Navigator.pop(context);
                });
              },
              child: const Text(
                'Continuer',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
