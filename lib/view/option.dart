import 'package:flutter/material.dart';

class OptionPage extends StatelessWidget {
  final String ewalletName; // Parameter nama E-Wallet

  OptionPage({required this.ewalletName}); // Constructor untuk menerima nama

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.green,
        title: Text('Top Up $ewalletName'), // Tampilkan nama E-Wallet
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(height: 16.0),
            TextField(
              decoration: InputDecoration(
                labelText: "Masukkan Nomor Anda :",
                prefixText: "+62 ",
                border: OutlineInputBorder(),
              ),
              keyboardType: TextInputType.phone,
            ),
            SizedBox(height: 14.0),
            Expanded(
              child: GridView.count(
                crossAxisCount: 2,
                crossAxisSpacing: 10,
                mainAxisSpacing: 10,
                childAspectRatio: 2.0,
                children: [
                  topUpOption("$ewalletName 50000", "Rp 50.000"),
                  topUpOption("$ewalletName 100000", "Rp 100.000"),
                  topUpOption("$ewalletName 200000", "Rp 200.000"),
                  topUpOption("$ewalletName 300000", "Rp 300.000"),
                  topUpOption("$ewalletName 500000", "Rp 500.000"),
                  topUpOption("$ewalletName 700000", "Rp 700.000"),
                  topUpOption("$ewalletName 800000", "Rp 800.000"),
                  topUpOption("$ewalletName 1000000", "Rp 1.000.000"),
                  topUpOption("$ewalletName 1500000", "Rp 1.500.000"),
                ],
              ),
            ),
            Container(
              color: Colors.grey.shade200,
              padding: EdgeInsets.all(16.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    "Total Pembayaran",
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  Text(
                    "Rp 1.500.000",
                    style: TextStyle(
                      color: Colors.red,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(height: 10.0),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  // Implementasi aksi tombol
                },
                child: Text("Lanjut"),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green,
                  padding: EdgeInsets.symmetric(vertical: 16.0),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget topUpOption(String title, String price) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: Colors.grey.shade300),
        borderRadius: BorderRadius.circular(8.0),
      ),
      padding: EdgeInsets.all(16.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            title,
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          SizedBox(height: 4.0),
          Text(
            price,
            style: TextStyle(color: Colors.orange),
          ),
        ],
      ),
    );
  }
}
