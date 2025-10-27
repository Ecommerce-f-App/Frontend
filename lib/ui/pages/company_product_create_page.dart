import 'package:flutter/material.dart';
import '../../services/company_service.dart';
import '../../models/product_models.dart';

class CompanyProductCreatePage extends StatefulWidget {
  const CompanyProductCreatePage({super.key});

  @override
  State<CompanyProductCreatePage> createState() => _CompanyProductCreatePageState();
}

class _CompanyProductCreatePageState extends State<CompanyProductCreatePage> {
  final _svc = CompanyService();
  final _name = TextEditingController();
  final _price = TextEditingController();
  final _stock = TextEditingController(text: '0');
  final _image = TextEditingController();
  final _desc = TextEditingController();
  bool _active = true;
  bool _saving = false;
  String? _error;

  @override
  void dispose() {
    _name.dispose();
    _price.dispose();
    _stock.dispose();
    _image.dispose();
    _desc.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    final name = _name.text.trim();
    final priceStr = _price.text.trim();
    final stockStr = _stock.text.trim();

    if (name.isEmpty) { setState(() => _error = 'El nombre es obligatorio.'); return; }
    final price = double.tryParse(priceStr);
    if (price == null || price <= 0) { setState(() => _error = 'Precio inválido.'); return; }
    final stock = int.tryParse(stockStr) ?? 0;
    if (stock < 0) { setState(() => _error = 'Stock no puede ser negativo.'); return; }

    setState(() { _saving = true; _error = null; });
    try {
      final ProductDto created = await _svc.createProduct(
        name: name,
        price: price,
        stock: stock,
        description: _desc.text.trim().isEmpty ? null : _desc.text.trim(),
        imageUrl: _image.text.trim().isEmpty ? null : _image.text.trim(),
        active: _active,
      );
      if (!mounted) return;
      Navigator.pop(context, created);
    } catch (e) {
      setState(() => _error = e.toString().replaceFirst('Exception: ', ''));
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(title: const Text('Nuevo producto')),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 560),
          child: ListView(
            padding: const EdgeInsets.all(16),
            children: [
              Text('Datos del producto', style: theme.textTheme.titleLarge),
              const SizedBox(height: 12),
              TextField(controller: _name, decoration: const InputDecoration(labelText: 'Nombre *')),
              const SizedBox(height: 8),
              TextField(
                controller: _price,
                decoration: const InputDecoration(labelText: 'Precio (Bs.) *'),
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
              ),
              const SizedBox(height: 8),
              TextField(
                controller: _stock,
                decoration: const InputDecoration(labelText: 'Stock *'),
                keyboardType: TextInputType.number,
              ),
              const SizedBox(height: 8),
              TextField(controller: _image, decoration: const InputDecoration(labelText: 'Imagen URL')),
              const SizedBox(height: 8),
              TextField(controller: _desc, decoration: const InputDecoration(labelText: 'Descripción'), maxLines: 3),
              const SizedBox(height: 8),
              SwitchListTile(
                value: _active,
                onChanged: (v) => setState(() => _active = v),
                title: const Text('Activo'),
              ),
              if (_error != null)
                Padding(
                  padding: const EdgeInsets.only(top: 8),
                  child: Text(_error!, style: const TextStyle(color: Colors.red)),
                ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: _saving ? null : _save,
                      icon: const Icon(Icons.save),
                      label: _saving ? const Text('Guardando...') : const Text('Guardar'),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
