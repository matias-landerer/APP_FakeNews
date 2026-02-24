import 'dart:convert';
import 'parametros.dart';
import 'dart:io';  // ← Para SocketException
import 'dart:async';  // ← Para TimeoutException
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

  try {
    final response = await http.post(
      Uri.parse("$API_BASE_URL/login"),
      headers: {"Content-Type": "application/json"},
      body: jsonEncode({
        "username": userController.text,
        "password": passController.text,
      }),
    ).timeout(
      const Duration(seconds: 10),  // Timeout de 10 segundos
    );

    final data = jsonDecode(response.body);

    setState(() {
      loading = false;
    });

    if (data["status"] == "InicioExitoso") {
      userid = data["user_id"];
      Navigator.pushReplacementNamed(context, "/home", arguments: userid);
    } else {
      setState(() {
        error = data["status"];
      });
    }
  } on TimeoutException catch (_) {
    // Timeout - el servidor no responde a tiempo
    setState(() {
      loading = false;
      error = "El servidor tardó demasiado en responder. Intenta de nuevo.";
    });
  } on SocketException catch (_) {
    // Sin conexión a internet o servidor no disponible
    setState(() {
      loading = false;
      error = "No se pudo conectar al servidor. Verifica tu conexión a internet.";
    });
  } on FormatException catch (_) {
    // Respuesta del servidor no es JSON válido
    setState(() {
      loading = false;
      error = "Error en la respuesta del servidor.";
    });
  } catch (e) {
    // Cualquier otro error
    setState(() {
      loading = false;
      error = "Error inesperado: ${e.toString()}";
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
