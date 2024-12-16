import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:soft_support_decktop/models/user.dart';
import 'package:soft_support_decktop/services/storage_service.dart';
import '../../theme/colors.dart';

class RecordsScreen extends StatelessWidget {
  const RecordsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Management des presences"),
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              AppColors.white,
              AppColors.offWhite,
            ],
          ),
        ),
        child: FutureBuilder<List<UserModel>>(
          future: StorageService.instance.getAllRecords(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }

            if (snapshot.hasError) {
              return Center(
                child: Text('Error: ${snapshot.error}'),
              );
            }

            final records = snapshot.data ?? [];

            if (records.isEmpty) {
              return const Center(
                child: Text('Aucun enregistrement trouvé'),
              );
            }

            return ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: records.length,
              itemBuilder: (context, index) {
                final record = records[index];
                return Card(
                  elevation: 4,
                  margin: const EdgeInsets.only(bottom: 16),
                  child: ListTile(
                    leading: record.image != null
                        ? CircleAvatar(
                            backgroundImage: NetworkImage(record.image!),
                            onBackgroundImageError: (_, __) =>
                                const Icon(Icons.error),
                          )
                        : const CircleAvatar(child: Icon(Icons.person)),
                    title: Text(
                      record.name,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('RFID: ${record.rfidCode}'),
                        Text(
                          'Date: ${DateFormat('dd/MM/yyyy HH:mm').format(record.timestamp)}',
                        ),
                      ],
                    ),
                  ),
                );
              },
            );
          },
        ),
      ),
    );
  }
}
