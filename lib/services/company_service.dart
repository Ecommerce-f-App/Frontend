import '../core/api_client.dart';
import '../models/product_models.dart';

class CompanyService {
  final _api = ApiClient().dio;

  Future<List<ProductDto>> myProducts() async {
    final res = await _api.get('/company/products');
    return (res.data as List).map((e) => ProductDto.fromJson(e)).toList();
  }

  Future<ProductDto> createProduct({
    required String name,
    required double price,
    int stock = 0,
    String? description,
    String? imageUrl,
    bool active = true,
  }) async {
    final res = await _api.post('/company/products', data: {
      'name': name,
      'price': price,
      'stock': stock,        // 👈 importante
      'description': description,
      'imageUrl': imageUrl,
      'active': active,
    });
    return ProductDto.fromJson(res.data);
  }

  Future<ProductDto> updateProduct({
    required String id,
    String? name,
    double? price,
    int? stock,
    String? description,
    String? imageUrl,
    bool? active,
  }) async {
    final res = await _api.put('/company/products/$id', data: {
      if (name != null) 'name': name,
      if (price != null) 'price': price,
      if (stock != null) 'stock': stock,
      if (description != null) 'description': description,
      if (imageUrl != null) 'imageUrl': imageUrl,
      if (active != null) 'active': active,
    });
    return ProductDto.fromJson(res.data);
  }
}
