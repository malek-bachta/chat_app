import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AuthenticationProvider with ChangeNotifier {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  User? _user;
  bool _isLoading = false;
  bool _isRememberMe = false;

  User? get user => _user;
  bool get isLoading => _isLoading;
  bool get isRememberMe => _isRememberMe;

  void setRememberMe(bool value) {
    _isRememberMe = value;
    notifyListeners();
  }

  AuthenticationProvider() {
    _loadUser();
  }

  Future<void> _loadUser() async {
    _user = _auth.currentUser;
    final prefs = await SharedPreferences.getInstance();
    _isRememberMe = prefs.getBool('rememberMe') ?? false;
    notifyListeners();
  }

  Future<void> login(String email, String password, bool rememberMe) async {
    _setLoading(true);
    try {
      final userCredential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      _user = userCredential.user;

      if (rememberMe) {
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('savedEmail', email);
        await prefs.setBool('rememberMe', true);
      } else {
        await _clearSavedData();
      }

      notifyListeners();
    } catch (e) {
      throw Exception('Login failed: ${e.toString()}');
    } finally {
      _setLoading(false);
    }
  }

  Future<void> register(String email, String password) async {
    _setLoading(true);
    try {
      final userCredential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      await _firestore.collection('Users').doc(userCredential.user!.uid).set({
        'uid': userCredential.user!.uid,
        'email': email,
        'userName': email.split('@')[0],
      });
      _user = userCredential.user;
      notifyListeners();
    } catch (e) {
      throw Exception('Registration failed: $e');
    } finally {
      _setLoading(false);
    }
  }

  Future<void> logout() async {
    await _auth.signOut();
    _user = null;
    if (!_isRememberMe) {
      await _clearSavedData();
    }
    notifyListeners();
  }

  Future<void> _clearSavedData() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('savedEmail');
    await prefs.setBool('rememberMe', false);
  }

  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }
}
