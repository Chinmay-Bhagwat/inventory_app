import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import '../screens/auth_screen.dart';
import '../screens/settings_screen.dart';

class CommonLayout extends StatelessWidget {
  final Widget body;
  final String title;

  CommonLayout({
    super.key,
    required this.body,
    required this.title,
  });

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
    return Scaffold(
      appBar: AppBar(
        title: Text(title),
        actions: [
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => const SettingsScreen(),
                ),
              );
            },
          ),
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () async {
              await FirebaseAuth.instance.signOut();

              Navigator.pushAndRemoveUntil(
                context,
                MaterialPageRoute(builder: (_) => AuthScreen()),
                (route) => false,
              );
            },
          ),
        ],
      ),

      drawer: Drawer(
        child: Column(
          children: [
            const DrawerHeader(
              child: Text('Sectors', style: TextStyle(fontSize: 20)),
            ),

            Expanded(
              child: StreamBuilder(
                stream: sectors.snapshots(),
                builder: (context, snapshot) {
                  if (!snapshot.hasData) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  final docs = snapshot.data!.docs;

                  return ListView.builder(
                    itemCount: docs.length,
                    itemBuilder: (context, index) {
                      return ListTile(
                        title: Text(docs[index]['name']),
                      );
                    },
                  );
                },
              ),
            ),

            ListTile(
              leading: const Icon(Icons.add),
              title: const Text("Add Sector"),
              onTap: () => addSector(context),
            ),
          ],
        ),
      ),

      body: body,
    );
  }
}