import 'package:flutter/material.dart';
import 'session.dart';

/// Envuelve una ruta protegida: valida que exista sesión antes de
/// construir la página real. Si no hay sesión, redirige a /login.
class AuthGuard extends StatelessWidget {
  final Widget Function(String userId) builder;
  const AuthGuard({super.key, required this.builder});

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<String?>(
      future: getSession(),
      builder: (context, snapshot) {
        if (snapshot.connectionState != ConnectionState.done) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        final userId = snapshot.data;
        if (userId == null) {
          // No hay sesión: redirige a login apenas termine este build.
          WidgetsBinding.instance.addPostFrameCallback((_) {
            Navigator.of(context).pushNamedAndRemoveUntil(
              "/login",
              (route) => false,
            );
          });
          return const SizedBox.shrink();
        }

        return builder(userId);
      },
    );
  }
}