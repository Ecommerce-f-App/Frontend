import 'dart:developer' as dev;
import 'package:dio/dio.dart';
import '../core/api_client.dart';
import '../models/company_models.dart';
import '../models/product_models.dart';

class CatalogService {
  final _api = ApiClient().dio;

  Future<List<CompanyDto>> companies({int page = 1, int pageSize = 50}) async {
    dev.log('➡️ GET /catalog/companies  base=${_api.options.baseUrl}');
    final res = await _api.get(
      '/catalog/companies',
      queryParameters: {'page': page, 'pageSize': pageSize},
    );
    dev.log('✅ companies status=${res.statusCode} data=${res.data}');
    final items = (res.data['items'] as List);
    return items.map((e) => CompanyDto.fromJson(e)).toList();
  }

  Future<List<ProductDto>> productsByCompany(String companyId,
      {int page = 1, int pageSize = 50}) async {
    dev.log('➡️ GET /catalog/companies/$companyId/products');
    final res = await _api.get(
      '/catalog/companies/$companyId/products',
      queryParameters: {'page': page, 'pageSize': pageSize},
    );
    dev.log('✅ products status=${res.statusCode} data=${res.data}');
    final items = (res.data['items'] as List);
    return items.map((e) => ProductDto.fromJson(e)).toList();
  }
}
