import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'package:intl/intl.dart';
import 'package:web_socket_channel/web_socket_channel.dart';
import 'detailTransaction.dart';
import 'detail.dart';
import '../model/product.dart';
import 'rating.dart';

class OrderPage extends StatefulWidget {
  final Function(
          int dikemasCount, int dikirimCount, int tibaCount, int selesaiCount)
      onProductCountUpdated;
  final int initialTabIndex;

  OrderPage({required this.onProductCountUpdated, this.initialTabIndex = 0});

  @override
  _OrderPageState createState() => _OrderPageState();
}

class _OrderPageState extends State<OrderPage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  List<String> invoices = [];
  List<Product> productsDikemas = [];
  List<Product> productsDikirim = [];
  List<Product> productsTiba = [];
  List<Product> productsSelesai = [];
  bool isLoading = true;

  final WebSocketChannel channel = WebSocketChannel.connect(
    Uri.parse('ws://192.168.0.160/ecomart/public/ws'),
  );

  final NumberFormat _currencyFormat =
      NumberFormat.currency(locale: 'id_ID', symbol: 'Rp. ', decimalDigits: 0);

  @override
  void initState() {
    super.initState();
    _loadInvoices();
    _loadCompletedProducts(); // Load completed products from local storage
    _tabController = TabController(
        length: 3, vsync: this, initialIndex: widget.initialTabIndex);
    _tabController.addListener(() {
      if (_tabController.indexIsChanging) {
        String pengantaran = _getPengantaran(_tabController.index);
        _fetchAllProducts(pengantaran);
      }
    });
    _listenToWebSocket();
  }

  Future<void> _loadInvoices() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    List<String>? storedInvoices = prefs.getStringList('invoices');

    if (storedInvoices != null && storedInvoices.isNotEmpty) {
      setState(() {
        invoices = storedInvoices;
        isLoading = false;
      });
      await _fetchAllProducts('Dikemas');
      await _fetchAllProducts('Dikirim');
      await _fetchAllProducts('Tiba');
      await _fetchAllProducts('Selesai');
    } else {
      setState(() {
        isLoading = false;
      });
    }
  }

  Future<void> _loadCompletedProducts() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    List<String> storedCompletedProducts =
        prefs.getStringList('completedProducts') ?? [];

    setState(() {
      productsSelesai = storedCompletedProducts.map((productJson) {
        Map<String, dynamic> productMap = jsonDecode(productJson);
        return Product.fromJson(productMap);
      }).toList();
    });
  }

  Future<void> _saveProductToLocal(Product product) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String key = 'product_${product.id}';

    String? existingProductJson = prefs.getString(key);
    if (existingProductJson != null) {
      Map<String, dynamic> existingProduct = jsonDecode(existingProductJson);
      existingProduct['jumlah'] += 1; // Tambahkan jumlah
      await prefs.setString(key, jsonEncode(existingProduct));
      print(
          'Produk sudah ada, jumlah diperbarui: ${existingProduct['jumlah']}');
    } else {
      Map<String, dynamic> newProduct = {
        'id': product.id,
        'nama': product.namaProduct,
        'harga': product.harga,
        'gambar': product.gambar,
        'jumlah': 1,
      };
      await prefs.setString(key, jsonEncode(newProduct));
      print('Produk baru disimpan: ${newProduct}');
    }
  }

  Future<void> _fetchAllProducts(String pengantaran) async {
    setState(() {
      isLoading = true;
      _resetProductList(pengantaran);
    });

    for (String invoice in invoices) {
      await _fetchProducts(invoice, pengantaran);
    }

    widget.onProductCountUpdated(productsDikemas.length, productsDikirim.length,
        productsTiba.length, productsSelesai.length);

    setState(() {
      isLoading = false;
    });
  }

  Future<void> _fetchProducts(String invoice, String pengantaran) async {
    try {
      final response = await http.get(Uri.parse(
          'http://192.168.0.160/ecomart/public/api/history/$invoice/$pengantaran'));
      if (response.statusCode == 200) {
        List<dynamic> data = jsonDecode(response.body);
        if (data.isNotEmpty) {
          setState(() {
            for (var item in data) {
              Product product = Product.fromJson(item);
              if (pengantaran == 'Dikemas') {
                productsDikemas.add(product);
              } else if (pengantaran == 'Dikirim') {
                if (product.status == 'Dikirim') {
                  productsDikirim.add(product);
                }
              } else if (pengantaran == 'Tiba') {
                if (product.status == 'Tiba') {
                  productsTiba.add(product);
                }
              } else if (pengantaran == 'Selesai') {
                productsSelesai.add(product);
              }
            }
          });
        }
      }
    } catch (error) {
      print("Error fetching products: $error");
    }
  }

  void _resetProductList(String pengantaran) {
    if (pengantaran == 'Dikemas') {
      productsDikemas = [];
    } else if (pengantaran == 'Dikirim') {
      productsDikirim = [];
    } else if (pengantaran == 'Tiba') {
      productsTiba = [];
    } else if (pengantaran == 'Selesai') {
      productsSelesai = [];
    }
  }

  String _getPengantaran(int index) {
    if (index == 1) return 'Dikirim';
    if (index == 2) return 'Selesai';
    return 'Dikemas'; // Default
  }

  void _listenToWebSocket() {
    channel.stream.listen((message) {
      final decodedMessage = jsonDecode(message);
      final invoiceKey = decodedMessage['invoice'];
      final status = decodedMessage['status'];

      _updateProductList(invoiceKey, status);
      widget.onProductCountUpdated(productsDikemas.length,
          productsDikirim.length, productsTiba.length, productsSelesai.length);
    });
  }

  void _updateProductList(String invoiceKey, String newStatus) {
    final existingProductIndex = productsDikirim
        .indexWhere((product) => product.namaProduct == invoiceKey);

    if (existingProductIndex != -1) {
      setState(() {
        Product updatedProduct =
            productsDikirim[existingProductIndex].copyWith(status: newStatus);
        productsDikirim.removeAt(existingProductIndex);

        if (newStatus == 'Tiba') {
          productsTiba.add(updatedProduct);
        } else if (newStatus == 'Selesai') {
          productsSelesai.add(updatedProduct);
        } else {
          productsDikirim.add(updatedProduct);
        }
      });
    }
  }

  final String apiUrl = 'http://192.168.0.160/ecomart/public/api/update';

  Future<void> updatePengantaran(
      String invoice, int productId, String pengantaran) async {
    try {
      // Mempersiapkan body request
      Map<String, dynamic> body = {
        'invoice': invoice,
        'produk_id': productId,
        'pengantaran': pengantaran,
      };

      // Mengirimkan request PUT ke API
      final response = await http.put(
        Uri.parse(apiUrl),
        headers: {
          'Content-Type': 'application/json',
        },
        body: jsonEncode(body), // Mengubah body menjadi format JSON
      );

      // Mengecek jika pembaruan berhasil
      if (response.statusCode == 200) {
        final responseData = jsonDecode(response.body);
        print('Pengantaran berhasil diperbarui: ${responseData['message']}');
        _refreshData();
      } else {
        // Menangani kesalahan dari server
        print('Gagal memperbarui pengantaran: ${response.statusCode}');
      }
    } catch (error) {
      // Menangani kesalahan koneksi atau lainnya
      print('Terjadi kesalahan: $error');
    }
  }

  Future<void> _deleteProduct(Product product) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    invoices.remove(
        product.namaProduct); // Asumsikan namaProduct sebagai kunci invoice
    await prefs.setStringList('invoices', invoices);

    setState(() {
      productsDikemas.remove(product);
      productsDikirim.remove(product);
      productsTiba.remove(product);
      productsSelesai.remove(product);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Pesanan Saya'),
        bottom: TabBar(
          controller: _tabController,
          tabs: [
            Tab(text: 'Dikemas'),
            Tab(text: 'Dikirim'),
            Tab(text: 'Selesai'),
          ],
        ),
        backgroundColor: Colors.white,
      ),
      body: Container(
        color: Color(0xFFf7f7f7),
        child: isLoading
            ? Center(child: CircularProgressIndicator())
            : RefreshIndicator(
                onRefresh: _refreshData, // Fungsi untuk memuat ulang data
                child: TabBarView(
                  controller: _tabController,
                  children: [
                    _buildProductList(productsDikemas),
                    _buildProductList(productsDikirim + productsTiba),
                    _buildProductList(productsSelesai),
                  ],
                ),
              ),
      ),
    );
  }

