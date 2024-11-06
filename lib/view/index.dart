import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../controller/product.dart';
import '../controller/cart.dart';
import '../model/product.dart';
import '../model/cart.dart';
import 'detail.dart';
import 'search.dart';
import 'cart.dart';
import 'favorite.dart'; // Import the FavoritePage
import 'notifikasi.dart';
import 'riwayat.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'product.dart';
import 'menu.dart';
import 'topup.dart';

class ProductListView extends StatefulWidget {
  @override
  _ProductListViewState createState() => _ProductListViewState();
}

class _ProductListViewState extends State<ProductListView> {
  final ProductController _productController = ProductController();
  final CartController _cartController = CartController();
  int _selectedIndex = 0;
  int _cartItemCount = 0;
  int notificationCount = 0;

  @override
  void initState() {
    super.initState();
    _updateCartCount();
    _loadNotificationCount();
  }

  Future<void> _updateCartCount() async {
    try {
      final cartItems = await _cartController.getCartItems();
      setState(() {
        _cartItemCount = cartItems.length;
      });
    } catch (e) {
      print('Error updating cart count: $e');
    }
  }

  Future<void> _loadNotificationCount() async {
    final prefs = await SharedPreferences.getInstance();
    final keys =
        prefs.getKeys().where((key) => key.startsWith('transaction_')).toList();
    setState(() {
      notificationCount = keys.length; // Count the notifications
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: _selectedIndex == 0
          ? AppBar(
              automaticallyImplyLeading: false,
              backgroundColor: Colors.green,
              title: GestureDetector(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => SearchPage()),
                  );
                },
                child: AbsorbPointer(
                  child: Container(
                    height: 35.0,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(20.0),
                    ),
                    child: TextField(
                      decoration: InputDecoration(
                        hintText: 'Search',
                        hintStyle: TextStyle(color: Colors.grey),
                        prefixIcon: Icon(Icons.search, color: Colors.grey),
                        border: InputBorder.none,
                        contentPadding:
                            EdgeInsets.only(left: 10.0, top: 5.0, bottom: 9.0),
                      ),
                    ),
                  ),
                ),
              ),
              actions: [
                IconButton(
                  icon: Stack(
                    children: [
                      Icon(Icons.notifications, color: Colors.white),
                      if (notificationCount > 0)
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
                                '$notificationCount',
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
                      MaterialPageRoute(
                        builder: (context) => NotificationPage(),
                      ),
                    ).then((_) {
                      _loadNotificationCount(); // Memuat ulang jumlah notifikasi setelah kembali
                    });
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
                        MaterialPageRoute(
                          builder: (context) => CartPage(),
                        ));
                  },
                ),
              ],
            )
          : null,
      body: _buildBody(),
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        backgroundColor: Colors.green,
        selectedItemColor: Colors.yellow,
        unselectedItemColor: Colors.white,
        currentIndex: _selectedIndex,
        onTap: (index) {
          setState(() {
            _selectedIndex = index;
          });
        },
        items: [
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.favorite),
            label: 'Favorite',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.shopping_bag),
            label: 'Product',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.error_outline),
            label: 'Report',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.motorcycle_sharp),
            label: 'myOrder',
          ),
        ],
      ),
    );
  }

  Widget _buildBody() {
    switch (_selectedIndex) {
      case 0:
        return RefreshIndicator(
          onRefresh: () async {
            await _productController.fetchProducts();
          },
          child: ListView(
            children: [
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(10.0),
                  child: Image.asset(
                    'assets/iklan.png',
                    width: double.infinity,
                    height: 150,
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 10.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    GestureDetector(
                      onTap: () {},
                      child:
                          _buildFeatureIcon(Icons.new_releases, 'New Product'),
                    ),
                    GestureDetector(
                      onTap: () {},
                      child: _buildFeatureIcon(Icons.local_offer, 'Promo'),
                    ),
                    GestureDetector(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => TopupPage()),
                        );
                      },
                      child: _buildFeatureIcon(Icons.wallet_giftcard, 'Top Up'),
                    ),
                    GestureDetector(
                      onTap: () {
                        _showFeatureModal(
                            'Categories'); // Tampilkan halaman baru
                      },
                      child: _buildFeatureIcon(Icons.category, 'Categories'),
                    ),
                  ],
                ),
              ),
              FutureBuilder<List<Product>>(
                future: _productController.fetchProducts(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return Center(child: CircularProgressIndicator());
                  } else if (snapshot.hasError) {
                    return Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Align(
                            alignment: Alignment.topCenter,
                            child: Image.asset(
                              'assets/error.png',
                              width: 250,
                              height: 250,
                            ),
                          ),
                          Text('Error: ${snapshot.error}',
                              style:
                                  TextStyle(fontSize: 16, color: Colors.green)),
                        ],
                      ),
                    );
                  } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                    return Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Align(
                            alignment: Alignment.topCenter,
                            child: Image.asset(
                              'assets/error.png',
                              width: 100,
                              height: 100,
                            ),
                          ),
                          SizedBox(height: 10),
                          Text('No products available',
                              style:
                                  TextStyle(fontSize: 16, color: Colors.black)),
                        ],
                      ),
                    );
                  } else {
                    final products = snapshot.data!;
                    return GridView.builder(
                      shrinkWrap: true,
                      physics: NeverScrollableScrollPhysics(),
                      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 2,
                        crossAxisSpacing: 10,
                        mainAxisSpacing: 10,
                        childAspectRatio: 2 / 2.3,
                      ),
                      padding: const EdgeInsets.all(10.0),
                      itemCount: products.length,
                      itemBuilder: (context, index) {
                        final product = products[index];
                        final formattedPrice = NumberFormat.simpleCurrency(
                                locale: 'id_ID', name: 'IDR')
                            .format(product.harga);

                        return GestureDetector(
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => ProductDetailView(
                                  product: product,
                                  onCartUpdated: _updateCartCount,
                                ),
                              ),
                            ).then((_) {
                              _updateCartCount();
                            });
                          },
                          child: Card(
                            elevation: 1,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.stretch,
                              children: [
                                Container(
                                  height: 120,
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.vertical(
                                        top: Radius.circular(10.0)),
                                    image: DecorationImage(
                                      image: NetworkImage(
                                          'http://192.168.0.160/ecomart/public/storage/' +
                                              product.gambar),
                                      fit: BoxFit.cover,
                                    ),
                                  ),
                                ),
                                Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        product.nama,
                                        style: TextStyle(
                                            fontWeight: FontWeight.bold,
                                            fontSize: 14),
                                      ),
                                      SizedBox(height: 5),
                                      Text(
                                        formattedPrice,
                                        style: TextStyle(
                                          color: Colors.green,
                                          fontSize: 12,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    );
                  }
                },
              ),
            ],
          ),
        );
      case 1:
        return FavoritePage();
      case 2:
        return ProductPage();
      case 3:
        return MenuPage();
      case 4:
        return HistoryPage();
      default:
        return Center(
          child: Text('Page not found'),
        );
    }
  }

  void _showFeatureModal(String feature) {
    showModalBottomSheet(
      context: context,
      builder: (context) {
        return Container(
          height: 800, // Set height of the modal
          child: Center(
            child: Text(
              feature,
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
          ),
        );
      },
    );
  }

  Widget _buildFeatureIcon(IconData iconData, String label) {
    return Column(
      children: [
        Container(
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: Colors.green[50],
          ),
          padding: EdgeInsets.all(10),
          child: Icon(iconData, size: 30, color: Colors.green),
        ),
        SizedBox(height: 5),
        Text(label, style: TextStyle(fontSize: 12)),
      ],
    );
  }
}

class NotificationService {
  final SharedPreferences prefs;

  NotificationService(this.prefs);

  Future<void> markAsRead(String notificationId) async {
    await prefs.setBool(notificationId, true);
  }

  Future<int> getUnreadCount() async {
    final keys =
        prefs.getKeys().where((key) => key.startsWith('transaction_')).toList();
    int unreadCount = 0;

    for (var key in keys) {
      if (prefs.getBool(key) != true) {
        unreadCount++;
      }
    }
    return unreadCount;
  }
}
