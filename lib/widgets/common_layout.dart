import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:provider/provider.dart';

import '../theme/theme_provider.dart';
import '../screens/auth_screen.dart';
import '../screens/settings_screen.dart';
import '../screens/department_screen.dart';
import '../providers/user_role_provider.dart';

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

  // 🔹 ADD SECTOR
  void addSector(BuildContext context) {
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
    final roleProvider = context.watch<UserRoleProvider>();

    return Scaffold(
      appBar: AppBar(
        title: Text(title),
        actions: [
          // 🌙 / ☀️ THEME TOGGLE
          IconButton(
            icon: Icon(
              context.watch<ThemeProvider>().isDarkMode
                  ? Icons.light_mode
                  : Icons.dark_mode,
            ),
            onPressed: () {
              context.read<ThemeProvider>().toggleTheme();
            },
          ),

          // ⚙️ SETTINGS
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

          // 🚪 LOGOUT
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

      // 📂 SIDEBAR
      drawer: Drawer(
        child: Column(
          children: [
            const DrawerHeader(
              child: Text(
                'Sectors',
                style: TextStyle(fontSize: 20),
              ),
            ),

            // 🔹 SECTORS LIST
            Expanded(
              child: StreamBuilder(
                stream: sectors.orderBy('name').snapshots(),
                builder: (context, snapshot) {
                  if (!snapshot.hasData) {
                    return const Center(
                      child: CircularProgressIndicator(),
                    );
                  }

                  final docs = snapshot.data!.docs;

                  if (docs.isEmpty) {
                    return const Center(
                      child: Text("No Sectors yet"),
                    );
                  }

                  return ListView.builder(
                    itemCount: docs.length,
                    itemBuilder: (context, index) {
                      final doc = docs[index];
                      final data =
                          doc.data() as Map<String, dynamic>;

                      return ListTile(
                        title: Text(data['name'] ?? "No Name"),
                        onTap: () {
                          Navigator.pop(context);

                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => DepartmentScreen(
                                sectorId: doc.id,
                                sectorName: data['name'] ?? "Sector",
                              ),
                            ),
                          );
                        },
                      );
                    },
                  );
                },
              ),
            ),

            // ➕ ADD SECTOR (ADMIN ONLY)
            if (!roleProvider.isLoading && roleProvider.isAdmin)
              ListTile(
                leading: const Icon(Icons.add),
                title: const Text("Add Sector"),
                onTap: () => addSector(context),
              ),
          ],
        ),
      ),

      // 📦 BODY
      body: roleProvider.isLoading
          ? const Center(child: CircularProgressIndicator())
          : body,
    );
  }
}