import 'package:flutter/material.dart';

class ReportCenter extends StatefulWidget {
  @override
  _ReportCenterState createState() => _ReportCenterState();
}

class _ReportCenterState extends State<ReportCenter> {
  final TextEditingController _invoiceController = TextEditingController();
  bool _barangRusak = false;
  bool _buahBusuk = false;
  bool _batalPesanan = false;
  bool _reportAplikasi = false;
  bool _lainnya = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios, color: Colors.black),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        title: Text(
          'REPORT CENTER',
          style: TextStyle(
            color: Colors.black,
            fontWeight: FontWeight.bold,
            fontSize: 18,
          ),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        child: Container(
          padding: EdgeInsets.all(16.0),
          color: Colors.white,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _buildIcon(
                    iconData: Icons.cancel_outlined,
                    labelText: 'Batalkan Pesanan',
                    onTap: () {
                      setState(() {
                        _batalPesanan = true;
                      });
                    },
                  ),
                  _buildIcon(
                    iconData: Icons.delivery_dining,
                    labelText: 'Barang Rusak',
                    onTap: () {
                      setState(() {
                        _barangRusak = true;
                      });
                    },
                  ),
                  _buildIcon(
                    iconData: Icons.home_repair_service_outlined,
                    labelText: 'Report Aplikasi',
                    onTap: () {
                      setState(() {
                        _reportAplikasi = true;
                      });
                    },
                  ),
                ],
              ),
              SizedBox(height: 24.0),
              Text(
                'Masukan Nomor Invoice',
                style: TextStyle(
                  fontSize: 14.0,
                  fontWeight: FontWeight.bold,
                  color: Colors.black.withOpacity(0.8),
                ),
              ),
              SizedBox(height: 8.0),
              TextField(
                controller: _invoiceController,
                decoration: InputDecoration(
                  hintText: 'Nomor Invoice',
                  hintStyle: TextStyle(color: Colors.grey),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  filled: true,
                  fillColor: Colors.grey[200],
                ),
              ),
              SizedBox(height: 24.0),
              Text(
                'FAQ',
                style: TextStyle(
                  fontSize: 18.0,
                  fontWeight: FontWeight.bold,
                  color: Colors.black.withOpacity(0.8),
                ),
              ),
              SizedBox(height: 16.0),
              _buildCircularCheckbox(
                title: '[Laporan Barang Rusak] Laporkan barang yang rusak',
                value: _barangRusak,
                onChanged: (value) {
                  setState(() {
                    _barangRusak = value ?? false;
                  });
                },
              ),
              Divider(color: Colors.grey),
              _buildCircularCheckbox(
                title: '[Laporan Buah/Sayur Busuk] Laporkan Buah/Sayur yang busuk',
                value: _buahBusuk,
                onChanged: (value) {
                  setState(() {
                    _buahBusuk = value ?? false;
                  });
                },
              ),
              Divider(color: Colors.grey),
              _buildCircularCheckbox(
                title: '[Batalkan Pesanan] Salah pesanan',
                value: _batalPesanan,
                onChanged: (value) {
                  setState(() {
                    _batalPesanan = value ?? false;
                  });
                },
              ),
              Divider(color: Colors.grey),
              _buildCircularCheckbox(
                title: 'Report Aplikasi',
                value: _reportAplikasi,
                onChanged: (value) {
                  setState(() {
                    _reportAplikasi = value ?? false;
                  });
                },
              ),
              Divider(color: Colors.grey),
              _buildCircularCheckbox(
                title: 'Lainnya',
                value: _lainnya,
                onChanged: (value) {
                  setState(() {
                    _lainnya = value ?? false;
                  });
                },
              ),
              SizedBox(height: 24.0),
              Text(
                'Tuliskan apa yang terjadi :',
                style: TextStyle(
                  fontSize: 14.0,
                  fontWeight: FontWeight.bold,
                  color: Colors.black.withOpacity(0.8),
                ),
              ),
              SizedBox(height: 8.0),
              TextField(
                maxLines: 5,
                decoration: InputDecoration(
                  hintText: 'Jelaskan masalah yang Anda alami',
                  hintStyle: TextStyle(color: Colors.grey),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  filled: true,
                  fillColor: Colors.grey[200],
                ),
              ),
              SizedBox(height: 32.0),
              Center(
                child: ElevatedButton(
                  onPressed: () {
                    print('Invoice: ${_invoiceController.text}');
                    print('Barang Rusak: $_barangRusak');
                    print('Buah Busuk: $_buahBusuk');
                    print('Batalkan Pesanan: $_batalPesanan');
                    print('Report Aplikasi: $_reportAplikasi');
                    print('Lainnya: $_lainnya');
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Color.fromARGB(255, 44, 103, 46),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    padding: EdgeInsets.symmetric(
                      horizontal: 145.0,
                      vertical: 18.0,
                    ),
                  ),
                  child: Text(
                    'Kirim!',
                    style: TextStyle(
                      fontSize: 18.0,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                      letterSpacing: 1.0,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildIcon({
    required IconData iconData,
    required String labelText,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        children: [
          Container(
            padding: EdgeInsets.all(12),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.grey[200],
            ),
            child: Icon(
              iconData,
              size: 40.0,
              color: Color.fromARGB(255, 44, 103, 46),
            ),
          ),
          SizedBox(height: 8.0),
          Text(
            labelText,
            style: TextStyle(
              fontSize: 12.0,
              color: Colors.black.withOpacity(0.7),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCircularCheckbox({
    required String title,
    required bool value,
    required ValueChanged<bool?> onChanged,
  }) {
    return ListTile(
      leading: GestureDetector(
        onTap: () {
          onChanged(!value);
        },
        child: Container(
          height: 15.0,
          width: 15.0,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(
              color: Color.fromARGB(255, 44, 103, 46),
              width: 2.0,
            ),
            color: value ? Color.fromARGB(255, 44, 103, 46) : Colors.transparent,
          ),
          child: value
              ? Icon(
                  Icons.check,
                  size: 12.0,
                  color: Colors.white,
                )
              : null,
        ),
      ),
      title: Text(
        title,
        style: TextStyle(
          fontSize: 14.0,
          color: Colors.black.withOpacity(0.8),
        ),
      ),
      onTap: () {
        onChanged(!value);
      },
    );
  }
}
