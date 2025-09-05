import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/entities/product.dart';
import '../../data/datasources/catalog_remote_datasource.dart';
import '../../data/repositories/catalog_repository_impl.dart';

class CatalogViewModel extends AsyncNotifier<List<Product>> {
  @override
  Future<List<Product>> build() async {
    final repository = CatalogRepositoryImpl(
      remoteDataSource: CatalogRemoteDataSource(),
    );

    return await repository.getProducts();
  }
}

// Provider exposé à la vue
final catalogViewModelProvider =
AsyncNotifierProvider<CatalogViewModel, List<Product>>(CatalogViewModel.new);
