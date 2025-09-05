import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../catalog/domain/entities/product.dart';
import '../../domain/entities/cart_item.dart';

class CartController extends StateNotifier<List<CartItem>> {
  CartController() : super(const []);

  void add(Product p, {int qty = 1}) {
    final idx = state.indexWhere((e) => e.productId == p.id);
    if (idx == -1) {
      state = [
        ...state,
        CartItem(
          productId: p.id,
          title: p.title,
          thumbnail: p.thumbnail,
          price: p.price,
          quantity: qty,
        )
      ];
    } else {
      final updated = [...state];
      final current = updated[idx];
      updated[idx] = current.copyWith(quantity: current.quantity + qty);
      state = updated;
    }
  }

  void increment(int productId) {
    final idx = state.indexWhere((e) => e.productId == productId);
    if (idx == -1) return;
    final updated = [...state];
    updated[idx] = updated[idx].copyWith(quantity: updated[idx].quantity + 1);
    state = updated;
  }

  void decrement(int productId) {
    final idx = state.indexWhere((e) => e.productId == productId);
    if (idx == -1) return;
    final item = state[idx];
    if (item.quantity <= 1) {
      remove(productId);
    } else {
      final updated = [...state];
      updated[idx] = item.copyWith(quantity: item.quantity - 1);
      state = updated;
    }
  }

  void remove(int productId) {
    state = state.where((e) => e.productId != productId).toList();
  }

  void clear() => state = const [];
}

final cartProvider =
StateNotifierProvider<CartController, List<CartItem>>((ref) => CartController());

final cartTotalProvider = Provider<double>((ref) {
  final items = ref.watch(cartProvider);
  return items.fold<double>(0, (sum, e) => sum + e.price * e.quantity);
});

final cartCountProvider = Provider<int>((ref) {
  final items = ref.watch(cartProvider);
  return items.fold<int>(0, (sum, e) => sum + e.quantity);
});
