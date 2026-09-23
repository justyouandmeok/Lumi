import 'package:flutter/material.dart';

import '../state/scope.dart';
import '../theme.dart';
import 'signup_page.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final email = TextEditingController();
  final password = TextEditingController();

  @override
  void dispose() {
    email.dispose();
    password.dispose();
    super.dispose();
  }

  bool get _ok => email.text.trim().isNotEmpty && password.text.isNotEmpty;

  @override
  Widget build(BuildContext context) {
    final store = AppStateScope.of(context);
    return Scaffold(
      backgroundColor: NexoColors.background,
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 360),
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text(
                    'Lumi',
                    style: TextStyle(
                      fontSize: 36,
                      fontWeight: FontWeight.w700,
                      letterSpacing: -0.8,
                    ),
                  ),
                  const SizedBox(height: 28),
                  TextField(
                    controller: email,
                    onChanged: (_) => setState(() {}),
                    decoration: const InputDecoration(
                      hintText: 'Email o usuario',
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 10),
                  TextField(
                    controller: password,
                    obscureText: true,
                    onChanged: (_) => setState(() {}),
                    decoration: const InputDecoration(
                      hintText: 'Contraseña',
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 16),
                  SizedBox(
                    width: double.infinity,
                    height: 42,
                    child: FilledButton(
                      onPressed: _ok ? () => store.logIn() : null,
                      style: FilledButton.styleFrom(
                        backgroundColor: const Color(0xFF0095F6),
                      ),
                      child: const Text('Entrar'),
                    ),
                  ),
                  const SizedBox(height: 18),
                  TextButton(
                    onPressed: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(builder: (_) => const SignupPage()),
                      );
                    },
                    child: const Text('¿No tenés cuenta? Registrate'),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
