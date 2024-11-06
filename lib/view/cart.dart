// CartPage.dart

import 'package:flutter/material.dart';
import '../model/cart.dart';
import '../controller/cart.dart';
import 'addres.dart';

class CartPage extends StatefulWidget {
  @override
  _CartPageState createState() => _CartPageState();
}

class _CartPageState extends State<CartPage> {
  final CartController _cartController = CartController();
  List<CartItem> _cartItems = [];

  @override
  void initState() {
    super.initState();
    _loadCartItems();
  }

  void _loadCartItems() async {
    try {
      final items = await _cartController.getCartItems();
      setState(() {
        _cartItems = items;
      });
    } catch (error) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error loading cart items: $error')),
      );
    }
  }

  void _updateItemQuantity(CartItem item, int delta) async {
    final newQuantity = item.kuantitas + delta;

    if (newQuantity < 1) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Minimum quantity is 1')),
      );
      return;
    }

    setState(() {
      item.kuantitas = newQuantity;
    });

    try {
      await _cartController.updateCartItem(item);
    } catch (error) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error updating item: $error')),
      );
      setState(() {
        item.kuantitas -= delta;
      });
    }
  }

  Future<bool> _confirmRemoveFromCart(CartItem item) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Konfirmasi Hapus'),
          content: Text('Apakah kamu yakin ingin menghapus produk ini dari keranjang?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: Text('Batal'),
            ),
            TextButton(
              onPressed: () => Navigator.of(context).pop(true),
              child: Text('Hapus'),
            ),
          ],
        );
      },
    );

    return confirm ?? false;
  }

  Future<void> _removeFromCart(CartItem item) async {
    try {
      await _cartController.removeCartItem(item.id);
      setState(() {
        _cartItems.remove(item);
      });
    } catch (error) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error removing item: $error')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final isCartEmpty = _cartItems.isEmpty;
    final totalAmount = _cartItems.fold(
      0,
      (total, item) => total + item.harga * item.kuantitas,
    );

    return Scaffold(
      appBar: AppBar(
        title: Text('Keranjang Saya'),
        backgroundColor: Colors.white,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: isCartEmpty
                ? Center(child: Text('Keranjang kamu kosong'))
                : ListView.builder(
                    itemCount: _cartItems.length,
                    itemBuilder: (context, index) {
                      final item = _cartItems[index];

                      return Dismissible(
                        key: ValueKey(item.id),
                        direction: DismissDirection.endToStart,
                        confirmDismiss: (direction) async {
                          final shouldRemove = await _confirmRemoveFromCart(item);
                          if (shouldRemove) {
                            await _removeFromCart(item);
                          }
                          return shouldRemove;
                        },
                        background: Container(
                          color: Colors.red,
                          alignment: Alignment.centerRight,
                          padding: EdgeInsets.symmetric(horizontal: 20),
                          child: Icon(Icons.delete, color: Colors.white, size: 30),
                        ),
                        child: ListTile(
                          leading: Image.network(
                            item.gambar,
                            width: 50,
                            height: 50,
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) {
                              return Icon(Icons.image_not_supported);
                            },
                          ),
                          title: Text(item.nama),
                          subtitle: Text(
                            'Rp${item.harga.toString()}',
                            style: TextStyle(color: Colors.grey),
                          ),
                          trailing: SizedBox(
                            width: 150,
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.end,
                              children: [
                                Container(
                                  decoration: BoxDecoration(
                                    color: Colors.green,
                                    shape: BoxShape.circle,
                                  ),
                                  child: SizedBox(
                                    width: 40,
                                    height: 40,
                                    child: IconButton(
                                      icon: Icon(Icons.remove, color: Colors.white),
                                      iconSize: 18,
                                      onPressed: () => _updateItemQuantity(item, -1),
                                    ),
                                  ),
                                ),
                                Container(
                                  padding: EdgeInsets.symmetric(horizontal: 8),
                                  child: Text('${item.kuantitas}', style: TextStyle(fontSize: 16)),
                                ),
                                Container(
                                  decoration: BoxDecoration(
                                    color: Colors.green,
                                    shape: BoxShape.circle,
                                  ),
                                  child: SizedBox(
                                    width: 40,
                                    height: 40,
                                    child: IconButton(
                                      icon: Icon(Icons.add, color: Colors.white),
                                      iconSize: 18,
                                      onPressed: () => _updateItemQuantity(item, 1),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      );
                    },
                  ),
          ),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('${_cartItems.length} barang', style: TextStyle(color: Colors.grey)),
                    Text('Rp$totalAmount', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                  ],
                ),
                SizedBox(height: 20),
                ElevatedButton(
                  onPressed: () {
                    if (!isCartEmpty) {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => AddressPage(cartItems: _cartItems),
                        ),
                      );
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: isCartEmpty ? Colors.grey : Colors.green,
                    padding: EdgeInsets.symmetric(vertical: 16.0),
                  ),
                  child: Text(
                    'CHECKOUT',
                    style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
