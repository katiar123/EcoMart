import 'package:flutter/material.dart';
import 'pesanan.dart';

class RatingPage extends StatelessWidget {
  final Product product;

  RatingPage({required this.product});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Nilai Produk!'),
        backgroundColor: Colors.purple[50],
        elevation: 0,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Image.network(
                  'http://192.168.0.160/ecomart/public/storage/'+product.gambar, // Update this path to your image
                  width: 100,
                  height: 100,
                  fit: BoxFit.cover,
                ),
                SizedBox(width: 16),
                Expanded(
                  child: Text(
                    product.namaProduct,
                    style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
                  ),
                ),
              ],
            ),
            SizedBox(height: 24),
            Text(
              'Kualitas Produk',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            StarRating(
              onRatingChanged: (rating) {
                print('Rating Produk: $rating');
              },
            ),
            SizedBox(height: 16),
            TextField(
              decoration: InputDecoration(
                hintText: 'Bagikan pengalaman tentang produk kami (Opsional)',
                border: OutlineInputBorder(),
              ),
              maxLines: 3,
            ),
            SizedBox(height: 24),
            Text(
              'Tentang Layanan',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            StarRating(
              onRatingChanged: (rating) {
                print('Rating Layanan: $rating');
              },
            ),
            SizedBox(height: 24),
            Text(
              'Waktu Pengiriman',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            StarRating(
              onRatingChanged: (rating) {
                print('Rating Pengiriman: $rating');
              },
            ),
            SizedBox(height: 15),
            Text(
              'Rate Apk kami',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            StarRating(
              onRatingChanged: (rating) {
                print('Rating Aplikasi: $rating');
              },
            ),
            SizedBox(height: 4),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                TextButton(
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  child: Text(
                    'Nanti Saja',
                    style: TextStyle(color: Colors.green),
                  ),
                ),
                ElevatedButton(
                  onPressed: () {
                    // Navigator.push(
                    //   context,
                    //   MaterialPageRoute(builder: (context) => ThankYouPage()),
                    // );
                  },
                  child: Text('OK'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class StarRating extends StatefulWidget {
  final int starCount;
  final double rating;
  final ValueChanged<double> onRatingChanged;

  StarRating({
    this.starCount = 5,
    this.rating = .0,
    required this.onRatingChanged,
  });

  @override
  _StarRatingState createState() => _StarRatingState();
}

class _StarRatingState extends State<StarRating> {
  late double _currentRating;

  @override
  void initState() {
    super.initState();
    _currentRating = widget.rating;
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(widget.starCount, (index) {
        return IconButton(
          icon: Icon(
            index < _currentRating ? Icons.star : Icons.star_border,
            color: Colors.yellow[700],
          ),
          onPressed: () {
            setState(() {
              _currentRating = index + 1.0;
              widget.onRatingChanged(_currentRating);
            });
          },
        );
      }),
    );
  }
}