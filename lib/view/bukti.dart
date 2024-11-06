import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/services.dart';
import 'finish.dart';
import 'notifikasi.dart';

class Bukti extends StatefulWidget {
  final String? payment;
  final String? bankName;
  final int total;
  final String invoice;
  String nama;
  String gambar;
  final List<dynamic> id; // Ubah parameter ini menjadi List<int>

  Bukti(
      {required this.payment,
      this.bankName,
      required this.total,
      required this.invoice,
      required this.nama,
      required this.gambar,
      required this.id});

  @override
  _BuktiState createState() => _BuktiState();
}

class _BuktiState extends State<Bukti> {
  final NumberFormat _currencyFormat =
      NumberFormat.currency(locale: 'id_ID', symbol: 'Rp. ', decimalDigits: 0);
  final ImagePicker _picker = ImagePicker();
  XFile? _image;
  bool _isTransactionCompleted = false;

  @override
  void initState() {
    super.initState();
    _checkTransactionStatus();
  }

  Future<void> _checkTransactionStatus() async {
    final prefs = await SharedPreferences.getInstance();
    final status = prefs.getString('transaction_${widget.invoice}');
    if (status == 'Paid') {
      setState(() {
        _isTransactionCompleted = true;
      });
    }
  }

  void _showLoadingDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
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
      _showLoadingDialog();
      var request = http.MultipartRequest('POST', Uri.parse(url));

      request.fields['nama'] = widget.nama;
      request.fields['invoice'] = widget.invoice;
      request.fields['total'] = widget.total.toString();
      request.fields['payment'] = widget.payment ?? '';
      request.fields['status'] = 'Unpaid';
      request.fields['pengantaran'] = 'Belum dikonfirmasi';

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
        await saveTransactionToLocalStorage();
        await saveStatusToLocalStorage(widget.invoice, 'Processing');
      } else {
        print('Gagal mengunggah bukti transfer');
      }
    } catch (e) {
      print('Terjadi kesalahan: $e');
    } finally {
      _hideLoadingDialog();
    }
  }

  Future<String> encodeImageToBase64(File imageFile) async {
    try {
      final bytes = await imageFile.readAsBytes();
      return base64Encode(bytes);
    } catch (e) {
      print('Error encoding image: $e');
      return '';
    }
  }

  Future<void> saveTransactionToLocalStorage() async {
    final prefs = await SharedPreferences.getInstance();
    List<String>? transactions = prefs.getStringList('transactions') ?? [];

    transactions.add(jsonEncode({
      'nama': widget.nama,
      'invoice': widget.invoice,
      'total': widget.total,
      'payment': widget.payment,
      'status': 'Unpaid',
      'gambar': widget.gambar,
      'id': widget.id,
    }));

    await prefs.setStringList('transactions', transactions);
  }

  Future<void> saveInvoice(String invoice) async {
    final prefs = await SharedPreferences.getInstance();
    List<String>? invoices = prefs.getStringList('invoices') ?? [];
    
    if (!invoices.contains(invoice)) {
      invoices.add(invoice);
      await prefs.setStringList('invoices', invoices);
    }
  }


  Future<void> saveStatusToLocalStorage(
      String invoiceNumber, String status) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('transaction_$invoiceNumber', status);
  }

  void _navigateToFinishPage() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => FinishPage()),
    );
  }

  Future<void> _handleFinishButton() async {
    if (!_isTransactionCompleted) {
      await insert();
      await saveStatusToLocalStorage(widget.invoice, 'Processing');
      await saveInvoice(widget.invoice);
    } else {
      await saveStatusToLocalStorage(widget.invoice, 'Paid');
      await _showNotificationIfPaid();
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
        actions: [
          IconButton(
            icon: Icon(Icons.notifications),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => NotificationPage()),
              );
            },
          ),
        ],
      ),
      body: Container(
        color: Colors.grey[200],
        child: Column(
          children: [
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
                                  height: 25,
                                  color: Colors.black,
                                ),
                                IconButton(
                                  icon: Icon(Icons.copy, size: 16),
                                  onPressed: () {
                                    Clipboard.setData(
                                      ClipboardData(text: widget.invoice),
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
                                        'Status Transaksi',
                                        style: TextStyle(fontSize: 17),
                                      ),
                                      SizedBox(height: 5),
                                      Container(
                                        padding: EdgeInsets.all(10),
                                        width: 120,
                                        decoration: BoxDecoration(
                                          color: _isTransactionCompleted
                                              ? Colors.orange
                                              : Colors.red,
                                          borderRadius:
                                              BorderRadius.circular(20),
                                        ),
                                        child: Center(
                                          child: Text(
                                            _isTransactionCompleted
                                                ? 'Processing'
                                                : 'Unpaid',
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
                                : _showImagePickerDialog,
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
                                      width: 200,
                                      height: 120,
                                      child: ClipRRect(
                                        borderRadius: BorderRadius.circular(15),
                                        child: Image.file(
                                          File(_image!.path),
                                          fit: BoxFit.cover,
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
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Container(
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
                              backgroundColor: Colors.green,
                            ),
                            child: Text(
                              _isTransactionCompleted ? 'Selesai' : 'Kirim',
                              style: TextStyle(color: Colors.white),
                            ),
                          ),
                        ),
                      )
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
