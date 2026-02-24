import 'dart:convert';
import 'parametros.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class HomePage extends StatefulWidget {
  const HomePage({super.key});
  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int? userId;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final args = ModalRoute.of(context)?.settings.arguments;
    if (args is int) {
      userId = args;
    }
  }

  final controller = TextEditingController();
  String score = "";
  String label = "";
  String fuentes = "";
  bool showOptions = false;

  Future<void> enviarTitular() async {
    final response = await http.post(
      Uri.parse("$API_BASE_URL/analyze"),
      headers: {"Content-Type": "application/json"},
      body: jsonEncode({
        "titular": controller.text,
        "user_id": userId,
      }),
    );

    final data = jsonDecode(response.body);
    setState(() {
      final resultado = data["resultado"] ?? {};
      score = (resultado["score"] ?? "").toString();
      label = (resultado["label"] ?? "").toString();
      fuentes = (resultado["fuentes"] ?? "").toString();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Fake News Detector"),
        actions: [
          IconButton(
            tooltip: showOptions ? "Ocultar opciones" : "Mostrar opciones",
            icon: const Icon(Icons.more_vert),
            onPressed: () {
              setState(() {
                showOptions = !showOptions;
              });
            },
          ),
        ],
      ),
      body: Stack(
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                TextField(
                  controller: controller,
                  decoration: const InputDecoration(
                    labelText: "Titular de la noticia",
                  ),
                ),
                const SizedBox(height: 20),
                ElevatedButton(
                  onPressed: enviarTitular,
                  child: const Text("Analizar"),
                ),
                const SizedBox(height: 20),
                if (score.isNotEmpty || label.isNotEmpty || fuentes.isNotEmpty)
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text("La noticia es '$score' real"),
                      const SizedBox(height: 8),
                      Text(label),
                      const SizedBox(height: 8),
                      const Text("Fuentes:"),
                      Text(fuentes),
                    ],
                  ),
              ],
            ),
          ),
          AnimatedPositioned(
            duration: const Duration(milliseconds: 220),
            curve: Curves.easeOut,
            top: 0,
            bottom: 0,
            right: showOptions ? 0 : -260,
            width: 260,
            child: Material(
              elevation: 8,
              color: Colors.grey.shade100,
              child: SafeArea(
                left: false,
                right: false,
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        "Opciones",
                        style: TextStyle(
                          fontWeight: FontWeight.w600,
                          fontSize: 16,
                        ),
                      ),
                      const SizedBox(height: 12),
                      InkWell(
                        onTap: () {
                          Navigator.pushNamed(context, "/statistics", arguments: userId);
                        },
                        child: const Text(
                          "Ir a datos",
                          style: TextStyle(
                            color: Colors.blue,
                            decoration: TextDecoration.underline,
                          ),
                        ),
                      ),
                      const SizedBox(height: 10),
                      InkWell(
                        onTap: () {
                          Navigator.pushNamedAndRemoveUntil(
                            context,
                            "/login",
                            (route) => false,
                          );
                        },
                        child: const Text(
                          "Cerrar sesión",
                          style: TextStyle(
                            color: Colors.blue,
                            decoration: TextDecoration.underline,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
