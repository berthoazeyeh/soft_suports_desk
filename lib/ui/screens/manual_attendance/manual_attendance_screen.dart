import 'package:flutter/material.dart';
import 'package:soft_support_decktop/models/manuel_attendance.dart';
import 'package:soft_support_decktop/services/storage_service.dart';

import 'widgets/item_widget.dart';

class ManualAttendanceScreen extends StatefulWidget {
  const ManualAttendanceScreen({super.key});

  @override
  State<ManualAttendanceScreen> createState() => _ManualAttendanceScreenState();
}

class _ManualAttendanceScreenState extends State<ManualAttendanceScreen> {
  String searchQuery = "";
  String selectedType = "Students";
  bool isLoading = false;
  bool isLoadingData = false;

  List<ManuelAttendance> allEmployees = [];
  List<ManuelAttendance> filteredData = [];
  List<String> list = ["Students", "Employees"];

  @override
  void initState() {
    super.initState();
    fetchData();
  }

  void fetchData() async {
    setState(() {
      isLoadingData = true;
    });

    final data = await StorageService.instance
        .getFilterAttendances(selectedType == "Students");

    if (data.success) {
      setState(() {
        allEmployees = data.data;
        filteredData = data.data;
        isLoadingData = false;
      });
    } else {
      setState(() {
        isLoadingData = false;
      });
    }
  }

  void onSearch(String query) {
    setState(() {
      searchQuery = query;
      filteredData = allEmployees
          .where((employee) => employee.resPartner.displayName
              .toLowerCase()
              .contains(query.toLowerCase()))
          .toList();
    });
  }

  Widget renderUser(Map<String, dynamic> user) {
    return ListTile(
      title: Text(
        user['user_name'],
        style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
      ),
      subtitle: Text(
        user['type'] == "student" ? "Student" : "Employee",
        style: const TextStyle(color: Colors.grey),
      ),
      trailing: const Icon(Icons.chevron_right),
      onTap: () {
        // Navigate or perform action
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Gestion des présences'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: list
                  .map((item) => Row(
                        children: [
                          Radio<String>(
                            value: item,
                            groupValue: selectedType,
                            onChanged: (value) {
                              setState(() {
                                selectedType = value!;
                                fetchData();
                              });
                            },
                          ),
                          Text(
                            item,
                            style: const TextStyle(fontSize: 16),
                          ),
                        ],
                      ))
                  .toList(),
            ),
            TextField(
              onChanged: onSearch,
              decoration: InputDecoration(
                labelText: "Rechercher un employé",
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(15),
                ),
              ),
            ),
            const SizedBox(height: 16),
            Text(
              'Liste des utilisateurs (${filteredData.length})',
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Expanded(
              child: isLoadingData
                  ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          CircularProgressIndicator(
                              color: Theme.of(context).primaryColor),
                          const SizedBox(height: 16),
                          const Text('Chargement...'),
                        ],
                      ),
                    )
                  : filteredData.isEmpty
                      ? const Center(
                          child: Text(
                            "Aucun utilisateur trouvé",
                            style: TextStyle(fontSize: 16),
                          ),
                        )
                      : ListView.builder(
                          itemCount: filteredData.length,
                          itemBuilder: (context, index) {
                            return UserItem(
                              attendance: filteredData[index],
                              onRefrech: () {
                                fetchData();
                              },
                            );
                          },
                        ),
            ),
          ],
        ),
      ),
    );
  }
}
