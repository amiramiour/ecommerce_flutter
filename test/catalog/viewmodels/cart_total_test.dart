import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:ecommerce_flutter/features/cart/presentation/viewmodels/cart_viewmodel.dart';
import 'package:ecommerce_flutter/features/catalog/domain/entities/product.dart';

void main() {
  test('Cart total sums prices × quantities', () {
    final container = ProviderContainer();
    final cart = container.read(cartProvider.notifier);

    final p1 = Product(
      id: 1,
      title: 'A',
      price: 10,
      thumbnail: '',
      description: '',
      category: '',
      images: const [],
    );
    final p2 = Product(
      id: 2,
      title: 'B',
      price: 5.5,
      thumbnail: '',
      description: '',
      category: '',
      images: const [],
    );

    cart.add(p1);
    cart.add(p2);
    cart.add(p1);

    final total = container.read(cartTotalProvider);
    expect(total, 10 * 2 + 5.5);
  });
}
