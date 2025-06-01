import 'package:hive/hive.dart';

part 'book_model.g.dart'; // untuk generate adapter Hive

@HiveType(typeId: 0)
class Book extends HiveObject {
  @HiveField(0)
  final int id;

  @HiveField(1)
  final String title;

  @HiveField(2)
  final List<String> authors;

  @HiveField(3)
  final Map<String, String> downloadLinks; // semua link download format

  @HiveField(4)
  final String? description;

  Book({
    required this.id,
    required this.title,
    required this.authors,
    required this.downloadLinks,
    this.description,
  });

  factory Book.fromJson(Map<String, dynamic> json) {
    List<dynamic> authorsJson = json['authors'] ?? [];
    List<String> authorsList = authorsJson.map<String>((author) {
      return author['name'] ?? 'Unknown Author';
    }).toList();

    Map<String, dynamic>? formats = json['formats'];
    Map<String, String> links = {};
    if (formats != null) {
      formats.forEach((key, value) {
        if (value is String) {
          links[key] = value;
        }
      });
    }

    return Book(
      id: json['id'],
      title: json['title'] ?? 'No Title',
      authors: authorsList,
      downloadLinks: links,
      description: json['subjects'] != null
          ? (json['subjects'] as List<dynamic>).join(", ")
          : null,
    );
  }
}
