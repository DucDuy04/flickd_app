import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../services/auth_service.dart';

final profileProvider = NotifierProvider<ProfileController, String?>(
  () => ProfileController(),
);

class ProfileController extends Notifier<String?> {
  int? _userId;

  int? get userId => _userId;

  //set userId khi đăng nhập
  void setUserId(int? id) {
    _userId = id;
    if (id != null) _fetchUsername();
  }

  @override
  String? build() {
    _loadSavedUsername();
    _loadSavedUserId();
    return null;
  }

  Future<void> _loadSavedUserId() async {
    final prefs = await SharedPreferences.getInstance();
    final saved = prefs.getInt('userId');
    if (saved != null) {
      _userId = saved;
      // fetch username nếu có userId
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
    // nếu có userId, gọi AuthService để lấy username
    try {
      final auth = AuthService();
      final name = await auth.usernameById(_userId!);
      state = name;
      await _saveUsername(name);
    } catch (e) {}
  }

  //set username và lưu vào prefs
  Future<void> setUsername(String? name) async {
    state = name;
    await _saveUsername(name);
  }
}
