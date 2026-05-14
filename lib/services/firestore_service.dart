import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class FirestoreService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  // Returns null if no user is signed in — callers must guard against this
  String? get uid => FirebaseAuth.instance.currentUser?.uid;

  // =========================
  // SAVE PLAYER PROFILE
  // =========================
  Future<void> saveUserProfile({
    required String name,
    required String avatar,
    required String authType,
  }) async {
    if (uid == null) return;
    await _db
        .collection('users')
        .doc(uid)
        .collection('data')
        .doc('profile')
        .set({
      'name': name,
      'avatar': avatar,
      'authType': authType,
      'email': FirebaseAuth.instance.currentUser?.email,
      'createdAt': FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));
  }

  // =========================
  // SAVE GAME STATE
  // =========================
  Future<void> saveGameState({
    required int balance,
    required int day,
    required int scams,
  }) async {
    if (uid == null) return;
    await _db
        .collection('users')
        .doc(uid)
        .collection('data')
        .doc('gameState')
        .set({
      'balance': balance,
      'day': day,
      'scams': scams,
      'updatedAt': FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));
  }

  // =========================
  // LOAD GAME STATE
  // =========================
  Future<Map<String, dynamic>?> loadGameState() async {
    if (uid == null) return null; // not logged in yet — return nothing
    final doc = await _db
        .collection('users')
        .doc(uid)
        .collection('data')
        .doc('gameState')
        .get();
    return doc.exists ? doc.data() : null;
  }

  // =========================
  // LOAD PROFILE
  // =========================
  Future<Map<String, dynamic>?> loadProfile() async {
    if (uid == null) return null;
    final doc = await _db
        .collection('users')
        .doc(uid)
        .collection('data')
        .doc('profile')
        .get();
    return doc.exists ? doc.data() : null;
  }

  // =========================
  // SAVE LEADERBOARD ENTRY
  // =========================
  Future<void> saveLeaderboardEntry({
    required String name,
    required String avatar,
    required int balance,
    required int day,
    required int scams,
    required String ending,
  }) async {
    if (uid == null) return;
    await _db.collection('leaderboard').doc(uid).set({
      'name': name,
      'avatar': avatar,
      'balance': balance,
      'day': day,
      'scams': scams,
      'ending': ending,
      'updatedAt': FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));
  }
}