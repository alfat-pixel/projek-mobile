import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/book_model.dart';

class ApiService {
  static const String baseUrl = 'https://gutendex.com/books/';

  // Fetch list buku dengan optional page parameter
  static Future<List<Book>> fetchBooks({int page = 1}) async {
    try {
      final response = await http.get(Uri.parse('$baseUrl?page=$page'));

      if (response.statusCode == 200) {
        final data = json.decode(response.body);

        List<dynamic> results = data['results'];

        List<Book> books = results.map<Book>((json) => Book.fromJson(json)).toList();

        return books;
      } else {
        throw Exception('Failed to load books from API');
      }
    } catch (e) {
      throw Exception('Error fetching books: $e');
    }
  }
}
