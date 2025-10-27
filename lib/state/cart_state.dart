import 'package:flutter/material.dart';
import '../services/cart_service.dart';

class CartState extends ChangeNotifier {
  final _svc = CartService();
  int _count = 0;
  int get count => _count;

  /// Vuelve a contar todas las unidades del carrito
  Future<void> refresh() async {
    final items = await _svc.myCart();
    _count = items.fold(0, (s, it) => s + it.quantity);
    notifyListeners();
  }

  /// Agrega y refresca el contador
  Future<void> add(String productId, int qty) async {
    await _svc.add(productId, qty);
    await refresh();
  }

  /// Llamá esto al volver desde /cart para actualizar el badge
  Future<void> sync() => refresh();
}
