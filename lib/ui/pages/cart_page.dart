import 'package:flutter/material.dart';
import '../../services/cart_service.dart';

class CartPage extends StatefulWidget {
  const CartPage({super.key});
  @override
  State<CartPage> createState() => _CartPageState();
}

class _CartPageState extends State<CartPage> {
  final _svc = CartService();
  List<CartItemVm> _items = [];
  bool _loading = true;

  double get _total => _items.fold(0, (s, it) => s + it.subtotal);

  Future<void> _load() async {
    setState(() => _loading = true);
    try {
      _items = await _svc.myCart();
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _inc(CartItemVm it) async {
    final qty = it.quantity + 1;
    await _svc.updateQty(it.id, qty);
    setState(() => it.quantity = qty);
  }

  Future<void> _dec(CartItemVm it) async {
    if (it.quantity <= 1) return;
    final qty = it.quantity - 1;
    await _svc.updateQty(it.id, qty);
    setState(() => it.quantity = qty);
  }

  Future<void> _remove(CartItemVm it) async {
    await _svc.remove(it.id);
    setState(() => _items.removeWhere((x) => x.id == it.id));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Mi carrito')),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : _items.isEmpty
              ? const Center(child: Text('Tu carrito está vacío'))
              : Column(
                  children: [
                    Expanded(
                      child: ListView.separated(
                        itemCount: _items.length,
                        separatorBuilder: (_, __) => const Divider(height: 1),
                        itemBuilder: (_, i) {
                          final it = _items[i];
                          return ListTile(
                            leading: it.imageUrl != null
                              ? Image.network(it.imageUrl!, width: 56, height: 56, fit: BoxFit.cover)
                              : const Icon(Icons.image),
                            title: Text(it.name),
                            subtitle: Text('Bs. ${it.unitPrice.toStringAsFixed(2)} x ${it.quantity} = '
                                'Bs. ${it.subtotal.toStringAsFixed(2)}'),
                            trailing: SizedBox(
                              width: 130,
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.end,
                                children: [
                                  IconButton(onPressed: () => _dec(it), icon: const Icon(Icons.remove)),
                                  Text('${it.quantity}'),
                                  IconButton(onPressed: () => _inc(it), icon: const Icon(Icons.add)),
                                  IconButton(onPressed: () => _remove(it), icon: const Icon(Icons.delete_outline)),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.all(16),
                      child: Row(
                        children: [
                          Expanded(child: Text('Total: Bs. ${_total.toStringAsFixed(2)}',
                              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16))),
                          ElevatedButton(
                            onPressed: () {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(content: Text('Checkout pronto 😉')),
                              );
                            },
                            child: const Text('Comprar'),
                          )
                        ],
                      ),
                    )
                  ],
                ),
    );
  }
}
