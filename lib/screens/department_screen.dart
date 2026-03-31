import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:provider/provider.dart';

import '../widgets/common_layout.dart';
import '../providers/user_role_provider.dart';
import '../screens/desk_screen.dart';

class DepartmentScreen extends StatelessWidget {
  final String sectorId;
  final String sectorName;

  const DepartmentScreen({
    super.key,
    required this.sectorId,
    required this.sectorName,
  });

  CollectionReference get departments => FirebaseFirestore.instance
      .collection('sectors')
      .doc(sectorId)
      .collection('departments');

  // 🔹 ADD DEPARTMENT
  void addDepartment(BuildContext context) {
    TextEditingController controller = TextEditingController();

    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text("Add Department"),
        content: TextField(
          controller: controller,
          decoration: const InputDecoration(hintText: "Department name"),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Cancel"),
          ),
          ElevatedButton(
            onPressed: () async {
              if (controller.text.isNotEmpty) {
                await departments.add({
                  'name': controller.text,
                  'color': null,
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

  // 🔹 RENAME
  void renameDepartment(BuildContext context, DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;

    TextEditingController controller =
        TextEditingController(text: data['name'] ?? "");

    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text("Rename Department"),
        content: TextField(controller: controller),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Cancel"),
          ),
          ElevatedButton(
            onPressed: () async {
              await doc.reference.update({'name': controller.text});
              Navigator.pop(context);
            },
            child: const Text("Save"),
          ),
        ],
      ),
    );
  }

  // 🔹 DELETE
  void deleteDepartment(String id) async {
    await departments.doc(id).delete();
  }

  // 🔹 CHANGE COLOR
  void changeColor(BuildContext context, DocumentSnapshot doc) {
    final colors = [
      Colors.blue,
      Colors.red,
      Colors.green,
      Colors.orange,
      Colors.purple,
    ];

    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text("Select Color"),
        content: Wrap(
          spacing: 10,
          children: colors.map((color) {
            return GestureDetector(
              onTap: () async {
                await doc.reference.update({'color': color.value});
                Navigator.pop(context);
              },
              child: CircleAvatar(backgroundColor: color),
            );
          }).toList(),
        ),
      ),
    );
  }

  // 🔹 ADD DESK
  void showAddDeskDialog(BuildContext context, String departmentId) {
    TextEditingController controller = TextEditingController();

    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text("Add Desk"),
        content: TextField(
          controller: controller,
          decoration: const InputDecoration(hintText: "Desk name"),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Cancel"),
          ),
          ElevatedButton(
            onPressed: () async {
              if (controller.text.isNotEmpty) {
                await FirebaseFirestore.instance
                    .collection('sectors')
                    .doc(sectorId)
                    .collection('departments')
                    .doc(departmentId)
                    .collection('desks')
                    .add({
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

    return CommonLayout(
      title: sectorName,
      body: Stack(
        children: [
          // 🔹 DEPARTMENTS LIST (ACCORDION)
          StreamBuilder(
            stream: departments.orderBy('name').snapshots(),
            builder: (context, snapshot) {
              if (!snapshot.hasData) {
                return const Center(child: CircularProgressIndicator());
              }

              final docs = snapshot.data!.docs;

              if (docs.isEmpty) {
                return const Center(child: Text("No Departments yet"));
              }

              return ListView(
                children: docs.map((doc) {
                  final data = doc.data() as Map<String, dynamic>;

                  final desksRef = FirebaseFirestore.instance
                      .collection('sectors')
                      .doc(sectorId)
                      .collection('departments')
                      .doc(doc.id)
                      .collection('desks');

                  return Card(
                    margin: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 5,
                    ),
                    color: (data['color'] != null)
                        ? Color(data['color'])
                        : null,
                    child: ExpansionTile(
                      title: Text(
                        data['name'] ?? "No Name",
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),

                      // 🔥 ADMIN MENU ONLY
                      trailing: roleProvider.isAdmin
                          ? PopupMenuButton<String>(
                              onSelected: (value) {
                                if (value == 'rename') {
                                  renameDepartment(context, doc);
                                } else if (value == 'delete') {
                                  deleteDepartment(doc.id);
                                } else if (value == 'color') {
                                  changeColor(context, doc);
                                }
                              },
                              itemBuilder: (context) => const [
                                PopupMenuItem(
                                    value: 'rename',
                                    child: Text("Rename")),
                                PopupMenuItem(
                                    value: 'color',
                                    child: Text("Change Color")),
                                PopupMenuItem(
                                    value: 'delete',
                                    child: Text("Delete")),
                              ],
                            )
                          : null,

                      children: [
                        // 🔹 DESKS LIST
                        StreamBuilder(
                          stream: desksRef.orderBy('name').snapshots(),
                          builder: (context, deskSnap) {
                            if (!deskSnap.hasData) {
                              return const Padding(
                                padding: EdgeInsets.all(10),
                                child: CircularProgressIndicator(),
                              );
                            }

                            final desks = deskSnap.data!.docs;

                            return Column(
                              children: [
                                ...desks.map((desk) {
                                  final deskData =
                                      desk.data() as Map<String, dynamic>;

                                  return ListTile(
                                    leading:
                                        const Icon(Icons.work_outline),
                                    title: Text(
                                      deskData['name'] ?? "Unnamed Desk",
                                    ),
                                    onTap: () {
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (_) => DeskScreen(
                                            deskId: desk.id,
                                            deskName:
                                                deskData['name'] ?? "Desk",
                                          ),
                                        ),
                                      );
                                    },
                                  );
                                }),

                                // ➕ ADD DESK (ADMIN ONLY)
                                if (roleProvider.isAdmin)
                                  ListTile(
                                    leading: const Icon(Icons.add),
                                    title: const Text("Add Desk"),
                                    onTap: () {
                                      showAddDeskDialog(context, doc.id);
                                    },
                                  ),
                              ],
                            );
                          },
                        ),
                      ],
                    ),
                  );
                }).toList(),
              );
            },
          ),

          // ➕ ADD DEPARTMENT (ADMIN ONLY)
          if (roleProvider.isAdmin)
            Positioned(
              bottom: 20,
              right: 20,
              child: FloatingActionButton(
                onPressed: () => addDepartment(context),
                child: const Icon(Icons.add),
              ),
            ),
        ],
      ),
    );
  }
}