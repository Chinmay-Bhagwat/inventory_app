import 'package:flutter/material.dart';
import '../widgets/common_layout.dart';

class DeskScreen extends StatelessWidget {
  final String deskId;
  final String deskName;

  const DeskScreen({
    super.key,
    required this.deskId,
    required this.deskName,
  });

  @override
  Widget build(BuildContext context) {
    return CommonLayout(
      title: deskName,
      body: GridView.builder(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
        itemCount: 6,
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 4,
          crossAxisSpacing: 6,
          mainAxisSpacing: 10,
          childAspectRatio: 0.8,
        ),
        itemBuilder: (context, index) {
          final items = [
            {"icon": Icons.task, "title": "Temp Tasks"},
            {"icon": Icons.refresh, "title": "Review Cycle"},
            {"icon": Icons.storage, "title": "Desk Data"},
            {"icon": Icons.people, "title": "Emp Info"},
            {"icon": Icons.info, "title": "Desk Info"},
            {"icon": Icons.description, "title": "About Desk"},
          ];

          return _buildTile(
            context,
            items[index]["icon"] as IconData,
            items[index]["title"] as String,
          );
        },
      ),
    );
  }

  Widget _buildTile(BuildContext context, IconData icon, String title) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        InkWell(
          borderRadius: BorderRadius.circular(50),
          onTap: () {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text("$title clicked")),
            );
          },
          child: Container(
            width: 55,
            height: 55,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Theme.of(context).colorScheme.primary.withOpacity(0.12),
            ),
            child: Icon(
              icon,
              size: 26,
              color: Theme.of(context).colorScheme.primary,
            ),
          ),
        ),

        const SizedBox(height: 5),

        Text(
          title,
          textAlign: TextAlign.center,
          style: const TextStyle(fontSize: 11),
        ),
      ],
    );
  }
}