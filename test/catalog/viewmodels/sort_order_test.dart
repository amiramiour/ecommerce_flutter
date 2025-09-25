import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ecommerce_flutter/features/catalog/presentation/viewmodels/catalog_viewmodel.dart';

void main() {
  test('Sort order changes properly', () {
    final container = ProviderContainer();
    final sortNotifier = container.read(sortOrderProvider.notifier);

    sortNotifier.state = SortOrder.priceAsc;
    expect(container.read(sortOrderProvider), SortOrder.priceAsc);
  });
}
