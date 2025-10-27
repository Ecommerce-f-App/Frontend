import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import 'state/auth_state.dart';
import 'ui/pages/login_page.dart';
import 'ui/pages/admin_companies_page.dart';
import 'ui/pages/company_products_page.dart';
import 'ui/pages/catalog_page.dart';

void main() {
  runApp(const EcommerceUpsaApp());
}

// 🔑 clave global para obtener el context raíz más adelante
final navigatorKey = GlobalKey<NavigatorState>();

class EcommerceUpsaApp extends StatefulWidget {
  const EcommerceUpsaApp({super.key});

  @override
  State<EcommerceUpsaApp> createState() => _EcommerceUpsaAppState();
}

class _EcommerceUpsaAppState extends State<EcommerceUpsaApp> {
  late final GoRouter _router;

  @override
  void initState() {
    super.initState();
    _router = GoRouter(
      navigatorKey: navigatorKey, // aquí va el key
      initialLocation: '/login',
      refreshListenable: _RouterAuthListenable(),
      routes: [
        GoRoute(path: '/login', builder: (_, __) => const LoginPage()),
        GoRoute(path: '/admin/companies', builder: (_, __) => const AdminCompaniesPage()),
        GoRoute(path: '/company/products', builder: (_, __) => const CompanyProductsPage()),
        GoRoute(path: '/catalog', builder: (_, __) => const CatalogPage()),
      ],
      redirect: (context, state) {
        final auth = _RouterAuthListenable.currentAuth;
        final logged = auth?.isLogged ?? false;
        final role = auth?.role ?? -1;

        final path = state.uri.toString();
        final loggingIn = path == '/login';

        bool isAdminRoute() => path.startsWith('/admin');
        bool isCompanyRoute() => path.startsWith('/company');
        bool isCatalogRoute() => path.startsWith('/catalog');

        // No logueado: solo puede estar en /login
        if (!logged) return loggingIn ? null : '/login';

        // Recién logueado: envía al "home" por rol
        if (loggingIn) {
          if (role == 0) return '/admin/companies';
          if (role == 1) return '/company/products';
          if (role == 2) return '/catalog';
          return '/login';
        }

        // Ya logueado: si entra a un lugar que no es de su rol, reubícalo
        if (role == 0 && !isAdminRoute()) return '/admin/companies';
        if (role == 1 && !isCompanyRoute()) return '/company/products';
        if (role == 2 && !isCatalogRoute()) return '/catalog';

        return null; // todo ok, no redirigir
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => AuthState()..loadMe(),
      child: MaterialApp.router(
        title: 'EcommerceUpsa',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(useMaterial3: true, colorSchemeSeed: Colors.indigo),
        routerConfig: _router,
        // nota: MaterialApp.router no lleva navigatorKey; ya lo pusimos en GoRouter
      ),
    );
  }
}

class _RouterAuthListenable extends ChangeNotifier {
  static _RouterAuthListenable? _instance;
  static AuthState? get currentAuth => _instance?._auth;
  AuthState? _auth;

  _RouterAuthListenable() {
    _instance = this;
    // escucha Provider cuando el árbol ya existe
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final ctx = navigatorKey.currentContext;
      if (ctx != null) {
        _auth = Provider.of<AuthState>(ctx, listen: false);
        _auth?.addListener(notifyListeners);
      }
    });
  }

  @override
  void dispose() {
    _auth?.removeListener(notifyListeners);
    super.dispose();
  }
}
