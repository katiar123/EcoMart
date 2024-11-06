import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'pesanan.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class DetailTransactionPage extends StatelessWidget {
  final Product product;

  DetailTransactionPage({required this.product});

  final NumberFormat _currencyFormat =
      NumberFormat.currency(locale: 'id_ID', symbol: 'Rp. ', decimalDigits: 0);

  String capitalizeFirstLetter(String word) {
  if (word.isEmpty) {
    return word; // Mengembalikan kata jika kosong
  }
  return word[0].toUpperCase() + word.substring(1);
}

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Rincian Pesanan',
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: Colors.green,
        leading: BackButton(color: Colors.white),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Card Pesanan Selesai
            Container(
              padding: const EdgeInsets.all(16.0),
              decoration: BoxDecoration(
                color: Colors.green.shade100,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            capitalizeFirstLetter(product.nama),
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                          Text('INVOICE: ${product.invoice}'),
                        ],
                      ),
                      ElevatedButton(
                        onPressed: () async {
                          // Salin invoice ke clipboard
                          await Clipboard.setData(
                              ClipboardData(text: product.invoice));
                          // Beri notifikasi ke pengguna (misalnya Snackbar)
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text('Invoice berhasil disalin'),
                              duration: Duration(seconds: 2),
                            ),
                          );
                        },
                        child: Text(
                          'Salin Invoice',
                          style: TextStyle(color: Colors.white),
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.green,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            SizedBox(height: 16),

            // Info Pengiriman Card
            Card(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              elevation: 4,
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Info Pengirim',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 18,
                      ),
                    ),
                    SizedBox(height: 4),
                    Row(
                      children: [
                        Icon(Icons.check_circle, color: Colors.green),
                        SizedBox(width: 8),
                        Text(
                          product.status == "Tiba" ||
                                  product.status == "Selesai"
                              ? 'Pesanan telah tiba di alamat tujuan'
                              : product.status == "Dikirim"
                                  ? 'Pesanan masih dalam perjalanan'
                                  : 'Pesanan masih dikemas',
                          style: TextStyle(color: Colors.green),
                        ),
                      ],
                    ),
                    SizedBox(height: 8),
                    Text(
                      '📍 Alamat Pengiriman',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    SizedBox(height: 4),
                    Text(
                      'Blok ${product.blok}, No. ${product.no_rumah}',
                      style: TextStyle(fontSize: 15),
                    ),
                  ],
                ),
              ),
            ),
            SizedBox(height: 16),

            // Product Detail Card
            Card(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              elevation: 4,
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  children: [
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Image.network(
                          'http://192.168.0.160/ecomart/public/storage/${product.gambar}',
                          height: 80,
                          width: 80,
                          fit: BoxFit.cover,
                        ),
                        SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                product.namaProduct,
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 18,
                                ),
                              ),
                              SizedBox(height: 4),
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                      '${product.kuantitas}x ${_currencyFormat.format(product.harga)}'),
                                  Chip(
                                    label: Text(capitalizeFirstLetter(product.kategori)),
                                    backgroundColor: Colors.green.shade100,
                                  ),
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
                        Text(
                          'Total Pesanan:',
                          style: TextStyle(
                              fontWeight: FontWeight.bold, fontSize: 16),
                        ),
                        SizedBox(width: 5),
                        Text(
                          _currencyFormat.format(product.subtotal),
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            SizedBox(height: 16),

            // Total Harga
          ],
        ),
      ),
    );
  }
}
