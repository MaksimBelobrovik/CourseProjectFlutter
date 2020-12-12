import 'dart:async';
import 'dart:io';

import 'package:conventer/HistoryModel.dart';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'package:sqflite/sqflite.dart';

class DBProvider {
  DBProvider._();

  static final DBProvider db = DBProvider._();

  Database _database;

  Future<Database> get database async {
    if (_database != null) return _database;
    // if _database is null we instantiate it
    _database = await initDB();
    return _database;
  }

  initDB() async {
    Directory documentsDirectory = await getApplicationDocumentsDirectory();
    String path = join(documentsDirectory.path, "TestDB.db");
    return await openDatabase(path, version: 1, onOpen: (db) {},
        onCreate: (Database db, int version) async {
          await db.execute("CREATE TABLE HistoryModel ("
              "id INTEGER PRIMARY KEY,"
              "first_name TEXT,"
              "first_val TEXT,"
              "last_name TEXT,"
              "second_val TEXT"
              ")");
        });
  }

  newHistoryModel(HistoryModel newHistoryModel) async {
    final db = await database;
    var table = await db.rawQuery("SELECT MAX(id)+1 as id FROM HistoryModel");
    int id = table.first["id"];
    var raw = await db.rawInsert(
        "INSERT Into HistoryModel (id,first_name,first_val,last_name,second_val)"
            " VALUES (?,?,?,?,?)",
        [id, newHistoryModel.firstName,newHistoryModel.firstVal, newHistoryModel.lastName, newHistoryModel.secondVal]);
    return raw;
  }

  updateHistoryModel(HistoryModel newHistoryModel) async {
    final db = await database;
    var res = await db.update("HistoryModel", newHistoryModel.toMap(),
        where: "id = ?", whereArgs: [newHistoryModel.id]);
    return res;
  }

  getHistoryModel(int id) async {
    final db = await database;
    var res = await db.query("HistoryModel", where: "id = ?", whereArgs: [id]);
    return res.isNotEmpty ? HistoryModel.fromMap(res.first) : null;
  }

  Future<List<HistoryModel>> getAllHistoryModels() async {
    final db = await database;
    var res = await db.query("HistoryModel");
    List<HistoryModel> list =
    res.isNotEmpty ? res.map((c) => HistoryModel.fromMap(c)).toList() : [];
    return list;
  }

  deleteHistoryModel(int id) async {
    final db = await database;
    return db.delete("HistoryModel", where: "id = ?", whereArgs: [id]);
  }

  deleteAll() async {
    final db = await database;
    db.rawDelete("Delete * from HistoryModel");
  }
}