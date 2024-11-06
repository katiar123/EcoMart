import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import '../model/product.dart';
import 'detail.dart';

class ProductPage extends StatefulWidget {
  @override
  ProductState createState() => ProductState();
}

class ProductState extends State<ProductPage> {
  List<Product> makanan = [];
  List<Product> tools = [];
  List<Product> cosmetics = [];

  @override
  void initState() {
    super.initState();
    fetchProducts();
  }

  Future<void> fetchProducts() async {
    final url = Uri.parse('http://192.168.0.160/ecomart/public/api/products');
    final response = await http.get(url);

    if (response.statusCode == 200) {
      final List<dynamic> data = json.decode(response.body);
      setState(() {
        // Konversi data menjadi list Product
        final products = data.map((item) => Product.fromJson(item)).toList();
        makanan = products.where((item) => item.kategori == 'makanan').toList();
        tools = products.where((item) => item.kategori == 'Tools').toList();
        cosmetics = products.where((item) => item.kategori == 'Cosmetics').toList();
      });
    } else {
      throw Exception('Failed to load products');
    }
  }

  Widget _buildProductGrid(String title, List<Product> items) {
    return Padding(
      padding: const EdgeInsets.all(10.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: TextStyle(
              color: Colors.black,
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: 16.0),
          Container(
            height: 220,
            child: GridView.count(
              shrinkWrap: true,
              physics: NeverScrollableScrollPhysics(),
              crossAxisCount: 4,
              crossAxisSpacing: 16.0,
              mainAxisSpacing: 16.0,
              children: items.map((product) {
                return GestureDetector(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => ProductDetailView(product: product),
                      ),
                    );
                  },
                  child: Column(
                    children: [
                      Card(
                        child: Image.network(
                          'http://192.168.0.160/ecomart/public/storage/' +
                              product.gambar,
                          height: 49,
                          width: 60,
                          fit: BoxFit.cover,
                        ),
                      ),
                      Text(
                        product.nama,
                        style: TextStyle(
                          fontSize: 16.0,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                );
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.green,
        title: Center(
          child: Text(
            'Products',
            style: TextStyle(
              color: Colors.white,
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.search),
            onPressed: () {},
          ),
        ],
        elevation: 0,
      ),
      body: ListView(
        children: [
          makanan.isEmpty && tools.isEmpty && cosmetics.isEmpty
              ? Center(child: CircularProgressIndicator())
              : Column(
                  children: [
                    if (makanan.isNotEmpty) _buildProductGrid('Makanan', makanan),
                    if (tools.isNotEmpty) _buildProductGrid('Tools', tools),
                    if (cosmetics.isNotEmpty) _buildProductGrid('Cosmetics', cosmetics),
                  ],
                ),
        ],
      ),
    );
  }
}
