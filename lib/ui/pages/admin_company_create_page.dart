import 'package:flutter/material.dart';
import '../../services/admin_service.dart';

class AdminCompanyCreatePage extends StatefulWidget {
  const AdminCompanyCreatePage({super.key});

  @override
  State<AdminCompanyCreatePage> createState() => _AdminCompanyCreatePageState();
}

class _AdminCompanyCreatePageState extends State<AdminCompanyCreatePage> {
  final _name = TextEditingController();
  final _nit  = TextEditingController();
  final _logo = TextEditingController();
  final _service = AdminService();
  bool _saving = false;
  String? _error;

  Future<void> _save() async {
    setState(() { _saving = true; _error = null; });
    try {
      await _service.createCompany(name: _name.text.trim(), nit: _nit.text.trim(), logoUrl: _logo.text.trim().isEmpty ? null : _logo.text.trim());
      if (mounted) Navigator.pop(context);
    } catch (e) {
      _error = 'No se pudo crear. ¿NIT duplicado?';
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Nueva empresa')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(children: [
          TextField(controller: _name, decoration: const InputDecoration(labelText: 'Nombre')),
          const SizedBox(height: 8),
          TextField(controller: _nit, decoration: const InputDecoration(labelText: 'NIT')),
          const SizedBox(height: 8),
          TextField(controller: _logo, decoration: const InputDecoration(labelText: 'Logo URL (opcional)')),
          if (_error != null) Padding(padding: const EdgeInsets.only(top: 8), child: Text(_error!, style: const TextStyle(color: Colors.red))),
          const SizedBox(height: 12),
          ElevatedButton(onPressed: _saving ? null : _save, child: const Text('Crear')),
        ]),
      ),
    );
  }
}
