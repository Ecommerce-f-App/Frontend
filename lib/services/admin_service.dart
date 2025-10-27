import 'package:dio/dio.dart';
import '../core/api_client.dart';
import '../models/company_models.dart';

class AdminService {
  final _api = ApiClient().dio;

  Future<List<CompanyDto>> getCompanies() async {
    final res = await _api.get('/admin/companies', queryParameters: {'page': 1, 'pageSize': 50});
    final items = (res.data['items'] as List).map((e) => CompanyDto.fromJson(e)).toList();
    return items;
    // (res.data['total'] disponible si necesitas paginar)
  }

  Future<CompanyDto> createCompany({required String name, required String nit, String? logoUrl}) async {
    final res = await _api.post('/admin/companies', data: {
      'name': name,
      'nit': nit,
      'logoUrl': logoUrl,
    });
    return CompanyDto.fromJson(res.data);
  }
}
