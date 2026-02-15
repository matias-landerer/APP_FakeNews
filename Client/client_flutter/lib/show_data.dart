import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class ShowDataPage extends StatefulWidget {
  const ShowDataPage({super.key});
  @override
  State<ShowDataPage> createState() => _ShowDataPageState();
}

class _ShowDataPageState extends State<ShowDataPage> {
  bool loading = false;
  String error = "";
  bool autoLoaded = false;
  int? userId; // Guardamos el userId recibido
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
      userId = args;
      showData(args);
    } else if (args is String) {
      final parsed = int.tryParse(args);
      if (parsed != null) {
        userId = parsed;
        showData(parsed);
      }
    } else {
      // Si no se recibe argumento, mostramos error
      setState(() {
        error = "No se recibió ID de usuario.";
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(userId != null 
            ? "Estadísticas" 
            : "Estadísticas"),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            if (loading) const LinearProgressIndicator(),
            if (error.isNotEmpty)
              Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: Text(
                  error,
                  style: const TextStyle(color: Colors.red),
                ),
              ),
            Expanded(
              child: rows.isEmpty
                  ? Center(
                      child: loading
                          ? const CircularProgressIndicator()
                          : const Text("Sin datos para mostrar."),
                    )
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