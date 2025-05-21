import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class AuthService {
  static const String _baseUrl = 'http://localhost:5000';
  static String? _token;
  static String? _userId;

  // Initialize auth data from SharedPreferences
  static Future<void> init() async {
    final prefs = await SharedPreferences.getInstance();
    _token = prefs.getString('token');
    _userId = prefs.getString('userId');
  }

  // Get current token
  static String? get token => _token;

  // Get current user ID
  static String? get userId => _userId;

  // Check if user is logged in
  static bool get isLoggedIn => _token != null && _userId != null;

  // Get headers with authentication
  static Map<String, String> get headers => {
        'Content-Type': 'application/json',
        if (_token != null) 'Authorization': 'Bearer $_token',
      };

  // Make authenticated GET request
  static Future<http.Response> get(String endpoint) async {
    if (!isLoggedIn) {
      throw Exception('User not authenticated');
    }
    return http.get(
      Uri.parse('$_baseUrl$endpoint'),
      headers: headers,
    );
  }

  // Make authenticated POST request
  static Future<http.Response> post(String endpoint, {required Map<String, dynamic> body}) async {
    if (!isLoggedIn) {
      throw Exception('User not authenticated');
    }
    return http.post(
      Uri.parse('$_baseUrl$endpoint'),
      headers: headers,
      body: json.encode(body),
    );
  }

  // Make authenticated PUT request
  static Future<http.Response> put(String endpoint, {required Map<String, dynamic> body}) async {
    if (!isLoggedIn) {
      throw Exception('User not authenticated');
    }
    return http.put(
      Uri.parse('$_baseUrl$endpoint'),
      headers: headers,
      body: json.encode(body),
    );
  }

  // Clear auth data
  static Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('token');
    await prefs.remove('userId');
    await prefs.remove('username');
    await prefs.remove('email');
    _token = null;
    _userId = null;
  }
} 