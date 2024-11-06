class CartItem {
  final int id;
  final int product_id;
  final String nama;
  final String gambar;
  final int harga;
  int kuantitas; // Pastikan ini adalah tipe int

  CartItem({
    required this.id,
    required this.product_id,
    required this.nama,
    required this.gambar,
    required this.harga,
    required this.kuantitas,
  });

  // Untuk serialisasi dan deserialisasi jika diperlukan
  factory CartItem.fromJson(Map<String, dynamic> json) {
    return CartItem(
      id: json['id'],
      product_id: json['product_id'],
      nama: json['nama'],
      gambar: json['gambar'],
      harga: json['harga'],
      kuantitas: json['kuantitas'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id':id,
      'product_id':product_id,
      'nama': nama,
      'gambar': gambar,
      'harga': harga,
      'kuantitas': kuantitas,
    };
  }
}

