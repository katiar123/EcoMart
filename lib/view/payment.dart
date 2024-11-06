import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../model/product.dart';
import '../model/cart.dart';
import 'paymentMethod.dart';
import 'rekening.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:math';


class PaymentPage extends StatefulWidget {
  final Product? product;
  final int? quantity;
  final String? number;
  final String? blok;
  final String? shippingOption;
  final List<CartItem>? cartItems;
  String name;

  PaymentPage(
      {this.product,
      this.quantity,
      this.number,
      this.blok,
      this.shippingOption,
      this.cartItems,
      required this.name});

  @override
  _PaymentPageState createState() => _PaymentPageState();
}

class _PaymentPageState extends State<PaymentPage> {
  final NumberFormat _currencyFormat =
      NumberFormat.currency(locale: 'id_ID', symbol: 'Rp. ', decimalDigits: 0);

  String? selectedPaymentMethod;
  String? selectedBank;
  bool loading = false;

  @override
  Widget build(BuildContext context) {
    final bool isFromCart = widget.cartItems != null;
    double subtotal = 0.0;
    int quantity = 0;

    if (isFromCart) {
      // Untuk cart items
      if (widget.cartItems != null) {
        for (var item in widget.cartItems!) {
          subtotal += item.harga.toDouble() * item.kuantitas;
          quantity += item.kuantitas;
        }
      }
    } else {
      // Untuk produk individual
      final double itemPrice = widget.product?.harga.toDouble() ?? 0.0;
      quantity = widget.quantity ?? 0; // Default ke 0 jika quantity null
      subtotal = itemPrice * quantity;
    }

    final double shippingCost =
        widget.shippingOption == 'express' ? 7000.0 : 2000.0;
    final double serviceFee = 2000.0; // Biaya layanan tetap
    final double totalPrice = subtotal + shippingCost + serviceFee;

    // Gabungkan blok dan nomor rumah
    final address = widget.blok != null
        ? 'Blok: ${widget.blok}, No. Rumah: ${widget.number}'
        : '';

    String InvoiceNumber() {
      final DateTime now = DateTime.now();
      final String formattedDate = DateFormat('yyyyMMdd').format(now);
      final Random random = Random();
      final int randomNumber = random.nextInt(1000); // 0 hingga 999
      final String formattedRandomNumber = randomNumber.toString().padLeft(3, '0');
      final String invoiceNumber = 'ECO-$formattedDate-$formattedRandomNumber';

      return invoiceNumber;
    }

 Future<void> insertToDatabase() async {
  final url = Uri.parse('http://192.168.0.159/ecomart/public/api/sales'); // URL API Laravel

  if (widget.name == null) {
    print('Error: Name is null');
    return;
  }

  // Menghasilkan nomor invoice sekali dan menyimpannya
  final invoice = InvoiceNumber();

  // Mengumpulkan semua product_id dari cartItems dan casting ke List<int>
  final productIds = widget.cartItems != null
      ? widget.cartItems!.map((item) => item.product_id as int).toList()
      : [widget.product!.id];

  final items = widget.cartItems != null
      ? widget.cartItems!
          .map((item) => {
                'produk_id': item.product_id,
                'nama_product': item.nama ?? '',
                'harga': item.harga ?? 0,
                'kuantitas': item.kuantitas ?? 0, // Pastikan tidak null
                'subtotal': (item.harga?.toDouble() ?? 0) * (item.kuantitas ?? 0),
                'gambar': item.gambar,
              })
          .toList()
      : widget.product != null
          ? [
              {
                'produk_id': widget.product!.id ?? 0, // Pastikan tidak null
                'nama_product': widget.product!.nama ?? '',
                'harga': widget.product!.harga ?? 0,
                'kuantitas': widget.quantity ?? 0, // Pastikan tidak null
                'subtotal': (widget.product!.harga?.toDouble() ?? 0) * (widget.quantity ?? 0),
                'gambar': widget.product!.gambar
              }
            ]
          : [];

  final body = {
    'nama': widget.name,
    'no_rumah': widget.number ?? '', // Pastikan tidak null
    'blok': widget.blok ?? '', // Pastikan tidak null
    'items': items,
    'payment': selectedPaymentMethod ?? '', // Pastikan tidak null
    'invoice': invoice, // Gunakan nomor invoice yang sama
  };

  setState(() {
    loading = true;
  });

  try {
    final response = await http.post(
      url,
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json', // Tambahkan header Accept
      },
      body: json.encode(body),
    );

    if (response.statusCode == 200) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => CheckoutPage(
            bankName: selectedBank,
            total: totalPrice.toInt(),
            payment: selectedPaymentMethod,
            invoice: invoice, // Gunakan nomor invoice yang sama
            nama: widget.name,
            product_id: productIds, // Kirim semua ID produk sebagai List<int>
            gambar: widget.product?.gambar ?? '', // Pastikan gambar tidak null
          ),
        ),
      );
    } else {
      print('Failed to insert data: ${response.statusCode}');
      print('Response body: ${response.body}');
    }
  } catch (e) {
    print('Error: $e');
  } finally {
    setState(() {
      loading = false;
    });
  }
}



    return Scaffold(
      appBar: AppBar(
        title: Text('Checkout'),
        backgroundColor: Colors.white,
      ),
      body: Stack(
        children: [
          Container(
            color: Colors.grey[200],
            child: Column(
              children: [
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          padding: EdgeInsets.symmetric(vertical: 20.0),
                          child: Row(
                            children: [
                              Expanded(
                                child: Row(
                                  children: [
                                    Icon(Icons.location_on,
                                        color: Colors.black, size: 38),
                                    SizedBox(width: 10),
                                    Expanded(
                                      child: Row(
                                        children: List.generate(4, (index) {
                                          return Expanded(
                                            child: Container(
                                              margin: EdgeInsets.symmetric(
                                                  horizontal: 2),
                                              height: 3,
                                              decoration: BoxDecoration(
                                                shape: BoxShape.circle,
                                                color: Colors.black,
                                              ),
                                            ),
                                          );
                                        }),
                                      ),
                                    ),
                                    SizedBox(width: 10),
                                    Icon(Icons.credit_card,
                                        color: Colors.black, size: 38),
                                    SizedBox(width: 10),
                                    Expanded(
                                      child: Row(
                                        children: List.generate(4, (index) {
                                          return Expanded(
                                            child: Container(
                                              margin: EdgeInsets.symmetric(
                                                  horizontal: 2),
                                              height: 3,
                                              decoration: BoxDecoration(
                                                shape: BoxShape.circle,
                                                color: Colors.grey,
                                              ),
                                            ),
                                          );
                                        }),
                                      ),
                                    ),
                                    SizedBox(width: 10),
                                    Icon(Icons.check_circle,
                                        color: Colors.grey, size: 38),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                        SizedBox(height: 17),

                        // Address Info
                        Container(
                          padding: EdgeInsets.all(16.0),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(8),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.grey.withOpacity(0.3),
                                spreadRadius: 1,
                                blurRadius: 5,
                                offset: Offset(0, 3),
                              ),
                            ],
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Shipping Address',
                                style: TextStyle(
                                    fontSize: 16, fontWeight: FontWeight.bold),
                              ),
                              SizedBox(height: 8),
                              Row(
                                children: [
                                  Icon(Icons.location_on,
                                      color: Colors.green, size: 24),
                                  SizedBox(width: 10),
                                  Expanded(
                                    child: Text(
                                      address,
                                      style: TextStyle(fontSize: 14),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                        SizedBox(height: 16),

                        // Product Info List
                        if (isFromCart) ...[
                          ListView.builder(
                            shrinkWrap: true,
                            physics:
                                NeverScrollableScrollPhysics(), // Disable scrolling
                            itemCount: widget.cartItems!.length,
                            itemBuilder: (context, index) {
                              final item = widget.cartItems![index];
                              return Container(
                                padding: EdgeInsets.all(16.0),
                                margin: EdgeInsets.only(bottom: 16.0),
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(8),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.grey.withOpacity(0.3),
                                      spreadRadius: 1,
                                      blurRadius: 5,
                                      offset: Offset(0, 3),
                                    ),
                                  ],
                                ),
                                child: Row(
                                  children: [
                                    Image.network(
                                      item.gambar,
                                      width: 60,
                                      height: 60,
                                    ),
                                    SizedBox(width: 10),
                                    Expanded(
                                      child: Text(
                                        item.nama,
                                        style: TextStyle(
                                            fontSize: 16,
                                            fontWeight: FontWeight.bold),
                                      ),
                                    ),
                                    Text(
                                      '${item.kuantitas} x ${_currencyFormat.format(item.harga.toDouble())}',
                                      style: TextStyle(fontSize: 16),
                                    ),
                                  ],
                                ),
                              );
                            },
                          ),
                        ] else ...[
                          Container(
                            padding: EdgeInsets.all(16.0),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(8),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.grey.withOpacity(0.3),
                                  spreadRadius: 1,
                                  blurRadius: 5,
                                  offset: Offset(0, 3),
                                ),
                              ],
                            ),
                            child: Row(
                              children: [
                                Image.network(
                                  widget.product!.gambar,
                                  width: 60,
                                  height: 60,
                                ),
                                SizedBox(width: 10),
                                Expanded(
                                  child: Text(
                                    widget.product!.nama,
                                    style: TextStyle(
                                        fontSize: 16, fontWeight: FontWeight.bold),
                                  ),
                                ),
                                Text(
                                  '$quantity x ${_currencyFormat.format(widget.product!.harga.toDouble())}',
                                  style: TextStyle(fontSize: 16),
                                ),
                              ],
                            ),
                          ),
                        ],
                        SizedBox(height: 8),

                        // Shipping Option
                        Container(
                          padding: EdgeInsets.all(16.0),
                          width: double.infinity, // Set width to infinity
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(8),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.grey.withOpacity(0.3),
                                spreadRadius: 1,
                                blurRadius: 5,
                                offset: Offset(0, 3),
                              ),
                            ],
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Shipping Option',
                                style: TextStyle(
                                    fontSize: 16, fontWeight: FontWeight.bold),
                              ),
                              SizedBox(height: 8),
                              Text(
                                widget.shippingOption == 'express'
                                    ? 'Express Shipping'
                                    : 'Standard Shipping',
                                style: TextStyle(fontSize: 16),
                              ),
                            ],
                          ),
                        ),
                        SizedBox(height: 16),

                        // Payment Method
                        GestureDetector(
                          onTap: () async {
                            final result = await Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => PaymentMethodPage(
                                  selectedPaymentMethod: selectedPaymentMethod,
                                  selectedBank: selectedBank,
                                  onPaymentMethodSelected: (paymentMethod, bank) {
                                    setState(() {
                                      selectedPaymentMethod = paymentMethod;
                                      selectedBank = bank;
                                    });
                                  },
                                ),
                              ),
                            );

                            // Update UI if needed
                          },
                          child: Container(
                            padding: EdgeInsets.all(16.0),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(8),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.grey.withOpacity(0.3),
                                  spreadRadius: 1,
                                  blurRadius: 5,
                                  offset: Offset(0, 3),
                                ),
                              ],
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Expanded(
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.start,
                                    children: [
                                      Icon(Icons.payment,
                                          color: Colors.blue, size: 24),
                                      SizedBox(width: 10),
                                      Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            'Payment method : ${selectedPaymentMethod ?? 'Select'}',
                                            style: TextStyle(fontSize: 16),
                                          ),
                                          if (selectedBank != null)
                                            Text(
                                              selectedBank!,
                                              style: TextStyle(
                                                  fontSize: 14, color: Colors.grey),
                                            ),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                                Icon(Icons.arrow_forward_ios, size: 16),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                // Payment Details
                Align(
                  alignment: Alignment.bottomCenter,
                  child: Container(
                    padding: EdgeInsets.all(16.0),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(25),
                        topRight: Radius.circular(25),
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.grey.withOpacity(0.3),
                          spreadRadius: 1,
                          blurRadius: 5,
                          offset: Offset(0, 3),
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Payment Details',
                          style:
                              TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                        ),
                        SizedBox(height: 16),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text('Subtotal', style: TextStyle(fontSize: 16)),
                            Text(_currencyFormat.format(subtotal),
                                style: TextStyle(fontSize: 16)),
                          ],
                        ),
                        SizedBox(height: 8),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text('Shipping Cost', style: TextStyle(fontSize: 16)),
                            Text(_currencyFormat.format(shippingCost),
                                style: TextStyle(fontSize: 16)),
                          ],
                        ),
                        SizedBox(height: 8),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text('Service Fee', style: TextStyle(fontSize: 16)),
                            Text(_currencyFormat.format(serviceFee),
                                style: TextStyle(fontSize: 16)),
                          ],
                        ),
                        Divider(),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text('Total Price',
                                style: TextStyle(
                                    fontSize: 18, fontWeight: FontWeight.bold)),
                            Text(_currencyFormat.format(totalPrice),
                                style: TextStyle(
                                    fontSize: 18, fontWeight: FontWeight.bold)),
                          ],
                        ),
                        SizedBox(height: 16),
                        Container(
                          width: double.infinity,
                          child: ElevatedButton(
                          onPressed: selectedPaymentMethod != null && selectedBank != null
                              ? () {
                                  insertToDatabase();
                                }
                              : null, // Tombol akan nonaktif jika metode pembayaran belum dipilih
                          child: Text('Checkout',
                          style: TextStyle(color: Colors.white)),
                          style: ElevatedButton.styleFrom(
                            padding: EdgeInsets.symmetric(vertical: 16.0),
                            backgroundColor:
                                Colors.green, // Warna tombol saat aktif
                          ),
                        )
                        ),
                      ],
                    ),
                  ),
                ),
                
              ],
            ),
          ),
          if (loading)
            Center(
              child: CircularProgressIndicator(),
            ),
        ],
      ),
    );
  }
}
