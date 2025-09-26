import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter/material.dart';

import 'package:ecommerce_flutter/features/checkout/presentation/pages/orders_page.dart';
import 'package:ecommerce_flutter/features/checkout/presentation/viewmodels/orders_viewmodel.dart';
import 'package:ecommerce_flutter/features/checkout/domain/entities/order.dart';
import 'package:ecommerce_flutter/features/cart/domain/entities/cart_item.dart';

Widget _wrapWithMaterial(Widget child, ProviderContainer container) {
  return UncontrolledProviderScope(
    container: container,
    child: MaterialApp(home: child),
  );
}

/// Contrôleur de test qui remplace OrdersController
class TestOrdersController extends OrdersController {
  TestOrdersController(List<Order> initial) : super() {
    state = initial;
  }
}

void main() {
  testWidgets('affiche message vide si aucune commande',
          (WidgetTester tester) async {
        final container = ProviderContainer(
          overrides: [
            ordersProvider.overrideWith((ref) => TestOrdersController([])),
          ],
        );
        addTearDown(container.dispose);

        await tester.pumpWidget(_wrapWithMaterial(const OrdersPage(), container));

        expect(find.textContaining('Aucune commande'), findsOneWidget);
      });

  testWidgets('affiche une liste de commandes', (WidgetTester tester) async {
    final fakeOrders = [
      Order(
        id: '1',
        items: <CartItem>[],
        createdAt: DateTime.now(),
        total: 10.0,
        status: 'paid',
      ),
      Order(
        id: '2',
        items: <CartItem>[],
        createdAt: DateTime.now(),
        total: 20.0,
        status: 'pending',
      ),
    ];

    final container = ProviderContainer(
      overrides: [
        ordersProvider.overrideWith((ref) => TestOrdersController(fakeOrders)),
      ],
    );
    addTearDown(container.dispose);

    await tester.pumpWidget(_wrapWithMaterial(const OrdersPage(), container));

    expect(find.textContaining('Commande #1'), findsOneWidget);
    expect(find.textContaining('Commande #2'), findsOneWidget);
  });
}
