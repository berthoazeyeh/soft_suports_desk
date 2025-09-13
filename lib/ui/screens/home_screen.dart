import 'dart:developer';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:soft_support_decktop/api/cubit/synchronisation_cubit.dart';
import 'package:soft_support_decktop/api/state/synchronisation_data_ui_model.dart';
import 'package:soft_support_decktop/services/database_service.dart';
import 'package:soft_support_decktop/ui/components/badging_dialog.dart';
import 'package:soft_support_decktop/ui/components/config_dialog.dart';
import 'package:soft_support_decktop/ui/components/settings_panel.dart';
import 'package:soft_support_decktop/ui/screens/login_screen.dart';
import '../../services/rfid_service.dart';
import '../../services/tts_service.dart';
import '../components/animated_logo.dart';
import '../components/my_banner_widget.dart';
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
  final FocusNode _focusNode = FocusNode();
  final TextEditingController _controller = TextEditingController();
  @override
  void initState() {
    super.initState();

    BlocProvider.of<SynchronisationCubit>(context).getAllOnLineData();
    _initializeDatabase();
  }

  Future<void> _initializeDatabase() async {
    final synCubit = BlocProvider.of<SynchronisationCubit>(context).state;
    try {
      await DatabaseService.instance.database;
      if (mounted) {
        if (synCubit.devisePosition == null) {
          if (mounted) {
            showDialog(
              context: context,
              builder: (BuildContext context) {
                return Dialog(
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(5)),
                    child: const ConfigDialog());
              },
            ).then((homeScreenState) {
              if (synCubit.devisePosition == null) {
                _initializeDatabase();
              }
            });
          }
        }
      }
      _ttsService.speakGreeting(_isFrench);
      // if (mounted) {
      //   FocusScope.of(context).requestFocus(_focusNode);
      // }
    } catch (e) {
      if (kDebugMode) {
        print('Error initializing database: $e');
      }
    }
  }

  Future<void> handleRfidInput(BuildContext context, String rfidCode,
      double timing, SynchronisationCubit authCubit) async {
    try {
      log(rfidCode);
      final user = await _rfidService.getUserByRfidCode(rfidCode, timing);
      if (user.data != null) {
        _ttsService.speakAttendance(user.message, _isFrench);
        authCubit.synDataUpToServer();
      }
      if (context.mounted) {
        _showAutoDismissDialog(context, user, rfidCode);
      }
    } catch (e) {
      if (context.mounted) {
        _showAutoDismissDialog(
            context,
            (
              success: false,
              data: null,
              message: "Une erreur s'est produit veillez reesayer"
            ),
            rfidCode);
      }
    }
  }

  void _showAutoDismissDialog(
    BuildContext context,
    GetUserByRfidCodeType data,
    String rfidCode,
  ) {
    showDialog(
        context: context,
        builder: (BuildContext context) {
          // Contenu du modal
          return Dialog(
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(5)),
              child: BadgingDialog(
                data: data,
                rfid: rfidCode,
              ));
        });

    // Fermer le modal après 3 secondes
    Future.delayed(const Duration(seconds: 4), () {
      if (context.mounted) {
        if (Navigator.of(context).canPop()) {
          Navigator.of(context).pop(); // Ferme le dialog
        }
        FocusScope.of(context).requestFocus(_focusNode);
        _controller.clear();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final authCubit = BlocProvider.of<SynchronisationCubit>(context);
    final synCubit = BlocProvider.of<SynchronisationCubit>(context).state;

    final devisePosition = synCubit.devisePosition;
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: const SystemUiOverlayStyle(
        statusBarColor: Color(0xFF00233b),
        statusBarIconBrightness: Brightness.light,
        statusBarBrightness: Brightness.dark,
      ),
      child: SafeArea(
        child: Scaffold(
          body: BlocBuilder<SynchronisationCubit, SynchronisationDataUiModel>(
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
                    horizontal: 10,
                    vertical: 10,
                  ), // Optionnel pour ajouter un peu de marge
                  decoration: BoxDecoration(
                    color:
                        const Color(0xFF00233b), // Couleur de fond de la carte
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
                            color: Colors
                                .white, // Similaire à `theme.secondaryText`
                          ),
                          textAlign: TextAlign.right,
                        ),
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: SingleChildScrollView(
                    child: Column(
                      children: [
                        TimeDisplay(
                          minutes: minutes,
                          seconds: seconds,
                          nfcTimeMessage:
                              "Le temps d'attente pour un employé entre deux badging succesif est de:",
                        ),
                        InkWell(
                          onTap: () {
                            log('...');
                            FocusScope.of(context).requestFocus(_focusNode);
                            FocusScope.of(context).autofocus(_focusNode);
                          },
                          child: Container(
                              height: 210,
                              padding: const EdgeInsets.symmetric(vertical: 10),
                              child: const ListeningIndicator()),
                        ),
                        Opacity(
                          opacity: 0.002, // Rend le champ invisible
                          child: TextFormField(
                            onFieldSubmitted: (e) {
                              handleRfidInput(context, e, timing, authCubit);
                            },
                            controller: _controller,
                            focusNode: _focusNode,
                            autofocus: true,
                            decoration:
                                const InputDecoration(border: InputBorder.none),
                          ),
                        ),
                        const Text(
                          'Passez votre carte sur le lecteur externe.',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w200,
                            color: Colors
                                .black, // Similaire à `theme.secondaryText`
                          ),
                          textAlign: TextAlign.center,
                        ),
                        if (devisePosition != null)
                          Wrap(
                            alignment: WrapAlignment.center,
                            spacing: 5,
                            children: [
                              Text.rich(
                                TextSpan(
                                  text: 'Configuration : ',
                                  style: const TextStyle(
                                    fontSize: 16,
                                  ),
                                  children: [
                                    TextSpan(
                                      text:
                                          '${devisePosition.deviceId} -- ${devisePosition.positionName}',
                                      style: const TextStyle(
                                          fontWeight: FontWeight.bold),
                                    ),
                                  ],
                                ),
                              ),
                              InkWell(
                                  onTap: () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                          builder: (context) =>
                                              const LoginScreen(
                                                isForDevicePosition: true,
                                              )),
                                    ).then((_) {
                                      _initializeDatabase();
                                      if (context.mounted) {
                                        FocusScope.of(context)
                                            .requestFocus(_focusNode);
                                      }
                                    });
                                  },
                                  child: Icon(
                                    Icons.update_sharp,
                                    color: Colors.green[900],
                                  ))
                            ],
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
                                    setState(() {});
                                    if (synCubit.devisePosition == null) {
                                      _initializeDatabase();
                                      setState(() {});
                                      return;
                                    }
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                          builder: (context) =>
                                              const RecordsScreen()),
                                    ).then((_) {
                                      _initializeDatabase();
                                      if (context.mounted) {
                                        FocusScope.of(context)
                                            .requestFocus(_focusNode);
                                      }
                                    });
                                  },
                                  onPressLogin: () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                          builder: (context) =>
                                              const LoginScreen()),
                                    ).then((_) {
                                      _initializeDatabase();
                                      if (context.mounted) {
                                        FocusScope.of(context)
                                            .requestFocus(_focusNode);
                                      }
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
                    ),
                  ),
                ),
              ],
            );
          }),
          floatingActionButton: FloatingActionButton(
            onPressed: () {
              BlocProvider.of<SynchronisationCubit>(context).getAllOnLineData();
              if (context.mounted) {
                FocusScope.of(context).requestFocus(_focusNode);
              }
              FocusScope.of(context).requestFocus(_focusNode);
            },
            backgroundColor: Colors.blue,
            child: const Icon(Icons.update),
          ),
        ),
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
