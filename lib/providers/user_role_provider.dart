import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class UserRoleProvider extends ChangeNotifier {
  String role = "user";
  bool isLoading = true;

  // ✅ THIS WAS MISSING
  bool get isAdmin => role == "admin";

  Future<void> fetchRole() async {
    final user = FirebaseAuth.instance.currentUser;

    if (user == null) {
      isLoading = false;
      notifyListeners();
      return;
    }

    // 🔍 DEBUG
    print("UID: ${user.uid}");

    final doc = await FirebaseFirestore.instance
        .collection('users')
        .doc(user.uid)
        .get();

    if (doc.exists) {
      role = doc.data()?['role'] ?? "user";
    }

    // 🔍 DEBUG
    print("Fetched role: $role");

    isLoading = false;
    notifyListeners();
  }
}