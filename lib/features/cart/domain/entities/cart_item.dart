class CartItem {
  final int productId;
  final String title;
  final String thumbnail;
  final double price;
  final int quantity;

  const CartItem({
    required this.productId,
    required this.title,
    required this.thumbnail,
    required this.price,
    required this.quantity,
  });

  CartItem copyWith({int? quantity}) => CartItem(
        productId: productId,
        title: title,
        thumbnail: thumbnail,
        price: price,
        quantity: quantity ?? this.quantity,
      );
}
