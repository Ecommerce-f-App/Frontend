import 'package:flutter/material.dart';

class CatalogPage extends StatelessWidget {
  const CatalogPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Catálogo')),
      body: const Center(child: Text('Catálogo público para clientes')),
    );
  }
}
