import 'dart:convert';
import 'package:http/http.dart' as http;
import '../model/product.dart';

class ProductController {
  final String _baseUrl = 'http://192.168.0.160/ecomart/public/api';

  // Mengambil daftar produk berdasarkan ID
  Future<List<Product>> getProductsByIds(List<int> ids) async {
    try {
      final response = await http.post(
        Uri.parse('$_baseUrl/products/by_ids'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'ids': ids}),
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        return data.map((item) => Product.fromJson(item)).toList();
      } else {
        throw Exception('Failed to load products');
      }
    } catch (e) {
      throw Exception('Failed to load products: $e');
    }
  }

  // Mengambil daftar produk
  Future<List<Product>> fetchProducts() async {
    try {
      final response = await http.get(Uri.parse('$_baseUrl/products'));
      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        return data.map((json) => Product.fromJson(json)).toList();
      } else {
        throw Exception('Failed to load products');
      }
    } catch (e) {
      throw Exception('Failed to load products: $e');
    }
  }
}
