import 'package:flutter/material.dart';
import 'package:flutter/services.dart'; // Tambahkan import ini untuk TextInputFormatter
import '../model/product.dart';
import '../model/cart.dart'; // Import model CartItem jika diperlukan
import 'payment.dart'; // Pastikan untuk menyesuaikan import sesuai dengan struktur folder Anda

class AddressPage extends StatefulWidget {
  final Product? product;
  final int? quantity;
  final List<CartItem>? cartItems; // Tambahkan parameter cartItems untuk kasus dari cart

  AddressPage({this.product, this.quantity, this.cartItems});

  @override
  _AddressPageState createState() => _AddressPageState();
}

class _AddressPageState extends State<AddressPage> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _homeNumberController = TextEditingController();
  final TextEditingController _blockController = TextEditingController();
  final TextEditingController _numberController = TextEditingController();
  bool _isChecked = false;
  final _formKey = GlobalKey<FormState>();
  String? _selectedShippingOption;

  void _proceedToPayment() {
    if (_formKey.currentState?.validate() ?? false) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => PaymentPage(
            name: _nameController.text,
            product: widget.product,
            quantity: widget.quantity,
            cartItems: widget.cartItems, // Kirimkan cartItems jika ada
            number: _numberController.text,
            shippingOption: _selectedShippingOption,
            blok: _blockController.text,
          ),
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Harap isi semua field dengan benar')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Checkout'),
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              Expanded(
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Row(
                              children: [
                                Icon(Icons.location_on, color: Colors.black, size: 28), // Perbesar ukuran ikon
                                SizedBox(width: 10),
                                Expanded(
                                  child: Row(
                                    children: List.generate(5, (_) {
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
                                Icon(Icons.credit_card, color: Colors.grey, size: 28), // Perbesar ukuran ikon
                                SizedBox(width: 10),
                                Expanded(
                                  child: Row(
                                    children: List.generate(5, (_) {
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
                                Icon(Icons.check_circle, color: Colors.grey, size: 28), // Perbesar ukuran ikon
                              ],
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 30),
                      Row(
                        children: [
                          Icon(Icons.location_on, color: Colors.orange, size: 28), // Ikon untuk bagian judul
                          SizedBox(width: 10),
                          Text('Billing Address', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                        ],
                      ),
                      SizedBox(height: 16),
                      TextFormField(
                        controller: _nameController,
                        decoration: InputDecoration(
                          labelText: 'Nama Lengkap',
                          prefixIcon: Icon(Icons.person), // Ikon pada TextFormField
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) return 'Nama Lengkap tidak boleh kosong';
                          return null;
                        },
                      ),
                      SizedBox(height: 16),
                      Row(
                        children: [
                          Expanded(
                            child: TextFormField(
                              controller: _numberController,
                              keyboardType: TextInputType.number, // Set tipe input menjadi angka
                              decoration: InputDecoration(
                                labelText: 'No. Rumah',
                                prefixIcon: Icon(Icons.home), // Ikon pada TextFormField
                              ),
                              validator: (value) {
                                if (value == null || value.isEmpty) return 'No. Rumah tidak boleh kosong';
                                return null;
                              },
                            ),
                          ),
                          SizedBox(width: 16),
                          Expanded(
                            child: TextFormField(
                              controller: _blockController,
                              keyboardType: TextInputType.text,
                              textCapitalization: TextCapitalization.characters, // Membuat semua huruf menjadi besar
                              inputFormatters: [LengthLimitingTextInputFormatter(1)], // Membatasi input hanya satu huruf
                              decoration: InputDecoration(
                                labelText: 'Blok Rumah',
                                prefixIcon: Icon(Icons.location_city), // Ikon pada TextFormField
                              ),
                              validator: (value) {
                                if (value == null || value.isEmpty) return 'Blok Rumah tidak boleh kosong';
                                return null;
                              },
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 16),
                      DropdownButtonFormField<String>(
                        decoration: InputDecoration(
                          labelText: 'Opsi Pengiriman',
                          prefixIcon: Icon(Icons.local_shipping), // Ikon pada DropdownButtonFormField
                        ),
                        value: _selectedShippingOption,
                        items: [
                          DropdownMenuItem(child: Text('Pengiriman Standar'), value: 'standard'),
                          DropdownMenuItem(child: Text('Pengiriman Express (+ Rp 5.000)'), value: 'express'),
                        ],
                        onChanged: (value) {
                          setState(() {
                            _selectedShippingOption = value;
                          });
                        },
                        validator: (value) {
                          if (value == null) return 'Pilih opsi pengiriman';
                          return null;
                        },
                      ),
                      SizedBox(height: 16),
                      Row(
                        children: [
                          Checkbox(
                            value: _isChecked,
                            onChanged: (bool? value) {
                              setState(() {
                                _isChecked = value ?? false;
                              });
                            },
                          ),
                          Expanded(
                            child: Text('Simpan detail untuk alamat pengiriman di masa mendatang'),
                          ),
                        ],
                      ),
                      SizedBox(height: 16),
                    ],
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: ElevatedButton.icon(
                  onPressed: () {
                    _proceedToPayment();
                  },
                  style: ElevatedButton.styleFrom(
                    padding: EdgeInsets.symmetric(vertical: 16),
                    backgroundColor: Colors.green,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10), // Menghilangkan border radius
                    ),
                    minimumSize: Size(double.infinity, 50), // Membuat tombol menjadi panjang
                  ),
                  icon: Icon(Icons.payment, color: Colors.white), // Ikon pada tombol
                  label: Text('Lanjutkan ke Pembayaran', style: TextStyle(color: Colors.white)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
