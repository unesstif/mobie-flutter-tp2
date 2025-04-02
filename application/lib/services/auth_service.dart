import 'dart:convert';
import 'dart:async';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../config/api_config.dart';

class AuthService {
  static const String _tokenKey = 'auth_token';
  static const String _userEmailKey = 'user_email';
  static const Duration _timeoutDuration = Duration(seconds: 10);

  Future<bool> login(String email, String password) async {
    try {
      print('Attempting to login with email: $email');
      print('API URL: ${ApiConfig.baseUrl}/auth/login');

      final response = await http
          .post(
        Uri.parse('${ApiConfig.baseUrl}/auth/login'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'email': email,
          'password': password,
        }),
      )
          .timeout(_timeoutDuration, onTimeout: () {
        print('Login request timed out');
        throw TimeoutException('Login request timed out');
      });

      print('Login response status: ${response.statusCode}');
      print('Login response body: ${response.body}');

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final token = data['token'];

        if (token == null) {
          print('No token received in response');
          return false;
        }

        // Store token and user email
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString(_tokenKey, token);
        await prefs.setString(_userEmailKey, email);

        print('Login successful, token stored');
        return true;
      } else if (response.statusCode == 401) {
        print('Invalid credentials');
        return false;
      } else {
        print('Login failed with status: ${response.statusCode}');
        print('Response body: ${response.body}');
        return false;
      }
    } on TimeoutException {
      print('Login request timed out');
      return false;
    } on http.ClientException catch (e) {
      print('Network error occurred: $e');
      return false;
    } catch (e) {
      print('Login error: $e');
      return false;
    }
  }

  Future<String?> getToken() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString(_tokenKey);
      print('Retrieved token: ${token != null ? 'exists' : 'null'}');
      return token;
    } catch (e) {
      print('Error getting token: $e');
      return null;
    }
  }

  Future<String?> getUserEmail() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return prefs.getString(_userEmailKey);
    } catch (e) {
      print('Error getting user email: $e');
      return null;
    }
  }

  Future<void> logout() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_tokenKey);
      await prefs.remove(_userEmailKey);
      print('Logout successful');
    } catch (e) {
      print('Error during logout: $e');
    }
  }
}
