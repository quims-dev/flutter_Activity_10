import 'package:firebase_notes/auth_service.dart';
import 'package:firebase_notes/home_page.dart';
import 'package:firebase_notes/register_page.dart';
import 'package:flutter/material.dart';

class LoginPage extends StatefulWidget {
  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final AuthService auth = AuthService();
  final TextEditingController emailCtrl = TextEditingController();
  final TextEditingController passwordCtrl = TextEditingController();
  bool loading = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
  title: const Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Text("Login"),
      Text("QUIMBO"),
    ],
  ),
),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: emailCtrl,
                decoration: InputDecoration(
                    labelText: "Email", border: OutlineInputBorder()),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: passwordCtrl,
                obscureText: true,
                decoration: InputDecoration(
                    labelText: "Password", border: OutlineInputBorder()),
              ),
              Align(
                alignment: Alignment.centerRight,
                child: TextButton(
                  child: const Text("Forgot Password?"),
                  onPressed: () {
                    showDialog(
                      context: context,
                      builder: (_) {
                        final resetCtrl = TextEditingController();
                        return AlertDialog(
                          title: const Text("Reset Password"),
                          content: TextField(
                            controller: resetCtrl,
                            decoration: const InputDecoration(
                              labelText: "Enter email",
                              border: OutlineInputBorder(),
                            ),
                          ),
                          actions: [
                            TextButton(
                                onPressed: () => Navigator.pop(context),
                                child: const Text("Cancel")),
                            ElevatedButton(
                              onPressed: () async {
                                if (resetCtrl.text.isEmpty) return;

                                final ok = await auth.resetPassword(resetCtrl.text);

                                Navigator.pop(context);

                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text(ok
                                        ? "Reset email sent."
                                        : "Error sending reset link."),
                                  ),
                                );
                              },
                              child: const Text("Send"),
                            )
                          ],
                        );
                      },
                    );
                  },
                ),
              ),

              const SizedBox(height: 10),

              ElevatedButton(
                child: loading
                    ? const CircularProgressIndicator(color: Colors.white)
                    : const Text("Login with Email"),
                onPressed: () async {
                  setState(() => loading = true);

                  final user = await auth.signInWithEmail(
                    emailCtrl.text.trim(),
                    passwordCtrl.text.trim(),
                  );

                  setState(() => loading = false);

                  if (user != null) {
                    if (!user.emailVerified) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text("Please verify your email first."),
                        ),
                      );
                    } else {
                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(builder: (_) => const HomePage()),
                      );
                    }
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text("Invalid email or password")),
                    );
                  }
                },
              ),

              const SizedBox(height: 24),
              Row(
                children: const [
                  Expanded(child: Divider()),
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 8),
                    child: Text("OR"),
                  ),
                  Expanded(child: Divider()),
                ],
              ),

              const SizedBox(height: 24),

              ElevatedButton.icon(
                icon: const Icon(Icons.login),
                label: const Text("Sign in with Google"),
                onPressed: () async {
                  setState(() => loading = true);
                  final user = await auth.signInWithGoogle();
                  setState(() => loading = false);

                  if (user != null) {
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(builder: (_) => const HomePage()),
                    );
                  }
                },
              ),

              const SizedBox(height: 12),

              TextButton(
                child: const Text("Don't have an account? Register"),
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => RegisterPage()),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
