import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class ShowDataPage extends StatefulWidget {
  const ShowDataPage({super.key});
  @override
  State<ShowDataPage> createState() => _ShowDataPageState();
}

class _ShowDataPageState extends State<ShowDataPage> {
  final userIdController = TextEditingController();
  bool loading = false;
  String error = "";
  bool autoLoaded = false;
  List<List<dynamic>> rows = [];

  Future<void> showData(int userId) async {
    setState(() {
      loading = true;
      error = "";
    });

    try {
      final request = http.Request(
        "GET",
        Uri.parse("http://10.0.2.2:5000/statistics"),
      );
      request.headers["Content-Type"] = "application/json";
      request.body = jsonEncode({"id": userId});

      final streamed = await request.send();
      final response = await http.Response.fromStream(streamed);

      if (response.statusCode >= 400) {
        setState(() {
          loading = false;
          error = "Error ${response.statusCode} al obtener datos.";
          rows = [];
        });
        return;
      }

      final decoded = jsonDecode(response.body);
      final data = (decoded["data"] ?? []) as List<dynamic>;

      setState(() {
        rows = data.map((e) => List<dynamic>.from(e)).toList();
        loading = false;
      });
    } catch (e) {
      setState(() {
        loading = false;
        error = "No se pudo conectar al servidor.";
        rows = [];
      });
    }
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (autoLoaded) {
      return;
    }
    autoLoaded = true;
    final args = ModalRoute.of(context)?.settings.arguments;
    if (args is int) {
      showData(args);
    } else if (args is String) {
      final parsed = int.tryParse(args);
      if (parsed != null) {
        showData(parsed);
      }
    }
  }

  @override
  void dispose() {
    userIdController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Estadísticas"),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            TextField(
              controller: userIdController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                labelText: "ID de usuario",
              ),
            ),
            const SizedBox(height: 12),
            ElevatedButton(
              onPressed: loading
                  ? null
                  : () {
                      final userId = int.tryParse(userIdController.text);
                      if (userId == null) {
                        setState(() {
                          error = "Ingresa un ID de usuario válido.";
                        });
                        return;
                      }
                      showData(userId);
                    },
              child: const Text("Cargar datos"),
            ),
            const SizedBox(height: 12),
            if (loading) const LinearProgressIndicator(),
            if (error.isNotEmpty)
              Padding(
                padding: const EdgeInsets.only(top: 8),
                child: Text(
                  error,
                  style: const TextStyle(color: Colors.red),
                ),
              ),
            const SizedBox(height: 8),
            Expanded(
              child: rows.isEmpty
                  ? const Center(child: Text("Sin datos para mostrar."))
                  : ListView.separated(
                      itemCount: rows.length,
                      separatorBuilder: (context, index) =>
                          const SizedBox(height: 8),
                      itemBuilder: (context, index) {
                        final row = rows[index];
                        final titular = row.isNotEmpty
                            ? (row[0]?.toString() ?? "")
                            : "";
                        final resultado = row.length > 1
                            ? (row[1]?.toString() ?? "")
                            : "";
                        final fecha = row.length > 2
                            ? (row[2]?.toString() ?? "")
                            : "";

                        return Card(
                          child: ListTile(
                            title: Text(titular),
                            subtitle: Text(
                              "Resultado: $resultado\nFecha: $fecha",
                            ),
                          ),
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }
}
