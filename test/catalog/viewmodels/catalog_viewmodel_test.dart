import 'package:flutter_test/flutter_test.dart';
import 'package:ecommerce_flutter/features/catalog/domain/entities/product.dart';
import 'package:ecommerce_flutter/features/catalog/presentation/viewmodels/catalog_viewmodel.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

void main() {
  test('CatalogViewModel fetches products', () async {
    final container = ProviderContainer();
    final viewModel = container.read(catalogViewModelProvider.notifier);

    final products = await viewModel.build();

    expect(products, isA<List<Product>>());
    expect(products, isNotEmpty);
  });
}
