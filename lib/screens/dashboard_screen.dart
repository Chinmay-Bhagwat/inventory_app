import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../widgets/common_layout.dart';

class DashboardScreen extends StatelessWidget {
  DashboardScreen({super.key});

  final CollectionReference sectors =
      FirebaseFirestore.instance.collection('sectors');

  void addSector(BuildContext context) async {
    TextEditingController controller = TextEditingController();

    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text("Add Sector"),
        content: TextField(
          controller: controller,
          decoration: const InputDecoration(hintText: "Sector name"),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Cancel"),
          ),
          ElevatedButton(
            onPressed: () async {
              if (controller.text.isNotEmpty) {
                await sectors.add({
                  'name': controller.text,
                  'createdAt': Timestamp.now(),
                });
              }
              Navigator.pop(context);
            },
            child: const Text("Add"),
          ),
        ],
      ),
    );
  }



@override
Widget build(BuildContext context) {
  return CommonLayout(
    title: "Inventory App",
    body: const Center(
      child: Text("Select a sector from sidebar"),
    ),
  );
}
}