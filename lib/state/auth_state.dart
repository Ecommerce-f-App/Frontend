import 'package:flutter/foundation.dart';
import '../models/auth_models.dart';
import '../services/auth_service.dart';

class AuthState extends ChangeNotifier {
  final _auth = AuthService();
  MeResponse? me;

  Future<void> login(String email, String password) async {
    await _auth.login(email, password);
    me = await _auth.me();
    notifyListeners();
  }

  Future<void> register(String email, String password) async {
    await _auth.registerClient(email, password);
    me = await _auth.me();
    notifyListeners();
  }

  Future<void> loadMe() async {
    try {
      me = await _auth.me();
    } catch (_) {
      me = null;
    }
    notifyListeners();
  }

  Future<void> logout() async {
    await _auth.logout();
    me = null;
    notifyListeners();
  }

  bool get isLogged => me != null;
  int get role => me?.role ?? -1; // 0 admin, 1 empresa, 2 cliente
}
