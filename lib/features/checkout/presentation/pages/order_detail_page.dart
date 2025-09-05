import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../viewmodels/orders_viewmodel.dart';

class OrderDetailPage extends ConsumerWidget {
  final String orderId;
  const OrderDetailPage({super.key, required this.orderId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final orders = ref.watch(ordersProvider);
    final order = orders.firstWhere((o) => o.id == orderId);

    return Scaffold(
      appBar: AppBar(title: Text('Commande #${order.id}')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Date : ${order.createdAt.toLocal()}'),
            Text('Statut : ${order.status}'),
            const SizedBox(height: 12),
            Text('Articles :', style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 8),
            Expanded(
              child: ListView.builder(
                itemCount: order.items.length,
                itemBuilder: (_, i) {
                  final it = order.items[i];
                  return ListTile(
                    leading: Image.network(it.thumbnail, width: 50, height: 50),
                    title: Text(it.title, maxLines: 2, overflow: TextOverflow.ellipsis),
                    subtitle: Text('${it.quantity} × \$${it.price.toStringAsFixed(2)}'),
                    trailing: Text(
                      '\$${(it.price * it.quantity).toStringAsFixed(2)}',
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                  );
                },
              ),
            ),
            const SizedBox(height: 12),
            Text(
              'Total : \$${order.total.toStringAsFixed(2)}',
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
          ],
        ),
      ),
    );
  }
}
