import 'dart:convert';
import 'dart:io';
import 'package:alfa_scout/data/user_api_service.dart';
import 'package:alfa_scout/domain/models/user_profile.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class UserFirestoreApiService implements UserApiService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  @override
  Future<void> saveUserProfile(UserProfile profile) async {
    final uid = profile.uid;
    await _firestore.collection('users').doc(uid).set(profile.toMap());

    final user = _auth.currentUser;
    if (user != null) {
      await user.updateDisplayName('${profile.name} ${profile.surname}');
    }
  }

  @override
  Future<UserProfile?> getUserProfile(String uid) async {
    final doc = await _firestore.collection('users').doc(uid).get();
    final data = doc.data();
    if (doc.exists && data != null) {
      return UserProfile.fromMap(uid, data);
    }
    return null;
  }

  Future<String> convertFileToBase64(File file) async {
    final bytes = await file.readAsBytes();
    return base64Encode(bytes);
  }
}





