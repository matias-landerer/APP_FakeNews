import 'dart:async';
import 'dart:convert';
import 'dart:io';
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

    if (userController.text == '' || passController.text == ''){
      setState(() {
        loading = false;
        error = "Por favor, rellene todos los datos.";
      });
      return;
    }

    try {
      final response = await http
          .post(
            Uri.parse("$API_BASE_URL/login"),
            headers: {"Content-Type": "application/json"},
            body: jsonEncode({
              "username_mail": userController.text,
              "password": passController.text,
            }),
          )
          .timeout(const Duration(seconds: 10));

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
      setState(() {
        loading = false;
        error = "El servidor tardó demasiado en responder. Intenta de nuevo.";
      });
    } on SocketException catch (_) {
      setState(() {
        loading = false;
        error =
            "No se pudo conectar al servidor. Verifica tu conexión a internet.";
      });
    } on FormatException catch (_) {
      setState(() {
        loading = false;
        error = "Error en la respuesta del servidor.";
      });
    } catch (e) {
      setState(() {
        loading = false;
        error = "Error inesperado: ${e.toString()}";
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
                      Icons.shield_rounded,
                      size: 34,
                      color: secondary,
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      "Iniciar sesión",
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
                      decoration: const InputDecoration(labelText: "Usuario o Email"),
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: passController,
                      decoration: const InputDecoration(
                        labelText: "Contraseña",
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
                        onPressed: login,
                        child: const Text("Entrar"),
                      ),
                    const SizedBox(height: 8),
                    TextButton(
                      onPressed: () {
                        Navigator.pushReplacementNamed(context, "/register");
                      },
                      child: const Text("Crear cuenta"),
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
