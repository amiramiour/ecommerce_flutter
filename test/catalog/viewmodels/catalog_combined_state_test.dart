import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:ecommerce_flutter/features/catalog/presentation/viewmodels/catalog_viewmodel.dart';

void main() {
  test('Combined catalog UI state providers update independently', () {
    final container = ProviderContainer();

    expect(container.read(searchQueryProvider), isA<String>());
    expect(container.read(selectedCategoryProvider), isA<String?>());
    expect(container.read(sortOrderProvider), isA<SortOrder>());

    container.read(searchQueryProvider.notifier).state = 'phone';
    container.read(selectedCategoryProvider.notifier).state = 'electronics';
    container.read(sortOrderProvider.notifier).state = SortOrder.priceDesc;

    expect(container.read(searchQueryProvider), 'phone');
    expect(container.read(selectedCategoryProvider), 'electronics');
    expect(container.read(sortOrderProvider), SortOrder.priceDesc);
  });
}
