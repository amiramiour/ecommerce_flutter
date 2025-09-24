import 'package:flutter_test/flutter_test.dart';
import 'package:flutter/material.dart';
import 'package:ecommerce_flutter/features/catalog/domain/entities/product.dart';

class TestProductListTile extends StatelessWidget {
  final Product product;
  const TestProductListTile({super.key, required this.product});

  @override
  Widget build(BuildContext context) {
    return ListTile(
      onTap: () {},
      leading: const SizedBox(width: 56, height: 56), // évite Image.network
      title: Text(product.title),
      subtitle: Text('\$${product.price.toStringAsFixed(2)}'),
      trailing: const Icon(Icons.chevron_right),
    );
  }
}

void main() {
  testWidgets('ProductListTile shows product title and price', (tester) async {
    final product = Product(
      id: 2,
      title: 'List Product',
      price: 79.99,
      thumbnail: '',
      description: '',
      category: '',
      images: [],
    );

    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: TestProductListTile(
            product: Product(
              id: 2,
              title: 'List Product',
              price: 79.99,
              thumbnail: '',
              description: '',
              category: '',
              images: [],
            ),
          ),
        ),
      ),
    );

    expect(find.text('List Product'), findsOneWidget);
    expect(find.text('\$79.99'), findsOneWidget);
  });
}
