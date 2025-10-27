import 'dart:async'; // 👈 necesario para Timer
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../services/catalog_service.dart';
import '../../services/favorites_service.dart';
import '../../services/cart_service.dart';
import '../../state/cart_state.dart';
import '../../models/company_models.dart';
import '../../models/product_models.dart';

class CatalogPage extends StatefulWidget {
  const CatalogPage({super.key});
  @override
  State<CatalogPage> createState() => _CatalogPageState();
}

class _CatalogPageState extends State<CatalogPage> {
  final _catalog = CatalogService();
  final _fav = FavoritesService();
  final _cartSvc = CartService(); // por si lo usás después

  List<CompanyDto> _companies = [];
  List<ProductDto> _products = [];
  Set<String> _favIds = {};
  String? _companyId;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _loadAll();

    // ⏱️ Watchdog: si a los 8s sigue cargando, cortamos y avisamos.
    Timer(const Duration(seconds: 8), () {
      if (mounted && _loading) {
        setState(() => _loading = false);
        _showError('Red lenta o CORS en Azure. Mostrando vista sin datos.');
      }
    });
  }

  void _showError(Object e) {
    if (!mounted) return;
    final msg = e.toString().replaceFirst('Exception: ', '');
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(msg.isEmpty ? 'Ocurrió un error' : msg)),
    );
  }

  /// Carga empresas y productos con timeouts;
  /// Favoritos se sincroniza en segundo plano para no bloquear la UI.
  Future<void> _loadAll() async {
    setState(() => _loading = true);
    try {
      // 1) Empresas (timeout 6s)
      _companies = await _catalog
          .companies()
          .timeout(const Duration(seconds: 6), onTimeout: () {
        throw Exception('Timeout cargando empresas');
      });

      // 2) Productos de la primera empresa (timeout 6s)
      if (_companies.isNotEmpty) {
        _companyId = _companies.first.id;
        _products = await _catalog
            .productsByCompany(_companyId!)
            .timeout(const Duration(seconds: 6), onTimeout: () {
          throw Exception('Timeout cargando productos');
        });
      } else {
        _products = [];
      }

      // 3) Favoritos en segundo plano (timeout 6s, silencioso)
      _syncFavoritesSilently();
    } catch (e) {
      _showError('No se pudo cargar el catálogo: $e');
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _syncFavoritesSilently() async {
    try {
      final ids = await _fav
          .myFavoritesIds()
          .timeout(const Duration(seconds: 6));
      if (!mounted) return;
      setState(() => _favIds = ids.toSet());
    } catch (_) {
      // No bloquea la pantalla ni muestra error.
    }
  }

  Future<void> _changeCompany(String? id) async {
    if (id == null) return;
    setState(() {
      _companyId = id;
      _loading = true;
      _products = [];
    });
    try {
      _products = await _catalog
          .productsByCompany(id)
          .timeout(const Duration(seconds: 6), onTimeout: () {
        throw Exception('Timeout cargando productos');
      });
      _syncFavoritesSilently();
    } catch (e) {
      _showError('No se pudieron cargar los productos de la empresa: $e');
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _toggleFav(String productId) async {
    try {
      await _fav.toggle(productId);
      setState(() {
        if (_favIds.contains(productId)) {
          _favIds.remove(productId);
        } else {
          _favIds.add(productId);
        }
      });
    } catch (e) {
      _showError('No se pudo actualizar favorito: $e');
    }
  }

  Future<void> _addToCart(ProductDto p) async {
    final qty = await showModalBottomSheet<int>(
      context: context,
      builder: (_) => _QtySheet(
        productName: p.name,
        price: p.price,
        max: p.stock <= 0 ? 9999 : p.stock,
      ),
    );
    if (qty == null) return;

    try {
      await context.read<CartState>().add(p.id, qty);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Agregado x$qty: ${p.name}')),
      );
    } catch (e) {
      _showError('No se pudo agregar al carrito: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    final hasCompanies = _companies.isNotEmpty;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Catálogo'),
        actions: [
          Consumer<CartState>(
            builder: (_, cart, __) => Stack(
              alignment: Alignment.topRight,
              children: [
                IconButton(
                  onPressed: () => Navigator
                      .pushNamed(context, '/cart')
                      .then((_) => context.read<CartState>().sync()),
                  icon: const Icon(Icons.shopping_cart_outlined),
                  tooltip: 'Carrito',
                ),
                if (cart.count > 0)
                  Positioned(
                    right: 6,
                    top: 6,
                    child: Container(
                      padding: const EdgeInsets.all(4),
                      decoration: const BoxDecoration(color: Colors.red, shape: BoxShape.circle),
                      child: Text(
                        '${cart.count}',
                        style: const TextStyle(color: Colors.white, fontSize: 11),
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                if (hasCompanies)
                  Padding(
                    padding: const EdgeInsets.fromLTRB(12, 12, 12, 4),
                    child: Row(
                      children: [
                        const Text('Empresa:'),
                        const SizedBox(width: 8),
                        Expanded(
                          child: DropdownButton<String>(
                            value: _companyId,
                            isExpanded: true,
                            items: _companies
                                .map((c) =>
                                  DropdownMenuItem(value: c.id, child: Text(c.name)))
                                .toList(),
                            onChanged: _changeCompany,
                          ),
                        ),
                      ],
                    ),
                  )
                else
                  const Padding(
                    padding: EdgeInsets.all(16),
                    child: Align(
                      alignment: Alignment.centerLeft,
                      child: Text('No hay empresas activas'),
                    ),
                  ),
                Expanded(
                  child: _products.isEmpty
                      ? const Center(child: Text('Sin productos'))
                      : GridView.builder(
                          padding: const EdgeInsets.all(12),
                          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 2,
                            mainAxisSpacing: 12,
                            crossAxisSpacing: 12,
                            childAspectRatio: 0.72,
                          ),
                          itemCount: _products.length,
                          itemBuilder: (_, i) {
                            final p = _products[i];
                            final fav = _favIds.contains(p.id);
                            return Card(
                              clipBehavior: Clip.antiAlias,
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.stretch,
                                children: [
                                  Expanded(
                                    child: p.imageUrl != null
                                        ? Image.network(p.imageUrl!, fit: BoxFit.cover)
                                        : const Icon(Icons.image_not_supported, size: 56),
                                  ),
                                  Padding(
                                    padding: const EdgeInsets.all(8),
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          p.name,
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                          style: const TextStyle(fontWeight: FontWeight.bold),
                                        ),
                                        const SizedBox(height: 2),
                                        Text('Bs. ${p.price.toStringAsFixed(2)}'),
                                        const SizedBox(height: 6),
                                        Row(
                                          children: [
                                            IconButton(
                                              icon: Icon(
                                                fav ? Icons.favorite : Icons.favorite_border,
                                              ),
                                              onPressed: () => _toggleFav(p.id),
                                            ),
                                            const SizedBox(width: 4),
                                            Expanded(
                                              child: ElevatedButton.icon(
                                                onPressed: () => _addToCart(p),
                                                icon: const Icon(Icons.add_shopping_cart),
                                                label: const Text('Agregar'),
                                              ),
                                            ),
                                          ],
                                        )
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            );
                          },
                        ),
                ),
              ],
            ),
    );
  }
}

class _QtySheet extends StatefulWidget {
  final String productName;
  final double price;
  final int max;
  const _QtySheet({required this.productName, required this.price, required this.max});
  @override
  State<_QtySheet> createState() => _QtySheetState();
}

class _QtySheetState extends State<_QtySheet> {
  int _qty = 1;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(mainAxisSize: MainAxisSize.min, children: [
        Text(widget.productName, style: const TextStyle(fontWeight: FontWeight.bold)),
        const SizedBox(height: 8),
        Row(mainAxisAlignment: MainAxisAlignment.center, children: [
          IconButton(
            onPressed: _qty > 1 ? () => setState(() => _qty--) : null,
            icon: const Icon(Icons.remove),
          ),
          Text('$_qty'),
          IconButton(
            onPressed: _qty < (widget.max <= 0 ? 9999 : widget.max)
                ? () => setState(() => _qty++)
                : null,
            icon: const Icon(Icons.add),
          ),
        ]),
        const SizedBox(height: 8),
        ElevatedButton(
          onPressed: () => Navigator.pop(context, _qty),
          child: Text('Agregar • Bs. ${(widget.price * _qty).toStringAsFixed(2)}'),
        ),
        const SizedBox(height: 8),
      ]),
    );
  }
}
