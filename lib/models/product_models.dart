class ProductDto {
  final String id;
  final String companyId;
  final String name;
  final String? description;
  final double price;
  final String? imageUrl;
  final bool active;
  final int stock; // 👈 añadimos stock

  ProductDto({
    required this.id,
    required this.companyId,
    required this.name,
    this.description,
    required this.price,
    this.imageUrl,
    required this.active,
    required this.stock, // 👈 añadimos
  });

  factory ProductDto.fromJson(Map<String, dynamic> j) => ProductDto(
        id: j['id'],
        companyId: j['companyId'],
        name: j['name'],
        description: j['description'],
        price: (j['price'] as num).toDouble(),
        imageUrl: j['imageUrl'],
        active: j['active'],
        stock: j['stock'] ?? 0, // 👈 si no viene en JSON, queda en 0
      );
}
