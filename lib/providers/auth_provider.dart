import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

enum AuthStatus { unknown, authenticated, unauthenticated, newUser }

class AuthsProvider with ChangeNotifier {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  User? _user;
  AuthStatus _status = AuthStatus.unknown;

  AuthsProvider() {
    _auth.authStateChanges().listen(_onAuthStateChanged);
  }

  AuthStatus get status => _status;

  Stream<AuthStatus> get authStatusStream =>
      _auth.authStateChanges().map((user) {
        if (user != null) {
          return AuthStatus.authenticated;
        } else {
          return AuthStatus.unauthenticated;
        }
      });
  Future<void> _onAuthStateChanged(User? firebaseUser) async {
    if (firebaseUser == null) {
      _status = AuthStatus.unauthenticated;
    } else {
      _status = AuthStatus.authenticated;
    }
    notifyListeners();
  }

  Future<void> _checkUserStatus() async {
    DocumentSnapshot userDoc =
        await _firestore.collection('users').doc(_user!.uid).get();

    if (userDoc.exists) {
      Map<String, dynamic> userData = userDoc.data() as Map<String, dynamic>;
      if (userData['status'] == 'new') {
        _status = AuthStatus.newUser;
      } else {
        _status = AuthStatus.authenticated;
      }
    } else {
      _status = AuthStatus.newUser;
    }

    notifyListeners();
  }

  Future<void> signIn(String email, String password) async {
    try {
      await _auth.signInWithEmailAndPassword(email: email, password: password);
    } catch (e) {
      rethrow;
    }
  }

  Future<void> signUp(String email, String password) async {
    try {
      await _auth.createUserWithEmailAndPassword(
          email: email, password: password);
    } catch (e) {
      rethrow;
    }
  }

  Future<void> signOut() async {
    await _auth.signOut();
    _status = AuthStatus.unauthenticated;
    notifyListeners();
  }

  Future<void> completeUserSetup(Map<String, dynamic> userData) async {
    if (_user == null) throw Exception("Utilisateur non authentifié");

    await _firestore.collection('users').doc(_user!.uid).set(userData);
    _status = AuthStatus.authenticated;
    notifyListeners();
  }
}
