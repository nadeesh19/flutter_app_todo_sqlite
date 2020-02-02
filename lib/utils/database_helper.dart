import 'package:flutter_app/models/note.dart';
import 'package:sqflite/sqflite.dart';
import 'dart:async';
import 'dart:io';
import 'package:path_provider/path_provider.dart';

class DatabaseHelper {
  static DatabaseHelper _databaseHelper; // Singleton DatabaseHelper
  static Database _database; // Singleton Database

  // DB Table & column Names
  String noteTable = 'note_table';
  String colId = 'id';
  String colTitle = 'title';
  String colDescription = 'description';
  String colDate = 'date';
  String colPriority = 'priority';

  DatabaseHelper._createInstance(); // Named Constructor to create instance of DatabaseHelper

  factory DatabaseHelper() {
    if (_databaseHelper == null) {
      _databaseHelper = DatabaseHelper
          ._createInstance(); // This is executed only once, singleton object
    }

    return _databaseHelper;
  }

  Future<Database> get database async {
    if (_database == null) {
      _database = await initializeDatabase();
    }

    return _database;
  }

  Future<Database> initializeDatabase() async {
    // Get the directory path for both Android and IOS to store Database
    Directory directory = await getApplicationDocumentsDirectory();
    String path = directory.path + 'notes.db';

    // Open/Create the database at a given path
    var notesDatabase =
        await openDatabase(path, version: 1, onCreate: _createDb);

    return notesDatabase;
  }

  void _createDb(Database db, int newVersion) async {
    String createDbSqlQuery =
        'CREATE TABLE $noteTable($colId INTEGER PRIMARY KEY AUTOINCREMENT, $colTitle TEXT,'
        '$colDescription TEXT, $colPriority INTEGER, $colDate TEXT )';

    await db.execute(createDbSqlQuery);
  }

// CRUD Operations

// Fetch Operations: Get all Note objects from Database
  Future<List<Map<String, dynamic>>> getNoteMapList() async {
    Database db = await this.database;
//    var result = await db.rawQuery('SELECT * FROM $noteTable ORDER BY $colPriority ASC');
    // or
    var result = await db.query(noteTable, orderBy: '$colPriority ASC');

    return result;
  }

// Insert Operations: Insert a Note object to Database
  Future<int> insertNote(Note note) async{

    Database db = await this.database;
    var result = await db.insert(noteTable, note.toMap());
    return result;

  }


// Update Operations: Update a Note object and Save it to Database
  Future<int> updateNote(Note note) async{

    var db = await this.database;
    var result = await db.update(noteTable, note.toMap(), where: '$colId = ?', whereArgs: [note.id]);
    return result;

  }
// Delete Operations: Delete a Note object from Database
  Future<int> deleteNote(int id) async{

    var db = await this.database;
    var result = await db.rawDelete('DELETE FROM $noteTable WHERE $colId = $id');
    return result;

  }
// Get number of Note Objects in Database
  Future<int> getCount() async{

    Database db = await this.database;
    List<Map<String, dynamic>> countValue = await db.rawQuery('SELECT COUNT (*) FROM $noteTable');
    int result = Sqflite.firstIntValue(countValue);
    return result;

  }

  // get the "Map list" [ List<Map> ] and convert in to 'Note List' [ List<Note> ]
  Future<List<Note>> getNoteList() async{

    var noteMapList = await getNoteMapList(); // Get 'Map List' from Database
    int count = noteMapList.length; // Count the number of map entries in db table

    List<Note> noteList = List<Note>();
    // for Loop to create a 'Note List' from a 'Map List'
    for(int i = 0; i < count; i++){
      noteList.add(Note.fromMapObject(noteMapList[i]));
    }
    return noteList;

  }

}




























