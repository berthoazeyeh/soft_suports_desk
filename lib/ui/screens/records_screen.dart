import 'dart:developer';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:intl/intl.dart';
import 'package:path_provider/path_provider.dart';
import 'package:scrollable_table_view/scrollable_table_view.dart';
import 'package:soft_support_decktop/models/attendances.dart';
import 'package:soft_support_decktop/services/draw_pdf_servives.dart';
import 'package:soft_support_decktop/services/storage_service.dart';
import 'package:soft_support_decktop/ui/components/popup_menu_widget.dart';
import 'package:soft_support_decktop/ui/components/record_dialog.dart';
import 'package:syncfusion_flutter_pdf/pdf.dart';
import 'package:to_csv/to_csv.dart' as export_csv;

class RecordsScreen extends StatefulWidget {
  const RecordsScreen({super.key});

  @override
  State<RecordsScreen> createState() => _RecordsScreenState();
}

class _RecordsScreenState extends State<RecordsScreen> {
  List<WeekDay> getCurrentWeekDates() {
    const List<String> weekLabels = [
      'Lundi',
      'Mardi',
      'Mercredi',
      'Jeudi',
      'Vendredi',
      'Samedi',
      'Dimanche',
    ];
    final now = DateTime.now();
    final monday = now.subtract(Duration(days: now.weekday - 1));
    return List.generate(7, (index) {
      final dayDate = monday.add(Duration(days: index));
      return WeekDay(label: weekLabels[index], date: dayDate);
    });
  }

  String searchQuery = '';
  void onSearch(String query) {
    setState(() {
      searchQuery = query;
    });
  }

