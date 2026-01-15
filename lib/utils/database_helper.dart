import 'package:sqflite/sqflite.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart';
import 'dart:io';
import '../features/ledger/models/ledger_entry_model.dart';
import '../features/inventory/models/product_model.dart';
import '../features/inventory/models/invoice_model.dart';

class DatabaseHelper {
  static final DatabaseHelper _instance = DatabaseHelper._internal();
  static Database? _database;

  factory DatabaseHelper() => _instance;

  DatabaseHelper._internal();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    Directory documentsDirectory = await getApplicationDocumentsDirectory();
    String path = join(documentsDirectory.path, 'TryLedger.db');
    return await openDatabase(
      path,
      version: 2,
      onCreate: _onCreate,
      onUpgrade: _onUpgrade,
    );
  }

  Future<void> _onCreate(Database db, int version) async {
    // Create ledger_entries table
    await db.execute('''
      CREATE TABLE ledger_entries (
        id INTEGER PRIMARY KEY,
        description TEXT NOT NULL,
        debit REAL NOT NULL,
        credit REAL NOT NULL,
        date TEXT NOT NULL
      )
    ''');

    // Create products table
    await db.execute('''
      CREATE TABLE products (
        id INTEGER PRIMARY KEY,
        name TEXT NOT NULL,
        price REAL NOT NULL,
        stock INTEGER NOT NULL,
        category TEXT
      )
    ''');

    // Create invoices table
    await db.execute('''
      CREATE TABLE invoices (
        id INTEGER PRIMARY KEY,
        reference TEXT NOT NULL,
        date TEXT NOT NULL,
        items TEXT NOT NULL,
        total REAL NOT NULL
      )
    ''');
  }

  Future<void> _onUpgrade(Database db, int oldVersion, int newVersion) async {
    if (oldVersion < 2) {
      // Create invoices table
      await db.execute('''
        CREATE TABLE invoices (
          id INTEGER PRIMARY KEY,
          reference TEXT NOT NULL,
          date TEXT NOT NULL,
          items TEXT NOT NULL,
          total REAL NOT NULL
        )
      ''');
    }
  }

  // Ledger Entry methods
  Future<List<LedgerEntry>> getLedgerEntries() async {
    Database db = await database;
    List<Map<String, dynamic>> maps = await db.query('ledger_entries');
    return List.generate(maps.length, (i) {
      return LedgerEntry.fromJson(maps[i]);
    });
  }

  Future<void> insertLedgerEntry(LedgerEntry entry) async {
    Database db = await database;
    await db.insert('ledger_entries', entry.toJson());
  }

  Future<void> updateLedgerEntry(LedgerEntry entry) async {
    Database db = await database;
    await db.update(
      'ledger_entries',
      entry.toJson(),
      where: 'id = ?',
      whereArgs: [entry.id],
    );
  }

  Future<void> deleteLedgerEntry(int id) async {
    Database db = await database;
    await db.delete('ledger_entries', where: 'id = ?', whereArgs: [id]);
  }

  // Product methods
  Future<List<Product>> getProducts() async {
    Database db = await database;
    List<Map<String, dynamic>> maps = await db.query('products');
    print('Queried products: $maps');
    return List.generate(maps.length, (i) {
      return Product.fromJson(maps[i]);
    });
  }

  Future<void> insertProduct(Product product) async {
    Database db = await database;
    Map<String, dynamic> data = product.toJson();
    data.remove('id');
    print('Inserting product data: $data');
    try {
      await db.insert('products', data);
      print('Product inserted successfully');
    } catch (e) {
      print('Error inserting product: $e');
    }
  }

  Future<void> updateProduct(Product product) async {
    Database db = await database;
    await db.update(
      'products',
      product.toJson(),
      where: 'id = ?',
      whereArgs: [product.id],
    );
  }

  Future<void> deleteProduct(int id) async {
    Database db = await database;
    await db.delete('products', where: 'id = ?', whereArgs: [id]);
  }

  // Invoice methods
  Future<List<Invoice>> getInvoices() async {
    Database db = await database;
    List<Map<String, dynamic>> maps = await db.query('invoices');
    return List.generate(maps.length, (i) {
      return Invoice.fromJson(maps[i]);
    });
  }

  Future<void> insertInvoice(Invoice invoice) async {
    Database db = await database;
    Map<String, dynamic> data = invoice.toJson();
    data.remove('id');
    await db.insert('invoices', data);
  }

  Future<void> updateInvoice(Invoice invoice) async {
    Database db = await database;
    await db.update(
      'invoices',
      invoice.toJson(),
      where: 'id = ?',
      whereArgs: [invoice.id],
    );
  }

  Future<void> deleteInvoice(int id) async {
    Database db = await database;
    await db.delete('invoices', where: 'id = ?', whereArgs: [id]);
  }
}
