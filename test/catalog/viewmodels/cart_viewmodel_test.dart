import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ecommerce_flutter/features/cart/presentation/viewmodels/cart_viewmodel.dart';
import 'package:ecommerce_flutter/features/catalog/domain/entities/product.dart';

void main() {
  test('Add product to cart increases count', () {
    final container = ProviderContainer();
    final cart = container.read(cartProvider.notifier);

    final product = Product(
      id: 1,
      title: 'Test',
      price: 10,
      thumbnail: '',
      description: '',
      category: '',
      images: [], //  ajouté ici
    );

    cart.add(product);

    final count = container.read(cartCountProvider);
    expect(count, 1);
  });
}
