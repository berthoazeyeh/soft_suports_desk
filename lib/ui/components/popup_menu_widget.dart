import 'package:flutter/material.dart';

import 'my_loader_builder.dart';

class MyPopupMenu extends StatelessWidget {
  const MyPopupMenu({
    this.onGeneratePDF,
    this.onGenerateExcel,
    super.key,
  });
  final Future Function()? onGeneratePDF;
  final Future Function()? onGenerateExcel;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 20,
      child: PopupMenuButton(
        padding: const EdgeInsets.all(0),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(15.0),
        ),
        itemBuilder: (BuildContext context) {
          return <PopupMenuEntry>[
            PopupMenuItem(
              child: MyLoaderBuilder(
                onEnd: () {
                  if (context.mounted) {
                    Navigator.of(context).pop();
                  }
                },
                process: onGenerateExcel ?? () => Future.value(),
                loadingStateBuilder: (_) => const Padding(
                  padding: EdgeInsets.all(2.5),
                  child: ListTile(
                    title: Text(
                      'Telecharger la version Excel',
                      style: TextStyle(
                        color: Color.fromRGBO(0, 0, 0, 1),
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    leading: SizedBox.square(
                      dimension: 12,
                      child: CircularProgressIndicator.adaptive(),
                    ),
                  ),
                ),
                normalStateBuilder: (_, onTap) => ListTile(
                  onTap: onTap,
                  title: const Text(
                    'Telecharger la version Excel',
                    style: TextStyle(
                      color: Color.fromRGBO(0, 0, 0, 1),
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  leading: const Icon(Icons.file_present_rounded),
                ),
              ),
            ),
            PopupMenuItem(
              child: MyLoaderBuilder(
                onEnd: () {
                  if (context.mounted) {
                    Navigator.of(context).pop();
                  }
                },
                process: onGeneratePDF ?? () => Future.value(),
                loadingStateBuilder: (_) => const Padding(
                  padding: EdgeInsets.all(2.5),
                  child: ListTile(
                    title: Text(
                      'Telecharger la Version PDF',
                      style: TextStyle(
                        color: Color.fromRGBO(0, 0, 0, 1),
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    leading: SizedBox.square(
                      dimension: 12,
                      child: CircularProgressIndicator.adaptive(),
                    ),
                  ),
                ),
                normalStateBuilder: (_, onTap) => ListTile(
                  onTap: onTap,
                  title: const Text(
                    'Telecharger la version PDF',
                    style: TextStyle(
                      color: Color.fromRGBO(0, 0, 0, 1),
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  leading: const Icon(Icons.picture_as_pdf_sharp),
                ),
              ),
            ),
          ];
        },
        icon: Icon(
          Icons.print,
          color: Theme.of(context).primaryColor,
        ),
        position: PopupMenuPosition.under,
      ),
    );
  }
}
