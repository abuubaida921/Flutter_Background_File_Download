import 'package:get/get.dart';
import 'package:path_provider/path_provider.dart';
import 'package:dio/dio.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'dart:io';

import 'download_task.dart';

// GetX Controller for Managing Download Tasks
class DownloadController extends GetxController {
  var downloadTasks = <DownloadTask>[].obs;
  late Database _database;

  @override
  void onInit() {
    super.onInit();
    _initDatabase(); // Initialize database when controller is created
  }

  Future<void> _initDatabase() async {
    String path = join(await getDatabasesPath(), 'downloads.db');
    _database = await openDatabase(
      path,
      version: 1,
      onCreate: (db, version) async {
        await db.execute(
          '''
          CREATE TABLE downloads (
            id TEXT PRIMARY KEY,
            title TEXT,
            url TEXT,
            filePath TEXT,
            author TEXT,
            publisher TEXT,
            category TEXT,
            avatars TEXT,
            progress REAL,
            isDownloading INTEGER,
            isPaused INTEGER
          )
          ''',
        );
      },
    );
    _loadTasks();    // Load tasks from the database
  }

  Future<void> _insertTask(DownloadTask task) async {
    await _database.insert(
      'downloads',
      task.toJson(), // Serialize task to JSON
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<void> _updateTask(DownloadTask task) async {
    await _database.update(
      'downloads',
      task.toJson(), // Serialize task to JSON
      where: 'id = ?',
      whereArgs: [task.id],
    );
  }

  Future<void> _deleteTask(String id) async {
    await _database.delete(
      'downloads',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  Future<void> _loadTasks() async {
    final List<Map<String, dynamic>> maps = await _database.query('downloads');
    downloadTasks.value =
        List.generate(maps.length, (i) => DownloadTask.fromJson(maps[i])); // Deserialize JSON to task
  }

  Future<void> downloadPDF(DownloadTask task) async {
    task.isDownloading = true;
    await _insertTask(task);
    try {
      final dio = Dio();

      // Get the application's documents directory
      final documentsDirectory = await getApplicationDocumentsDirectory();

      // Ensure the directory exists
      if (!Directory(documentsDirectory.path).existsSync()) {
        Directory(documentsDirectory.path).createSync(recursive: true);
      }

      // Set the file path with a valid file name
      // final String filePath = join(documentsDirectory.path, '${task.title.replaceAll(RegExp(r'[\\/:*?"<>|]'), '_')}.pdf');
      final String filePath = join(documentsDirectory.path, '${task.id.replaceAll(RegExp(r'[\\/:*?"<>|]'), '_')}.pdf');
      task.filePath = filePath; // Update the filePath

      await _updateTask(task); // Save updated file path to database

      final response = await dio.download(
        task.url,
        task.filePath,
        onReceiveProgress: (received, total) {
          if (total != -1) {
            task.progress = (received / total * 100);
            downloadTasks.refresh();
          }
        },
      );

      if (response.statusCode == 200) {
        task.isDownloading = false;
        task.isPaused = false;
        task.progress = 100.0;
        await _updateTask(task);
        downloadTasks.refresh();
      }
    } catch (e) {
      task.isDownloading = false;
      await _updateTask(task);
      print('Download error: $e');
    }
  }

  Future<void> pauseDownload(DownloadTask task) async {
    task.isDownloading = false;
    task.isPaused = true;
    await _updateTask(task);
    downloadTasks.refresh();
  }

  Future<void> resumeDownload(DownloadTask task) async {
    task.isDownloading = true;
    task.isPaused = false;
    await _updateTask(task);
    downloadTasks.refresh();
    await downloadPDF(task);
  }

  Future<void> deleteDownload(DownloadTask task) async {
    await _deleteTask(task.id);
    downloadTasks.remove(task);
    downloadTasks.refresh();
    final File file = File(task.filePath);
    if (await file.exists()) {
      await file.delete();
    }
  }
}
