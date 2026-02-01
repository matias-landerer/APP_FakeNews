import 'dart:convert';
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

  Future<void> register() async {
    setState(() {
      loading = true;
      error = "";
    });

    final response = await http.post(
      Uri.parse("http://10.0.2.2:5000/register"),
      headers: {"Content-Type": "application/json"},
      body: jsonEncode({
        "username": userController.text,
        "email": emailController.text,
        "password": passController.text,
      }),
    );

    final data = jsonDecode(response.body);

    setState(() {
      loading = false;
    });

    if (data["status"] == "RegistroExitoso") {
      // Login exitoso → ir a Home
      Navigator.pushReplacementNamed(context, "/home");
    }
    
    else {
      setState(() {
        error = data["status"];
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Iniciar sesión")),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            TextField(
              controller: userController,
              decoration: const InputDecoration(labelText: "Usuario"),
            ),
            TextField(
              controller: emailController,
              decoration: const InputDecoration(labelText: "Email"),
            ),
            TextField(
              controller: passController,
              decoration: const InputDecoration(labelText: "Contraseña"),
              obscureText: true,
            ),
            TextField(
              controller: pass2Controller,
              decoration: const InputDecoration(labelText: "Confirme Contraseña"),
              obscureText: true,
            ),
            const SizedBox(height: 20),
            if (loading) const CircularProgressIndicator(),
            if (!loading)
              ElevatedButton(
                onPressed: register,
                child: const Text("Entrar"),
              ),
            const SizedBox(height: 10),
            Text(error, style: const TextStyle(color: Colors.red)),
          ],
        ),
      ),
    );
  }
}
