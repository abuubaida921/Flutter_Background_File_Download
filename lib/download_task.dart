// Model Class for Download Task
class DownloadTask {
  final String id;
  final String title;
  final String url;
  String filePath; // Make filePath non-final to update it dynamically
  final String author;
  final String publisher;
  final String category;
  final String avatars;
  double progress;
  bool isDownloading;
  bool isPaused;

  DownloadTask({
    required this.id,
    required this.title,
    required this.url,
    required this.filePath,
    required this.author,
    required this.publisher,
    required this.category,
    required this.avatars,
    this.progress = 0.0,
    this.isDownloading = false,
    this.isPaused = false,
  });

  // Convert a DownloadTask object to a JSON map
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'url': url,
      'filePath': filePath,
      'author': author,
      'publisher': publisher,
      'category': category,
      'avatars': avatars,
      'progress': progress,
      'isDownloading': isDownloading ? 1 : 0, // Store boolean as integer
      'isPaused': isPaused ? 1 : 0,           // Store boolean as integer
    };
  }

  // Create a DownloadTask object from a JSON map
  factory DownloadTask.fromJson(Map<String, dynamic> json) {
    return DownloadTask(
      id: json['id'] as String,
      title: json['title'] as String,
      url: json['url'] as String,
      filePath: json['filePath'] as String,
      author: json['author'] as String,
      publisher: json['publisher'] as String,
      category: json['category'] as String,
      avatars: json['avatars'] as String,
      progress: (json['progress'] as num).toDouble(), // Handle numeric progress
      isDownloading: (json['isDownloading'] as int) == 1, // Convert integer back to boolean
      isPaused: (json['isPaused'] as int) == 1,           // Convert integer back to boolean
    );
  }
}