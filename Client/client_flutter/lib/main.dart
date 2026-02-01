import 'package:flutter/material.dart';
import 'login_page.dart';
import 'home_page.dart';
import 'register_page.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      initialRoute: "/login",
      routes: {
        "/login": (context) => const LoginPage(),
        "/home": (context) => const HomePage(),
        "/register": (context) => const RegisterPage(),
      },
    );
  }
}


/*import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      home: HomePage(),
    );
  }
}

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final controller = TextEditingController();
  String resultado = "";

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
      appBar: AppBar(title: const Text("Fake News Detector")),
      body: Padding(
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
    );
  }
}
*/