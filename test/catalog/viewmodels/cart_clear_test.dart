import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:ecommerce_flutter/features/cart/presentation/viewmodels/cart_viewmodel.dart';
import 'package:ecommerce_flutter/features/catalog/domain/entities/product.dart';

void main() {
  test('Clear empties the cart and resets total/count', () {
    final container = ProviderContainer();
    final cart = container.read(cartProvider.notifier);

    final p = Product(
      id: 1,
      title: 'Test',
      price: 12.0,
      thumbnail: '',
      description: '',
      category: '',
      images: const [],
    );

    cart.add(p);
    cart.add(p);

    expect(container.read(cartCountProvider), 2);
    expect(container.read(cartTotalProvider), 24.0);

    cart.clear();

    expect(container.read(cartProvider), isEmpty);
    expect(container.read(cartCountProvider), 0);
    expect(container.read(cartTotalProvider), 0.0);
  });
}
