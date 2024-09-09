import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart' as sq;
import 'package:sqflite/sql.dart';

class DatabaseHelper {
  /// Private database variable to perform the database actions
  static sq.Database? _database;

  /// Function used to initialise the database
  Future<sq.Database> _initDatabase() async {
    String databasePath = await sq.getDatabasesPath();
    String path = join(databasePath, 'todo_database.db');
    return sq.openDatabase(
      path,
      onCreate: _onCreate,
      version: 1,
    );
  }

  /// Function is used to create the tables if didn't exists
  Future<void> _onCreate(sq.Database db, int version) async {
    await db.execute(
      'CREATE TABLE todos(id TEXT PRIMARY KEY, title TEXT, isCompleted INTEGER)',
    );
  }

  /// Function used to return the Database
  Future<sq.Database> get getDatabase async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  /// Function used to insert the data into the table
  Future<void> insertData(String table, Map<String, dynamic> values) async {
    final db = await getDatabase;
    db.insert(
      table,
      values,
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  /// Function used to get the data from the table
  Future<List<Map<String, dynamic>>> getData(String table) async {
    final db = await getDatabase;
    return db.query(table);
  }

  /// Function used to update the data into the table
  Future<void> updateData(String table, Map<String, dynamic> values) async {
    final db = await getDatabase;
    String id = values['id'];
    await db.update(
      table,
      values,
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  /// Function used to delete the data from the table
  Future<void> deleteData(String table, String id) async {
    final db = await getDatabase;
    await db.delete(
      table,
      where: 'id = ?',
      whereArgs: [id],
    );
  }
}

final databaseHelperProvider = Provider<DatabaseHelper>((ref) {
  return DatabaseHelper();
});
