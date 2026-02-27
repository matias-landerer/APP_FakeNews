import 'dart:convert';
import 'parametros.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final userController = TextEditingController();
  final emailController = TextEditingController();
  final passController = TextEditingController();
  final pass2Controller = TextEditingController();

  String error = "";
  bool loading = false;

  int userid = 0;

  Future<void> register() async {
    setState(() {
      loading = true;
      error = "";
    });

    final response = await http.post(
      Uri.parse("$API_BASE_URL/register"),
      headers: {"Content-Type": "application/json"},
      body: jsonEncode({
        "username": userController.text,
        "email": emailController.text,
        "password": passController.text,
        "pass2": pass2Controller.text,
      }),
    );

    final data = jsonDecode(response.body);

    setState(() {
      loading = false;
    });

    if (data["status"] == "RegistroExitoso") {
      userid = data["user_id"];
      Navigator.pushReplacementNamed(context, "/home", arguments: userid);
    } else {
      setState(() {
        error = data["status"];
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    const secondary = Color(0xFFEF342A);

    return Scaffold(
      appBar: AppBar(),
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 520),
              child: Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.86),
                  borderRadius: BorderRadius.circular(24),
                  border: Border.all(color: Colors.white),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.08),
                      blurRadius: 20,
                      offset: const Offset(0, 8),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const Icon(
                      Icons.person_add_alt_1_rounded,
                      size: 34,
                      color: secondary,
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      "Crear cuenta",
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.w800,
                        color: Color(0xFF1D1D1B),
                      ),
                    ),
                    const SizedBox(height: 20),
                    TextField(
                      controller: userController,
                      decoration: const InputDecoration(labelText: "Usuario"),
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: emailController,
                      decoration: const InputDecoration(labelText: "Email"),
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: passController,
                      decoration: const InputDecoration(
                        labelText: "Contraseña",
                      ),
                      obscureText: true,
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: pass2Controller,
                      decoration: const InputDecoration(
                        labelText: "Confirme Contraseña",
                      ),
                      obscureText: true,
                    ),
                    const SizedBox(height: 20),
                    if (loading)
                      const Center(
                        child: CircularProgressIndicator(color: secondary),
                      ),
                    if (!loading)
                      ElevatedButton(
                        onPressed: register,
                        child: const Text("Registrarse"),
                      ),
                      const SizedBox(height: 8),
                      TextButton(
                        onPressed: () {
                          Navigator.pushReplacementNamed(context, "/login");
                        },
                        child: const Text("Ya tengo una cuenta"),
                      ),
                    if (error.isNotEmpty) ...[
                      const SizedBox(height: 10),
                      Text(
                        error,
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          color: secondary,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
