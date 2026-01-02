import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../services/auth_service.dart';
import '../controllers/wishlist_controller.dart';
import '../controllers/profile_controller.dart';

class LoginPage extends ConsumerStatefulWidget {
  const LoginPage({Key? key}) : super(key: key);

  @override
  ConsumerState<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends ConsumerState<LoginPage> {
  final usernameController = TextEditingController();
  final passwordController = TextEditingController();
  final AuthService _authService = AuthService();

  String message = '';
  bool isLoading = false;

  void _login() async {
    setState(() {
      isLoading = true;
      message = '';
    });
    try {
      final result = await _authService.login(
        usernameController.text,
        passwordController.text,
      );

      int? parsedUserId;
      String msg = '';

      if (result is Map) {
        // try common shapes: {"id":..} or {"user": {"id":..}}
        if (result['id'] != null)
          parsedUserId = int.tryParse(result['id'].toString());
        if (parsedUserId == null &&
            result['user'] is Map &&
            result['user']['id'] != null) {
          parsedUserId = int.tryParse(result['user']['id'].toString());
        }
        if (result['message'] != null) msg = result['message'].toString();
        if (msg.isEmpty && result['status'] != null)
          msg = result['status'].toString();
        if (msg.isEmpty) msg = result.toString();
      } else {
        msg = result.toString();
      }

      final success =
          msg.toLowerCase().contains('success') || parsedUserId != null;
      if (success) {
        // set userId on wishlist controller so wishlist operations are tied to account
        if (parsedUserId == null) {
          // try fetching profile from backend (some backends expose /me)
          try {
            final profile = await _authService.fetchCurrentUser();
            if (profile is Map && profile['id'] != null) {
              parsedUserId = int.tryParse(profile['id'].toString());
            }
          } catch (e) {}
        }

        if (parsedUserId != null) {
          // persist userId for later auto-load
          try {
            final prefs = await SharedPreferences.getInstance();
            await prefs.setInt('userId', parsedUserId);
          } catch (e) {}
          ref.read(favouriteMoviesProvider.notifier).setUserId(parsedUserId);
          // also tell profile controller to fetch username from backend
          ref.read(profileProvider.notifier).setUserId(parsedUserId);
        }
        Navigator.of(context).pushReplacementNamed('home');
      } else {
        setState(() => message = msg);
      }
    } catch (e) {
      setState(() => message = e.toString());
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  void _toRegister() {
    Navigator.of(context).pushReplacementNamed('register');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: null,
      body: Column(
        children: [
          Container(
            color: Colors.blue,
            padding: EdgeInsets.symmetric(vertical: 30),
            width: double.infinity,
            child: Center(
              child: Text(
                'Form Đăng Nhập',
                style: TextStyle(color: Colors.white, fontSize: 28),
              ),
            ),
          ),
          Expanded(
            child: Center(
              child: Card(
                margin: EdgeInsets.all(24),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(24.0),
                  child: ListView(
                    shrinkWrap: true,
                    children: [
                      TextField(
                        controller: usernameController,
                        decoration: InputDecoration(
                          labelText: 'Tên đăng nhập',
                          border: OutlineInputBorder(),
                        ),
                      ),
                      SizedBox(height: 16),
                      TextField(
                        controller: passwordController,
                        obscureText: true,
                        decoration: InputDecoration(
                          labelText: 'Mật khẩu',
                          border: OutlineInputBorder(),
                        ),
                      ),
                      SizedBox(height: 15),
                      ElevatedButton(
                        onPressed: isLoading ? null : _login,
                        style: ElevatedButton.styleFrom(
                          minimumSize: Size(double.infinity, 48),
                          backgroundColor: Colors.purple[100],
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(22),
                          ),
                        ),
                        child: isLoading
                            ? CircularProgressIndicator()
                            : Text(
                                'Đăng Nhập',
                                style: TextStyle(color: Colors.blue),
                              ),
                      ),
                      SizedBox(height: 8),
                      // Nút chuyển qua đăng ký
                      Center(
                        child: TextButton(
                          onPressed: isLoading ? null : _toRegister,
                          child: Text("Chưa có tài khoản? Đăng ký"),
                        ),
                      ),

                      if (message.isNotEmpty) ...[
                        SizedBox(height: 12),
                        Text(
                          message,
                          style: TextStyle(color: Colors.red),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
