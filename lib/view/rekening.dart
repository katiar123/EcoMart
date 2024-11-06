import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'bukti.dart';

class CheckoutPage extends StatelessWidget {
  final String? bankName;
  final int total;
  String? payment;
  String invoice;
  String nama;
  String gambar;
  final List<dynamic> product_id; // Ubah parameter ini menjadi List<int>

  CheckoutPage({
    this.bankName,
    required this.total,
    required this.payment,
    required this.invoice,
    required this.nama,
    required this.gambar,
    required this.product_id
  });

  final Map<String, String> rekeningNumber = {
    'BCA': '6282 3628 36',
    'BRI': '8881 08324 9234 7942',
    'BNI': '9854 8689 8745',
    'Mandiri': '9859 8345 3456'
  };

  void copyToClipboard(BuildContext context, String rekeningNumber) {
    Clipboard.setData(ClipboardData(text: rekeningNumber));
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Nomor rekening telah disalin ke clipboard!'),
      ),
    );
  }

  final NumberFormat _currencyFormat =
      NumberFormat.currency(locale: 'id_ID', symbol: 'Rp. ', decimalDigits: 0);

  @override
  Widget build(BuildContext context) {
    final rekening = rekeningNumber[bankName];

    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: Text('Checkout'),
        // Menghilangkan ikon back button
        automaticallyImplyLeading: false,
        backgroundColor: Colors.white,
      ),
      body: Container(
        color: Colors.grey[200],
        child: Column(
          children: [
            // Progress Indicator
            Container(
              color: Colors.white,
              padding: EdgeInsets.only(right: 25, left: 25, bottom: 10),
              child: Row(
                children: [
                  Expanded(
                    child: Row(
                      children: [
                        Icon(Icons.location_on, color: Colors.black, size: 38),
                        SizedBox(width: 10),
                        Expanded(
                          child: Row(
                            children: List.generate(4, (index) {
                              return Expanded(
                                child: Container(
                                  margin: EdgeInsets.symmetric(horizontal: 2),
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
                        Icon(Icons.credit_card, color: Colors.black, size: 38),
                        SizedBox(width: 10),
                        Expanded(
                          child: Row(
                            children: List.generate(4, (index) {
                              return Expanded(
                                child: Container(
                                  margin: EdgeInsets.symmetric(horizontal: 2),
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
                        Icon(Icons.check_circle, color: Colors.grey, size: 38),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            // Image Placeholder
            Image.asset('assets/transaksi.png'),
            // Bank Details Section
            Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.only(
                  bottomLeft: Radius.circular(20),
                  bottomRight: Radius.circular(20),
                ),
              ),
              padding: EdgeInsets.all(20),
              child: Column(
                children: [
                  if (bankName != null && rekening != null) ...[
                    Text(
                      '${bankName} Rekening Number',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 18,
                      ),
                    ),
                    SizedBox(height: 10),
                    Text(
                      rekening,
                      style: TextStyle(
                        fontSize: 24,
                        color: Colors.yellow[800],
                        letterSpacing: 1.5,
                      ),
                    ),
                    SizedBox(height: 10),
                    OutlinedButton(
                      onPressed: () {
                        copyToClipboard(context, rekening);
                      },
                      style: OutlinedButton.styleFrom(
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.zero,
                        ),
                        side: BorderSide(color: Colors.black),
                      ),
                      child: Text(
                        'COPY CODE',
                        style: TextStyle(color: Colors.black),
                      ),
                    ),
                    SizedBox(height: 5),
                    Text(
                      'Account name: KATIAR WADHI',
                      style: TextStyle(fontSize: 16),
                    ),
                    SizedBox(height: 5),
                    Text(
                      'Please complete the transaction.',
                      style: TextStyle(fontSize: 14),
                      textAlign: TextAlign.center,
                    ),
                    Text(
                      'If the end of the day still not paid, the transaction will be failed',
                      style: TextStyle(fontSize: 14),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ],
              ),
            ),
            SizedBox(height: 20),
            // Terms and Conditions Section
            Expanded(
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(20),
                    topRight: Radius.circular(20),
                  ),
                ),
                child: Column(
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(17),
                      child: Text(
                        'Fee Terms and Conditions:\n'
                        '1. Starting November 1st 2023, your balance will be charged with admin fee Rp 1.000\n'
                        '2. You can only use this Virtual Account for the top-up.\n'
                        '3. If you need help with the transaction, please contact our support team.',
                        style: TextStyle(fontSize: 16),
                      ),
                    ),
                    Divider(),
                    Container(
                      padding:
                          const EdgeInsets.only(right: 15, left: 15, top: 5),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                'Total Pembayaran',
                                style: TextStyle(fontSize: 18),
                              ),
                              SizedBox(height: 5),
                              Text(
                                _currencyFormat.format(total),
                                style: TextStyle(
                                  fontSize: 22,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                          SizedBox(height: 20),
                          ElevatedButton(
                            onPressed: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => Bukti(
                                    payment: payment,
                                    bankName: bankName,
                                    total: total,
                                    invoice: invoice,
                                    nama: nama,
                                    gambar: gambar,
                                    id: product_id,
                                  ),
                                ),
                              );
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.green,
                              minimumSize: Size(double.infinity, 50),
                            ),
                            child: Text(
                              'Lanjutkan',
                              style:
                                  TextStyle(fontSize: 18, color: Colors.white),
                            ),
                          ),
                        ],
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