  DateTimeRange? dateRange;
  String selectedType = "Students";
  WeekDay? selectedWeek;
  DateTime? selectedDateTime;
  List<String> list = ["Students", "Employees"];
  @override
  Widget build(BuildContext context) {
    Intl.defaultLocale = 'fr_FR';
    final date = dateRange != null
        ? DateFormat('yyyy-MM-dd').format(dateRange!.start)
        : selectedWeek != null
            ? DateFormat('yyyy-MM-dd').format(selectedWeek!.date)
            : null;
    // if (kDebugMode) {
    //   print(date);
    // }
    Future<void> generateDoc(List<AttendanceRecord> records) async {
      // Create a new PDF document.
      Directory? root = await getDownloadsDirectory();
      final PdfDocument document = PdfDocument();
      //Add page to the PDF
      final PdfPage page = document.pages.add();
      //Get page client size
      final Size pageSize = page.getClientSize();
      //Draw rectangle
      page.graphics.drawRectangle(
          bounds: Rect.fromLTWH(0, 0, pageSize.width, pageSize.height),
          pen: PdfPen(PdfColor(142, 170, 219)));
      //Generate PDF grid.
      final PdfGrid grid =
          DrawPdfServives().getGrid(formatHeaderPrint(), records);
      //Draw the header section by creating text element
      final PdfLayoutResult result =
          DrawPdfServives().drawHeader(page, pageSize, grid);
      //Draw grid
      DrawPdfServives().drawGrid(page, grid, result);
      //Add invoice footer
      DrawPdfServives().drawFooter(page, pageSize);
      //Save the PDF document
      final List<int> bytes = await document.save();
      document.dispose();
      if (root != null) {
        File('${root.path}/Raport-$selectedType-${DateFormat("dd-MM-yyyy-HH-mm-ss").format(DateTime.now())}-${DateTime.now().microsecond.toString()}.pdf')
            .writeAsBytes(bytes);
      } else {
        Directory? root = await getApplicationDocumentsDirectory();
        File('${root.path}/Raport-$selectedType-${DateFormat("dd-MM-yyyy-HH-mm-ss").format(DateTime.now())}-${DateTime.now().microsecond.toString()}.pdf')
            .writeAsBytes(bytes);
      }
      EasyLoading.showSuccess(
          'File generated successfully path:${'${root?.path ?? ''}/Raport-$selectedType-${DateFormat("dd-MM-yyyy").format(DateTime.now())}-${DateTime.now().microsecond.toString()}.pdf'}');

// Dispose the document.
      log('..../////////');
      document.dispose();
    }

    Future<void> generateCSVFile() async {
      List<String> header = [];
      header.add('No.');
      header.add('User Name');
      header.add('Mobile');
      header.add('ID Number');
      List<List<String>> listOfLists = [];
      List<String> data1 = ['1', 'Bilal Saeed', '1374934', '912839812'];
      List<String> data2 = ['2', 'Ahmar', '21341234', '192834821'];

      listOfLists.add(data1);
      listOfLists.add(data2);

      await export_csv.myCSV(header, listOfLists).then((e) {
        if (kDebugMode) {
          EasyLoading.showSuccess(
              'CSV file generated successfully${e.toString()}');
        }
      });
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text("Management des presences"),
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
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
          ),
          Container(
            decoration: BoxDecoration(color: Colors.blue[400]),
            padding: const EdgeInsets.symmetric(
              horizontal: 15.0,
              vertical: 10,
            ),
            child: Wrap(
              alignment: WrapAlignment.spaceBetween,
              crossAxisAlignment: WrapCrossAlignment.center,
              runSpacing: 10,
              children: [
                Text(
                  'Filtre: $selectedType, Toute la semaine',
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w900,
                    fontSize: 16,
                  ),
                ),
                Wrap(
                  runSpacing: 15,
                  spacing: 10,
                  alignment: WrapAlignment.spaceEvenly,
                  children: getCurrentWeekDates()
                      .map((item) => InkWell(
                            onTap: () {
                              setState(() {
                                selectedWeek = item;
                                dateRange = null;
                              });
                            },
                            child: Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 10,
                                  vertical: 3,
                                ),
                                decoration: BoxDecoration(
                                    color: item.label == selectedWeek?.label
                                        ? Colors.green[900]
                                        : Colors.white54,
                                    borderRadius: BorderRadius.circular(5)),
                                child: Text(item.label,
                                    style: TextStyle(
                                      color: item.label == selectedWeek?.label
                                          ? Colors.white
                                          : Colors.black,
                                    ))),
                          ))
                      .toList(),
                ),
                InkWell(
                  onTap: () {
                    showDialog(
                      context: context,
                      builder: (BuildContext context) {
                        return Dialog(
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(5)),
                            child: RecordDialog(
                              onConfirm: (date) {
                                setState(() {
                                  dateRange = date;
                                  selectedWeek = null;
                                  selectedDateTime = null;
                                });
                              },
                            ));
                      },
                    );
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 3,
                    ),
                    decoration: BoxDecoration(
                        color: Colors.white54,
                        borderRadius: BorderRadius.circular(5)),
                    child: Wrap(
                      children: [
                        if (dateRange != null)
                          Text(
                              'du  ${DateFormat('dd MMMM yyyy').format(dateRange!.start)} au ${DateFormat('dd MMMM yyyy').format(dateRange!.end)}')
                        else
                          const Text('Choisir Une date')
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
              onChanged: onSearch,
              decoration: InputDecoration(
                labelText: "Rechercher un employé",
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(15),
                ),
              ),
            ),
          ),
          FutureBuilder<GetResponse$Attendance>(
              future: StorageService.instance.getAllAttendances(
                  isStudent: selectedType == "Students", date: date),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (snapshot.hasError) {
                  return Center(
                    child: Text('Error: ${snapshot.error}'),
                  );
                }
                final records = (snapshot.data?.data ?? [])
                    .where((record) => record.partner.displayName
                        .toLowerCase()
                        .contains(searchQuery.toLowerCase()))
                    .toList();

                if (records.isEmpty) {
                  return Center(
                    child: selectedDateTime != null
                        ? Text(
                            style: const TextStyle(
                              fontWeight: FontWeight.w700,
                              color: Colors.black,
                              fontSize: 16,
                            ),
                            'Aucun enregistrement trouvé pour la date du: ${DateFormat.yMMMMEEEEd().format(selectedDateTime!)} a ${DateFormat.Hms().format(selectedDateTime!)} ')
                        : Text(
                            'Aucun enregistrement trouvé pour les $selectedType'),
                  );
                }

                final PaginationController paginationController =
                    PaginationController(
                  rowCount: records.length,
                  rowsPerPage: 7,
                );
                if (selectedWeek != null || dateRange != null) {
                  return Expanded(
                      child: Column(
                    children: [
                      Expanded(
                        child: ScrollableTableView(
                          paginationController: paginationController,
                          rowDividerHeight: 2,
                          headers: formatHeader().map((item) {
                            return TableViewHeader(
                              width: item.width,
                              label: item.label,
                            );
                          }).toList(),
                          rows: records.map((product) {
                            return TableViewRow(
                                height: 60, cells: formatBody(product));
                          }).toList(),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 25),
                        child: ValueListenableBuilder(
                            valueListenable: paginationController,
                            builder: (context, value, child) {
                              return Row(
                                children: [
                                  Text(
                                      "${paginationController.currentPage}    of    ${paginationController.pageCount}"),
                                  Row(
                                    children: [
                                      IconButton(
                                        onPressed: paginationController
                                                    .currentPage <=
                                                1
                                            ? null
                                            : () {
                                                paginationController.previous();
                                              },
                                        iconSize: 20,
                                        splashRadius: 20,
                                        icon: Icon(
                                          Icons.arrow_back_ios_new_rounded,
                                          color: paginationController
                                                      .currentPage <=
                                                  1
                                              ? Colors.black26
                                              : Theme.of(context).primaryColor,
                                        ),
                                      ),
                                      const SizedBox(
                                        width: 40,
                                      ),
                                      IconButton(
                                        onPressed: paginationController
                                                    .currentPage >=
                                                paginationController.pageCount
                                            ? null
                                            : () {
                                                paginationController.next();
                                              },
                                        iconSize: 20,
                                        splashRadius: 20,
                                        icon: Icon(
                                          Icons.arrow_forward_ios_rounded,
                                          color: paginationController
                                                      .currentPage >=
                                                  paginationController.pageCount
                                              ? Colors.black26
                                              : Theme.of(context).primaryColor,
                                        ),
                                      ),
                                      Padding(
                                        padding: const EdgeInsets.symmetric(
                                            horizontal: 10.0),
                                        child: MyPopupMenu(
                                          onGeneratePDF: () async {
                                            await generateDoc(records);
                                          },
                                          onGenerateExcel: () async {
                                            await generateCSVFile();
                                          },
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              );
                            }),
                      ),
                    ],
                  ));
                }
                return Expanded(
                  child: SingleChildScrollView(
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                      ),
                      decoration: BoxDecoration(color: Colors.blue[400]),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          Wrap(
                              runSpacing: 15,
                              spacing: 10,
                              alignment: WrapAlignment.spaceEvenly,
                              children: records.map(
                                (record) {
                                  return Card(
                                    elevation: 4,
                                    child: Padding(
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 20.0, vertical: 10.0),
                                      child: Column(
                                        children: [
                                          Wrap(
                                            crossAxisAlignment:
                                                WrapCrossAlignment.center,
                                            spacing: 10,
                                            children: [
                                              CircleAvatar(
                                                radius: 15,
                                                backgroundImage: NetworkImage(
                                                    record.partner.avatar),
                                                onBackgroundImageError:
                                                    (_, __) =>
                                                        const Icon(Icons.error),
                                              ),
                                              SizedBox(
                                                width: 200,
                                                child: Text(
                                                  record.partner.displayName,
                                                  style: const TextStyle(
                                                    fontWeight: FontWeight.bold,
                                                  ),
                                                ),
                                              ),
                                            ],
                                          ),
                                          const SizedBox(
                                            height: 10,
                                          ),
                                          Wrap(
                                            children: [
                                              Text(
                                                  '${DateFormat.yMMMEd().format(record.checkIn)} a ${DateFormat.Hms().format(record.checkIn)} '),
                                              Icon(
                                                size: 15,
                                                Icons.arrow_upward,
                                                color: Colors.green[900],
                                              ),
                                            ],
                                          ),
                                          if (record.checkOut != null)
                                            Wrap(
                                              children: [
                                                Text(
                                                    '${DateFormat.yMMMEd().format(record.checkOut!)} a ${DateFormat.Hms().format(record.checkOut!)} '),
                                                const Icon(
                                                  size: 15,
                                                  Icons.arrow_downward,
                                                  color: Colors.redAccent,
                                                ),
                                              ],
                                            ),
                                          const SizedBox(
                                            height: 10,
                                          ),
                                          Text(
                                              'RFID: ${record.partner.rfidNum} - ${record.partner.rfidCode}'),
                                        ],
                                      ),
                                    ),
                                  );
                                },
                              ).toList()),
                        ],
                      ),
                    ),
                  ),
                );
              }),
        ],
      ),
    );
  }
}

