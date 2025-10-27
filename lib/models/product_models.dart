class ProductDto {
  final String id;
  final String companyId;
  final String name;
  final String? description;
  final double price;
  final int stock;
  final String? imageUrl;
  final bool active;

  ProductDto({
    required this.id,
    required this.companyId,
    required this.name,
    required this.description,
    required this.price,
    required this.stock,
    required this.imageUrl,
    required this.active,
  });

  factory ProductDto.fromJson(Map<String, dynamic> j) => ProductDto(
        id: j['id'],
        companyId: j['companyId'],
        name: j['name'],
        description: j['description'],
        price: (j['price'] as num).toDouble(),
        stock: j['stock'],
        imageUrl: j['imageUrl'],
        active: j['active'],
      );
}
