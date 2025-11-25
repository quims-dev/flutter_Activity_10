import 'package:firebase_notes/auth_service.dart';
import 'package:firebase_notes/login_page.dart';
import 'package:flutter/material.dart';

class RegisterPage extends StatefulWidget {
  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final AuthService auth = AuthService();
  final TextEditingController emailCtrl = TextEditingController();
  final TextEditingController passwordCtrl = TextEditingController();
  bool loading = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Register")),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              TextField(
                controller: emailCtrl,
                decoration: const InputDecoration(
                  labelText: "Email",
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: passwordCtrl,
                obscureText: true,
                decoration: const InputDecoration(
                  labelText: "Password",
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 12),

              ElevatedButton(
                child: loading
                    ? const CircularProgressIndicator(color: Colors.white)
                    : const Text("Register"),
                onPressed: () async {
                  if (emailCtrl.text.isEmpty || passwordCtrl.text.isEmpty) return;

                  setState(() => loading = true);

                  final user = await auth.registerWithEmail(
                    emailCtrl.text.trim(),
                    passwordCtrl.text.trim(),
                  );

                  setState(() => loading = false);

                  if (user != null) {
                    await user.sendEmailVerification();

                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                          content:
                              Text("Verification email sent! Check your inbox.")),
                    );

                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(builder: (_) => LoginPage()),
                    );
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text("Registration failed")),
                    );
                  }
                },
              ),

              const SizedBox(height: 12),

              TextButton(
                child: const Text("Already have an account? Login"),
                onPressed: () {
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(builder: (_) => LoginPage()),
                  );
                },
              )
            ],
          ),
        ),
      ),
    );
  }
}
