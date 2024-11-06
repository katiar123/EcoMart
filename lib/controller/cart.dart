import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../model/cart.dart';

class CartController {
  Future<void> addToCart(CartItem item) async {
    final prefs = await SharedPreferences.getInstance();
    List<String> cart = prefs.getStringList('cart') ?? [];

    // Convert cart items from JSON to CartItem objects
    List<CartItem> cartItems = cart.map((i) => CartItem.fromJson(json.decode(i))).toList();

    // Check if item with the same product_id already exists
    final index = cartItems.indexWhere((i) => i.product_id == item.product_id);

    if (index != -1) {
      // Item already exists, update the quantity
      cartItems[index].kuantitas += item.kuantitas;
    } else {
      // Item does not exist, add it to the cart
      cartItems.add(item);
    }

    // Save updated cart items to SharedPreferences
    cart = cartItems.map((i) => json.encode(i.toJson())).toList();
    await prefs.setStringList('cart', cart);
  }

  Future<List<CartItem>> getCartItems() async {
    final prefs = await SharedPreferences.getInstance();
    List<String> cart = prefs.getStringList('cart') ?? [];
    
    // Decode data yang disimpan di local storage
    return cart.map((item) => CartItem.fromJson(json.decode(item))).toList();
  }

  Future<void> clearCart() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('cart');
  }

  Future<void> updateCartItem(CartItem item) async {
    final prefs = await SharedPreferences.getInstance();
    List<String> cart = prefs.getStringList('cart') ?? [];
    final index = cart.indexWhere((i) => CartItem.fromJson(json.decode(i)).product_id == item.product_id);

    if (index != -1) {
      // Update the item
      cart[index] = json.encode(item.toJson());
      await prefs.setStringList('cart', cart);
    } else {
      throw Exception("Item not found in cart");
    }
  }

  Future<void> removeCartItem(int itemId) async {
    final prefs = await SharedPreferences.getInstance();
    List<String> cart = prefs.getStringList('cart') ?? [];
    final index = cart.indexWhere((i) => CartItem.fromJson(json.decode(i)).id == itemId);

    if (index != -1) {
      cart.removeAt(index);
      await prefs.setStringList('cart', cart);
    } else {
      throw Exception("Item not found in cart");
    }
  }
}
