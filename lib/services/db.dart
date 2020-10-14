import 'dart:async';
import 'package:check_mk/models/model.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart' as p;

abstract class DB {

  static Database _db;

  static int get _version => 1;

  static Future<void> init() async {

    if (_db != null) { return; }

    try {

      var databasesPath = await getDatabasesPath();
      String _path = p.join(databasesPath, 'caeck_mk.db');

      _db = await openDatabase(_path, version: _version, onCreate: onCreate);
    }
    catch(ex) {
      print(ex);
    }
  }

  static void onCreate(Database db, int version) async {
    await db.execute(''
        'CREATE TABLE todo_service ('
        'id INTEGER PRIMARY KEY NOT NULL, '
        'uid TEXT,'
        'updatedate INTEGER,'
        'service_state TEXT,'
        'host TEXT,'
        'service_description TEXT,'
        'service_icons TEXT,'
        'svc_plugin_output TEXT,'
        'svc_state_age TEXT,'
        'svc_check_age TEXT,'
        'perfometer TEXT,'
        'sort INTEGER,'
        'sorce INTEGER'
        ')');
    await db.execute(''
        'CREATE TABLE todo_allhost ('
        'id INTEGER PRIMARY KEY NOT NULL, '
        'uid TEXT,'
        'updatedate INTEGER,'
        'host_state TEXT,'
        'host TEXT,'
        'host_icons TEXT,'
        'num_services_ok TEXT,'
        'num_services_warn TEXT,'
        'num_services_unknown TEXT,'
        'num_services_crit TEXT,'
        'num_services_pending TEXT,'
        'sort INTEGER,'
        'sorce INTEGER'
        ')');


    await db.execute(''
        'CREATE TABLE todo_lasevent ('
        'id INTEGER PRIMARY KEY NOT NULL, '
        'uid TEXT,'
        'updatedate INTEGER,'
        'log_icon TEXT,'
        'log_time TEXT,'
        'host TEXT,'
        'service_description TEXT,'
        'log_plugin_output TEXT,'
        'state TEXT,'
        'sort INTEGER,'
        'sorce INTEGER'
        ')');


    await db.execute(''
        'CREATE TABLE setup_app ('
        'ids INTEGER PRIMARY KEY NOT NULL, '
        'url TEXT,'
        'user TEXT,'
        'key TEXT,'
        'user2 TEXT,'
        'key2 TEXT'
        ')');
  }




  static Future<List<Map<String, dynamic>>> queryhost(String table, String host) async => _db.query(table,orderBy: "sort", where: 'id = ? OR host = ?', whereArgs: [1,host]); //select all for host




  static Future<List<Map<String, dynamic>>> query(String table) async => _db.query(table, where: 'sorce = ?', whereArgs: [1], orderBy: "sort"); //select all

  static Future<List<Map<String, dynamic>>> check(String table, String uid) async => _db.query(table, where: 'uid = ?', whereArgs: [uid]);  //get by uid
  static Future<List<Map<String, dynamic>>> check2(String table) async => _db.query(table, where: 'ids = ?', whereArgs: [1]);  //get by ids


  static Future<int> insert(String table, Model model) async =>
      await _db.insert(table, model.toMap());

  static Future<int> update(String table, Model model, String uid) async =>
      await _db.update(table, model.toMap(), where: 'uid = ?', whereArgs: [uid]);

  static Future<int> update2(String table, Model model) async =>
      await _db.update(table, model.toMap(), where: 'ids = ?', whereArgs: [1]);

  static Future<int> delete(String table, int TimeNowMius1Min) async =>

      await _db.delete(table, where: 'id != ? AND updatedate < ?' , whereArgs: [1,TimeNowMius1Min]);



static Future<int> deleteall(String table, int TimeNowMius1Min) async =>

await _db.delete(table, where: 'updatedate < ?' , whereArgs: [TimeNowMius1Min]);

}