import 'package:flutter/material.dart';

import '../state/scope.dart';
import '../theme.dart';

class SignupPage extends StatefulWidget {
  const SignupPage({super.key});

  @override
  State<SignupPage> createState() => _SignupPageState();
}

class _SignupPageState extends State<SignupPage> {
  final username = TextEditingController();
  final name = TextEditingController();
  final email = TextEditingController();
  final password = TextEditingController();

  @override
  void dispose() {
    username.dispose();
    name.dispose();
    email.dispose();
    password.dispose();
    super.dispose();
  }

  bool get _ok =>
      username.text.trim().isNotEmpty &&
      name.text.trim().isNotEmpty &&
      email.text.trim().isNotEmpty &&
      password.text.isNotEmpty;

  @override
  Widget build(BuildContext context) {
    final store = AppStateScope.of(context);
    return Scaffold(
      backgroundColor: NexoColors.background,
      appBar: AppBar(title: const Text('Crear cuenta')),
      body: ListView(
        padding: const EdgeInsets.all(24),
        children: [
          const Text(
            'Lumi',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 32, fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 24),
          TextField(
            controller: username,
            onChanged: (_) => setState(() {}),
            decoration: const InputDecoration(
              hintText: 'Usuario',
              border: OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 10),
          TextField(
            controller: name,
            onChanged: (_) => setState(() {}),
            decoration: const InputDecoration(
              hintText: 'Nombre visible',
              border: OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 10),
          TextField(
            controller: email,
            onChanged: (_) => setState(() {}),
            decoration: const InputDecoration(
              hintText: 'Email',
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
            height: 42,
            child: FilledButton(
              onPressed: _ok
                  ? () async {
                      await store.signUp(
                        username: username.text,
                        displayName: name.text,
                        bio: '',
                      );
                      if (context.mounted) Navigator.of(context).pop();
                    }
                  : null,
              style: FilledButton.styleFrom(
                backgroundColor: const Color(0xFF0095F6),
              ),
              child: const Text('Registrarte'),
            ),
          ),
        ],
      ),
    );
  }
}
