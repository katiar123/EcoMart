import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart'; // Import image_picker
import 'dart:io'; // Import untuk File
import 'package:flutter/services.dart';
import 'finish.dart';
import 'package:shared_preferences/shared_preferences.dart';

class Penjualan {
  final int id;
  final String nama;

  Penjualan({required this.id, required this.nama});

  final String url = 'http://192.168.0.159/ecomart/public/api/sales';

  Future<List<Penjualan>> sales() async {
    final response = await http.get(Uri.parse(url));

    if (response.statusCode == 200) {
      List<dynamic> jsonResponse = json.decode(response.body);

      // Convert JSON ke list of Penjualan
      List<Penjualan> salesList = jsonResponse.map((data) {
        return Penjualan(
          id: data['id'],
          nama: data['nama'],
        );
      }).toList();

      return salesList;
    } else {
      throw Exception('Failed to load sales data');
    }
  }
}

class Bukti extends StatefulWidget {
  final String? payment;
  final String? bankName;
  final int total;
  final String invoice;
  String nama;

  Bukti(
      {required this.payment,
      this.bankName,
      required this.total,
      required this.invoice,
      required this.nama});
  @override
  _BuktiState createState() => _BuktiState();
}

class _BuktiState extends State<Bukti> {
  final NumberFormat _currencyFormat =
      NumberFormat.currency(locale: 'id_ID', symbol: 'Rp. ', decimalDigits: 0);

  final ImagePicker _picker = ImagePicker();
  XFile? _image; // Untuk menyimpan gambar yang dipilih
  bool _isTransactionCompleted = false; // Variabel untuk status transaksi

  void _showLoadingDialog() {
    showDialog(
      context: context,
      barrierDismissible: false, // Dialog tidak bisa ditutup
      builder: (BuildContext context) {
        return AlertDialog(
          content: Row(
            children: [
              CircularProgressIndicator(),
              SizedBox(width: 20),
              Text('Mengirim...'),
            ],
          ),
        );
      },
    );
  }

  // Fungsi untuk menutup dialog loading
  void _hideLoadingDialog() {
    Navigator.of(context).pop();
  }

  Future<void> _pickImage(ImageSource source) async {
    final XFile? pickedFile = await _picker.pickImage(source: source);

    if (pickedFile != null) {
      setState(() {
        _image = pickedFile;
      });
    }
  }

  Future<void> insert() async {
    String url = 'http://192.168.0.159/ecomart/public/api/transaction';

    try {
      _showLoadingDialog(); // Tampilkan dialog loading
      var request = http.MultipartRequest('POST', Uri.parse(url));

      request.fields['nama'] = widget.nama;
      request.fields['invoice'] = widget.invoice;
      request.fields['total'] = widget.total.toString();
      request.fields['payment'] = widget.payment ?? '';
      request.fields['status'] = 'Unpaid';

      if (_image != null) {
        var imageFile = await http.MultipartFile.fromPath(
          'bukti',
          _image!.path,
        );
        request.files.add(imageFile);
      }

      var response = await request.send();

      if (response.statusCode == 200) {
        setState(() {
          _isTransactionCompleted = true;
        });
        print('Transaksi berhasil disimpan');
      } else {
        print('Gagal mengunggah bukti transfer');
      }
    } catch (e) {
      print('Terjadi kesalahan: $e');
    } finally {
      _hideLoadingDialog(); // Tutup dialog loading setelah response diterima
    }
  }

