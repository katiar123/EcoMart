import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../model/product.dart';
import '../model/cart.dart';
import '../controller/cart.dart';
import '../controller/favorite.dart';
import 'cart.dart';
import 'package:intl/intl.dart';
import 'favorite.dart';
import 'addres.dart'; // Pastikan nama file dan path benar

class ProductDetailView extends StatefulWidget {
  final Product product;
  final Function? onCartUpdated;

  ProductDetailView({required this.product,this.onCartUpdated});

  @override
  _ProductDetailViewState createState() => _ProductDetailViewState();
}

class _ProductDetailViewState extends State<ProductDetailView> {
  int quantity = 1;
  final CartController _cartController = CartController();
  final FavoriteController _favoriteController = FavoriteController();
  int _cartItemCount = 0;
  bool _isFavorite = false;

  final NumberFormat _currencyFormat = NumberFormat.simpleCurrency(locale: 'id_ID', name: 'IDR');

  void _addToCart() async {
    final cartItem = CartItem(
      id: 0,
      product_id: widget.product.id,
      nama: widget.product.nama,
      harga: widget.product.harga,
      kuantitas: quantity,
      gambar: widget.product.gambar,
    );

    try {
      await _cartController.addToCart(cartItem);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('${widget.product.nama} ditambahkan ke keranjang')),
      );
      _loadCartItems();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Gagal menambahkan ke keranjang: $e')),
      );
    }
  }

  void _incrementQuantity() {
    setState(() {
      quantity++;
    });
  }

  Future<void> _saveProductToLocalStorage() async {
    final prefs = await SharedPreferences.getInstance();
    final String productKey = 'product_${widget.product.id}';
    final productDetails = {
      'id': widget.product.id,
      'nama': widget.product.nama,
      'harga': widget.product.harga,
      'kuantitas': quantity,
      'gambar': widget.product.gambar,
    };

    try {
      await prefs.setString(productKey, jsonEncode(productDetails));
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Gagal menyimpan produk ke local storage: $e')),
      );
    }
  }

  void _decrementQuantity() {
    setState(() {
      if (quantity > 1) quantity--;
    });
  }

  Future<void> _buyNow() async {
  await _saveProductToLocalStorage();
  Navigator.push(
    context,
    MaterialPageRoute(
      builder: (context) => AddressPage(product: widget.product, quantity: quantity),
    ),
  );
}



  void _toggleFavorite() async {
    setState(() {
      _isFavorite = !_isFavorite;
    });

    try {
      final prefs = await SharedPreferences.getInstance();
      final favoriteList = prefs.getStringList('favorites') ?? [];

      if (_isFavorite) {
        favoriteList.add(widget.product.id.toString());
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('${widget.product.nama} ditambahkan ke favorit')),
        );
      } else {
        favoriteList.remove(widget.product.id.toString());
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('${widget.product.nama} dihapus dari favorit')),
        );
      }

      await prefs.setStringList('favorites', favoriteList);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Gagal mengupdate favorit: $e')),
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

  @override
  void initState() {
    super.initState();
    _loadCartItems();
    _checkIfFavorite();
  }

  void _checkIfFavorite() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final favoriteList = prefs.getStringList('favorites') ?? [];
      setState(() {
        _isFavorite = favoriteList.contains(widget.product.id.toString());
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Gagal memeriksa status favorit: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.green,
        actions: [
          IconButton(
            icon: Icon(Icons.search, color: Colors.white),
            onPressed: () {
              // Navigasi ke halaman pencarian
            },
          ),
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
                        maxWidth: 13,
                        maxHeight: 13,
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
        leading: BackButton(color: Colors.white),
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Image.network(
            'http://192.168.0.160/ecomart/public/storage/'+widget.product.gambar,
            fit: BoxFit.cover,
            height: 250,
            width: double.infinity,
          ),
          Padding(
            padding: EdgeInsets.all(16.0),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        widget.product.nama,
                        style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                      ),
                      Text(
                        _currencyFormat.format(widget.product.harga),
                        style: TextStyle(fontSize: 20, color: Colors.black, fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                ),
                IconButton(
                  icon: Icon(
                    _isFavorite ? Icons.favorite : Icons.favorite_border,
                    color: Colors.red,
                  ),
                  onPressed: _toggleFavorite,
                ),
              ],
            ),
          ),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(height: 16.0),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Tersedia',
                      style: TextStyle(fontSize: 16, color: Colors.grey),
                    ),
                    Row(
                      children: [
                        Container(
                          width: 40,
                          height: 40,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: Colors.green,
                          ),
                          child: IconButton(
                            icon: Icon(Icons.remove, color: Colors.white),
                            onPressed: _decrementQuantity,
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 15.0),
                          child: Text(
                            '$quantity',
                            style: TextStyle(fontSize: 20, color: Colors.black),
                          ),
                        ),
                        Container(
                          width: 40,
                          height: 40,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: Colors.green,
                          ),
                          child: IconButton(
                            icon: Icon(Icons.add, color: Colors.white),
                            onPressed: _incrementQuantity,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                SizedBox(height: 16.0),
                Text(
                  "Available in conventional and imperfect options. Imperfect carrots vary in size, are somewhat hollow, have 2-3 branches, and are smaller. However, the taste and nutrition remain the same.",
                  style: TextStyle(fontSize: 14, color: Colors.black),
                ),
                SizedBox(height: 8.0),
                Text(
                  "Brastagi baby carrots are young Brastagi carrots. So the taste is sweeter and the texture is crisper. Brastagi baby carrots can also be consumed raw.",
                  style: TextStyle(fontSize: 14, color: Colors.black),
                ),
              ],
            ),
          ),
          Spacer(),
          Row(
            children: [
              SizedBox(
                width: 150,
                child: ElevatedButton(
                  onPressed: _addToCart,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.black,
                    padding: EdgeInsets.symmetric(vertical: 16.0),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(0),
                    ),
                  ),
                  child: Icon(
                    Icons.shopping_cart,
                    color: Colors.white,
                    size: 28.0,
                  ),
                ),
              ),
              Expanded(
                child: SizedBox(
                  height: 60,
                  child: ElevatedButton(
                    onPressed: _buyNow,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green,
                      padding: EdgeInsets.symmetric(vertical: 16.0),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(0),
                      ),
                    ),
                    child: Center(
                      child: Text(
                        'Buy now',
                        style: TextStyle(fontSize: 18, color: Colors.white),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
