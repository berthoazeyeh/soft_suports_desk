import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:soft_support_decktop/api/cubit/synchronisation_cubit.dart';
import 'package:soft_support_decktop/api/state/synchronisation_data_ui_model.dart';

class EquipmentConfigurationScreen extends StatefulWidget {
  const EquipmentConfigurationScreen({super.key});

  @override
  State<EquipmentConfigurationScreen> createState() =>
      _EquipmentConfigurationScreenState();
}

class _EquipmentConfigurationScreenState
    extends State<EquipmentConfigurationScreen> {
  TextEditingController equipmentIdController = TextEditingController();
  TextEditingController positionController = TextEditingController();

  @override
  void initState() {
    super.initState();
    final devisePosition =
        BlocProvider.of<SynchronisationCubit>(context).state.devisePosition;

    if (devisePosition != null) {
      setState(() {
        equipmentIdController.text = devisePosition.deviceId;
        positionController.text = devisePosition.positionName;
      });
    }
  }

  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  void handleConfiguration(
      BuildContext context, SynchronisationCubit synCubit) {
    if (_formKey.currentState!.validate()) {
      final equipmentId = equipmentIdController.text.trim();
      final position = positionController.text.trim();

      // Afficher un message de succès
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            "Équipement configuré avec succès : \nIdentifiant: $equipmentId\nPosition: $position",
          ),
          backgroundColor: Colors.green,
        ),
      );

      synCubit.setDevicePosition(DevisePosition(
        deviceId: equipmentIdController.text,
        positionName: positionController.text,
      ));
      // Effacer les champs après soumission
      equipmentIdController.clear();
      positionController.clear();
      if (mounted) {
        Navigator.pop(context);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final synCubit = BlocProvider.of<SynchronisationCubit>(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Configuration de l\'équipement'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Text(
                "Veuillez configurer votre équipement.",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 10),
              const Text(
                "NB. l'identifiant est a lire sur l'equipement physique",
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w300),
              ),
              const SizedBox(height: 20),
              TextFormField(
                controller: equipmentIdController,
                decoration: const InputDecoration(
                  labelText: 'Identifiant de l\'équipement',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.devices),
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return "L'identifiant est obligatoire.";
                  }
                  if (value.trim().length < 5) {
                    return "L'identifiant doit avoir au moins 5 caractères.";
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: positionController,
                decoration: const InputDecoration(
                  labelText: 'Position de l\'équipement',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.location_on),
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return "La position est obligatoire.";
                  }
                  if (value.trim().length < 5) {
                    return "La position doit avoir au moins 5 caractères.";
                  }
                  return null;
                },
              ),
              const SizedBox(height: 30),
              ElevatedButton.icon(
                onPressed: () => handleConfiguration(context, synCubit),
                icon: const Icon(Icons.save),
                label: const Text('Configurer l\'équipement'),
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  textStyle: const TextStyle(fontSize: 16),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
