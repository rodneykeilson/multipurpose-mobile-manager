import 'dart:async';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';
import 'product.dart';

class DatabaseHelper {
  static final DatabaseHelper instance = DatabaseHelper._init();
  static Database? _database;

  DatabaseHelper._init();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB('multipurpose_mobile_manager.db');
    return _database!;
  }

  Future<Database> _initDB(String filePath) async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, filePath);
    return await openDatabase(path, version: 1, onCreate: _createDB);
  }

  Future _createDB(Database db, int version) async {
    await db.execute('''
      CREATE TABLE persediaan_barang (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        nama_barang TEXT NOT NULL,
        jumlah_barang INTEGER NOT NULL,
        price REAL NOT NULL,
        product_image_url TEXT,
        created_at TEXT,
        updated_at TEXT
      )
    ''');

    await db.execute('''
      CREATE TABLE checkouts (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        customer_name TEXT,
        description TEXT,
        quantity INTEGER,
        unit_price REAL,
        total_price REAL
      )
    ''');

    await db.execute('''
      CREATE TABLE costs (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        client_name TEXT,
        product_name TEXT,
        quantity INTEGER,
        unit_price REAL,
        total_price REAL
      )
    ''');

    // New table for daftar_karyawan
    await db.execute('''
      CREATE TABLE daftar_karyawan (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        nama_karyawan TEXT NOT NULL,
        posisi TEXT NOT NULL,
        tanggal_mulai_kerja TEXT NOT NULL,
        info_absensi TEXT DEFAULT 'Present'
      )
    ''');
  }

  // Product Methods
  Future<int> insertProduct(Product product) async {
    final db = await instance.database;
    return await db.insert('persediaan_barang', product.toMap());
  }

  Future<List<Product>> fetchAllProducts() async {
    final db = await instance.database;
    final result = await db.query('persediaan_barang');
    return result.map((json) => Product.fromMap(json)).toList();
  }

  Future<int> updateProduct(Product product) async {
    final db = await instance.database;
    return await db.update(
      'persediaan_barang',
      product.toMap(),
      where: 'id = ?',
      whereArgs: [product.id],
    );
  }

  Future<void> updateProductQuantity(int productId, int newQuantity) async {
    final db = await database;
    await db.update(
      'persediaan_barang',
      {'jumlah_barang': newQuantity}, 
      where: 'id = ?',
      whereArgs: [productId],
    );
  }

  Future<int> deleteProduct(int id) async {
    final db = await instance.database;
    return await db.delete(
      'persediaan_barang',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  Future<int> insertKaryawan(Map<String, dynamic> karyawanData) async {
    final db = await database;
    return await db.insert('daftar_karyawan', karyawanData);
  }

  Future<List<Map<String, dynamic>>> fetchAllKaryawan() async {
    final db = await database;
    return await db.query('daftar_karyawan');
  }

  Future<int> updateKaryawanAttendance(int id, String status) async {
    final db = await database;
    return await db.update(
      'daftar_karyawan',
      {'info_absensi': status},
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  // Checkout Methods
  Future<int> insertCheckout(Map<String, dynamic> checkoutData) async {
    final db = await database;
    return await db.insert('checkouts', checkoutData);
  }

  Future<List<Map<String, dynamic>>> fetchCheckouts() async {
    final db = await database;
    return await db.query('checkouts');
  }

  // Cost Methods
  Future<int> insertCost(Map<String, dynamic> costData) async {
    final db = await database;
    return await db.insert('costs', costData);
  }

  Future<List<Map<String, dynamic>>> fetchCosts() async {
    final db = await database;
    return await db.query('costs');
  }

  Future<int> deleteCost(int id) async {
    final db = await instance.database;
    return await db.delete(
      'costs',
      where: 'id = ?',
      whereArgs: [id],
    );
  }
}
