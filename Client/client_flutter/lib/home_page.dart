import 'dart:async';
import 'dart:convert';
import 'dart:io';
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
  String error = "";
  bool loading = false;
  bool showOptions = false;

  Future<void> enviarTitular() async {
    setState(() {
      loading = true;
      error = "";
    });

    try {
      final response = await http
          .post(
            Uri.parse("$API_BASE_URL/analyze"),
            headers: {"Content-Type": "application/json"},
            body: jsonEncode({"titular": controller.text, "user_id": userId}),
          )
          .timeout(const Duration(seconds: 10));

      final data = jsonDecode(response.body);

      if (data["resultado"]?["label"] ==
          "Error: No tiene suficientes créditos") {
        throw Exception("Error: No tiene suficientes créditos");
      }

      setState(() {
        final resultado = data["resultado"] ?? {};
        score = (resultado["score"] ?? "").toString();
        label = (resultado["label"] ?? "").toString();
        fuentes = (resultado["fuentes"] ?? "").toString();
        error = "";
      });
    } on TimeoutException catch (_) {
      setState(() {
        error = "El servidor tardó demasiado en responder. Intenta de nuevo.";
      });
    } on SocketException catch (_) {
      setState(() {
        error =
            "No se pudo conectar al servidor. Verifica tu conexión a internet.";
      });
    } on FormatException catch (_) {
      setState(() {
        error = "Error en la respuesta del servidor.";
      });
    } on Exception catch (_) {
      setState(() {
        error = "Error: No tiene suficientes créditos";
      });
    } catch (e) {
      setState(() {
        error = "Error inesperado: ${e.toString()}";
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
              shape: const RoundedRectangleBorder(
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(24),
                ),
              ),
              clipBehavior: Clip.antiAlias,
              child: SafeArea(
                left: false,
                right: false,
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 16),
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: () {
                            Navigator.pushNamed(
                              context,
                              "/statistics",
                              arguments: userId,
                            );
                          },
                          child: const Text("Historial de consultas"),
                        ),
                      ),
                      const SizedBox(height: 12),
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: () {
                            Navigator.pushNamed(context, "/info");
                          },
                          child: const Text("Ir a info"),
                        ),
                      ),
                      const SizedBox(height: 12),
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: () {
                            Navigator.pushNamedAndRemoveUntil(
                              context,
                              "/login",
                              (route) => false,
                            );
                          },
                          child: const Text("Cerrar sesión"),
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
