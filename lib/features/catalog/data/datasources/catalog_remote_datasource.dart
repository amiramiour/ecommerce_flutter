import 'dart:convert';
import 'package:http/http.dart' as http;
import '../../domain/entities/product.dart';

class CatalogRemoteDataSource {
  Future<List<Product>> fetchProducts() async {
    final response =
        await http.get(Uri.parse('https://fakestoreapi.com/products'));

    if (response.statusCode == 200) {
      final List<dynamic> data = jsonDecode(response.body);
      return data.map((json) => Product.fromJson(json)).toList();
    } else {
      throw Exception('Erreur lors du chargement des produits');
    }
  }
}
