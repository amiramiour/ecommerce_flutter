import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../domain/entities/product.dart';
import '../../domain/repositories/catalog_repository.dart';
import '../../data/datasources/catalog_remote_datasource.dart';
import '../../data/repositories/catalog_repository_impl.dart';

/// --- Data layer providers (DI propre) ---
final catalogRemoteDataSourceProvider =
    Provider<CatalogRemoteDataSource>((ref) => CatalogRemoteDataSource());

final catalogRepositoryProvider = Provider<CatalogRepository>((ref) {
  final ds = ref.watch(catalogRemoteDataSourceProvider);
  return CatalogRepositoryImpl(remoteDataSource: ds);
});

/// --- ViewModel (AsyncNotifier) ---
class CatalogViewModel extends AsyncNotifier<List<Product>> {
  @override
  Future<List<Product>> build() async {
    final repo = ref.read(catalogRepositoryProvider);
    return await repo.getProducts();
  }
}

final catalogViewModelProvider =
    AsyncNotifierProvider<CatalogViewModel, List<Product>>(
        CatalogViewModel.new);

/// --- Product by id (pour la page détail) ---
final productByIdProvider = Provider.family<Product?, int>((ref, id) {
  final list = ref.watch(catalogViewModelProvider).valueOrNull;
  if (list == null) return null;
  try {
    return list.firstWhere((p) => p.id == id);
  } catch (_) {
    return null;
  }
});

/// --- UI state: recherche + catégorie sélectionnée ---
final searchQueryProvider = StateProvider<String>((ref) => '');
final selectedCategoryProvider = StateProvider<String?>((ref) => null);

/// --- Tri & disposition (grille/liste) ---
enum SortOrder { relevance, priceAsc, priceDesc, titleAsc, titleDesc }

final sortOrderProvider =
    StateProvider<SortOrder>((ref) => SortOrder.relevance);
final isGridProvider = StateProvider<bool>((ref) => true);

/// Catégories disponibles (déduites localement)
final categoriesProvider = Provider<List<String>>((ref) {
  final list =
      ref.watch(catalogViewModelProvider).valueOrNull ?? const <Product>[];
  final set = <String>{};
  for (final p in list) {
    final c = p.category.trim();
    if (c.isNotEmpty) set.add(c);
  }
  final cats = set.toList()..sort();
  return cats;
});

/// Produits filtrés (recherche + catégorie) puis triés
final filteredProductsProvider = Provider<List<Product>>((ref) {
  final list =
      ref.watch(catalogViewModelProvider).valueOrNull ?? const <Product>[];
  final q = ref.watch(searchQueryProvider).trim().toLowerCase();
  final cat = ref.watch(selectedCategoryProvider);
  final sort = ref.watch(sortOrderProvider);

  // filtre
  final filtered = list.where((p) {
    final matchQuery = q.isEmpty ||
        p.title.toLowerCase().contains(q) ||
        p.description.toLowerCase().contains(q);
    final matchCat = (cat == null) || p.category == cat;
    return matchQuery && matchCat;
  }).toList();

  // tri
  switch (sort) {
    case SortOrder.relevance:
      // on garde l’ordre naturel (API)
      break;
    case SortOrder.priceAsc:
      filtered.sort((a, b) => a.price.compareTo(b.price));
      break;
    case SortOrder.priceDesc:
      filtered.sort((a, b) => b.price.compareTo(a.price));
      break;
    case SortOrder.titleAsc:
      filtered.sort(
          (a, b) => a.title.toLowerCase().compareTo(b.title.toLowerCase()));
      break;
    case SortOrder.titleDesc:
      filtered.sort(
          (a, b) => b.title.toLowerCase().compareTo(a.title.toLowerCase()));
      break;
  }

  return filtered;
});
