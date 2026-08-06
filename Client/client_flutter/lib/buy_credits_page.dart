import 'dart:convert';
import 'parametros.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:url_launcher/url_launcher.dart';

class BuyCreditsPage extends StatefulWidget {
  const BuyCreditsPage({super.key});
  @override
  State<BuyCreditsPage> createState() => _BuyCreditsPageState();
}

class _BuyCreditsPageState extends State<BuyCreditsPage> {
  String? userId;
  bool loading = false;
  String? loadingPackage;
  String error = "";

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final args = ModalRoute.of(context)?.settings.arguments;
    if (args is String) userId = args;
  }

  void _showPaymentInstructions() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text("Completa tu pago"),
        content: const Text(
          "Se abrió Mercado Pago en tu navegador.\n\n"
          "1. Completa el pago ahí.\n"
          "2. Cuando termines, vuelve a esta app.\n"
          "3. Tus créditos se acreditan automáticamente unos "
          "segundos después del pago.\n\n"
          "Si no los ves de inmediato, espera un momento y vuelve a "
          "entrar a esta pantalla.",
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text("Entendido"),
          ),
        ],
      ),
    );
  }

  Future<void> _buyCredits(String packageId) async {
    setState(() {
      loading = true;
      loadingPackage = packageId;
      error = "";
    });

    try {
      final response = await http.post(
        Uri.parse("$API_BASE_URL/buy-credits"),
        headers: {
          "Content-Type": "application/json",
          "Authorization": "Bearer $userId",
        },
        body: jsonEncode({"package": packageId}),
      ).timeout(const Duration(seconds: 10));

      final data = jsonDecode(response.body);

      if (response.statusCode != 200) {
        setState(() {
          error = data["status"] ?? "Error al iniciar el pago.";
        });
        return;
      }

      final checkoutUrl = data["init_point"];
      final url = Uri.parse(checkoutUrl);
      if (await canLaunchUrl(url)) {
        await launchUrl(url, mode: LaunchMode.externalApplication);
        if (mounted) _showPaymentInstructions();
      } else {
        setState(() => error = "No se pudo abrir la página de pago.");
      }
    } catch (_) {
      setState(() {
        error = "No se pudo conectar al servidor.";
      });
    } finally {
      if (mounted) {
        setState(() {
          loading = false;
          loadingPackage = null;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    const secondary = Color(0xFFEF342A);

    final packages = [
      {"id": "100",  "credits": "100",   "price": "\$990",   "desc": "Para empezar"},
      //{"id": "500",  "credits": "500",   "price": "\$3.990", "desc": "Más popular"},
      //{"id": "1000", "credits": "1.000", "price": "\$6.990", "desc": "Mejor valor"},
    ];

    return Scaffold(
      appBar: AppBar(title: const Text("Comprar créditos")),
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 520),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Container(
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
                          Icons.monetization_on_outlined,
                          size: 34,
                          color: secondary,
                        ),
                        const SizedBox(height: 8),
                        const Text(
                          "Elige un paquete",
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.w800,
                            color: Color(0xFF1D1D1B),
                          ),
                        ),
                        const SizedBox(height: 4),
                        const Text(
                          "Cada crédito equivale a un análisis de titular.",
                          textAlign: TextAlign.center,
                          style: TextStyle(color: Color(0xFF6C6C66), fontSize: 13),
                        ),
                        const SizedBox(height: 24),
                        ...packages.map((pkg) {
                          final isLoading = loading && loadingPackage == pkg["id"];
                          return Padding(
                            padding: const EdgeInsets.only(bottom: 12),
                            child: _PackageTile(
                              credits: pkg["credits"]!,
                              price: pkg["price"]!,
                              desc: pkg["desc"]!,
                              isLoading: isLoading,
                              disabled: loading,
                              onTap: () => _buyCredits(pkg["id"]!),
                            ),
                          );
                        }),
                        if (error.isNotEmpty) ...[
                          const SizedBox(height: 8),
                          Text(
                            error,
                            textAlign: TextAlign.center,
                            style: const TextStyle(
                              color: secondary,
                              fontWeight: FontWeight.w600,
                              fontSize: 13,
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    "El pago se procesa de forma segura a través de Mercado Pago. "
                    "Los créditos se acreditarán automáticamente una vez confirmado el pago.",
                    textAlign: TextAlign.center,
                    style: TextStyle(color: Color(0xFF6C6C66), fontSize: 12),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _PackageTile extends StatelessWidget {
  final String credits;
  final String price;
  final String desc;
  final bool isLoading;
  final bool disabled;
  final VoidCallback onTap;

  const _PackageTile({
    required this.credits,
    required this.price,
    required this.desc,
    required this.isLoading,
    required this.disabled,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    const secondary = Color(0xFFEF342A);

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: disabled ? null : onTap,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          decoration: BoxDecoration(
            color: const Color(0xFFE4E4D8),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: secondary.withValues(alpha: 0.35)),
          ),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "$credits créditos",
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        color: Color(0xFF1D1D1B),
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      desc,
                      style: const TextStyle(
                        fontSize: 12,
                        color: Color(0xFF6C6C66),
                      ),
                    ),
                  ],
                ),
              ),
              if (isLoading)
                const SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: secondary,
                  ),
                )
              else
                Text(
                  price,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: secondary,
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}