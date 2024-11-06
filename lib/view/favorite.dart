import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../model/product.dart'; // Import model produk
import '../controller/product.dart'; // Import controller produk
import '../controller/cart.dart'; // Import controller cart
import 'detail.dart'; // Import halaman detail produk
import 'cart.dart'; // Import halaman cart
import 'package:intl/intl.dart';

class FavoritePage extends StatefulWidget {
  @override
  _FavoritePageState createState() => _FavoritePageState();
}

class _FavoritePageState extends State<FavoritePage> {
  final ProductController _productController = ProductController();
  final CartController _cartController = CartController();
  List<Product> _favoriteProducts = [];
  final NumberFormat _currencyFormat = NumberFormat.simpleCurrency(locale: 'id_ID', name: 'IDR');
  bool _isLoading = true; // Status loading
  int _cartItemCount = 0; // Jumlah item di keranjang

  @override
  void initState() {
    super.initState();
    _loadFavoriteProducts();
    _loadCartItems();
  }

  void _loadFavoriteProducts() async {
    setState(() {
      _isLoading = true; // Mulai loading
    });

    try {
      final prefs = await SharedPreferences.getInstance();
      final favoriteIds = prefs.getStringList('favorites') ?? [];
      final List<Product> products = await _productController.fetchProducts();

      setState(() {
        _favoriteProducts = products.where((product) => favoriteIds.contains(product.id.toString())).toList();
        _isLoading = false; // Loading selesai
      });
    } catch (e) {
      setState(() {
        _isLoading = false; // Loading selesai, walaupun gagal
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Gagal memuat produk favorit: $e')),
      );
    }
  }

  void _loadCartItems() async {
    try {
      final cartItems = await _cartController.getCartItems();
      setState(() {
        _cartItemCount = cartItems.length;
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Gagal memuat item di keranjang: $e')),
      );
    }
  }

  void _removeFromFavorites(Product product) async {
    final prefs = await SharedPreferences.getInstance();
    final favoriteIds = prefs.getStringList('favorites') ?? [];
    favoriteIds.remove(product.id.toString());
    await prefs.setStringList('favorites', favoriteIds);

    setState(() {
      _favoriteProducts.remove(product);
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('${product.nama} dihapus dari favorit')),
    );
  }

  void _navigateToProductDetail(Product product) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ProductDetailView(
          product: product,
          onCartUpdated: _loadFavoriteProducts, // Optional: refresh favorite products when returning
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Favorit',
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: Colors.green,
        actions: [
          IconButton(
            icon: Stack(
              children: [
                Icon(Icons.shopping_cart, color: Colors.white),
                if (_cartItemCount > 0)
                  Positioned(
                    right: 0,
                    top: 0,
                    child: Container(
                      padding: EdgeInsets.all(2),
                      decoration: BoxDecoration(
                        color: Colors.red,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      constraints: BoxConstraints(
                        maxWidth: 15,
                        maxHeight: 15,
                      ),
                      child: Center(
                        child: Text(
                          '$_cartItemCount',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 8,
                            fontWeight: FontWeight.bold,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ),
                  ),
              ],
            ),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => CartPage()),
              );
            },
          ),
        ],
      ),
      body: _isLoading
          ? Center(child: CircularProgressIndicator()) // Tampilkan loading saat isLoading true
          : _favoriteProducts.isEmpty
              ? Center(child: Text('Belum ada produk favorit'))
              : ListView.builder(
                  itemCount: _favoriteProducts.length,
                  itemBuilder: (context, index) {
                    final product = _favoriteProducts[index];
                    return GestureDetector(
                      onTap: () => _navigateToProductDetail(product),
                      child: Container(
                        margin: EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
                        padding: EdgeInsets.all(8.0),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(8.0),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.grey.withOpacity(0.2),
                              spreadRadius: 2,
                              blurRadius: 4,
                              offset: Offset(0, 2),
                            ),
                          ],
                        ),
                        child: Row(
                          children: [
                            Image.network(
                              'http://192.168.0.160/ecomart/public/storage/'+product.gambar,
                              width: 80,
                              height: 80,
                              fit: BoxFit.cover,
                            ),
                            SizedBox(width: 16),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    product.nama,
                                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  SizedBox(height: 8),
                                  Text(
                                    _currencyFormat.format(product.harga),
                                    style: TextStyle(color: Colors.green, fontSize: 14),
                                  ),
                                ],
                              ),
                            ),
                            IconButton(
                              icon: Icon(Icons.favorite, color: Colors.red),
                              onPressed: () => _removeFromFavorites(product),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
    );
  }
}
