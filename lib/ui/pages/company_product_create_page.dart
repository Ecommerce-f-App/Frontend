import 'package:flutter/material.dart';
import '../../services/company_service.dart';

class CompanyProductCreatePage extends StatefulWidget {
  const CompanyProductCreatePage({super.key});

  @override
  State<CompanyProductCreatePage> createState() => _CompanyProductCreatePageState();
}

class _CompanyProductCreatePageState extends State<CompanyProductCreatePage> {
  final _name = TextEditingController();
  final _desc = TextEditingController();
  final _price = TextEditingController();
  final _stock = TextEditingController(text: '0');
  final _image = TextEditingController();
  final _service = CompanyService();
  bool _saving = false;
  String? _error;

  Future<void> _save() async {
    setState(() { _saving = true; _error = null; });
    try {
      await _service.createProduct(
        name: _name.text.trim(),
        description: _desc.text.trim().isEmpty ? null : _desc.text.trim(),
        price: double.tryParse(_price.text.trim()) ?? 0,
        stock: int.tryParse(_stock.text.trim()) ?? 0,
        imageUrl: _image.text.trim().isEmpty ? null : _image.text.trim(),
      );
      if (mounted) Navigator.pop(context);
    } catch (e) {
      _error = 'No se pudo crear el producto.';
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Nuevo producto')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: SingleChildScrollView(
          child: Column(children: [
            TextField(controller: _name, decoration: const InputDecoration(labelText: 'Nombre')),
            const SizedBox(height: 8),
            TextField(controller: _desc, decoration: const InputDecoration(labelText: 'Descripción')),
            const SizedBox(height: 8),
            TextField(controller: _price, decoration: const InputDecoration(labelText: 'Precio (num)'), keyboardType: TextInputType.number),
            const SizedBox(height: 8),
            TextField(controller: _stock, decoration: const InputDecoration(labelText: 'Stock'), keyboardType: TextInputType.number),
            const SizedBox(height: 8),
            TextField(controller: _image, decoration: const InputDecoration(labelText: 'Imagen URL (opcional)')),
            if (_error != null) Padding(padding: const EdgeInsets.only(top: 8), child: Text(_error!, style: const TextStyle(color: Colors.red))),
            const SizedBox(height: 12),
            ElevatedButton(onPressed: _saving ? null : _save, child: const Text('Crear')),
          ]),
        ),
      ),
    );
  }
}
