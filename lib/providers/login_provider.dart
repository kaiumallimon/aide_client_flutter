import 'dart:convert';

import 'package:aide_client/views/pages/admin_wrapper.dart';
import 'package:aide_client/views/pages/user_wrapper.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'package:supabase_flutter/supabase_flutter.dart';

class LoginProvider extends ChangeNotifier {
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  bool _isLoading = false;

  bool get isLoading => _isLoading;

  set isLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }

  void clearFields() {
    emailController.clear();
    passwordController.clear();
  }

  Future<void> login(BuildContext context) async {
    try {
      SharedPreferences preferences = await SharedPreferences.getInstance();

      String email = emailController.text.trim();
      String password = passwordController.text.trim();

      if (email.isEmpty || password.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Please fill in all fields"),
            backgroundColor: Colors.red,
          ),
        );
        return;
      }

      isLoading = true;
      notifyListeners();

      final response = await http.post(
        Uri.parse("http://127.0.0.1:5000/api/auth/login/"),
        body: {"email": email, "password": password},
      );

      isLoading = false;
      notifyListeners();

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = Map<String, dynamic>.from(
          jsonDecode(response.body),
        );

        // Navigate through nested "user" keys
        final tokens = data['tokens'];
        final accessToken = tokens['access_token'];
        final refreshToken = tokens['refresh_token'];

        // Save tokens using SharedPreferences
        await preferences.setString('access_token', accessToken);
        await preferences.setString('refresh_token', refreshToken);
        notifyListeners();

        clearFields();

        final userId = data['user']['id'];

        final profileResponse =
            await Supabase.instance.client
                .from('profiles')
                .select('full_name, role')
                .eq('id', userId)
                .maybeSingle();

        if (profileResponse != null) {
          // store user profile data in shared preferences
          await preferences.setString('name', profileResponse['full_name']);
          await preferences.setString('user_id', userId);
          await preferences.setString('role', profileResponse['role']);

          notifyListeners();

          if (profileResponse['role'] == 'admin') {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) => AdminWrapperPage()),
            );
          } else {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) => UserWrapper()),
            );
          }
        }
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("Login failed: ${response.body}"),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      isLoading = false;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error: $e"), backgroundColor: Colors.red),
      );
    }
  }
}
