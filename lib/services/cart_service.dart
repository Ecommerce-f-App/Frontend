import '../core/api_client.dart';

class CartItemVm {
  final String id;
  final String productId;
  final String name;
  final String? imageUrl;
  final double unitPrice;
  int quantity;
  CartItemVm({
    required this.id,
    required this.productId,
    required this.name,
    required this.imageUrl,
    required this.unitPrice,
    required this.quantity,
  });
  double get subtotal => unitPrice * quantity;
  factory CartItemVm.fromJson(Map<String, dynamic> j) => CartItemVm(
    id: j['id'],
    productId: j['productId'],
    name: j['productName'],
    imageUrl: j['imageUrl'],
    unitPrice: (j['unitPrice'] as num).toDouble(),
    quantity: j['quantity'],
  );
}

class CartService {
  final _api = ApiClient().dio;

  Future<List<CartItemVm>> myCart() async {
    final res = await _api.get('/cart');
    return (res.data as List).map((e) => CartItemVm.fromJson(e)).toList();
  }

  Future<void> add(String productId, int qty) async {
    await _api.post('/cart/items', data: {'productId': productId, 'quantity': qty});
  }

  Future<void> updateQty(String itemId, int qty) async {
    await _api.put('/cart/items/$itemId', data: {'quantity': qty});
  }

  Future<void> remove(String itemId) async {
    await _api.delete('/cart/items/$itemId');
  }
}
