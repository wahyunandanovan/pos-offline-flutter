import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

/// Database Helper - Singleton pattern untuk manajemen SQLite
class DBHelper {
  static final DBHelper instance = DBHelper._init();
  static Database? _database;

  DBHelper._init();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB('pos_offline.db');
    return _database!;
  }

  Future<Database> _initDB(String filePath) async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, filePath);

    return await openDatabase(
      path,
      version: 1,
      onCreate: _createDB,
      onUpgrade: _upgradeDB,
    );
  }

  /// Create tables untuk semua modul
  Future<void> _createDB(Database db, int version) async {
    // Users table
    await db.execute('''
      CREATE TABLE users (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        username TEXT UNIQUE NOT NULL,
        password TEXT NOT NULL,
        fullName TEXT NOT NULL,
        email TEXT,
        phone TEXT,
        role TEXT NOT NULL DEFAULT 'kasir',
        isActive INTEGER NOT NULL DEFAULT 1,
        avatarPath TEXT,
        createdAt TEXT NOT NULL,
        updatedAt TEXT NOT NULL
      )
    ''');

    // Products table
    await db.execute('''
      CREATE TABLE products (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        sku TEXT UNIQUE NOT NULL,
        name TEXT NOT NULL,
        description TEXT,
        category TEXT,
        buyPrice REAL NOT NULL DEFAULT 0,
        sellPrice REAL NOT NULL DEFAULT 0,
        stock INTEGER NOT NULL DEFAULT 0,
        minStock INTEGER DEFAULT 0,
        soldQuantity INTEGER NOT NULL DEFAULT 0,
        barcode TEXT,
        imagePath TEXT,
        isActive INTEGER NOT NULL DEFAULT 1,
        createdAt TEXT NOT NULL,
        updatedAt TEXT NOT NULL
      )
    ''');

    // Transactions table
    await db.execute('''
      CREATE TABLE transactions (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        transactionCode TEXT UNIQUE NOT NULL,
        userId INTEGER NOT NULL,
        userName TEXT NOT NULL,
        subtotal REAL NOT NULL,
        discount REAL NOT NULL DEFAULT 0,
        tax REAL NOT NULL DEFAULT 0,
        total REAL NOT NULL,
        paid REAL NOT NULL,
        change REAL NOT NULL DEFAULT 0,
        paymentMethod TEXT NOT NULL,
        notes TEXT,
        status TEXT NOT NULL DEFAULT 'completed',
        createdAt TEXT NOT NULL,
        FOREIGN KEY (userId) REFERENCES users (id)
      )
    ''');

    // Transaction items table
    await db.execute('''
      CREATE TABLE transaction_items (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        transactionId INTEGER NOT NULL,
        productId INTEGER NOT NULL,
        productName TEXT NOT NULL,
        sku TEXT NOT NULL,
        quantity INTEGER NOT NULL,
        price REAL NOT NULL,
        discount REAL NOT NULL DEFAULT 0,
        subtotal REAL NOT NULL,
        FOREIGN KEY (transactionId) REFERENCES transactions (id) ON DELETE CASCADE,
        FOREIGN KEY (productId) REFERENCES products (id)
      )
    ''');

    // Sessions table untuk persisten login
    await db.execute('''
      CREATE TABLE sessions (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        userId INTEGER NOT NULL,
        token TEXT UNIQUE NOT NULL,
        expiresAt TEXT NOT NULL,
        createdAt TEXT NOT NULL,
        FOREIGN KEY (userId) REFERENCES users (id)
      )
    ''');

    // Insert default admin user
    await db.insert('users', {
      'username': 'admin',
      'password': 'admin123', // In production, use hashed password
      'fullName': 'Administrator',
      'email': 'admin@posoffline.com',
      'phone': '081234567890',
      'role': 'admin',
      'isActive': 1,
      'createdAt': DateTime.now().toIso8601String(),
      'updatedAt': DateTime.now().toIso8601String(),
    });

    // Insert sample kasir user
    await db.insert('users', {
      'username': 'kasir1',
      'password': 'kasir123',
      'fullName': 'Kasir Satu',
      'email': 'kasir1@posoffline.com',
      'phone': '082345678901',
      'role': 'kasir',
      'isActive': 1,
      'createdAt': DateTime.now().toIso8601String(),
      'updatedAt': DateTime.now().toIso8601String(),
    });

    // Insert sample products
    final sampleProducts = [
      {
        'sku': 'PRD001',
        'name': 'Indomie Goreng',
        'description': 'Mie instan rasa original',
        'category': 'Makanan',
        'buyPrice': 2500.0,
        'sellPrice': 3500.0,
        'stock': 100,
        'minStock': 20,
        'barcode': '8992388101',
        'isActive': 1,
        'createdAt': DateTime.now().toIso8601String(),
        'updatedAt': DateTime.now().toIso8601String(),
      },
      {
        'sku': 'PRD002',
        'name': 'Aqua 600ml',
        'description': 'Air mineral kemasan',
        'category': 'Minuman',
        'buyPrice': 2000.0,
        'sellPrice': 3000.0,
        'stock': 150,
        'minStock': 30,
        'barcode': '8991234567',
        'isActive': 1,
        'createdAt': DateTime.now().toIso8601String(),
        'updatedAt': DateTime.now().toIso8601String(),
      },
      {
        'sku': 'PRD003',
        'name': 'Teh Botol Sosro',
        'description': 'Teh dalam botol',
        'category': 'Minuman',
        'buyPrice': 3000.0,
        'sellPrice': 4500.0,
        'stock': 80,
        'minStock': 15,
        'barcode': '8992761234',
        'isActive': 1,
        'createdAt': DateTime.now().toIso8601String(),
        'updatedAt': DateTime.now().toIso8601String(),
      },
    ];

    for (var product in sampleProducts) {
      await db.insert('products', product);
    }
  }

  Future<void> _upgradeDB(Database db, int oldVersion, int newVersion) async {
    // Handle database upgrades in future versions
    if (oldVersion < newVersion) {
      // Add migration logic here
    }
  }

  /// Close database connection
  Future<void> close() async {
    final db = await instance.database;
    await db.close();
  }

  /// Clear all data (for testing purposes)
  Future<void> clearAllData() async {
    final db = await instance.database;
    await db.delete('transaction_items');
    await db.delete('transactions');
    await db.delete('sessions');
    await db.delete('products');
    await db.delete('users');
  }

  /// Reset database (drop and recreate)
  Future<void> resetDatabase() async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, 'pos_offline.db');

    await deleteDatabase(path);
    _database = null;
    await database; // Reinitialize
  }
}
