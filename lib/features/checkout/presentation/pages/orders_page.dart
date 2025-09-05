import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../viewmodels/orders_viewmodel.dart';

class OrdersPage extends ConsumerWidget {
  const OrdersPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final orders = ref.watch(ordersProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Mes commandes')),
      body: orders.isEmpty
          ? const Center(child: Text('Aucune commande pour le moment'))
          : ListView.separated(
        padding: const EdgeInsets.all(16),
        separatorBuilder: (_, __) => const SizedBox(height: 12),
        itemCount: orders.length,
        itemBuilder: (_, i) {
          final o = orders[i];
          return Card(
            child: ListTile(
              title: Text('Commande #${o.id}'),
              subtitle: Text(
                '${o.items.length} article(s) • ${o.createdAt.toLocal()}',
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              trailing: Text(
                '\$${o.total.toStringAsFixed(2)}',
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
              onTap: () => context.push('/orders/${o.id}'),
            ),
          );
        },
      ),
    );
  }
}
