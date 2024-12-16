import 'dart:developer';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:soft_support_decktop/api/api_client.dart';
import 'package:soft_support_decktop/api/cubit/synchronisation_cubit.dart';
import 'package:soft_support_decktop/api/state/synchronisation_data_ui_model.dart';
import 'package:soft_support_decktop/services/database_service.dart';
import 'package:soft_support_decktop/ui/components/settings_panel.dart';
import 'package:soft_support_decktop/ui/screens/login_screen.dart';
import '../../services/rfid_service.dart';
import '../../services/tts_service.dart';
import '../components/animated_logo.dart';
import '../components/my_banner_widget.dart';
import '../components/rfid_dialog.dart';
import 'records_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key, required this.title});

  final String title;

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  bool _isVoiceEnabled = true;
  bool _isFrench = true;
  bool isManualInputVisible = false;
  final TTSService _ttsService = TTSService();
  final RFIDService _rfidService = RFIDService();

  @override
  void initState() {
    super.initState();
    BlocProvider.of<SynchronisationCubit>(context).getTimes();

    _initializeDatabase();
  }

  Future<void> _initializeDatabase() async {
    try {
      await DatabaseService.instance.database;
      final data = await APIClient().getAllPartner();
      final data1 = await APIClient().getLastAttendences();
      final data2 = await APIClient().getTimes();

      if (kDebugMode) {
        print("bonjour a tous");
        print(data.success);
        print(data.resPartners.length);
        print(data2);
        print(data1);
      }

      _ttsService.speakGreeting(_isFrench);
    } catch (e) {
      if (kDebugMode) {
        print('Error initializing database: $e');
      }
    }
  }

  Future<void> getTimes() async {
    try {
      await DatabaseService.instance.database;

      final data = await APIClient().getTimes();

      if (data['success']) {}
    } catch (e) {
      if (kDebugMode) {
        print('Error initializing database: $e');
      }
    }
  }

  Future<void> handleRfidInput(String rfidCode) async {
    try {
      // Fetch user data from the database
      final user = await _rfidService.getUserData(rfidCode);
      if (kDebugMode) {
        print("Get the data of the user");
      }

      if (user != null) {
        // Save the record in the database
        if (kDebugMode) {
          print("The user is found");
        }

        // Display user details in the dialog
        if (mounted) {
          _showRfidDialog(user.name, user.imageUrl);
        }
      } else {
        // Handle unknown user
        if (mounted) {
          _showRfidDialog('Utilisateur inconnu', null);
        }
      }
    } catch (e) {
      // Handle errors
      if (mounted) {
        _showRfidDialog('Erreur: $e', null);
      }
    }
  }

  void _showRfidDialog(String name, String? imageUrl) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return RFIDDialog(name: name, imageUrl: imageUrl);
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final authCubit = BlocProvider.of<SynchronisationCubit>(context);

    return Scaffold(
      body: SingleChildScrollView(
        child: BlocBuilder<SynchronisationCubit, SynchronisationDataUiModel>(
            builder: (context, synData) {
          final timing = synData.time;
          final int minutes = (timing).floor();
          final seconds = ((timing - minutes) * 60).round();
          return Column(
            children: [
              if (synData.isSyncing)
                Container(
                    margin: const EdgeInsets.all(10),
                    child: MyBannerWidget(title: synData.bannerMessage)),
              Container(
                padding: const EdgeInsets.symmetric(vertical: 15),
                margin: const EdgeInsets.symmetric(
                    horizontal: 10), // Optionnel pour ajouter un peu de marge
                decoration: BoxDecoration(
                  color: const Color(0xFF00233b), // Couleur de fond de la carte
                  borderRadius:
                      BorderRadius.circular(8), // Ajout d'un léger arrondi
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      blurRadius: 2,
                      offset:
                          const Offset(0, 2), // Pour donner une ombre subtile
                    ),
                  ],
                ),
                child: const Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Text(
                      'Bienvenue sur le Terminal de pointage de Soft Education', // Remplacez par votre traduction
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color:
                            Colors.white, // Similaire à `theme.secondaryText`
                      ),
                      textAlign: TextAlign.center,
                    ),
                    SizedBox(height: 15), // Espacement entre les éléments
                    Padding(
                      padding: EdgeInsets.only(right: 8.0),
                      child: Text(
                        'Power by Africa Systems',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color:
                              Colors.white, // Similaire à `theme.secondaryText`
                        ),
                        textAlign: TextAlign.right,
                      ),
                    ),
                  ],
                ),
              ),
              TimeDisplay(
                minutes: minutes,
                seconds: seconds,
                nfcTimeMessage:
                    "Le temps d'attente pour un employé entre deux badges est de:",
              ),
              Container(
                  height: 230,
                  padding: const EdgeInsets.symmetric(vertical: 10),
                  child: const ListeningIndicator()),
              const Text(
                'Passez votre carte sur le lecteur externe.',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w200,
                  color: Colors.black, // Similaire à `theme.secondaryText`
                ),
                textAlign: TextAlign.center,
              ),
              Container(
                decoration: const BoxDecoration(),
                child: Padding(
                  padding: const EdgeInsets.all(24.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      const SizedBox(height: 0),
                      SettingsPanel(
                        isVoiceEnabled: _isVoiceEnabled,
                        isFrench: _isFrench,
                        onVoiceChanged: (value) {
                          setState(() => _isVoiceEnabled = value);
                        },
                        onLanguageChanged: (value) {
                          setState(() => _isFrench = value);
                        },
                        onPressViewAttendance: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => const RecordsScreen()),
                          ).then((_) {
                            log(";;;;;;");
                          });
                        },
                        onPressLogin: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => const LoginScreen()),
                          ).then((_) {
                            log(";;;;;;");
                          });
                        },
                      ),
                      // if (isManualInputVisible) ...[
                      //   const SizedBox(height: 30),
                      //   ManualInput(
                      //     onRfidInput: handleRfidInput,
                      //   ),
                      // ],
                    ],
                  ),
                ),
              )
            ],
          );
        }),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          authCubit.setIsSyncing(!isManualInputVisible);
          authCubit.setBannerMessage('Synchronisation des données en cours');
          setState(() => isManualInputVisible = !isManualInputVisible);
        },
        backgroundColor: Colors.blue,
        child: const Icon(Icons.add),
      ),
    );
  }
}

class TimeDisplay extends StatelessWidget {
  final String nfcTimeMessage; // Équivalent de `I18n.t("nfctime")`
  final int minutes;
  final int seconds;

  const TimeDisplay({
    super.key,
    required this.nfcTimeMessage,
    required this.minutes,
    required this.seconds,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Text.rich(
        TextSpan(
          children: [
            TextSpan(
              text: nfcTimeMessage,
              style: const TextStyle(
                fontStyle: FontStyle.italic,
                fontSize: 18,
              ),
            ),
            if (minutes > 0)
              TextSpan(
                text: " $minutes minute(s)",
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                ),
              ),
            if (minutes <= 0)
              TextSpan(
                text: " $seconds seconde(s)",
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                ),
              ),
          ],
        ),
        textAlign: TextAlign.center,
      ),
    );
  }
}
