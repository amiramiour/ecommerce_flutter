import 'package:flutter_test/flutter_test.dart';
import 'package:ecommerce_flutter/features/catalog/presentation/viewmodels/catalog_viewmodel.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

void main() {
  test('Search query updates correctly', () {
    final container = ProviderContainer();
    final notifier = container.read(searchQueryProvider.notifier);

    notifier.state = 'Test';
    expect(container.read(searchQueryProvider), 'Test');
  });
}
