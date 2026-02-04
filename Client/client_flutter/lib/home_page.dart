import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class HomePage extends StatefulWidget {
  const HomePage({super.key});
  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final controller = TextEditingController();
  String resultado = "";
  bool showOptions = false;

  Future<void> enviarTitular() async {
    final response = await http.post(
      Uri.parse("http://10.0.2.2:5000/analyze"),
      headers: {"Content-Type": "application/json"},
      body: jsonEncode({
        "titular": controller.text,
      }),
    );

    final data = jsonDecode(response.body);
    setState(() {
      resultado = data["resultado"]["label"];
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
                Text(resultado),
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
                          Navigator.pushNamed(context, "/statistics");
                        },
                        child: const Text(
                          "Ir a datos",
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