List<HeaderType> formatHeader() {
  List<HeaderType> tmp = [
    HeaderType(label: "id", width: 100),
    HeaderType(label: "name", width: 200),
    HeaderType(label: "Checkin", width: 200),
    HeaderType(label: "CheckOut", width: 200),
    HeaderType(label: "Created_At", width: 200),
    HeaderType(label: "Updated_At", width: 200),
    HeaderType(label: "RFID_NUM", width: 200),
    HeaderType(label: "RFID_HEX", width: 200),
  ];
  return tmp;
}

List<HeaderType> formatHeaderPrint() {
  List<HeaderType> tmp = [
    HeaderType(label: "Nom et Prenom", width: 1),
    HeaderType(label: "Checkin", width: 2),
    HeaderType(label: "CheckOut", width: 3),
    HeaderType(label: "RFID Numerique", width: 4),
    HeaderType(label: "RFID Hexadecimale", width: 5),
    HeaderType(label: "Heure totale", width: 6),
  ];
  return tmp;
}

List<TableViewCell> formatBody(AttendanceRecord record) {
  List<HeaderType> header = formatHeader();
  List<TableViewCell> tablecell = [];

  for (var item in header) {
    switch (item.label) {
      case 'id':
        tablecell.add(TableViewCell(
          padding: const EdgeInsets.symmetric(horizontal: 10),
          child: Text(record.id.toString()),
        ));
        break;
      case 'name':
        tablecell.add(TableViewCell(
          padding: const EdgeInsets.symmetric(horizontal: 10),
          alignment: Alignment.centerLeft,
          child: Text(record.partner.displayName.toString()),
        ));
        break;
      case 'Checkin':
        tablecell.add(TableViewCell(
          padding: const EdgeInsets.symmetric(horizontal: 10),
          alignment: Alignment.centerLeft,
          child: Text(
              '${DateFormat.yMMMMEEEEd().format(record.checkIn)} a ${DateFormat.Hms().format(record.checkIn)} '),
        ));
        break;
      case 'CheckOut':
        tablecell.add(TableViewCell(
          padding: const EdgeInsets.symmetric(horizontal: 10),
          alignment: Alignment.centerLeft,
          child: Text(record.checkOut != null
              ? '${DateFormat.yMMMMEEEEd().format(record.checkOut!)} a ${DateFormat.Hms().format(record.checkOut!)} '
              : ''),
        ));
        break;
      case 'Created_At':
        tablecell.add(TableViewCell(
          padding: const EdgeInsets.symmetric(horizontal: 10),
          alignment: Alignment.centerLeft,
          child: Text(
              '${DateFormat.yMMMMEEEEd().format(record.createDate)} a ${DateFormat.Hms().format(record.createDate)} '),
        ));
        break;
      case 'Updated_At':
        tablecell.add(TableViewCell(
          padding: const EdgeInsets.symmetric(horizontal: 10),
          alignment: Alignment.centerLeft,
          child: Text(
              '${DateFormat.yMMMMEEEEd().format(record.updateDate)} a ${DateFormat.Hms().format(record.updateDate)} '),
        ));
        break;
      case 'RFID_NUM':
        tablecell.add(TableViewCell(
          padding: const EdgeInsets.symmetric(horizontal: 10),
          child: Text(record.partner.rfidNum),
        ));
        break;
      case 'RFID_HEX':
        tablecell.add(TableViewCell(
          padding: const EdgeInsets.symmetric(horizontal: 10),
          child: Text(record.partner.rfidCode),
        ));
        break;

      default:
        tablecell.add(const TableViewCell(
          padding: EdgeInsets.symmetric(horizontal: 10),
          alignment: Alignment.centerLeft,
          child: Text(''),
        ));
    }
  }

  return tablecell;
}

class WeekDay {
  final String label; // Label du jour (ex: "Lundi")
  final DateTime date; // Date correspondante

  WeekDay({required this.label, required this.date});
}

class HeaderType {
  final String label; // Label du jour (ex: "Lundi")
  final double width; // Date correspondante

  HeaderType({required this.label, required this.width});
}
