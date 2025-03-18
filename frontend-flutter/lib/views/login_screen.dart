import 'package:app_chat_nullo/apis/services/auth_service.dart';
import 'package:app_chat_nullo/providers/user_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class LoginScreen extends StatefulWidget {
  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final AuthService authService = AuthService();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final FlutterSecureStorage secureStorage = FlutterSecureStorage();
  bool isLoading = false;

  Future<void> _login(BuildContext context) async {
    if (isLoading) return; // Prevent multiple calls

    setState(() => isLoading = true);

    try {
      final response = await authService.login(
        emailController.text.trim(),
        passwordController.text.trim(),
      );

      if (response == null || response["error"] != null) {
        String errorMessage = response?["error"]?["message"] ?? "Login failed!";
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(errorMessage)));
      } else {
        // Load user data using provider without forcing rebuild
        await context.read<UserProvider>().loadUserData();
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Login successful!")));
        Navigator.pushReplacementNamed(context, '/home');
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Something went wrong. Try again.")));
      print("Login error: $e");
    } finally {
      if (mounted) setState(() => isLoading = false); // Prevent updating unmounted widgets
    }
  }

  @override
  Widget build(BuildContext context) {
    print("Building LoginScreen"); // Debugging: check excessive re-renders

    return Scaffold(
      backgroundColor: Colors.blueGrey[50],
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Icon(Icons.lock_outline, size: 80, color: Colors.blueGrey),
              SizedBox(height: 20),
              Text("Welcome Back!", style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
              SizedBox(height: 20),
              TextField(
                controller: emailController,
                decoration: InputDecoration(
                  labelText: "Email",
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.email),
                ),
              ),
              SizedBox(height: 15),
              TextField(
                controller: passwordController,
                obscureText: true,
                decoration: InputDecoration(
                  labelText: "Password",
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.lock),
                ),
              ),
              SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: isLoading ? null : () => _login(context),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blueGrey,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  child: isLoading
                      ? CircularProgressIndicator(color: Colors.white)
                      : Text("Login", style: TextStyle(fontSize: 18, color: Colors.white)),
                ),
              ),
              SizedBox(height: 15),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text("Don't have an account? "),
                  TextButton(
                    onPressed: () => Navigator.pushNamed(context, '/register'),
                    child: Text("Sign Up"),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
