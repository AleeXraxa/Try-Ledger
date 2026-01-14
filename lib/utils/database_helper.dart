import 'package:sqflite/sqflite.dart' hide Transaction;
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart';
import 'dart:io';
import '../features/ledger/models/ledger_entry_model.dart';
import '../features/inventory/models/product_model.dart';
import '../features/transactions/models/transaction_model.dart' as tx;

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
    return await openDatabase(path, version: 1, onCreate: _onCreate);
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

    // Create transactions table
    await db.execute('''
      CREATE TABLE transactions (
        id INTEGER PRIMARY KEY,
        type TEXT NOT NULL,
        amount REAL NOT NULL,
        description TEXT NOT NULL,
        date TEXT NOT NULL
      )
    ''');
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
    return List.generate(maps.length, (i) {
      return Product.fromJson(maps[i]);
    });
  }

  Future<void> insertProduct(Product product) async {
    Database db = await database;
    await db.insert('products', product.toJson());
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

  // Transaction methods
  Future<List<tx.Transaction>> getTransactions() async {
    Database db = await database;
    List<Map<String, dynamic>> maps = await db.query('transactions');
    return List.generate(maps.length, (i) {
      return tx.Transaction.fromJson(maps[i]);
    });
  }

  Future<void> insertTransaction(tx.Transaction transaction) async {
    Database db = await database;
    await db.insert('transactions', transaction.toJson());
  }

  Future<void> updateTransaction(tx.Transaction transaction) async {
    Database db = await database;
    await db.update(
      'transactions',
      transaction.toJson(),
      where: 'id = ?',
      whereArgs: [transaction.id],
    );
  }

  Future<void> deleteTransaction(int id) async {
    Database db = await database;
    await db.delete('transactions', where: 'id = ?', whereArgs: [id]);
  }
}
