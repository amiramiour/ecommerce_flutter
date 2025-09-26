import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:ecommerce_flutter/features/checkout/presentation/pages/orders_page.dart';

void main() {
  testWidgets('OrdersPage affiche le message quand aucune commande',
      (tester) async {
    await tester.pumpWidget(
      const ProviderScope(
        child: MaterialApp(home: OrdersPage()),
      ),
    );

    expect(find.text('Mes commandes'), findsOneWidget);
    expect(find.text('Aucune commande pour le moment'), findsOneWidget);
  });
}
