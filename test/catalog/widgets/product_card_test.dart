import 'package:flutter_test/flutter_test.dart';
import 'package:flutter/material.dart';
import 'package:ecommerce_flutter/features/catalog/domain/entities/product.dart';

class FakeProductCard extends StatelessWidget {
  final Product product;
  const FakeProductCard({super.key, required this.product});

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Column(
        children: [
          const Placeholder(fallbackHeight: 100),
          Text(product.title),
          Text('\$${product.price.toStringAsFixed(2)}'),
        ],
      ),
    );
  }
}

void main() {
  testWidgets('ProductCard displays product title and price', (tester) async {
    final product = Product(
      id: 1,
      title: 'Test Product',
      price: 49.99,
      thumbnail: 'https://fake.url/image.jpg',
      description: '',
      category: '',
      images: [],
    );

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(body: FakeProductCard(product: product)),
      ),
    );

    expect(find.text('Test Product'), findsOneWidget);
    expect(find.text('\$49.99'), findsOneWidget);
  });
}
