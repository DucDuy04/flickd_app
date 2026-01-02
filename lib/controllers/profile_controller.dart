import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../services/auth_service.dart';

final profileProvider = NotifierProvider<ProfileController, String?>(
  () => ProfileController(),
);

class ProfileController extends Notifier<String?> {
  int? _userId;

  int? get userId => _userId;

  /// Set currently logged in user id (call this after login)
  void setUserId(int? id) {
    _userId = id;
    if (id != null) _fetchUsername();
  }

  @override
  String? build() {
    // Non-blocking initial loads
    _loadSavedUsername();
    _loadSavedUserId();
    return null;
  }

  Future<void> _loadSavedUserId() async {
    final prefs = await SharedPreferences.getInstance();
    final saved = prefs.getInt('userId');
    if (saved != null) {
      _userId = saved;
      // loaded userId from prefs
      _fetchUsername();
    }
  }

  Future<void> _loadSavedUsername() async {
    final prefs = await SharedPreferences.getInstance();
    final saved = prefs.getString('username');
    if (saved != null) state = saved;
  }

  Future<void> _saveUsername(String? name) async {
    final prefs = await SharedPreferences.getInstance();
    if (name == null) {
      await prefs.remove('username');
    } else {
      await prefs.setString('username', name);
    }
  }

  Future<void> _fetchUsername() async {
    if (_userId == null) return;
    // fetching username
    try {
      final auth = AuthService();
      final name = await auth.usernameById(_userId!);
      state = name;
      await _saveUsername(name);
      // fetched username
    } catch (e) {
      // fetch failed
    }
  }

  /// Manually set username (saves to prefs and updates state)
  Future<void> setUsername(String? name) async {
    state = name;
    await _saveUsername(name);
  }
}
