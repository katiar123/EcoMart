import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:intl/intl.dart';
import 'dart:convert';
import 'detail.dart';
import 'package:web_socket_channel/web_socket_channel.dart';
import 'pesanan.dart' as pesanan; // Menggunakan alias untuk pesanan.dart
import '../model/product.dart' as model; // Menggunakan alias untuk product.dart

class HistoryPage extends StatefulWidget {
  @override
  _HistoryPageState createState() => _HistoryPageState();
}

class _HistoryPageState extends State<HistoryPage> {
  int countDikemas = 0;
  int countDikirim = 0;
  int countTiba = 0;
  int countSelesai = 0;

  final WebSocketChannel channel = WebSocketChannel.connect(
    Uri.parse('ws://192.168.0.160/ecomart/public/ws'),
  );

  List<Map<String, dynamic>> storedProducts = []; // Menyimpan produk yang diambil

  @override
  void initState() {
    super.initState();
    _loadProductCounts();
    _loadStoredProducts();
    _listenToWebSocket();
  }

  Future<void> _loadProductCounts() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      countDikemas = prefs.getInt('countDikemas') ?? 0;
      countDikirim = prefs.getInt('countDikirim') ?? 0;
      countTiba = prefs.getInt('countTiba') ?? 0;
      countSelesai = prefs.getInt('countSelesai') ?? 0;
    });
  }

  Future<void> _loadStoredProducts() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    List<String> keys = prefs.getKeys().where((key) => key.startsWith('product_')).toList();

    storedProducts.clear();

    for (String key in keys) {
      String? productJson = prefs.getString(key);
      if (productJson != null) {
        Map<String, dynamic> product = jsonDecode(productJson);
        storedProducts.add(product);
      }
    }

    setState(() {});
  }

  final NumberFormat _currencyFormat =
      NumberFormat.currency(locale: 'id_ID', symbol: 'Rp. ', decimalDigits: 0);

  Future<void> _deleteProduct(String key) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.remove(key);
    await _loadStoredProducts();
  }

  void _updateProductCount(int dikemasCount, int dikirimCount, int tibaCount, int selesaiCount) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      countDikemas = dikemasCount;
      countDikirim = dikirimCount;
      countTiba = tibaCount;
      countSelesai = selesaiCount;
    });
    prefs.setInt('countDikemas', dikemasCount);
    prefs.setInt('countDikirim', dikirimCount);
    prefs.setInt('countTiba', tibaCount);
    prefs.setInt('countSelesai', selesaiCount);
  }

  void navigateToOrderPage(int initialTabIndex) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => pesanan.OrderPage( // Menggunakan alias di sini
          onProductCountUpdated: _updateProductCount,
          initialTabIndex: initialTabIndex,
        ),
      ),
    ).then((_) {
      _loadStoredProducts();
    });
  }

  void _listenToWebSocket() {
    channel.stream.listen((message) {
      final decodedMessage = jsonDecode(message);
      final status = decodedMessage['status'];
      final action = decodedMessage['action'];

      if (action == 'update') {
        if (status == 'Dikemas') {
          _updateProductCount(countDikemas + 1, countDikirim, countTiba, countSelesai);
        } else if (status == 'Dikirim') {
          if (countDikemas > 0) {
            _updateProductCount(countDikemas - 1, countDikirim + 1, countTiba, countSelesai);
          } else if (countTiba > 0) {
            _updateProductCount(countDikemas - 1, countDikirim + 1, countTiba + 1, countSelesai);
          }
        } else if (status == 'Selesai') {
          _updateProductCount(countDikemas, countDikirim, countTiba, countSelesai + 1);
        }
      }
    });
  }

  @override
  void dispose() {
    channel.sink.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('History'),
        backgroundColor: Colors.white,
        centerTitle: true,
      ),
      body: Container(
        color: Colors.grey[200],
        child: Column(
          children: [
            Container(
              color: Colors.white,
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 15),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    IconButton(
                      onPressed: () {
                        navigateToOrderPage(0);
                      },
                      icon: Stack(
                        alignment: Alignment.topRight,
                        children: [
                          Column(
                            children: [
                              Image.asset('assets/box.png', width: 50, height: 50),
                              SizedBox(height: 10),
                              Text('Barang dikemas', style: TextStyle(fontSize: 13)),
                            ],
                          ),
                          if (countDikemas > 0)
                            Positioned(
                              right: 23,
                              top: 5,
                              child: Container(
                                height: 18,
                                width: 18,
                                alignment: Alignment.center,
                                decoration: BoxDecoration(
                                  color: const Color.fromARGB(255, 0, 77, 3),
                                  shape: BoxShape.circle,
                                ),
                                child: Text(
                                  countDikemas.toString(),
                                  style: TextStyle(color: Colors.white, fontSize: 12),
                                ),
                              ),
                            ),
                        ],
                      ),
                    ),
                    SizedBox(width: 25),
                    IconButton(
                      onPressed: () {
                        navigateToOrderPage(1);
                      },
                      icon: Stack(
                        alignment: Alignment.topRight,
                        children: [
                          Column(
                            children: [
                              Image.asset('assets/truck.png', width: 50, height: 50),
                              SizedBox(height: 10),
                              Text('OTW!', style: TextStyle(fontSize: 13)),
                            ],
                          ),
                          if (countDikirim > 0 || countTiba > 0)
                            Positioned(
                              right: 5,
                              top: 5,
                              child: Container(
                                height: 18,
                                width: 18,
                                alignment: Alignment.center,
                                decoration: BoxDecoration(
                                  color: const Color.fromARGB(255, 0, 77, 3),
                                  shape: BoxShape.circle,
                                ),
                                child: Text(
                                  (countDikirim + countTiba).toString(),
                                  style: TextStyle(color: Colors.white, fontSize: 12),
                                ),
                              ),
                            ),
                        ],
                      ),
                    ),
                    SizedBox(width: 25),
                    IconButton(
                      onPressed: () {
                        navigateToOrderPage(2);
                      },
                      icon: Stack(
                        alignment: Alignment.topRight,
                        children: [
                          Column(
                            children: [
                              Image.asset('assets/star.png', width: 50, height: 50),
                              SizedBox(height: 10),
                              Text('Beri Rating', style: TextStyle(fontSize: 13)),
                            ],
                          ),
                          if (countSelesai > 0)
                            Positioned(
                              right: 5,
                              top: 5,
                              child: Container(
                                height: 18,
                                width: 18,
                                alignment: Alignment.center,
                                decoration: BoxDecoration(
                                  color: const Color.fromARGB(255, 0, 77, 3),
                                  shape: BoxShape.circle,
                                ),
                                child: Text(
                                  countSelesai.toString(),
                                  style: TextStyle(color: Colors.white, fontSize: 12),
                                ),
                              ),
                            ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
            SizedBox(height: 10),
            Expanded(
              child: Container(
                padding: EdgeInsets.all(16),
                color: Colors.white,
                child: Column(
                  children: [
                    Row(
                      children: [
                        Icon(Icons.shopping_bag, size: 35),
                        SizedBox(width: 10),
                        Text('Beli Lagi', style: TextStyle(fontWeight: FontWeight.bold)),
                      ],
                    ),
                    Flexible(
                      fit: FlexFit.loose,
                      child: Container(
                        height: 170,
                        child: ListView.builder(
                          scrollDirection: Axis.horizontal,
                          itemCount: storedProducts.length,
                          itemBuilder: (context, index) {
                            final product = storedProducts[index];
                            return GestureDetector(
                                onTap: () {
                                  model.Product productInstance = model.Product.fromJson(product); // Menggunakan alias untuk product
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => ProductDetailView(product: productInstance),
                                    ),
                                  );
                                },
                              child: Container(
                                margin: EdgeInsets.only(right: 10, top: 15),
                                decoration: BoxDecoration(
                                  border: Border.all(
                                    width: 2,
                                    color: const Color.fromARGB(255, 202, 202, 202),
                                  ),
                                ),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Container(
                                      decoration: BoxDecoration(
                                        border: Border(
                                          bottom: BorderSide(
                                            color: Color.fromARGB(255, 202, 202, 202),
                                            width: 2,
                                          ),
                                        ),
                                      ),
                                      child: Image.network(
                                        'http://192.168.0.160/ecomart/public/storage/' + product['gambar'],
                                        fit: BoxFit.cover,
                                        width: 100,
                                        height: 100,
                                      ),
                                    ),
                                    Text(
                                      'Dibeli ${product['jumlah']} kali',
                                      style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 11,
                                      ),
                                    ),
                                    Text(
                                      _currencyFormat.format(product['harga']),
                                      style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 9,
                                        fontFamily: "arial",
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
