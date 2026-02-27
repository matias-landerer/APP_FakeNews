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
  bool loading = false;
  bool showOptions = false;

  Future<void> enviarTitular() async {
    setState(() {
      loading = true;
    });

    try {
      final response = await http.post(
        Uri.parse("$API_BASE_URL/analyze"),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({"titular": controller.text, "user_id": userId}),
      );

      final data = jsonDecode(response.body);
      setState(() {
        final resultado = data["resultado"] ?? {};
        score = (resultado["score"] ?? "").toString();
        label = (resultado["label"] ?? "").toString();
        fuentes = (resultado["fuentes"] ?? "").toString();
      });
    } finally {
      if (mounted) {
        setState(() {
          loading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    const secondary = Color(0xFFEF342A);

    return Scaffold(
      appBar: AppBar(
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
          SafeArea(
            child: Center(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(20),
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 720),
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
                        const Text(
                          "Fake News Detector",
                          style: TextStyle(
                            fontSize: 26,
                            fontWeight: FontWeight.w800,
                            color: Color(0xFF1D1D1B),
                          ),
                        ),
                        const SizedBox(height: 8),
                        const Text(
                          "Ingresa el titular para estimar si es real o falso.",
                          style: TextStyle(color: Color(0xFF6C6C66)),
                        ),
                        const SizedBox(height: 20),
                        TextField(
                          controller: controller,
                          maxLines: 2,
                          decoration: const InputDecoration(
                            labelText: "Titular de la noticia",
                          ),
                        ),
                        const SizedBox(height: 16),
                        if (loading)
                          const Center(
                            child: CircularProgressIndicator(color: secondary),
                          ),
                        if (!loading)
                          ElevatedButton(
                            onPressed: enviarTitular,
                            child: const Text("Analizar"),
                          ),
                        const SizedBox(height: 20),
                        if (score.isNotEmpty ||
                            label.isNotEmpty ||
                            fuentes.isNotEmpty)
                          Container(
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: const Color(0xFFE4E4D8),
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(
                                color: secondary.withValues(alpha: 0.35),
                              ),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  "La noticia es '$score' real",
                                  style: const TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                                const SizedBox(height: 8),
                                Text(label),
                                const SizedBox(height: 10),
                                const Text(
                                  "Fuentes:",
                                  style: TextStyle(fontWeight: FontWeight.w700),
                                ),
                                const SizedBox(height: 4),
                                Text(fuentes),
                              ],
                            ),
                          ),
                      ],
                    ),
                  ),
                ),
              ),
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
              elevation: 10,
              color: Colors.white,
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
                          fontWeight: FontWeight.w700,
                          fontSize: 18,
                          color: Color(0xFF1D1D1B),
                        ),
                      ),
                      const SizedBox(height: 16),
                      InkWell(
                        onTap: () {
                          Navigator.pushNamed(
                            context,
                            "/statistics",
                            arguments: userId,
                          );
                        },
                        child: const Text(
                          "Historial de consultas",
                          style: TextStyle(
                            color: secondary,
                            decoration: TextDecoration.underline,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                      const SizedBox(height: 14),
                      InkWell(
                        onTap: () {
                          Navigator.pushNamed(context, "/info");
                        },
                        child: const Text(
                          "Ir a info",
                          style: TextStyle(
                            color: secondary,
                            decoration: TextDecoration.underline,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                      const SizedBox(height: 14),
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
                            color: secondary,
                            decoration: TextDecoration.underline,
                            fontWeight: FontWeight.w700,
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
