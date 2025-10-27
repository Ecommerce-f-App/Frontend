class CartItemDto {
  final String productId;
  final String name;
  final double price;
  final int quantity;
  final String? imageUrl;

  CartItemDto({
    required this.productId,
    required this.name,
    required this.price,
    required this.quantity,
    this.imageUrl,
  });

  factory CartItemDto.fromJson(Map<String, dynamic> j) => CartItemDto(
        productId: j['productId'],
        name: j['name'],
        price: (j['price'] as num).toDouble(),
        quantity: j['quantity'],
        imageUrl: j['imageUrl'],
      );
}

class CartDto {
  final List<CartItemDto> items;
  final double total;

  CartDto({required this.items, required this.total});

  factory CartDto.fromJson(Map<String, dynamic> j) => CartDto(
        items: (j['items'] as List).map((e) => CartItemDto.fromJson(e)).toList(),
        total: (j['total'] as num).toDouble(),
      );
}
