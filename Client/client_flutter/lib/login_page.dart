import 'dart:convert';
import 'parametros.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final userController = TextEditingController();
  final passController = TextEditingController();

  String error = "";
  bool loading = false;

  int userid = 0;

  Future<void> login() async {
    setState(() {
      loading = true;
      error = "";
    });

    final response = await http.post(
      Uri.parse("$API_BASE_URL/login"),
      headers: {"Content-Type": "application/json"},
      body: jsonEncode({
        "username": userController.text,
        "password": passController.text,
      }),
    );

    final data = jsonDecode(response.body);

    setState(() {
      loading = false;
    });

    if (data["status"] == "InicioExitoso") {
      // Login exitoso → ir a Home
      userid = data["user_id"];
      Navigator.pushNamed(context, "/home", arguments: userid);
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
              controller: passController,
              decoration: const InputDecoration(labelText: "Contraseña"),
              obscureText: true,
            ),
            const SizedBox(height: 20),
            if (loading) const CircularProgressIndicator(),
            if (!loading)
              ElevatedButton(
                onPressed: login,
                child: const Text("Entrar"),
              ),
            
            TextButton(
              onPressed: () {
                Navigator.pushNamed(context, "/register");
              },
              child: const Text("Crear cuenta"),
            ),
            
            const SizedBox(height: 10),
            Text(error, style: const TextStyle(color: Colors.red)),
          ],
        ),
      ),
    );
  }
}
