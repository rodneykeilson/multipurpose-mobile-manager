import 'dart:convert';

class Product {
  String? id; // Firestore document ID
  String namaBarang;
  int jumlahBarang;
  double price;
  String? imageBase64; // Store image as a base64 string
  DateTime? createdAt;
  DateTime? updatedAt;

  Product({
    this.id,
    required this.namaBarang,
    required this.jumlahBarang,
    required this.price,
    this.imageBase64,
    this.createdAt,
    this.updatedAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'nama_barang': namaBarang,
      'jumlah_barang': jumlahBarang,
      'price': price,
      'image_base64': imageBase64,
      'created_at': createdAt?.toIso8601String(),
      'updated_at': updatedAt?.toIso8601String(),
    };
  }

  factory Product.fromMap(Map<String, dynamic> map) {
    return Product(
      namaBarang: map['nama_barang'] ?? '',
      jumlahBarang: map['jumlah_barang'] ?? 0,
      price: (map['price'] ?? 0).toDouble(),
      imageBase64: map['image_base64'],
      createdAt: map['created_at'] != null ? DateTime.parse(map['created_at']) : null,
      updatedAt: map['updated_at'] != null ? DateTime.parse(map['updated_at']) : null,
    );
  }
}
