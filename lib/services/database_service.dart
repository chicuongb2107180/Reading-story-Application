import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import '../models/novel.dart';

class DatabaseService {
  static final DatabaseService instance = DatabaseService._sharedInstance();
  DatabaseService._sharedInstance();

  Database? _db;

  Future<Database> get database async {
    if (_db != null) {
      return _db!;
    } else {
      _db = await _initDatabase('tate_world.db');
      return _db!;
    }
  }

  Future<Database> _initDatabase(String fileName) async {
    final databasePath = await getDatabasesPath();
    final path = join(databasePath, fileName);

    return await openDatabase(
      path,
      version: 1,
      onCreate: _onCreate,
    );
  }

  Future<void> _onCreate(Database db, int version) async {
    await db.execute('''CREATE TABLE saved_novels (
      id TEXT PRIMARY KEY,
      novel_name TEXT,
      description TEXT,
      is_completed INTEGER,
      author TEXT,
      image_cover TEXT,
      totalChaptersPublished INTEGER
    )''');
  }

  Future<void> saveNovel(Novel novel) async {
    final db = await database;
    await db.insert(
      'saved_novels',
      novel.toJson(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<void> removeSavedNovel(String id) async {
    final db = await database;
    await db.delete('saved_novels', where: 'id = ?', whereArgs: [id]);
  }

  Future<List<Map<String, dynamic>>> getSavedNovels() async {
    final db = await database;
    return await db.query('saved_novels');
  }

  void close() {
    if (_db != null) {
      _db!.close();
      _db = null;
    }
  }
}
