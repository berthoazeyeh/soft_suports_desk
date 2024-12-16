import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:soft_support_decktop/api/cubit/synchronisation_cubit.dart';
import 'package:soft_support_decktop/api/state/synchronisation_data_ui_model.dart';
import 'package:soft_support_decktop/ui/components/my_banner_widget.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>(); // Clé du formulaire
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

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
      body: BlocBuilder<SynchronisationCubit, SynchronisationDataUiModel>(
          builder: (context, synData) {
        return Column(
          children: [
            if (synData.isSyncing) MyBannerWidget(title: synData.bannerMessage),
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
                              child:
                                  Image.asset('assets/images/logo_circle.png')),
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
                            left: 15.0, right: 15.0, top: 15),
                        child: TextFormField(
                          controller: _passwordController,
                          obscureText: true,
                          decoration: const InputDecoration(
                              border: OutlineInputBorder(),
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
                            child: const Text(
                              'Log in ',
                              style:
                                  TextStyle(color: Colors.white, fontSize: 20),
                            ),
                            onPressed: () {
                              if (_formKey.currentState?.validate() ?? false) {
                                // Si le formulaire est valide
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                      content: Text('Logging in...')),
                                );
                                // Logique de connexion ici
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
    );
  }
}
