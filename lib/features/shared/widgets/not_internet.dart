import 'package:flutter/material.dart';

class NoInternetScreen extends StatelessWidget {
  const NoInternetScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 32),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.wifi_off,
                color: Colors.red.shade400,
                size: 100,
              ),
              const SizedBox(height: 24),
              Text(
                'Sin conexión a Internet',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.red.shade600,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              const Text(
                'Por favor, verifica tu conexión y vuelve a intentarlo.',
                style: TextStyle(fontSize: 16),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 40),
              ElevatedButton.icon(
                icon: const Icon(Icons.refresh),
                label: const Text('Reintentar'),
                onPressed: () {
                  // Aquí podrías ejecutar lógica para reintentar conexión
                  // o hacer refresh del estado de conexión
                },
                style: ElevatedButton.styleFrom(
                  minimumSize: const Size(140, 48),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}
