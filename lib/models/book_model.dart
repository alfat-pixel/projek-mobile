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
  final String? downloadUrl;

  @HiveField(4)
  final String? description;

  Book({
    required this.id,
    required this.title,
    required this.authors,
    this.downloadUrl,
    this.description,
  });

  factory Book.fromJson(Map<String, dynamic> json) {
    List<dynamic> authorsJson = json['authors'] ?? [];
    List<String> authorsList = authorsJson.map<String>((author) {
      return author['name'] ?? 'Unknown Author';
    }).toList();

    Map<String, dynamic>? formats = json['formats'];
    String? downloadLink;
    if (formats != null) {
      downloadLink = formats['application/pdf'] ??
          formats['text/plain; charset=utf-8'] ??
          formats['text/plain'];
    }

    return Book(
      id: json['id'],
      title: json['title'] ?? 'No Title',
      authors: authorsList,
      downloadUrl: downloadLink,
      description: json['subjects'] != null
          ? (json['subjects'] as List<dynamic>).join(", ")
          : null,
    );
  }
}
