import 'package:sqflite/sqflite.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart';
import 'dart:io';
import '../features/ledger/models/ledger_entry_model.dart';
import '../features/inventory/models/product_model.dart';
import '../features/inventory/models/invoice_model.dart';
import '../features/company/models/company_model.dart';

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
    Database db = await openDatabase(
      path,
      version: 9,
      onCreate: _onCreate,
      onUpgrade: _onUpgrade,
    );

    // Ensure new columns exist (for existing databases)
    await _ensureColumnsExist(db);

    return db;
  }

  Future<void> _onCreate(Database db, int version) async {
    // Create ledger_entries table
    await db.execute('''
      CREATE TABLE ledger_entries (
        id INTEGER PRIMARY KEY,
        description TEXT NOT NULL,
        debit REAL NOT NULL,
        credit REAL NOT NULL,
        date TEXT NOT NULL,
        company_id INTEGER,
        reference_no TEXT,
        qty INTEGER,
        rate REAL
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

      // Create company table
      await db.execute('''
        CREATE TABLE company (
          id INTEGER PRIMARY KEY,
          name TEXT NOT NULL,
          type TEXT NOT NULL,
          address TEXT NOT NULL,
          phone TEXT NOT NULL,
          email TEXT NOT NULL
        )
      ''');
    }
    if (oldVersion < 3) {
      // Create company table
      await db.execute('''
        CREATE TABLE company (
          id INTEGER PRIMARY KEY,
          name TEXT NOT NULL,
          type TEXT NOT NULL,
          address TEXT NOT NULL,
          phone TEXT NOT NULL,
          email TEXT NOT NULL
        )
      ''');
    }
    if (oldVersion < 4) {
      // Add type column to company table
      await db.execute(
        'ALTER TABLE company ADD COLUMN type TEXT NOT NULL DEFAULT ""',
      );
    }
    if (oldVersion < 5) {
      // Add company_id column to ledger_entries table
      await db.execute(
        'ALTER TABLE ledger_entries ADD COLUMN company_id INTEGER',
      );
    }
    if (oldVersion < 6) {
      // Add companyId column to products table
      await db.execute('ALTER TABLE products ADD COLUMN companyId INTEGER');
    }
    if (oldVersion < 7) {
      // Add companyId column to invoices table
      await db.execute('ALTER TABLE invoices ADD COLUMN companyId INTEGER');
    }
    if (oldVersion < 8) {
      // Add new columns to ledger_entries table
      await db.execute(
        'ALTER TABLE ledger_entries ADD COLUMN reference_no TEXT',
      );
      await db.execute('ALTER TABLE ledger_entries ADD COLUMN qty INTEGER');
      await db.execute('ALTER TABLE ledger_entries ADD COLUMN rate REAL');
    }
    // isActive column already exists in company table
  }

  Future<void> _ensureColumnsExist(Database db) async {
    // Check if new columns exist in ledger_entries table
    List<Map<String, dynamic>> columns = await db.rawQuery(
      "PRAGMA table_info(ledger_entries)",
    );

    bool hasReferenceNo = columns.any((col) => col['name'] == 'reference_no');
    bool hasQty = columns.any((col) => col['name'] == 'qty');
    bool hasRate = columns.any((col) => col['name'] == 'rate');

    try {
      if (!hasReferenceNo) {
        await db.execute(
          'ALTER TABLE ledger_entries ADD COLUMN reference_no TEXT',
        );
      }
    } catch (e) {
      // Column might already exist, ignore
    }

    try {
      if (!hasQty) {
        await db.execute('ALTER TABLE ledger_entries ADD COLUMN qty INTEGER');
      }
    } catch (e) {
      // Column might already exist, ignore
    }

    try {
      if (!hasRate) {
        await db.execute('ALTER TABLE ledger_entries ADD COLUMN rate REAL');
      }
    } catch (e) {
      // Column might already exist, ignore
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

  // Company methods
  Future<List<Company>> getCompanies() async {
    Database db = await database;
    List<Map<String, dynamic>> maps = await db.query('company');
    return List.generate(maps.length, (i) {
      return Company.fromJson(maps[i]);
    });
  }

  Future<void> insertCompany(Company company) async {
    Database db = await database;
    Map<String, dynamic> data = company.toJson();
    data.remove('id');
    await db.insert('company', data);
  }

  Future<void> updateCompany(Company company) async {
    Database db = await database;
    await db.update(
      'company',
      company.toJson(),
      where: 'id = ?',
      whereArgs: [company.id],
    );
  }

  Future<void> deleteCompany(int id) async {
    Database db = await database;
    await db.delete('company', where: 'id = ?', whereArgs: [id]);
  }

  // Backup method
  Future<Map<String, dynamic>> exportAllData() async {
    Database db = await database;

    // Get all data from all tables
    List<Map<String, dynamic>> ledgerEntries = await db.query('ledger_entries');
    List<Map<String, dynamic>> products = await db.query('products');
    List<Map<String, dynamic>> invoices = await db.query('invoices');
    List<Map<String, dynamic>> companies = await db.query('company');

    return {
      'version': 3,
      'exported_at': DateTime.now().toIso8601String(),
      'data': {
        'ledger_entries': ledgerEntries,
        'products': products,
        'invoices': invoices,
        'companies': companies,
      },
    };
  }

  // Restore method
  Future<void> importAllData(Map<String, dynamic> backupData) async {
    Database db = await database;

    // Clear existing data
    await db.delete('ledger_entries');
    await db.delete('products');
    await db.delete('invoices');
    await db.delete('company');

    // Import ledger entries
    if (backupData['data']['ledger_entries'] != null) {
      List<Map<String, dynamic>> ledgerEntries =
          List<Map<String, dynamic>>.from(backupData['data']['ledger_entries']);
      for (var entry in ledgerEntries) {
        await db.insert('ledger_entries', entry);
      }
    }

    // Import products
    if (backupData['data']['products'] != null) {
      List<Map<String, dynamic>> products = List<Map<String, dynamic>>.from(
        backupData['data']['products'],
      );
      for (var product in products) {
        await db.insert('products', product);
      }
    }

    // Import invoices
    if (backupData['data']['invoices'] != null) {
      List<Map<String, dynamic>> invoices = List<Map<String, dynamic>>.from(
        backupData['data']['invoices'],
      );
      for (var invoice in invoices) {
        await db.insert('invoices', invoice);
      }
    }

    // Import companies
    if (backupData['data']['companies'] != null) {
      List<Map<String, dynamic>> companies = List<Map<String, dynamic>>.from(
        backupData['data']['companies'],
      );
      for (var company in companies) {
        await db.insert('company', company);
      }
    }
  }
}
