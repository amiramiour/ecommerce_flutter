import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../cart/domain/entities/cart_item.dart';
import '../../domain/entities/order.dart';

class OrdersController extends StateNotifier<List<Order>> {
  OrdersController() : super(const []);

  void addOrder(List<CartItem> items, double total) {
    final order = Order(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      items: List.unmodifiable(items),
      total: total,
      createdAt: DateTime.now(),
      status: 'paid',
    );
    state = [order, ...state];
  }
}

final ordersProvider = StateNotifierProvider<OrdersController, List<Order>>(
    (ref) => OrdersController());
