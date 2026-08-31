import 'package:flutter/material.dart';
import 'session.dart';

class GuestGuard extends StatelessWidget {
  final Widget child;
  const GuestGuard({super.key, required this.child});

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
        if (userId != null) {
          // Ya hay sesión activa: redirige a home apenas termine este build.
          WidgetsBinding.instance.addPostFrameCallback((_) {
            Navigator.of(context).pushNamedAndRemoveUntil(
              "/home",
              (route) => false,
              arguments: userId,
            );
          });
          return const SizedBox.shrink();
        }

        return child;
      },
    );
  }
}