  Future<String?> fetchStatusFromServer(String invoiceNumber) async {
    final response = await http
        .get(Uri.parse('http://192.168.0.159/ecomart/public/api/transaction'));

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return data['status']; // Pastikan format sesuai dengan API
    } else {
      throw Exception('Gagal mengambil status dari server');
    }
  }

  Future<void> saveStatus(String invoiceNumber, String status) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('transaction_$invoiceNumber', status);
  }

  Future<void> _handleFinishButton() async {
    if (!_isTransactionCompleted) {
      await insert();
      // Setelah berhasil mengirim data, simpan status 'Processing'
      await saveStatus(widget.invoice, 'Processing');
    } else {
      // Simpan status 'Paid' jika transaksi sudah selesai
      await saveStatus(widget.invoice, 'Paid');

      // Navigasi ke halaman FinishPage
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => FinishPage()),
      );

      // Cek dan tampilkan notifikasi jika status berubah menjadi 'Paid'
      _showNotificationIfPaid();
    }
  }

  Future<void> _showNotificationIfPaid() async {
    final prefs = await SharedPreferences.getInstance();
    final status = prefs.getString('transaction_${widget.invoice}');

    if (status == 'Paid') {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Pesanan Anda telah dikonfirmasi oleh admin.'),
        ),
      );
    }
  }

  void _showImagePickerDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Pilih Sumber Gambar'),
          actions: <Widget>[
            TextButton(
              child: Text('Kamera'),
              onPressed: () {
                Navigator.of(context).pop();
                _pickImage(ImageSource.camera);
              },
            ),
            TextButton(
              child: Text('Galeri'),
              onPressed: () {
                Navigator.of(context).pop();
                _pickImage(ImageSource.gallery);
              },
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Checkout'),
        centerTitle: true,
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
                                    color: Colors.grey,
                                  ),
                                ),
                              );
                            }),
                          ),
                        ),
                        Icon(Icons.check_circle, color: Colors.grey, size: 38),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            // Image Placeholder
            Image.asset('assets/transaksi.png'),
            Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.only(
                  bottomLeft: Radius.circular(20),
                  bottomRight: Radius.circular(20),
                ),
              ),
              width: double.infinity,
              child: Padding(
                padding: EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Status Pembayaran',
                      style:
                          TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    SizedBox(height: 16),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Status 1
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Column(
                              children: [
                                Icon(Icons.check_circle,
                                    color: Colors.green, size: 30),
                                SizedBox(height: 10),
                                Column(
                                  children: List.generate(2, (index) {
                                    return Container(
                                      margin: EdgeInsets.symmetric(vertical: 2),
                                      height: 4,
                                      width: 4,
                                      decoration: BoxDecoration(
                                        shape: BoxShape.circle,
                                        color: Colors.grey,
                                      ),
                                    );
                                  }),
                                ),
                              ],
                            ),
                            SizedBox(width: 8),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text('Transaksi dibuat',
                                    style: TextStyle(fontSize: 15)),
                                Text('Transaksi berhasil dibuat.',
                                    style: TextStyle(fontSize: 12)),
                              ],
                            ),
                          ],
                        ),
                        SizedBox(height: 10),
                        // Status 2
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Column(
                              children: [
                                // AnimatedSwitcher untuk animasi perubahan ikon
                                AnimatedSwitcher(
                                  duration: Duration(
                                      milliseconds: 300), // Durasi animasi
                                  transitionBuilder: (Widget child,
                                      Animation<double> animation) {
                                    return ScaleTransition(
                                        scale: animation, child: child);
                                  },
                                  child: _isTransactionCompleted
                                      ? Icon(Icons.check_circle,
                                          color: Colors.green,
                                          size: 30,
                                          key: ValueKey(1)) // Icon centang
                                      : Icon(Icons.radio_button_checked,
                                          color: Colors.black,
                                          size: 30,
                                          key: ValueKey(2)), // Icon radio
                                ),
                                SizedBox(height: 10),
                                Column(
                                  children: List.generate(2, (index) {
                                    return Container(
                                      margin: EdgeInsets.symmetric(vertical: 2),
                                      height: 4,
                                      width: 4,
                                      decoration: BoxDecoration(
                                        shape: BoxShape.circle,
                                        color: Colors.grey,
                                      ),
                                    );
                                  }),
                                ),
                              ],
                            ),
                            SizedBox(width: 8),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text('Pembayaran',
                                    style: TextStyle(fontSize: 15)),
                                Text(
                                  _isTransactionCompleted
                                      ? 'Transaksi berhasil' // Text ketika transaksi berhasil
                                      : 'Silahkan melakukan pembayaran', // Text ketika belum selesai
                                  style: TextStyle(fontSize: 12),
                                ),
                              ],
                            ),
                          ],
                        ),

                        SizedBox(height: 10),
                        // Status 3
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Column(
                              children: [
                                Icon(Icons.radio_button_off,
                                    color: Colors.black, size: 30),
                              ],
                            ),
                            SizedBox(width: 8),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text('Selesai', style: TextStyle(fontSize: 15)),
                                Text('Transaksi selesai',
                                    style: TextStyle(fontSize: 12)),
                              ],
                            ),
                          ],
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            SizedBox(height: 20),
            Expanded(
              child: Container(
                width: double.infinity,
                decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(20),
                        topRight: Radius.circular(20))),
                child: Padding(
                  padding: EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Metode Pembayaran', style: TextStyle(fontSize: 18)),
                      if (widget.bankName != null)
                        Text('${widget.payment} [${widget.bankName}]')
                      else
                        Text('${widget.payment}'),
                      Divider(),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text('Nomor Invoice', style: TextStyle(fontSize: 17)),
                          Container(
                            padding: EdgeInsets.symmetric(
                                horizontal: 5, vertical: 2),
                            decoration: BoxDecoration(
                              border: Border.all(color: Colors.black),
                            ),
                            child: Row(
                              children: [
                                Text(widget.invoice),
                                SizedBox(width: 10),
                                Container(
                                  width: 1,
                                  height: 25, // Tinggi separator
                                  color: Colors.black,
                                ),
                                IconButton(
                                  icon: Icon(Icons.copy, size: 16),
                                  onPressed: () {
                                    // Logic to copy to clipboard
                                    Clipboard.setData(
                                      ClipboardData(
                                        text: widget.invoice,
                                      ),
                                    ).then((_) {
                                      ScaffoldMessenger.of(context)
                                          .showSnackBar(
                                        SnackBar(
                                          content:
                                              Text('Nomor invoice disalin'),
                                        ),
                                      );
                                    });
                                  },
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 10),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Container(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                Container(
                                  child: Column(
                                    children: [
                                      Text(
                                        'Total Transaksi',
                                        style: TextStyle(fontSize: 17),
                                      ),
                                      Text(
                                        _currencyFormat.format(widget.total),
                                        style: TextStyle(
                                            fontWeight: FontWeight.bold,
                                            fontSize: 17),
                                      )
                                    ],
                                  ),
                                ),
                                SizedBox(height: 10),
                                Container(
                                  child: Column(
                                    children: [
                                      Text(
                                        'Status Pembayaran',
                                        style: TextStyle(fontSize: 17),
                                      ),
                                      SizedBox(height: 10),
                                      // Pada status pembayaran
                                      Container(
                                        padding: EdgeInsets.all(10),
                                        width: 120,
                                        decoration: BoxDecoration(
                                          color: _isTransactionCompleted
                                              ? Colors.orange
                                              : Colors
                                                  .red, // Ubah warna sesuai status
                                          borderRadius:
                                              BorderRadius.circular(20),
                                        ),
                                        child: Center(
                                          child: Text(
                                            _isTransactionCompleted
                                                ? 'Processing'
                                                : 'Unpaid', // Ubah teks sesuai status
                                            style: TextStyle(
                                              fontWeight: FontWeight.bold,
                                              color: Colors.white,
                                            ),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                )
                              ],
                            ),
                          ),
                          GestureDetector(
                            onTap: _isTransactionCompleted
                                ? null
                                : _showImagePickerDialog, // Kunci gambar jika transaksi selesai
                            child: Container(
                              width: 200,
                              height: 120,
                              decoration: BoxDecoration(
                                color: Colors.grey,
                                borderRadius: BorderRadius.circular(15),
                              ),
                              child: Column(
                                children: [
                                  if (_image == null) ...[
                                    Container(
                                      padding:
                                          EdgeInsets.symmetric(vertical: 23),
                                      child: Column(children: [
                                        Icon(Icons.image),
                                        SizedBox(height: 10),
                                        Text('Kirim bukti transfer kesini'),
                                      ]),
                                    )
                                  ],
                                  if (_image != null)
                                    Container(
                                      width: 200, // Sesuaikan ukuran kontainer
                                      height: 120, // Sesuaikan ukuran kontainer
                                      child: ClipRRect(
                                        borderRadius: BorderRadius.circular(15),
                                        child: Image.file(
                                          File(_image!.path),
                                          fit: BoxFit
                                              .cover, // Gambar memenuhi kontainer
                                        ),
                                      ),
                                    ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                      Spacer(),
                      SizedBox(
                        width: double.infinity,
                        height: 50,
                        child: ElevatedButton(
                          onPressed: () {
                            if (!_isTransactionCompleted) {
                              _handleFinishButton();
                            } else {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (context) => FinishPage()),
                              );
                            }
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors
                                .green, // Warna tombol tetap hijau, terlepas dari status
                          ),
                          child: Text(
                            _isTransactionCompleted
                                ? 'Selesai'
                                : 'Kirim', // Ubah teks tombol sesuai status
                            style: TextStyle(color: Colors.white),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),

            
          ],
        ),
      ),
    );
  }
}
