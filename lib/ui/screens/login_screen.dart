import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:soft_support_decktop/api/cubit/synchronisation_cubit.dart';
import 'package:soft_support_decktop/api/cubit/user_cubit.dart';
import 'package:soft_support_decktop/api/state/synchronisation_data_ui_model.dart';
import 'package:soft_support_decktop/constants/string.dart';
import 'package:soft_support_decktop/models/attendances.dart';
import 'package:soft_support_decktop/models/user.dart';
import 'package:soft_support_decktop/services/user_service.dart';
import 'package:soft_support_decktop/ui/components/my_banner_widget.dart';
import 'package:soft_support_decktop/ui/screens/manual_attendance/manual_attendance_screen.dart';
import 'package:geolocator/geolocator.dart';

import 'equipment_configuration_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key, this.isForDevicePosition});
  final bool? isForDevicePosition;
  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>(); // Clé du formulaire
  // final TextEditingController _emailController =
  //     TextEditingController(text: 'admin@softeducat.org');
  // final TextEditingController _passwordController =
  //     TextEditingController(text: 'Dschang1');
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  bool showPassword = false;
  bool isLoading = false;
  final userServices = UserService();
  void onChangeShowPassword() {
    setState(() {
      showPassword = !showPassword;
    });
  }

  @override
  void initState() {
    super.initState();
    _determinePosition();
  }

  void handelSuccessLogin() {
    Navigator.push(
      context,
      MaterialPageRoute(
          builder: (context) => widget.isForDevicePosition != null
              ? const EquipmentConfigurationScreen()
              : const ManualAttendanceScreen()),
    ).then((_) {
      if (mounted) {
        Navigator.pop(context);
      }
    });
  }

  Future<void> handleSubmit({
    required String email,
    required String password,
  }) async {
    final authCubit = BlocProvider.of<AuthCubit>(context);
    try {
      // Démarrer le chargement
      setState(() {
        isLoading = true;
      });

      // Appel à l'API locale pour vérifier si l'utilisateur existe
      final localRes = await userServices.loginUserWithPartner(email, password);

      if (localRes['success']) {
        final user = UserModel.fromLocalJson(localRes['data']);
        authCubit.setUser(user);
        EasyLoading.showSuccess('Authentification réussie 0 ${user.name}');
        handelSuccessLogin();
      } else {
        // Appel à l'API distante pour tenter de se connecter

        final onLineres = await UserService().onLineLogin(
          email: _emailController.text,
          password: _passwordController.text,
          database: Strings.database,
        );
        final jsonData = onLineres.data;
        if (kDebugMode) {
          print(onLineres.message);
        }
        if (jsonData != null && jsonData['role'] == 'admin') {
          final user = UserModel.fromJson(jsonData);
          EasyLoading.showSuccess('Authentification réussie 1 ${user.name}');
          authCubit.setUser(user);
          handelSuccessLogin();

          // Créer l'utilisateur localement
          await userServices.createUserWithPartner(
            id: user.id,
            name: user.name,
            email: user.email,
            password: password,
            phone: user.phone,
            role: 'admin',
            partnerId: user.partnerId,
          );
        } else {
          // Erreur d'authentification
          EasyLoading.showSuccess(
              'Vous n\'avez pas les autorisations nécessaires. ${onLineres.data?['message'] ?? ''}');
        }
      }
    } catch (error) {
      // Gérer les erreurs
      EasyLoading.showError('$error');
    } finally {
      // Arrêter le chargement
      setState(() {
        isLoading = false;
      });
    }
  }

  Future<void> onLoginPress() async {
    handleSubmit(
        email: _emailController.text, password: _passwordController.text);
  }

  // Méthode de validation de l'email
  String? _validateEmail(String? value) {
    if (value == null || value.isEmpty) {
      return 'Please enter your email or username';
    }
    // Utilisation d'une expression régulière pour valider l'email
    String pattern = r'\b[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\.[A-Za-z]{2,}\b';
    RegExp regex = RegExp(pattern);
    if (!regex.hasMatch(value)) {
      return 'Please enter a valid email address';
    }
    return null;
  }

  // Méthode de validation du mot de passe
  String? _validatePassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'Please enter your password';
    }
    if (value.length < 6) {
      return 'Password must be at least 6 characters';
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text("Se connecter"),
      ),
      body: SingleChildScrollView(
        child: BlocBuilder<SynchronisationCubit, SynchronisationDataUiModel>(
            builder: (context, synData) {
          return Column(
            children: [
              if (synData.isSyncing)
                MyBannerWidget(title: synData.bannerMessage),
              Center(
                child: Container(
                  alignment: Alignment.center,
                  width: MediaQuery.of(context).size.width * .8,
                  child: Form(
                    key: _formKey, // Ajout de la clé pour valider le formulaire
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: <Widget>[
                        Padding(
                          padding: const EdgeInsets.symmetric(vertical: 50.0),
                          child: Center(
                            child: SizedBox(
                                width: 200,
                                height: 100,
                                child: Image.asset(
                                    'assets/images/logo_circle.png')),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 15),
                          child: TextFormField(
                            controller: _emailController,
                            decoration: const InputDecoration(
                                border: OutlineInputBorder(),
                                labelText: 'Email or username',
                                hintText:
                                    'Enter valid email id as abc@gmail.com'),
                            validator: _validateEmail, // Validation de l'email
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.only(
                              left: 15.0, right: 15.0, top: 35),
                          child: TextFormField(
                            controller: _passwordController,
                            obscureText: !showPassword,

                            decoration: InputDecoration(
                                suffixIcon: IconButton(
                                  onPressed: onChangeShowPassword,
                                  icon: Icon(
                                    showPassword
                                        ? Icons.visibility
                                        : Icons.visibility_off,
                                  ),
                                ),
                                border: const OutlineInputBorder(),
                                labelText: 'Password',
                                hintText: 'Enter secure password'),
                            validator:
                                _validatePassword, // Validation du mot de passe
                          ),
                        ),
                        SizedBox(
                          height: 65,
                          width: 360,
                          child: Padding(
                            padding: const EdgeInsets.only(top: 20.0),
                            child: ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.green[900],
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(100),
                                ),
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 35,
                                  vertical: 10,
                                ),
                              ),
                              child: isLoading
                                  ? const CircularProgressIndicator.adaptive()
                                  : const Text(
                                      'Log in ',
                                      style: TextStyle(
                                          color: Colors.white, fontSize: 20),
                                    ),
                              onPressed: () {
                                if (_formKey.currentState?.validate() ??
                                    false) {
                                  onLoginPress();
                                }
                              },
                            ),
                          ),
                        ),
                        const SizedBox(
                          height: 50,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          );
        }),
      ),
    );
  }

  Future<Position?> _determinePosition() async {
    try {
      bool serviceEnabled;
      LocationPermission permission;
      serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        return Future.error('Location services are disabled.');
      }

      permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          EasyLoading.showError('Location permissions are denied');
        }
      }

      if (permission == LocationPermission.deniedForever) {
        EasyLoading.showError(
            'Location permissions are permanently denied, we cannot request permissions.');
      }
      final res = await Geolocator.getCurrentPosition();
      if (kDebugMode) {
        print(res);
      }
      if (mounted) {
        BlocProvider.of<SynchronisationCubit>(context).setPosition(MyPosition(
          latitude: res.latitude.toString(),
          longitude: res.longitude.toString(),
        ));
      }

      return res;
    } on PlatformException catch (exception) {
      if (kDebugMode) {
        print(exception.message);
      }
      EasyLoading.showError(exception.message ?? '');
    } catch (e) {
      if (kDebugMode) {
        print(e);
      }
    }
    return null;
  }
}
