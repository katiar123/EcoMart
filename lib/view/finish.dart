import 'package:flutter/material.dart';
import 'index.dart';

class FinishPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Checkout'),
        centerTitle: true,
        backgroundColor: Colors.white,
        iconTheme: IconThemeData(color: Colors.black), // Mengatur warna ikon kembali
        elevation: 0, // Menghilangkan bayangan AppBar
      ),
      body: Container(
        color: Colors.white,
        child: Column(
          children: [
            // Bagian progress checkout dengan ikon lokasi, kartu kredit, dan check mark
            Container(
              padding: EdgeInsets.only(right: 25, left: 25, bottom: 10),
              child: Row(
                children: [
                  Expanded(
                    child: Row(
                      children: [
                        Icon(Icons.location_on, color: Colors.black, size: 38),
                        SizedBox(width: 8),
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
                        Icon(Icons.credit_card, color: Colors.black, size: 38),
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
                        Icon(Icons.check_circle, color: Colors.black, size: 38),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            // Expanded widget untuk menempatkan konten di tengah layar
            Expanded(
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center, // Posisikan secara vertikal di tengah
                  children: [
                    // Gambar berada di tengah
                    Image.asset(
                      'assets/cart.png',
                      width: 150,
                      height: 150,
                    ),
                    SizedBox(height: 20),
                    // Teks utama
                    Text(
                      'Pesanan Sukses',
                      style: TextStyle(
                        fontFamily: 'Poppins',
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Colors.black,
                      ),
                    ),
                    SizedBox(height: 8),
                    // Deskripsi pesanan
                    Text(
                      'Terima kasih telah membeli.\nTunggu Pesanan anda dikonfirmasi admin yaa',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontFamily: 'Poppins',
                        fontSize: 14,
                        color: Colors.grey,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            // ElevatedButton berada di bawah layar
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20.0),
              child: SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => ProductListView()),
                    );// Aksi kembali ke halaman sebelumnya
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green, // Warna tombol hijau
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30.0), // Tombol dengan sudut melengkung
                    ),
                  ),
                  child: Text(
                    'Kembali Belanja',
                    style: TextStyle(
                      fontFamily: 'Poppins',
                      fontSize: 16,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            ),
            SizedBox(height: 20), // Jarak antara tombol dengan bagian bawah layar
          ],
        ),
      ),
    );
  }
}
