import 'db_helper.dart';

class DBMigrationHelper {
  static Future<void> addSoldQuantityColumn() async {
    try {
      final db = await DBHelper.instance.database;

      final tableInfo = await db.rawQuery('PRAGMA table_info(products)');
      final hasColumn = tableInfo.any((col) => col['name'] == 'soldQuantity');

      if (!hasColumn) {
        await db.execute('''
          ALTER TABLE products 
          ADD COLUMN soldQuantity INTEGER NOT NULL DEFAULT 0
        ''');

        print('✅ Column soldQuantity added successfully');
      } else {
        print('ℹ️ Column soldQuantity already exists');
      }
    } catch (e) {
      print('❌ Error adding soldQuantity column: $e');
    }
  }
}
