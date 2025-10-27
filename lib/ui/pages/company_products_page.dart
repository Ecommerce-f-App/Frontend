import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../services/company_service.dart';
import '../../models/product_models.dart';
import '../../state/auth_state.dart';
import 'company_product_create_page.dart';

class CompanyProductsPage extends StatefulWidget {
  const CompanyProductsPage({super.key});

  @override
  State<CompanyProductsPage> createState() => _CompanyProductsPageState();
}

class _CompanyProductsPageState extends State<CompanyProductsPage> {
  final _service = CompanyService();
  List<ProductDto> _items = [];
  bool _loading = true;

  Future<void> _load() async {
    setState(() => _loading = true);
    try {
      _items = await _service.myProducts();
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
        title: const Text('Mis productos'),
        actions: [
          IconButton(
            onPressed: () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => const CompanyProductCreatePage())).then((_) => _load()),
            icon: const Icon(Icons.add),
            tooltip: 'Nuevo producto',
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
                final p = _items[i];
                return ListTile(
                  leading: p.imageUrl != null ? Image.network(p.imageUrl!, width: 48, height: 48, fit: BoxFit.cover) : const Icon(Icons.image_not_supported),
                  title: Text(p.name),
                  subtitle: Text('Bs. ${p.price.toStringAsFixed(2)} • Stock: ${p.stock}'),
                  trailing: Icon(p.active ? Icons.check_circle : Icons.block, color: p.active ? Colors.green : Colors.red),
                );
              },
            ),
    );
  }
}
