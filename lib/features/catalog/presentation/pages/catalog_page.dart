import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../auth/presentation/viewmodels/auth_controller.dart';
import '../viewmodels/catalog_viewmodel.dart';
import '../../domain/entities/product.dart';
import '../../../cart/presentation/viewmodels/cart_viewmodel.dart';
import 'package:ecommerce_flutter/features/common/presentation/widgets/app_drawer.dart';

class CatalogPage extends ConsumerStatefulWidget {
  const CatalogPage({super.key});

  @override
  ConsumerState<CatalogPage> createState() => _CatalogPageState();
}

class _CatalogPageState extends ConsumerState<CatalogPage> {
  final _searchCtrl = TextEditingController();
  Timer? _debounce;

  @override
  void initState() {
    super.initState();
    _searchCtrl.text = ref.read(searchQueryProvider);
    _searchCtrl.addListener(_onSearchChanged);
  }

  void _onSearchChanged() {
    _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 250), () {
      ref.read(searchQueryProvider.notifier).state = _searchCtrl.text;
    });
  }

  @override
  void dispose() {
    _debounce?.cancel();
    _searchCtrl.dispose();
    super.dispose();
  }

  Future<void> _refresh() async {
    await ref.refresh(catalogViewModelProvider.future);
  }

  @override
  Widget build(BuildContext context) {
    final productsAsync = ref.watch(catalogViewModelProvider);
    final filtered = ref.watch(filteredProductsProvider);
    final categories = ref.watch(categoriesProvider);
    final selectedCat = ref.watch(selectedCategoryProvider);
    final isGrid = ref.watch(isGridProvider);
    final sort = ref.watch(sortOrderProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Catalogue'),
        // Boutons actions en haut à droite
        actions: [
          // Grille / Liste
          IconButton(
            tooltip: isGrid ? 'Vue liste' : 'Vue grille',
            icon: Icon(isGrid ? Icons.view_list : Icons.grid_view),
            onPressed: () => ref.read(isGridProvider.notifier).state = !isGrid,
          ),

          // Tri
          PopupMenuButton<SortOrder>(
            tooltip: 'Trier',
            initialValue: sort,
            onSelected: (value) =>
                ref.read(sortOrderProvider.notifier).state = value,
            itemBuilder: (context) => const [
              PopupMenuItem(
                  value: SortOrder.relevance, child: Text('Pertinence')),
              PopupMenuItem(value: SortOrder.priceAsc, child: Text('Prix ↑')),
              PopupMenuItem(value: SortOrder.priceDesc, child: Text('Prix ↓')),
              PopupMenuItem(
                  value: SortOrder.titleAsc, child: Text('Titre A→Z')),
              PopupMenuItem(
                  value: SortOrder.titleDesc, child: Text('Titre Z→A')),
            ],
            icon: const Icon(Icons.sort),
          ),

          // Commandes
          IconButton(
            icon: const Icon(Icons.receipt_long),
            tooltip: 'Mes commandes',
            onPressed: () => context.push('/orders'),
          ),

          // Panier avec badge
          Builder(
            builder: (context) {
              final count = ref.watch(cartCountProvider);
              return Stack(
                clipBehavior: Clip.none,
                children: [
                  IconButton(
                    icon: const Icon(Icons.shopping_cart),
                    tooltip: 'Panier',
                    onPressed: () => context.push('/cart'),
                  ),
                  if (count > 0)
                    Positioned(
                      right: 6,
                      top: 6,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: Theme.of(context).colorScheme.primary,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Text(
                          '$count',
                          style: const TextStyle(
                              fontSize: 11, color: Colors.white),
                        ),
                      ),
                    ),
                ],
              );
            },
          ),
        ],
        // Champ de recherche
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(64),
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
            child: TextField(
              controller: _searchCtrl,
              decoration: InputDecoration(
                hintText: 'Rechercher un produit…',
                prefixIcon: const Icon(Icons.search),
                isDense: true,
                filled: true,
                border:
                    OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
              ),
            ),
          ),
        ),
      ),

      drawer: const AppDrawer(), // ✅ Menu latéral

      body: productsAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, _) => Center(child: Text('Erreur : $err')),
        data: (_) => RefreshIndicator(
          onRefresh: _refresh,
          child: CustomScrollView(
            slivers: [
              // Catégories
              SliverToBoxAdapter(
                child: SizedBox(
                  height: 48,
                  child: ListView.separated(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    scrollDirection: Axis.horizontal,
                    itemCount: categories.length + 1,
                    separatorBuilder: (_, __) => const SizedBox(width: 8),
                    itemBuilder: (context, index) {
                      if (index == 0) {
                        final isSelected = selectedCat == null;
                        return FilterChip(
                          label: const Text('Tous'),
                          selected: isSelected,
                          onSelected: (_) => ref
                              .read(selectedCategoryProvider.notifier)
                              .state = null,
                        );
                      }
                      final cat = categories[index - 1];
                      final isSelected = selectedCat == cat;
                      return FilterChip(
                        label: Text(cat),
                        selected: isSelected,
                        onSelected: (_) => ref
                            .read(selectedCategoryProvider.notifier)
                            .state = cat,
                      );
                    },
                  ),
                ),
              ),

              // Grille ou Liste
              if (isGrid)
                SliverPadding(
                  padding: const EdgeInsets.all(16),
                  sliver: SliverGrid(
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      childAspectRatio: 0.7,
                      crossAxisSpacing: 16,
                      mainAxisSpacing: 16,
                    ),
                    delegate: SliverChildBuilderDelegate(
                      (context, index) {
                        final product = filtered[index];
                        return ProductCard(product: product);
                      },
                      childCount: filtered.length,
                    ),
                  ),
                )
              else
                SliverList.builder(
                  itemCount: filtered.length,
                  itemBuilder: (context, index) {
                    final product = filtered[index];
                    return ProductListTile(product: product);
                  },
                ),
            ],
          ),
        ),
      ),
    );
  }
}

class ProductCard extends StatelessWidget {
  final Product product;
  const ProductCard({super.key, required this.product});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () => context.push('/product/${product.id}'),
      child: Card(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        elevation: 3,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Expanded(
              child: ClipRRect(
                borderRadius:
                    const BorderRadius.vertical(top: Radius.circular(16)),
                child: Image.network(product.thumbnail, fit: BoxFit.cover),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(8),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(product.title,
                      maxLines: 2, overflow: TextOverflow.ellipsis),
                  const SizedBox(height: 4),
                  Text(
                    '\$${product.price.toStringAsFixed(2)}',
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Colors.deepPurple,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class ProductListTile extends StatelessWidget {
  final Product product;
  const ProductListTile({super.key, required this.product});

  @override
  Widget build(BuildContext context) {
    return ListTile(
      onTap: () => context.push('/product/${product.id}'),
      leading: ClipRRect(
        borderRadius: BorderRadius.circular(8),
        child: Image.network(product.thumbnail,
            width: 56, height: 56, fit: BoxFit.cover),
      ),
      title: Text(product.title, maxLines: 2, overflow: TextOverflow.ellipsis),
      subtitle: Text('\$${product.price.toStringAsFixed(2)}'),
      trailing: const Icon(Icons.chevron_right),
    );
  }
}
