import 'package:flutter/material.dart';

import '../../theme/colors.dart';

class SettingsPanel extends StatelessWidget {
  final bool isVoiceEnabled;
  final bool isFrench;
  final ValueChanged<bool> onVoiceChanged;
  final ValueChanged<bool> onLanguageChanged;
  final void Function() onPressViewAttendance;
  final void Function() onPressLogin;
  const SettingsPanel({
    super.key,
    required this.isVoiceEnabled,
    required this.isFrench,
    required this.onVoiceChanged,
    required this.onLanguageChanged,
    required this.onPressViewAttendance,
    required this.onPressLogin,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: MediaQuery.of(context).size.width,
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(15),
        boxShadow: const [
          BoxShadow(
            color: AppColors.shadowColor,
            blurRadius: 10,
            spreadRadius: 2,
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const Text(
            'Parametre du lecteur',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: AppColors.darkGreen,
              fontSize: 16,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 10),
          Wrap(
            alignment: WrapAlignment.spaceEvenly,
            runSpacing: 15,
            children: [
              _buildSwitchRow(
                'Activer la voix de l\'IA',
                isVoiceEnabled,
                onVoiceChanged,
              ),
              _buildSwitchRow(
                'Langue (Français/Anglais) :',
                isFrench,
                onLanguageChanged,
              ),
            ],
          ),
          const SizedBox(height: 30),
          Wrap(
            alignment: WrapAlignment.spaceBetween,
            crossAxisAlignment: WrapCrossAlignment.center,
            runSpacing: 15,
            children: [
              Center(
                child: ElevatedButton(
                  onPressed: onPressLogin,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(100),
                    ),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 35,
                      vertical: 10,
                    ),
                  ),
                  child: const Text(
                    'Se connecter',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
              Center(
                child: ElevatedButton(
                  onPressed: onPressViewAttendance,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.black,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(100),
                    ),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 35,
                      vertical: 10,
                    ),
                  ),
                  child: const Text(
                    'Voir les Presences',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSwitchRow(
      String label, bool value, ValueChanged<bool> onChanged) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: AppColors.offWhite,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Wrap(
        alignment: WrapAlignment.spaceEvenly,
        crossAxisAlignment: WrapCrossAlignment.center,
        spacing: 10,
        runSpacing: 10,
        children: [
          Text(
            label,
            style: const TextStyle(
              color: Colors.black,
              fontSize: 16,
              fontWeight: FontWeight.w500,
            ),
          ),
          Switch(
            value: value,
            onChanged: onChanged,
          ),
        ],
      ),
    );
  }
}
