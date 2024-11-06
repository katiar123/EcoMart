import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:intl/intl.dart';
import 'package:web_socket_channel/web_socket_channel.dart';
import 'dart:async'; // Import untuk StreamController

class NotificationPage extends StatefulWidget {
  @override
  _NotificationPageState createState() => _NotificationPageState();
}

class _NotificationPageState extends State<NotificationPage> {
  final String baseUrl = 'http://192.168.0.159/ecomart/public/api';
  List<String> transactionKeys = [];
  Map<String, String> transactionStatuses = {};

  final WebSocketChannel channel = WebSocketChannel.connect(
    Uri.parse('ws://192.168.0.160/ecomart/public/ws'),
  );
  
  final StreamController<Map<String, String>> _streamController = StreamController.broadcast(); // StreamController dengan broadcast

  final NumberFormat _currencyFormat =
      NumberFormat.currency(locale: 'id_ID', symbol: 'Rp. ', decimalDigits: 0);

  @override
  void initState() {
    super.initState();
    _loadNotifications();
    _listenToWebSocket(); // Mendengarkan WebSocket
  }

  @override
  void dispose() {
    channel.sink.close(); // Tutup WebSocket saat halaman ditutup
    _streamController.close(); // Tutup StreamController
    super.dispose();
  }

  Future<void> _loadNotifications() async {
    final prefs = await SharedPreferences.getInstance();
    final keys =
        prefs.getKeys().where((key) => key.startsWith('transaction_')).toList();
    setState(() {
      transactionKeys =
          keys.map((key) => key.replaceFirst('transaction_', '')).toList();
    });
    await _updateAllTransactionStatuses();
    _streamController.add(transactionStatuses); // Kirim data awal ke stream
  }

  Future<void> _updateAllTransactionStatuses() async {
    for (String invoiceKey in transactionKeys) {
      final status = await _fetchStatusFromServer(invoiceKey);
      if (status != null) {
        setState(() {
          transactionStatuses[invoiceKey] = status;
        });
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('transaction_$invoiceKey', status);
      }
    }
    _streamController.add(transactionStatuses); // Update stream setelah semua status di-fetch
  }

  Future<String?> _fetchStatusFromServer(String invoiceKey) async {
    final url = Uri.parse('$baseUrl/transaction/$invoiceKey');
    final response = await http.get(url);

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return data['status'] as String?;
    } else {
      return null;
    }
  }

  Future<String> _getTransactionStatus(String invoiceKey) async {
    if (transactionStatuses.containsKey(invoiceKey)) {
      return transactionStatuses[invoiceKey]!;
    }
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('transaction_$invoiceKey') ?? 'Unknown';
  }

  void _listenToWebSocket() {
    channel.stream.listen((message) async {
      final decodedMessage = jsonDecode(message);
      final invoiceKey = decodedMessage['invoice_key'];
      final status = decodedMessage['status'];

      if (invoiceKey != null && status != null) {
        setState(() {
          transactionStatuses[invoiceKey] = status;
        });

        // Update di SharedPreferences
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('transaction_$invoiceKey', status);

        // Menambahkan data ke StreamController
        _streamController.add(transactionStatuses);
      }
    });
  }

  Future<Map<String, dynamic>?> _getTransactionDetails(
      String invoiceKey) async {
    final url = Uri.parse('$baseUrl/transaction/$invoiceKey');
    final response = await http.get(url);

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return data;
    } else {
      return null;
    }
  }

  void _showTransactionDetails(BuildContext context, String invoiceKey) async {
    final details = await _getTransactionDetails(invoiceKey);
    if (details != null) {
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text('Detail Transaksi $invoiceKey'),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Nama: ${details['nama']}'),
                Text('Status: ${details['status']}'),
                Text('Total: ${_currencyFormat.format(details['total'])}'),
                Text('Tanggal: ${details['tanggal']}'),
                Text('Metode Pembayaran: ${details['payment']}'),
              ],
            ),
            actions: [
              TextButton(
                child: Text('Tutup'),
                onPressed: () {
                  Navigator.of(context).pop();
                },
              ),
            ],
          );
        },
      );
    } else {
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text('Error'),
            content: Text('Gagal memuat detail transaksi.'),
            actions: [
              TextButton(
                child: Text('Tutup'),
                onPressed: () {
                  Navigator.of(context).pop();
                },
              ),
            ],
          );
        },
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Notifikasi', style: TextStyle(color: Colors.white)),
        leading: BackButton(color: Colors.white),
        backgroundColor: Colors.green,
        actions: [
          IconButton(
            icon: Icon(Icons.refresh),
            onPressed: () async {
              await _updateAllTransactionStatuses();
            },
          ),
        ],
      ),
      body: transactionKeys.isEmpty
          ? Center(child: Text('Belum ada notifikasi'))
          : StreamBuilder<Map<String, String>>(
              stream: _streamController.stream, // Mendengarkan StreamController
              builder: (context, snapshot) {
                if (!snapshot.hasData || snapshot.connectionState == ConnectionState.waiting) {
                  return Center(child: CircularProgressIndicator());
                } else {
                  return ListView.builder(
                    itemCount: transactionKeys.length,
                    itemBuilder: (context, index) {
                      String invoiceKey = transactionKeys[index];
                      String status =
                          transactionStatuses[invoiceKey] ?? 'Unknown';

                      return Dismissible(
                        key: Key(invoiceKey),
                        direction: DismissDirection.endToStart,
                        background: Container(
                          color: Colors.red,
                          padding: EdgeInsets.symmetric(horizontal: 20),
                          alignment: Alignment.centerRight,
                          child: Icon(Icons.delete, color: Colors.white),
                        ),
                        onDismissed: (direction) async {
                          final prefs =
                              await SharedPreferences.getInstance();
                          await prefs.remove('transaction_$invoiceKey');
                          setState(() {
                            transactionKeys.removeAt(index);
                          });
                        },
                        child: Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Card(
                            elevation: 5,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: ListTile(
                              leading: Icon(
                                status == 'Paid'
                                    ? Icons.check_circle
                                    : Icons.timelapse,
                                color: status == 'Paid'
                                    ? Colors.green
                                    : Colors.orange,
                              ),
                              title: Text('Pesanan: $invoiceKey',
                                  style:
                                      TextStyle(fontWeight: FontWeight.bold)),
                              subtitle: Text(_getStatusDisplay(status)),
                              trailing: Icon(Icons.arrow_forward_ios),
                              onTap: () =>
                                  _showTransactionDetails(context, invoiceKey),
                            ),
                          ),
                        ),
                      );
                    },
                  );
                }
              },
            ),
    );
  }

  String _getStatusDisplay(String status) {
    if (status == 'Paid') {
      return 'Pesanan Anda telah dikonfirmasi oleh admin';
    } else {
      return 'Pesanan menunggu dikonfirmasi admin. Tunggu sekitar 2 menit untuk dikonfirmasi';
    }
  }
}
