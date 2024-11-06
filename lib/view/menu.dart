import 'package:flutter/material.dart';
import 'report.dart';
import 'rating.dart';

class MenuPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.green, // Warna hijau seperti di gambar
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // _buildMenuItem(
            //   context,
            //   icon: Icons.star,
            //   title: 'Rating',
            //   destination: RatingPage(),
            // ),
            SizedBox(height: 16.0),
            _buildMenuItem(
              context,
              icon: Icons.info,
              title: 'Help Ecomart',
              destination: ReportCenter(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMenuItem(
    BuildContext context, {
    required IconData icon,
    required String title,
    required Widget destination,
  }) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => destination),
        );
      },
      child: Row(
        children: [
          Icon(
            icon,
            color: Color(0xFF0E4F22), // Warna hijau ikon
            size: 28.0,
          ),
          SizedBox(width: 16.0),
          Text(
            title,
            style: TextStyle(
              fontSize: 18.0,
              fontWeight: FontWeight.bold,
              color: Color(0xFF0E4F22), // Warna hijau teks
            ),
          ),
        ],
      ),
    );
  }
}


class HelpEcomartPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Help Ecomart'),
        backgroundColor: Color(0xFF0E4F22),
      ),
      body: Center(
        child: Text(
          'Halaman Help Ecomart',
          style: TextStyle(fontSize: 24.0),
        ),
      ),
    );
  }
}
