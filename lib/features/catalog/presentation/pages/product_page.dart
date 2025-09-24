import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../domain/entities/product.dart';
import '../viewmodels/catalog_viewmodel.dart';
import '../../../cart/presentation/viewmodels/cart_viewmodel.dart';

class ProductPage extends ConsumerStatefulWidget {
  final String productId;
  const ProductPage({super.key, required this.productId});

  @override
  ConsumerState<ProductPage> createState() => _ProductPageState();
}

class _ProductPageState extends ConsumerState<ProductPage> {
  int quantity = 1;

  @override
  Widget build(BuildContext context) {
    // Garantit le chargement (si deep-link direct)
    final listAsync = ref.watch(catalogViewModelProvider);
    final id = int.tryParse(widget.productId);

    return Scaffold(
      appBar: AppBar(
        title: const Text("Détail du produit"),
        actions: [
          // Badge panier
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
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: Theme.of(context).colorScheme.primary,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Text(
                          '$count',
                          style: const TextStyle(fontSize: 11, color: Colors.white),
                        ),
                      ),
                    ),
                ],
              );
            },
          ),
        ],
      ),
      body: listAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('Erreur : $e')),
        data: (_) {
          if (id == null) return const Center(child: Text('ID produit invalide'));
          final product = ref.watch(productByIdProvider(id));
          if (product == null) return const Center(child: Text('Produit introuvable'));

          return _ProductContent(
            product: product,
            quantity: quantity,
            onDec: () => setState(() {
              if (quantity > 1) quantity--;
            }),
            onInc: () => setState(() => quantity++),
            onAdd: () {
              ref.read(cartProvider.notifier).add(product, qty: quantity);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Ajouté au panier ✅')),
              );
            },
          );
        },
      ),
    );
  }
}

class _ProductContent extends StatelessWidget {
  final Product product;
  final int quantity;
  final VoidCallback onDec;
  final VoidCallback onInc;
  final VoidCallback onAdd;

  const _ProductContent({
    required this.product,
    required this.quantity,
    required this.onDec,
    required this.onInc,
    required this.onAdd,
  });

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Image
          ClipRRect(
            borderRadius: BorderRadius.circular(16),
            child: AspectRatio(
              aspectRatio: 16 / 10,
              child: Image.network(
                product.thumbnail,
                fit: BoxFit.cover,
                alignment: Alignment.center,
              ),
            ),
          ),
          const SizedBox(height: 16),

          // Titre
          Text(
            product.title,
            style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 8),

          if (product.category.isNotEmpty)
            Chip(
              label: Text(product.category),
              backgroundColor: Theme.of(context).colorScheme.primary.withOpacity(.08),
              labelStyle: TextStyle(color: Theme.of(context).colorScheme.primary),
            ),
          const SizedBox(height: 12),

          // Prix
          Text(
            '\$${product.price.toStringAsFixed(2)}',
            style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.deepPurple),
          ),
          const SizedBox(height: 16),

          // Description
          Text(product.description, style: Theme.of(context).textTheme.bodyMedium),
          const SizedBox(height: 24),

          // Quantité
          Row(
            children: [
              const Text('Quantité', style: TextStyle(fontWeight: FontWeight.w600)),
              const SizedBox(width: 12),
              IconButton(icon: const Icon(Icons.remove_circle_outline), onPressed: onDec),
              Text('$quantity', style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
              IconButton(icon: const Icon(Icons.add_circle_outline), onPressed: onInc),
            ],
          ),
          const SizedBox(height: 16),

          // Ajouter au panier
          SizedBox(
            width: double.infinity,
            height: 52,
            child: FilledButton.icon(
              icon: const Icon(Icons.add_shopping_cart),
              label: const Text('Ajouter au panier'),
              onPressed: onAdd,
            ),
          ),
        ],
      ),
    );
  }
}
