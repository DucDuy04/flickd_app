//packages
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
//services
import '../services/auth_service.dart';
//controllers
import '../controllers/wishlist_controller.dart';
import '../controllers/profile_controller.dart';

class AuthPage extends ConsumerStatefulWidget {
  // StatefulWidget: cần quản lý form, loading, error
  // Consumer: cho phép đọc, ghi Riverpod providers
  const AuthPage({Key? key}) : super(key: key);

  @override
  ConsumerState<AuthPage> createState() => _AuthPageState();
}

class _AuthPageState extends ConsumerState<AuthPage> {
  // 0 = Login, 1 = Register
  int _currentTab = 0;

  // Controllers
  final _usernameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  final AuthService _authService = AuthService();

  String _message = '';
  bool _isLoading = false;
  bool _passwordVisible = false;

  String _usernameError = '';
  String _emailError = '';
  String _passwordError = '';
  String _confirmPasswordError = '';

  @override
  void dispose() {
    _usernameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  void _switchTab(int tab) {
    setState(() {
      _currentTab = tab;
      _message = '';
      _usernameError = '';
      _emailError = '';
      _passwordError = '';
      _confirmPasswordError = '';
      //Xóa tất cả field khi chuyển tab
      _usernameController.clear();
      _emailController.clear();
      _passwordController.clear();
      _confirmPasswordController.clear();
    });
  }

  // ----------------LOGIN------------------
  Future<void> _login() async {
    //Xóa lỗi cũ
    setState(() {
      _usernameError = '';
      _passwordError = '';
      _message = '';
    });

    //Kiểm tra trường trống
    if (_usernameController.text.trim().isEmpty ||
        _passwordController.text.trim().isEmpty) {
      setState(() {
        if (_usernameController.text.trim().isEmpty) {
          _usernameError = 'Vui lòng nhập tên người dùng';
        }
        if (_passwordController.text.trim().isEmpty) {
          _passwordError = 'Vui lòng nhập mật khẩu';
        }
      });
      return;
    }

    setState(() {
      _isLoading = true;
      _message = '';
    });

    try {
      //Gọi hàm login từ AuthService
      final result = await _authService.login(
        _usernameController.text,
        _passwordController.text,
      );

      int? parsedUserId;
      String msg = '';

      if (result is Map) {
        if (result['id'] != null) {
          parsedUserId = int.tryParse(result['id'].toString());
        }
        if (parsedUserId == null &&
            result['user'] is Map &&
            result['user']['id'] != null) {
          parsedUserId = int.tryParse(result['user']['id'].toString());
        }
        if (result['message'] != null) msg = result['message'].toString();
        if (msg.isEmpty && result['status'] != null) {
          msg = result['status'].toString();
        }
        if (msg.isEmpty) msg = result.toString();
      } else {
        msg = result.toString();
      }

      final success =
          msg.toLowerCase().contains('success') ||
          msg.toLowerCase().contains('thành công') ||
          parsedUserId != null;

      if (success) {
        // if (parsedUserId == null) {
        //   try {
        //     final profile = await _authService.fetchCurrentUser();
        //     if (profile is Map && profile['id'] != null) {
        //       parsedUserId = int.tryParse(profile['id'].toString());
        //     }
        //   } catch (_) {}
        // }

        if (parsedUserId != null) {
          try {
            final prefs = await SharedPreferences.getInstance();
            await prefs.setInt('userId', parsedUserId);
          } catch (_) {}
          ref.read(favouriteMoviesProvider.notifier).setUserId(parsedUserId);
          ref.read(profileProvider.notifier).setUserId(parsedUserId);
        }

        if (mounted) {
          Navigator.of(context).pushReplacementNamed('home');
        }
      } else {
        setState(() {
          _message = msg;
        });
      }
    } catch (e) {
      String errorMsg = 'Sai tên username hoặc mật khẩu';
      setState(() {
        _message = errorMsg;
      });
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  // ---------------REGISTER------------------
  Future<void> _register() async {
    //Xóa lỗi cũ
    setState(() {
      _usernameError = '';
      _emailError = '';
      _passwordError = '';
      _confirmPasswordError = '';
      _message = '';
    });

    // Kiểm tra trường trống
    bool hasEmpty = false;
    if (_usernameController.text.trim().isEmpty) {
      _usernameError = 'Vui lòng nhập tên người dùng';
      hasEmpty = true;
    }
    if (_emailController.text.trim().isEmpty) {
      _emailError = 'Vui lòng nhập email';
      hasEmpty = true;
    }
    if (_passwordController.text.trim().isEmpty) {
      _passwordError = 'Vui lòng nhập mật khẩu';
      hasEmpty = true;
    }
    if (_confirmPasswordController.text.trim().isEmpty) {
      _confirmPasswordError = 'Vui lòng xác nhận mật khẩu';
      hasEmpty = true;
    }
    if (hasEmpty) {
      setState(() {});
      return;
    }

    if (_usernameController.text.trim().length < 3) {
      setState(() {
        _usernameError = 'Tên người dùng phải có ít nhất 3 ký tự';
      });
      return;
    }

    //validate username
    String? validateNoSpecialChar(String? value) {
      if (RegExp(r'[^a-zA-Z0-9]').hasMatch(value!)) {
        return 'Không được chứa ký tự đặc biệt';
      }
      return null;
    }

    final usernameError = validateNoSpecialChar(
      _usernameController.text.trim(),
    );
    if (usernameError != null) {
      setState(() {
        _usernameError = usernameError;
      });
      return;
    }

    // Validate email format
    final emailRegex = RegExp(
      r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$',
    );

    String? validateEmail(String? value) {
      if (value == null || value.trim().isEmpty) {
        return 'Email không được để trống';
      }

      if (!emailRegex.hasMatch(value.trim())) {
        return 'Email không hợp lệ';
      }

      return null;
    }

    final emailError = validateEmail(_emailController.text.trim());
    if (emailError != null) {
      setState(() {
        _emailError = emailError;
      });
      return;
    }

    // Validate mật khẩu
    if (_passwordController.text.length < 6) {
      setState(() {
        _passwordError = 'Mật khẩu phải có ít nhất 6 ký tự';
      });
      return;
    }

    if (_passwordController.text != _confirmPasswordController.text) {
      setState(() {
        _confirmPasswordError = 'Mật khẩu không khớp';
      });
      return;
    }

    setState(() {
      _isLoading = true;
      _message = '';
    });

    try {
      String msg = await _authService.signup(
        _usernameController.text,
        _emailController.text,
        _passwordController.text,
      );

      if (msg.toLowerCase().contains('success') ||
          msg.toLowerCase().contains('thành công')) {
        // Chuyển sang tab Login
        _switchTab(0);
        setState(() {
          _message = 'Đăng ký thành công! Vui lòng đăng nhập.';
        });
      } else {
        setState(() => _message = msg);
      }
    } catch (e) {
      String errorMsg = e.toString();
      setState(() => _message = errorMsg);
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Color(0xFF78350F), // amber-900
              Color(0xFF1E293B), // slate-800
              Color(0xFF1E3A8A), // blue-900
            ],
          ),
        ),
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Column(
              children: [
                const SizedBox(height: 40),
                _buildLogo(),
                const SizedBox(height: 32),
                _buildFormCard(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildLogo() {
    return Column(
      children: [
        Container(
          width: 80,
          height: 80,
          decoration: BoxDecoration(
            color: const Color(0xFFE85D04),
            borderRadius: BorderRadius.circular(16),
          ),
          child: const Icon(Icons.movie_filter, color: Colors.white, size: 48),
        ),
        const SizedBox(height: 16),
        const Text(
          'Flickd',
          style: TextStyle(
            color: Color(0xFFE85D04),
            fontSize: 32,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 8),
        const Text(
          'Save movies you want to watch later',
          style: TextStyle(color: Colors.white70, fontSize: 14),
        ),
      ],
    );
  }

  Widget _buildFormCard() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: const Color(0xFF3D3D5C),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildTabButtons(),
          const SizedBox(height: 24),
          //AnimatedSwitcher để chuyển đổi mượt giữa form Login và Register
          AnimatedSwitcher(
            duration: const Duration(milliseconds: 300),
            child: _currentTab == 0 ? _buildLoginForm() : _buildRegisterForm(),
          ),
        ],
      ),
    );
  }

  Widget _buildTabButtons() {
    return Container(
      height: 50,
      decoration: BoxDecoration(
        color: const Color(0xFF4A4A6A),
        borderRadius: BorderRadius.circular(25),
      ),
      child: Row(
        children: [_buildTabButton('Login', 0), _buildTabButton('Register', 1)],
      ),
    );
  }

  Widget _buildTabButton(String text, int index) {
    final isActive = _currentTab == index;
    return Expanded(
      child: GestureDetector(
        onTap: _isLoading ? null : () => _switchTab(index),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          decoration: BoxDecoration(
            color: isActive ? const Color(0xFFE85D04) : Colors.transparent,
            borderRadius: BorderRadius.circular(25),
          ),
          child: Center(
            child: Text(
              text,
              style: TextStyle(
                color: isActive ? Colors.white : Colors.white70,
                fontWeight: isActive ? FontWeight.bold : FontWeight.normal,
              ),
            ),
          ),
        ),
      ),
    );
  }

  // ------------------- LOGIN FORM -------------------
  Widget _buildLoginForm() {
    return Column(
      key: const ValueKey('login'),
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildTextField(
          label: 'Tên người dùng',
          hint: 'Nhập tên người dùng',
          controller: _usernameController,
          icon: Icons.person_outline,
          error: _usernameError,
          onChanged: (v) => setState(() => _usernameError = ''),
        ),
        const SizedBox(height: 16),
        _buildPasswordField(),
        const SizedBox(height: 8),
        Align(
          alignment: Alignment.centerRight,
          child: TextButton(
            onPressed: () {},
            child: const Text(
              'Quên mật khẩu?',
              style: TextStyle(color: Color(0xFFE85D04), fontSize: 12),
            ),
          ),
        ),
        const SizedBox(height: 16),
        _buildPrimaryButton('Login', _login),
        const SizedBox(height: 20),
        _buildMessage(),
      ],
    );
  }

