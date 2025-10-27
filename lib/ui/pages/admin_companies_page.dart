import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../services/admin_service.dart';
import '../../models/company_models.dart';
import '../../state/auth_state.dart';
import 'admin_company_create_page.dart';

class AdminCompaniesPage extends StatefulWidget {
  const AdminCompaniesPage({super.key});

  @override
  State<AdminCompaniesPage> createState() => _AdminCompaniesPageState();
}

class _AdminCompaniesPageState extends State<AdminCompaniesPage> {
  final _service = AdminService();
  List<CompanyDto> _items = [];
  bool _loading = true;

  Future<void> _load() async {
    setState(() => _loading = true);
    try {
      _items = await _service.getCompanies();
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  void initState() {
    super.initState();
    _load();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Empresas'),
        actions: [
          IconButton(
            onPressed: () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => const AdminCompanyCreatePage())).then((_) => _load()),
            icon: const Icon(Icons.add),
            tooltip: 'Crear empresa',
          ),
          IconButton(
            onPressed: () => context.read<AuthState>().logout(),
            icon: const Icon(Icons.logout),
          ),
        ],
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : ListView.separated(
              itemCount: _items.length,
              separatorBuilder: (_, __) => const Divider(height: 1),
              itemBuilder: (_, i) {
                final c = _items[i];
                return ListTile(
                  leading: c.logoUrl != null ? CircleAvatar(backgroundImage: NetworkImage(c.logoUrl!)) : const CircleAvatar(child: Icon(Icons.business)),
                  title: Text(c.name),
                  subtitle: Text('NIT: ${c.nit} • Activa: ${c.active ? "Sí" : "No"}'),
                );
              },
            ),
    );
  }
}
