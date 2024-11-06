class Product {
  final int id;
  final String nama;
  final int harga;
  final String kategori;
  final String gambar;

  Product({
    required this.id,
    required this.nama, 
    required this.harga, 
    required this.kategori,
    required this.gambar
  });

  factory Product.fromJson(Map<String, dynamic> json) {
    return Product(
      id: json['id'],
      nama: json['nama'],
      harga: json['harga'],
      kategori: json['kategori'],
      gambar: json['gambar'],
    );
  }
}
