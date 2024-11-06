import 'package:flutter/material.dart';
import 'option.dart'; // Pastikan import ini benar

class TopupPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.green,
        title: Text('Top Up'),
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Text(
                'Top Up E-Wallet',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
            ),
            GridView.count(
              crossAxisCount: 2,
              shrinkWrap: true,
              physics: NeverScrollableScrollPhysics(),
              children: [
                _buildEWalletTile(context, 'DANA', 'assets/dana.png'),
                _buildEWalletTile(context, 'Gopay', 'assets/gopay.jpg'),
                _buildEWalletTile(context, 'OVO', 'assets/ovo.jpg'),
                _buildEWalletTile(context, 'Shopee Pay', 'assets/spay.jpg'),
                _buildEWalletTile(context, 'Link Aja', 'assets/linkaja.jpg'),
              ],
            ),
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Text(
                'Isi Pulsa & Paket Data',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
            ),
            GridView.count(
              crossAxisCount: 2,
              shrinkWrap: true,
              physics: NeverScrollableScrollPhysics(),
              children: [
                _buildServiceTile('Isi Pulsa', Icons.phone_android),
                _buildServiceTile('Paket Data', Icons.network_cell),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEWalletTile(BuildContext context, String name, String imagePath) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => OptionPage(ewalletName: name), // Kirim nama E-Wallet
          ),
        );
      },
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(10),
            color: Colors.white,
            boxShadow: [
              BoxShadow(
                color: Colors.grey.withOpacity(0.3),
                spreadRadius: 2,
                blurRadius: 5,
                offset: Offset(0, 3),
              ),
            ],
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Image.asset(imagePath, width: 75, height: 75),
              SizedBox(height: 10),
              Text(name, style: TextStyle(fontSize: 16)),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildServiceTile(String name, IconData icon) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(10),
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.3),
              spreadRadius: 2,
              blurRadius: 5,
              offset: Offset(0, 3),
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 50, color: Colors.green),
            SizedBox(height: 10),
            Text(name, style: TextStyle(fontSize: 16)),
          ],
        ),
      ),
    );
  }
}
