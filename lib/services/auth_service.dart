import 'dart:convert';
import 'package:get_it/get_it.dart';

import '../models/app_config.dart';
import 'package:http/http.dart' as http;

class AuthService {
  final GetIt getIt = GetIt.instance;
  String? _be_url;

  AuthService() {
    AppConfig config = getIt<AppConfig>();
    _be_url = config.BE_URL;
  }

  Future<String> signup(String username, String email, String password) async {
    final url = Uri.parse('$_be_url/auth/signup');
    final response = await http.post(
      url,
      body: {'username': username, 'email': email, 'password': password},
    );
    if (response.statusCode == 200) {
      return response.body;
    } else {
      throw Exception('Đăng ký thất bại: ${response.body}');
    }
  }

  Future<dynamic> login(String username, String password) async {
    final url = Uri.parse('$_be_url/auth/login');
    final response = await http.post(
      url,
      body: {'username': username, 'password': password},
    );

    if (response.statusCode == 200) {
      final body = response.body;
      try {
        return json.decode(body);
      } catch (_) {
        return body;
      }
    } else {
      throw Exception('Login failed: ${response.body}');
    }
  }

  Future<dynamic> fetchCurrentUser() async {
    final url = Uri.parse('$_be_url/auth/me');
    try {
      final response = await http.get(url);
      if (response.statusCode == 200) {
        try {
          return json.decode(response.body);
        } catch (_) {
          return response.body;
        }
      }
    } catch (_) {}
    return null;
  }

  Future<void> addToWishlist(int userId, String filmId) async {
    final res = await http.post(
      Uri.parse('$_be_url/wishlist/add'),
      body: {'userId': userId.toString(), 'filmId': filmId},
    );
    if (res.statusCode != 200) {
      throw Exception('Add to wishlist failed: ${res.body}');
    }
  }

  Future<void> removeFromWishlist(int userId, String filmId) async {
    final res = await http.post(
      Uri.parse('$_be_url/wishlist/remove'),
      body: {'userId': userId.toString(), 'filmId': filmId},
    );
    if (res.statusCode != 200) {
      throw Exception('Remove from wishlist failed: ${res.body}');
    }
  }

  Future<List<String>> fetchWishlist(int userId) async {
    final res = await http.get(Uri.parse('$_be_url/wishlist/user/$userId'));
    if (res.statusCode == 200) {
      List<dynamic> rawList = json.decode(res.body);
      return rawList.map((e) => e.toString()).toList();
    } else {
      throw Exception('Failed to fetch wishlist: ${res.statusCode}');
    }
  }

  Future<String> usernameById(int userId) async {
    final uri = Uri.parse('$_be_url/auth/username/$userId');
    try {
      print('AuthService.usernameById: requesting $uri');
      final res = await http.get(uri);
      print(
        'AuthService.usernameById: status=${res.statusCode} body=${res.body}',
      );
      if (res.statusCode == 200) {
        final body = res.body;
        try {
          final decoded = json.decode(body);
          if (decoded is Map && decoded.containsKey('username'))
            return decoded['username'];
        } catch (_) {
          // not JSON, fallthrough to return raw body
        }
        return body;
      } else {
        throw Exception('Fetch username failed: ${res.statusCode} ${res.body}');
      }
    } catch (e) {
      print('AuthService.usernameById: error -> $e');
      rethrow;
    }
  }
}
