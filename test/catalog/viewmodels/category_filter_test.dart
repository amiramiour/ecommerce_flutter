import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ecommerce_flutter/features/catalog/presentation/viewmodels/catalog_viewmodel.dart';


void main() {
  test('Category filter updates correctly', () {
    final container = ProviderContainer();
    final notifier = container.read(selectedCategoryProvider.notifier);


    notifier.state = 'electronics';
    expect(container.read(selectedCategoryProvider), 'electronics');
  });
}