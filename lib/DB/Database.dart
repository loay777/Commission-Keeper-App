import 'dart:io';
import 'package:calculate_commission/DB/ComissionModel.dart';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path_provider/path_provider.dart';

class DBProvider {
  DBProvider._();
  static final DBProvider db = DBProvider._();

  static Database _database;

  Future<Database> get database async {
    if (_database != null)
      return _database;

    // if _database is null we instantiate it
    _database = await initDB();
    return _database;
  }

  initDB() async {
    Directory documentsDirectory = await getApplicationDocumentsDirectory();
    String path = join(documentsDirectory.path, "CommissionsDB.db");
    return await openDatabase(path, version: 1, onOpen: (db) {
    }, onCreate: (Database db, int version) async {
      await db.execute("CREATE TABLE Commission ("
          "id INTEGER PRIMARY KEY,"
          "commission_title TEXT,"
          "commission_value TEXT,"
          "date TEXT"
          ")");
    });
  }
  newCommission(Commission newCommission) async {
    final db = await database;
    //get the biggest id in the table
    var table = await db.rawQuery("SELECT MAX(id)+1 as id FROM Commission");
    int id = table.first["id"];
    //insert to the table using the new id
    var raw = await db.rawInsert(
        "INSERT Into Commission (id,commission_title,commission_value,date)"
            " VALUES (?,?,?,?)",
        [id, newCommission.commissionTitle, newCommission.commissionValue, newCommission.date]);
    return raw;
  }
  getCommission(int id) async {
    final db = await database;
    var res =await  db.query("Commission", where: "id = ?", whereArgs: [id]);
    return res.isNotEmpty ? Commission.fromMap(res.first) : Null ;
  }
  updateCommission(Commission newCommission) async {
    final db = await database;
    var res = await db.update("Commission", newCommission.toMap(),
        where: "id = ?", whereArgs: [newCommission.id]);
    return res;
  }
  Future<List<Commission>> getAllCommissions() async {
    final db = await database;
    var res = await db.query("Commission");
    List<Commission> list =
    res.isNotEmpty ? res.map((c) => Commission.fromMap(c)).toList() : [];
    return list;
  }
  deleteCommission(int id) async {
    final db = await database;
    return db.delete("Commission", where: "id = ?", whereArgs: [id]);
  }

}