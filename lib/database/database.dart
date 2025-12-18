import 'dart:async';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

import '../models/task.dart';
import '../models/user.dart';

class AppDatabase {
  static final AppDatabase instance = AppDatabase._instance();
  static Database? _database;

  AppDatabase._instance();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB("database.db");
    return _database!;
  }

  Future<Database> _initDB(String filePath) async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, filePath);

    print("DB PATH => $path");  // Debug log

    return await openDatabase(
      path,
      version: 1,
      onCreate: _createDB,
    );
  }

  Future _createDB(Database db, int version) async {
  await db.execute('''
    CREATE TABLE user (
      id INTEGER PRIMARY KEY AUTOINCREMENT,
      username TEXT NOT NULL UNIQUE,
      password TEXT NOT NULL, 
      email TEXT NOT NULL, 
      number TEXT NOT NULL 
    )
  ''');

  await db.execute('''
    CREATE TABLE tasks (
      id INTEGER PRIMARY KEY AUTOINCREMENT,
      user_id INTEGER NOT NULL,
      title TEXT NOT NULL, 
      context TEXT NOT NULL,
      deadline TEXT,         
      isDone INTEGER NOT NULL 
    )
  ''');
  }

  Future<bool> createNewUser(User user) async {
    final db = await database ; 
    final isValid = await db.insert(
      'user', 
      user.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,  
    ); 
    
    return isValid > 0 ; 
  }

  Future<bool> isUserValid(String username, String password) async {
    final db = await database;

    final List<Map<String, dynamic>> result = await db.query(
      'user',
      where: 'username = ? AND password = ?',
      whereArgs: [username, password],
    );

    return result.isNotEmpty;
  }

  Future<User?> retrieveUser(String username) async {
    final db = await database ; 

    final result = await db.query(
      'user',
      where: 'username = ?',
      whereArgs: [username], 
    );

    if(result.isNotEmpty) {
      return User.fromMap(result.first) ;
    }

    return null ;
  }

  Future<int> deleteUser(int userId) async {
    final db = await database ; 

    int rows = await db.delete(
      'user',
      where: 'id = ?',
      whereArgs: [userId] 
    );

    return rows ; 
  }

  Future<bool> resetPassword(String username, String newPassword, String email, String number) async {
    final db = await database ; 

    final List<Map<String, dynamic>> result = await db.query(
      'user',
      where: 'username = ? AND email = ? AND number = ?',
      whereArgs: [username, email, number],
    );
    
    if(result.isEmpty) {
      return false ; 
    }
    
    int updated = await db.update(
      'user', 
      {'password': newPassword},
      where: 'username = ?',
      whereArgs: [username],
    ) ;

    return updated > 0 ; 
  }

  Future<List<User>> getAllUsers() async {
    final db = await database;

    final List<Map<String, dynamic>> users = await db.query('user');

    return users.map((u) => User.fromMap(u)).toList();
  }

  Future<int> createTask(Task task) async {
    final db = await database;

    // only validate if a non-empty deadline was provided
    if (task.deadline != null && task.deadline!.isNotEmpty && !isValidDate(task.deadline!)) {
      throw Exception('Deadline format is invalid');
    }

    final id = await db.insert(
      'tasks',
      task.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
    return id;
  }

  Future<bool> updateTask(Task task, int status) async {
    final db = await database ; 

    if(status < 0 || status > 1) {
      throw Exception('Status message is invalid') ;
    }

    int rows = await db.update(
      'tasks', 
      {'isDone': status},
      where: 'id = ?',
      whereArgs: [task.id],
    );

    return rows > 0 ;
  }

  Future<List<Task>> getTasksByUser(int userId) async {
    final db = await database ; 

    final List<Map<String, dynamic>> userTasks = await db.query(
      'tasks',
      where: 'user_id = ?',
      whereArgs: [userId],
    );

    return userTasks.map((map) {
      return Task.fromMap(map) ;
    }).toList() ;
  }

  Future<int> editTask(Task task, int taskId) async{
    final db = await database ; 

    if (task.deadline != null && task.deadline!.isNotEmpty && !isValidDate(task.deadline!)) {
      throw Exception('Deadline format is invalid') ;
    }

    int rows = await db.update(
      'tasks', 
      {
        'user_id': task.user_id,
        'title': task.title,
        'context': task.context,
        'deadline': task.deadline, // can be null
      },
      where: 'id = ?',
      whereArgs: [taskId],
    ) ;

    return rows ; 
  }

  Future<List<Task>> getAllTasks() async {
    final db = await database;

    final List<Map<String, dynamic>> taskMaps = await db.query('tasks');

    return taskMaps.map((map) {
      return Task.fromMap(map);
    }).toList();
  }

  Future<int> deleteTask(int taskId) async{
    final db = await database ; 

    int rows = await db.delete(
      'tasks',
      where: 'id = ?',
      whereArgs: [taskId] 
    ); 

    return rows ; 
  }

  bool isValidDate(String date) {
    final regex = RegExp(r'^\d{4}-\d{2}-\d{2}$');
    if (!regex.hasMatch(date)) return false;

    try {
      final parsed = DateTime.parse(date);
      return true;
    } catch (e) {
      return false;
    }
  }
}