  // ------------------- REGISTER FORM -------------------
  Widget _buildRegisterForm() {
    return Column(
      key: const ValueKey('register'),
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildTextField(
          label: 'Tên người dùng',
          hint: 'Nhập tên người dùng',
          controller: _usernameController,
          icon: Icons.person_outline,
          error: _usernameError,
          onChanged: (v) => setState(() => _usernameError = ''),
        ),
        const SizedBox(height: 16),
        _buildTextField(
          label: 'Email',
          hint: 'Nhập email',
          controller: _emailController,
          icon: Icons.email_outlined,
          error: _emailError,
          onChanged: (v) => setState(() => _emailError = ''),
        ),
        const SizedBox(height: 16),
        _buildPasswordField(),
        const SizedBox(height: 16),
        _buildConfirmPasswordField(),
        const SizedBox(height: 20),
        _buildPrimaryButton('Create Account', _register),
        const SizedBox(height: 5),
        _buildMessage(),
      ],
    );
  }

  Widget _buildTextField({
    required String label,
    required String hint,
    required TextEditingController controller,
    required IconData icon,
    String? error,
    ValueChanged<String>? onChanged,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(color: Colors.white, fontSize: 14)),
        const SizedBox(height: 8),
        TextField(
          controller: controller,
          onChanged: onChanged,
          style: const TextStyle(color: Colors.white),
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: const TextStyle(color: Colors.white38),
            prefixIcon: Icon(icon, color: Colors.white38),
            filled: true,
            fillColor: const Color(0xFF4A4A6A),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide.none,
            ),
          ),
        ),
        if (error != null && error.isNotEmpty) ...[
          const SizedBox(height: 6),
          Text(
            error,
            style: const TextStyle(color: Colors.redAccent, fontSize: 12),
          ),
        ],
      ],
    );
  }

  Widget _buildPasswordField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Mật khẩu',
          style: TextStyle(color: Colors.white, fontSize: 14),
        ),
        const SizedBox(height: 8),
        TextField(
          controller: _passwordController,
          obscureText: !_passwordVisible,
          onChanged: (v) => setState(() => _passwordError = ''),
          style: const TextStyle(color: Colors.white),
          decoration: InputDecoration(
            hintText: 'Nhập mật khẩu',
            hintStyle: const TextStyle(color: Colors.white38),
            prefixIcon: const Icon(Icons.lock_outline, color: Colors.white38),
            suffixIcon: IconButton(
              icon: Icon(
                _passwordVisible ? Icons.visibility : Icons.visibility_off,
                color: Colors.white38,
              ),
              onPressed: () =>
                  setState(() => _passwordVisible = !_passwordVisible),
            ),
            filled: true,
            fillColor: const Color(0xFF4A4A6A),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide.none,
            ),
          ),
        ),
        if (_passwordError.isNotEmpty) ...[
          const SizedBox(height: 6),
          Text(
            _passwordError,
            style: const TextStyle(color: Colors.redAccent, fontSize: 12),
          ),
        ],
      ],
    );
  }

  Widget _buildConfirmPasswordField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Xác nhận mật khẩu',
          style: TextStyle(color: Colors.white, fontSize: 14),
        ),
        const SizedBox(height: 8),
        TextField(
          controller: _confirmPasswordController,
          obscureText: !_passwordVisible,
          onChanged: (v) => setState(() => _confirmPasswordError = ''),
          style: const TextStyle(color: Colors.white),
          decoration: InputDecoration(
            hintText: 'Nhập lại mật khẩu',
            hintStyle: const TextStyle(color: Colors.white38),
            prefixIcon: const Icon(Icons.lock_outline, color: Colors.white38),
            filled: true,
            fillColor: const Color(0xFF4A4A6A),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide.none,
            ),
          ),
        ),
        if (_confirmPasswordError.isNotEmpty) ...[
          const SizedBox(height: 6),
          Text(
            _confirmPasswordError,
            style: const TextStyle(color: Colors.redAccent, fontSize: 12),
          ),
        ],
      ],
    );
  }

  Widget _buildPrimaryButton(String text, VoidCallback onPressed) {
    return SizedBox(
      width: double.infinity,
      height: 50,
      child: ElevatedButton(
        onPressed: _isLoading ? null : onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFFE85D04),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(25),
          ),
        ),
        child: _isLoading
            ? const CircularProgressIndicator(color: Colors.white)
            : Text(
                text,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
      ),
    );
  }

  Widget _buildMessage() {
    if (_message.isEmpty) return const SizedBox.shrink();

    final isSuccess =
        _message.toLowerCase().contains('success') ||
        _message.toLowerCase().contains('thành công');
    return Padding(
      padding: const EdgeInsets.only(top: 16),
      child: Text(
        _message,
        style: TextStyle(
          color: isSuccess ? Colors.greenAccent : Colors.redAccent,
        ),
        textAlign: TextAlign.center,
      ),
    );
  }
}
