import 'package:flutter/material.dart';

class PaymentMethodPage extends StatefulWidget {
  final String? selectedPaymentMethod;
  final String? selectedBank;
  final Function(String, String?) onPaymentMethodSelected;

  PaymentMethodPage({
    required this.onPaymentMethodSelected,
    this.selectedPaymentMethod,
    this.selectedBank,
  });

  @override
  _PaymentMethodPageState createState() => _PaymentMethodPageState();
}

class _PaymentMethodPageState extends State<PaymentMethodPage> {
  String? _selectedPaymentMethod;
  String? _selectedBank;
  bool _showBankOptions = false;

  final Map<String, String> _banks = {
    'BCA': 'assets/bca.png',
    'Mandiri': 'assets/mandiri.png',
    'BNI': 'assets/bni.png',
    'BRI': 'assets/bri.png',
  };

  final Map<String, String> _paymentMethods = {
    'Transfer bank': 'assets/transfer.png',
    'credit_card': 'assets/kredit.png',
    'e_wallet': 'assets/ewallet.png',
  };

  @override
  void initState() {
    super.initState();
    _selectedPaymentMethod = widget.selectedPaymentMethod;
    _selectedBank = widget.selectedBank;
    _showBankOptions = _selectedPaymentMethod == 'Transfer bank';
  }

  void _selectPaymentMethod(String method) {
    setState(() {
      if (method == 'Transfer bank') {
        _showBankOptions = !_showBankOptions; // Toggle bank options visibility
      } else {
        _showBankOptions = false; // Close bank options for other methods
        _selectedBank = null; // Reset selected bank if not Transfer bank
      }
      _selectedPaymentMethod = method;
    });
  }

  void _selectBank(String bank) {
    setState(() {
      _selectedBank = bank;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Metode Pembayaran'),
        backgroundColor: Colors.white,
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  ListTile(
                    leading: Image.asset(_paymentMethods['Transfer bank']!, width: 40),
                    title: Text('Transfer Bank'), // Update label here
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        if (_selectedPaymentMethod == 'Transfer bank' && _selectedBank != null)
                          Icon(Icons.check_circle, color: Colors.orange),
                        Icon(_showBankOptions ? Icons.expand_less : Icons.expand_more),
                      ],
                    ),
                    onTap: () {
                      _selectPaymentMethod('Transfer bank');
                    },
                  ),
                  if (_showBankOptions)
                    Column(
                      children: _banks.entries.map((entry) {
                        return Column(
                          children: [
                            ListTile(
                              leading: Image.asset(entry.value, width: 40),
                              title: Text(entry.key),
                              trailing: _selectedBank == entry.key
                                  ? Icon(Icons.check_circle, color: Colors.orange)
                                  : null,
                              onTap: () {
                                _selectBank(entry.key);
                              },
                            ),
                            if (_banks.keys.last != entry.key) Divider(),
                          ],
                        );
                      }).toList(),
                    ),
                  
                  Divider(),

                  ListTile(
                    leading: Image.asset(_paymentMethods['credit_card']!, width: 40),
                    title: Text('Kartu Kredit'),
                    subtitle: Text('Belum tersedia', style: TextStyle(color: Colors.grey)),
                    trailing: _selectedPaymentMethod == 'credit_card'
                        ? Icon(Icons.check_circle, color: Colors.orange)
                        : null,
                    onTap: () {},
                    tileColor: Colors.grey.shade200,
                    enabled: false,
                  ),
                  
                  Divider(),

                  ListTile(
                    leading: Image.asset(_paymentMethods['e_wallet']!, width: 40),
                    title: Text('E-wallet'),
                    subtitle: Text('Belum tersedia', style: TextStyle(color: Colors.grey)),
                    trailing: _selectedPaymentMethod == 'e_wallet'
                        ? Icon(Icons.check_circle, color: Colors.orange)
                        : null,
                    onTap: () {},
                    tileColor: Colors.grey.shade200,
                    enabled: false,
                  ),
                ],
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  if (_selectedPaymentMethod != null && (_selectedPaymentMethod != 'Transfer bank' || _selectedBank != null)) {
                    widget.onPaymentMethodSelected(_selectedPaymentMethod!, _selectedBank);
                    Navigator.pop(context); // Navigate back
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Silakan pilih metode pembayaran dan bank (jika transfer bank) terlebih dahulu.')),
                    );
                  }
                },
                child: Text('Konfirmasi',style: TextStyle(color: Colors.white)),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green,
                  padding: EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