// Fungsi untuk memuat ulang data
  Future<void> _refreshData() async {
    await _loadInvoices(); // Memuat ulang invoice
    await _fetchAllProducts('Dikemas');
    await _fetchAllProducts('Dikirim');
    await _fetchAllProducts('Tiba');
    await _fetchAllProducts('Selesai');
  }

  Widget _buildProductList(List<Product> productList) {
    return productList.isEmpty
        ? Center(child: Text('No products found'))
        : ListView.builder(
            itemCount: productList.length,
            itemBuilder: (context, index) {
              return GestureDetector(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) =>
                          DetailTransactionPage(product: productList[index]),
                    ),
                  );
                },
                child: Container(
                  color: Colors.white,
                  margin: EdgeInsets.only(bottom: 10),
                  child: Stack(
                    children: [
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Column(
                          children: [
                            Row(
                              children: [
                                ClipRRect(
                                  borderRadius: BorderRadius.circular(8),
                                  child: Image.network(
                                    'http://192.168.0.160/ecomart/public/storage/' +
                                        productList[index].gambar,
                                    width: 80,
                                    height: 80,
                                    fit: BoxFit.cover,
                                  ),
                                ),
                                SizedBox(width: 10),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        productList[index].namaProduct,
                                        style: TextStyle(
                                            fontWeight: FontWeight.bold,
                                            fontSize: 16),
                                      ),
                                      Text('x ${productList[index].kuantitas}',
                                          style: TextStyle(color: Colors.grey)),
                                      SizedBox(height: 20),
                                      Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.end,
                                        children: [
                                          Text(_currencyFormat.format(
                                              productList[index].harga)),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                            Divider(),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.end,
                              children: [
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.end,
                                  children: [
                                    Text(
                                      'Total Pesanan: ${_currencyFormat.format(productList[index].subtotal)}',
                                      style: TextStyle(
                                          fontWeight: FontWeight.bold),
                                    ),
                                    if (productList[index].status == "Tiba")
                                      ElevatedButton(
                                        onPressed: () async {
                                          await updatePengantaran(
                                              productList[index].invoice,
                                              productList[index].id,
                                              'Selesai');
                                          await _saveProductToLocal(
                                              productList[index]);

                                          setState(() {
                                            productsDikirim.removeAt(index);
                                            productsSelesai
                                                .add(productList[index]);
                                          });

                                          ScaffoldMessenger.of(context)
                                              .showSnackBar(
                                            SnackBar(
                                                content: Text(
                                                    'Status pengantaran berhasil diperbarui!')),
                                          );
                                        },
                                        style: ButtonStyle(
                                          shape: MaterialStateProperty.all<
                                              RoundedRectangleBorder>(
                                            RoundedRectangleBorder(
                                              borderRadius: BorderRadius.zero,
                                            ),
                                          ),
                                          backgroundColor:
                                              MaterialStateProperty.all<Color>(
                                                  Colors.green), // Benar
                                        ),
                                        child: Text(
                                          'Selesai',
                                          style: TextStyle(color: Colors.white),
                                        ),
                                      )
                                    else if (productList[index].status ==
                                        "Selesai")
                                      Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.end,
                                        children: [
                                          ElevatedButton(
                                            onPressed: () {},
                                            style: ButtonStyle(
                                              shape: MaterialStateProperty.all<
                                                  RoundedRectangleBorder>(
                                                RoundedRectangleBorder(
                                                  borderRadius:
                                                      BorderRadius.zero,
                                                  side: BorderSide(
                                                      color: Colors.green,
                                                      width: 1.0),
                                                ),
                                              ),
                                              backgroundColor:
                                                  MaterialStateProperty.all<
                                                      Color>(Colors.white),
                                            ),
                                            child: Text('Beli Lagi',
                                                style: TextStyle(
                                                    color: Colors.green)),
                                          ),
                                          SizedBox(width: 5),
                                          ElevatedButton(
                                            onPressed: () async {
                                              Navigator.push(
                                                context,
                                                MaterialPageRoute(
                                                  builder: (context) =>
                                                      RatingPage(
                                                          product: productList[
                                                              index]),
                                                ),
                                              );
                                            },
                                            style: ButtonStyle(
                                              shape: MaterialStateProperty.all<
                                                  RoundedRectangleBorder>(
                                                RoundedRectangleBorder(
                                                  borderRadius:
                                                      BorderRadius.zero,
                                                ),
                                              ),
                                              backgroundColor:
                                                  MaterialStateProperty.all<
                                                          Color>(
                                                      Colors.green), // Benar
                                            ),
                                            child: Text(
                                              'Beri Nilai',
                                              style: TextStyle(
                                                  color: Colors.white),
                                            ),
                                          )
                                        ],
                                      ),
                                  ],
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                      Positioned(
                        top: 0,
                        right: 0,
                        child: IconButton(
                          icon: Icon(Icons.delete, color: Colors.red),
                          onPressed: () {
                            _deleteProduct(productList[index]);
                          },
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          );
  }
}

class Product {
  final String namaProduct;
  final String nama;
  final String gambar;
  final String blok;
  final String kategori;
  final int kuantitas;
  final int no_rumah;
  final int harga;
  final int subtotal;
  final String status;
  final String invoice;
  final int id;

  Product({
    required this.namaProduct,
    required this.nama,
    required this.gambar,
    required this.blok,
    required this.kategori,
    required this.kuantitas,
    required this.no_rumah,
    required this.harga,
    required this.subtotal,
    required this.status,
    required this.invoice,
    required this.id,
  });

  factory Product.fromJson(Map<String, dynamic> json) {
    return Product(
      namaProduct: json['nama_product'],
      nama: json['nama'],
      gambar: json['gambar'],
      blok: json['blok'],
      kategori: json['kategori'],
      kuantitas: json['kuantitas'],
      no_rumah: json['no_rumah'],
      harga: json['harga'],
      subtotal: json['subtotal'],
      status: json['pengantaran'], // Asumsikan ini sesuai dengan field di API
      invoice: json['invoice'], // Sesuaikan field ini
      id: json['produk_id'], // Sesuaikan field ini
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'nama_product': namaProduct,
      'nama': nama,
      'gambar': gambar,
      'blok': blok,
      'kategori': kategori,
      'kuantitas': kuantitas,
      'no_rumah': no_rumah,
      'harga': harga,
      'subtotal': subtotal,
      'pengantaran': status,
      'invoice': invoice,
      'id': id,
    };
  }

  Product copyWith({
    String? namaProduct,
    String? nama,
    String? gambar,
    String? blok,
    String? kategori,
    int? kuantitas,
    int? harga,
    int? subtotal,
    String? status,
    String? invoice,
    int? id,
  }) {
    return Product(
      namaProduct: namaProduct ?? this.namaProduct,
      nama: nama ?? this.nama,
      gambar: gambar ?? this.gambar,
      blok: blok ?? this.blok,
      kategori: kategori ?? this.kategori,
      kuantitas: kuantitas ?? this.kuantitas,
      no_rumah: no_rumah ?? this.no_rumah,
      harga: harga ?? this.harga,
      subtotal: subtotal ?? this.subtotal,
      status: status ?? this.status,
      invoice: invoice ?? this.invoice,
      id: id ?? this.id,
    );
  }
}
