import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';


class AuthenticationProvider with ChangeNotifier {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseMessaging _messaging = FirebaseMessaging.instance;

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

    if (_user != null) {
      await _updateDeviceToken();
    }
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

      await _updateDeviceToken();
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
      _user = userCredential.user;

      await _firestore.collection('Users').doc(_user!.uid).set({
        'uid': _user!.uid,
        'email': email,
        'userName': email.split('@')[0],
        'deviceToken': await _messaging.getToken(),
      });

      notifyListeners();
    } catch (e) {
      throw Exception('Registration failed: $e');
    } finally {
      _setLoading(false);
    }
  }

  // Future<void> _updateDeviceToken() async {
  //   if (_user != null) {
  //     try {
  //       final token = await _messaging.getToken();
  //       if (token != null) {
  //         await _firestore.collection('Users').doc(_user!.uid).update({
  //           'deviceToken': token,
  //         });
  //       }
  //     } catch (e) {
  //       print('Error updating device token: $e');
  //     }
  //   }
  // }

  Future<void> _updateDeviceToken() async {
  if (_user != null) {
    try {
      final token = await _messaging.getToken();
      if (token != null) {
        // Store the token in Firestore
        await _firestore.collection('Users').doc(_user!.uid).update({
          'deviceToken': token,
        });

        print('Device token updated in Firestore: $token');

        // Optional: Listen for token refresh
        FirebaseMessaging.instance.onTokenRefresh.listen((newToken) async {
          await _firestore.collection('Users').doc(_user!.uid).update({
            'deviceToken': newToken,
          });
          print('Device token refreshed and updated: $newToken');
        });
      }
    } catch (e) {
      print('Error updating device token in Firestore: $e');
    }
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
