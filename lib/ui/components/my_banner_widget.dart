import 'package:flutter/material.dart';

class MyBannerWidget extends StatelessWidget {
  const MyBannerWidget({
    super.key,
    required this.title,
  });

  final String title;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: MediaQuery.of(context).size.width,
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(color: Colors.grey.withOpacity(0.5)),
      child: Row(
        children: [
          const CircularProgressIndicator(
            color: Colors.green,
          ),
          const SizedBox(
            width: 20,
          ),
          Expanded(
            child: Text(
              title,
              style: const TextStyle(fontWeight: FontWeight.w200, fontSize: 16),
            ),
          ),
        ],
      ),
    );
  }
}
