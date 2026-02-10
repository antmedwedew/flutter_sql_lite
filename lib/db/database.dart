import 'dart:io';
import 'package:flutter_sql_lite/db/table/base.dart';
import 'package:flutter_sql_lite/db/tables.dart';
import 'package:path_provider/path_provider.dart';
import 'package:sqflite/sqflite.dart';

class DBProvider {
  DBProvider._();

  static final DBProvider db = DBProvider._();
  static Database? _database;

  Future<Database> get database async {
    if (_database != null) return _database!;

    _database = await _initDB();
    return _database!;
  }

  Future<Database> _initDB() async {
    Directory dir = await getApplicationDocumentsDirectory();
    String path = '${dir.path}University.db';
    return await openDatabase(path, version: 1, onCreate: _createDB);
  }

  void _createDB(Database db, int version) async {
    for (var table in tables) {
      await db.execute(table.createTableQuery);
    }
  }

  // read
  Future<List<T>> getFromTable<T>(BaseTable<T> table) async {
    final Database db = await database;
    final List<Map<String, dynamic>> maps = await db.query(table.tableName);
    return maps.map((map) => table.fromMap(map)).toList();
  }

  // insert одной или нескольких записей
  Future<dynamic> insertInTable<T>(BaseTable<T> table, T items) async {
    final Database db = await database;

    if (items is List) {
      final batch = db.batch();

      for (var item in items) {
        batch.insert(table.tableName, table.toMap(item));
      }

      await batch.commit(noResult: true);
    } else {
      return await db.insert(table.tableName, table.toMap(items));
    }
  }

  // update
  Future<int> updateTable<T>(BaseTable<T> table, T item) async {
    final Database db = await database;
    final Map<String, dynamic> data = table.toMap(item);

    return await db.update(
      table.tableName,
      data,
      where: 'id = ?',
      whereArgs: [data['id']],
    );
  }

  // delete
  Future<int> deleteItem<T>(BaseTable<T> table, int id) async {
    final Database db = await database;
    return await db.delete(table.tableName, where: 'id = ?', whereArgs: [id]);
  }
}

// Для более чистой архитектуры можно использовать паттерн репозиторий:
/*
class StudentRepository {
  final Database db;
  
  StudentRepository(this.db);
  
  Future<List<Student>> getAll() async {
    final maps = await db.query('Students');
    return maps.map((map) => Student.fromMap(map)).toList();
  }
  
  // Другие методы работы со студентами
}

// Использование:
final db = await DBProvider.db.database;
final studentRepo = StudentRepository(db);
final students = await studentRepo.getAll();
*/
