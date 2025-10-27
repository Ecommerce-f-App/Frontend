import '../core/api_client.dart';

class FavoritesService {
  final _api = ApiClient().dio;

  Future<void> toggle(String productId) async {
    await _api.post('/favorites/$productId'); // tu backend hace add/remove
  }

  Future<List<String>> myFavoritesIds() async {
    final res = await _api.get('/favorites');
    return (res.data as List).map((e) => e['productId'] as String).toList();
  }
}
