import 'package:flutter/material.dart';
import '../services/auth_service.dart';

class RegisterPage extends StatefulWidget {
  const RegisterPage({Key? key}) : super(key: key);

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final usernameController = TextEditingController();
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  final confirmPasswordController = TextEditingController();
  final AuthService _authService = AuthService();

  String message = '';
  bool passwordVisible = false;
  bool confirmPasswordVisible = false;
  bool isLoading = false;

  void _signup() async {
    if (passwordController.text != confirmPasswordController.text) {
      setState(() {
        message = "Mật khẩu xác nhận không khớp!";
      });
      return;
    }

    setState(() {
      isLoading = true;
      message = '';
    });

    try {
      String msg = await _authService.signup(
        usernameController.text,
        emailController.text,
        passwordController.text,
      );
      if (msg.toLowerCase().contains('success')) {
        // Đăng ký thành công, chuyển về LoginPage
        Navigator.of(context).pushReplacementNamed('login');
      } else {
        setState(() => message = msg);
      }
    } catch (e) {
      setState(() => message = e.toString());
    } finally {
      setState(() => isLoading = false);
    }
  }

  void _toLogin() {
    Navigator.of(context).pushReplacementNamed('login');
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
                'Form Đăng Kí tài khoản',
                style: TextStyle(color: Colors.white, fontSize: 28),
              ),
            ),
          ),
          Expanded(
            child: Center(
              child: Card(
                elevation: 2,
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
                          hintText: 'Vui lòng nhập tên đăng nhập',
                          border: OutlineInputBorder(),
                        ),
                      ),
                      SizedBox(height: 12),
                      TextField(
                        controller: emailController,
                        decoration: InputDecoration(
                          labelText: 'Email',
                          hintText: 'Vui lòng nhập email',
                          border: OutlineInputBorder(),
                        ),
                      ),
                      SizedBox(height: 12),
                      TextField(
                        controller: passwordController,
                        obscureText: !passwordVisible,
                        decoration: InputDecoration(
                          labelText: 'Mật khẩu',
                          hintText: 'Vui lòng nhập mật khẩu',
                          border: OutlineInputBorder(),
                          suffixIcon: IconButton(
                            icon: Icon(
                              passwordVisible
                                  ? Icons.visibility
                                  : Icons.visibility_off,
                            ),
                            onPressed: () => setState(
                              () => passwordVisible = !passwordVisible,
                            ),
                          ),
                        ),
                      ),
                      SizedBox(height: 12),
                      TextField(
                        controller: confirmPasswordController,
                        obscureText: !confirmPasswordVisible,
                        decoration: InputDecoration(
                          labelText: 'Xác nhận mật khẩu',
                          hintText: 'Vui lòng xác nhận mật khẩu',
                          border: OutlineInputBorder(),
                          suffixIcon: IconButton(
                            icon: Icon(
                              confirmPasswordVisible
                                  ? Icons.visibility
                                  : Icons.visibility_off,
                            ),
                            onPressed: () => setState(
                              () => confirmPasswordVisible =
                                  !confirmPasswordVisible,
                            ),
                          ),
                        ),
                      ),
                      SizedBox(height: 15),
                      ElevatedButton(
                        onPressed: isLoading ? null : _signup,
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
                                'Đăng Kí',
                                style: TextStyle(color: Colors.blue),
                              ),
                      ),
                      SizedBox(height: 8),
                      // Nút chuyển về Login
                      Center(
                        child: TextButton(
                          onPressed: isLoading ? null : _toLogin,
                          child: Text("Đã có tài khoản? Đăng nhập"),
                        ),
                      ),
                      if (message.isNotEmpty) ...[
                        SizedBox(height: 12),
                        Text(message, style: TextStyle(color: Colors.red)),
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
