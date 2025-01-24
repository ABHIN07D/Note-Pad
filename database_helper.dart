import 'package:sqflite/sqflite.dart' as sql;

class QueryHelper {
  static Future<void> createTable(sql.Database database) async {
    await database.execute(
      '''
      CREATE TABLE note (
        id INTEGER PRIMARY KEY AUTOINCREMENT NOT NULL,
        title TEXT,
        description TEXT,
        time TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP
      )
      '''
    );
  }

  static Future<sql.Database> db() async {
    return sql.openDatabase(
      "note_database.db",
      version: 1,
      onCreate: (sql.Database database, int version) async {
        await createTable(database);
      },
    );
  }

  static Future<int> createNote(String title, String? description) async {
    final db = await QueryHelper.db();
    final dataNote = {"title": title, "description": description};
    final id = await db.insert('note', dataNote, conflictAlgorithm: sql.ConflictAlgorithm.replace);
    return id;
  }

  static Future<List<Map<String, dynamic>>> getAllNotes() async {
    final db = await QueryHelper.db();
    return db.query("note", orderBy: "id");
  }

  static Future<List<Map<String, dynamic>>> getNoteById(int id) async {
    final db = await QueryHelper.db();
    return db.query("note", where: "id=?", whereArgs: [id], limit: 1);
  }

  static Future<int> updateNote(int id, String title, String description) async {
    final db = await QueryHelper.db();
    final dataNote = {
      "title": title,
      "description": description,
      "time": DateTime.now().toString(),
    };
    return await db.update('note', dataNote, where: "id=?", whereArgs: [id]);
  }

  static Future<int> deleteNote(int id) async {
    final db = await QueryHelper.db();
    return await db.delete('note', where: "id=?", whereArgs: [id]);
  }

  static Future<int> deleteAll() async {
    final db = await QueryHelper.db();
    return await db.delete('note');
  }

  static Future<int> getNoteCount() async {
    final db = await QueryHelper.db();
    final count = sql.Sqflite.firstIntValue(await db.rawQuery('SELECT COUNT(*) FROM note'));
    return count ?? 0;
  }
}
