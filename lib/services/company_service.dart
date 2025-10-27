import '../core/api_client.dart';
import '../models/product_models.dart';

class CompanyService {
  final _api = ApiClient().dio;

  Future<List<ProductDto>> myProducts() async {
    final res = await _api.get('/companies/me/products', queryParameters: {'page': 1, 'pageSize': 50});
    final items = (res.data['items'] as List).map((e) => ProductDto.fromJson(e)).toList();
    return items;
  }

  Future<ProductDto> createProduct({
    required String name,
    String? description,
    required double price,
    required int stock,
    String? imageUrl,
  }) async {
    final res = await _api.post('/companies/me/products', data: {
      'name': name,
      'description': description,
      'price': price,
      'stock': stock,
      'imageUrl': imageUrl,
    });
    return ProductDto.fromJson(res.data);
  }
}
