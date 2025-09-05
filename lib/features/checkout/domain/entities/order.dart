import '../../../cart/domain/entities/cart_item.dart';

class Order {
  final String id;
  final List<CartItem> items;
  final double total;
  final DateTime createdAt;
  final String status; // ex: 'paid'

  const Order({
    required this.id,
    required this.items,
    required this.total,
    required this.createdAt,
    required this.status,
  });
}
