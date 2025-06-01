import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';

import '../models/book_model.dart';
import '../services/api_service.dart';
import '../widgets/book_card.dart';
import 'book_detail_screen.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  late Future<List<Book>> _booksFuture;
  List<Book> _allBooks = [];
  List<Book> _filteredBooks = [];

  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _booksFuture = _loadBooks();

    _searchController.addListener(_filterBooks);
  }

  Future<List<Book>> _loadBooks() async {
    var box = Hive.box<Book>('books');
    List<Book> books;
    if (box.isNotEmpty) {
      books = box.values.toList();
    } else {
      books = await ApiService.fetchBooks();
      await box.clear();
      await box.addAll(books);
    }
    _allBooks = books;
    _filteredBooks = books;
    return books;
  }

  void _filterBooks() {
    final query = _searchController.text.toLowerCase();

    setState(() {
      _filteredBooks = _allBooks.where((book) {
        final titleLower = book.title.toLowerCase();
        final authorsLower = book.authors.join(', ').toLowerCase();
        return titleLower.contains(query) || authorsLower.contains(query);
      }).toList();
    });
  }

  @override
  void dispose() {
    _searchController.removeListener(_filterBooks);
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('E-Book Dashboard'),
      ),
      body: FutureBuilder<List<Book>>(
        future: _booksFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text('No books found'));
          } else {
            return Column(
              children: [
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: TextField(
                    controller: _searchController,
                    decoration: const InputDecoration(
                      labelText: 'Search books',
                      prefixIcon: Icon(Icons.search),
                      border: OutlineInputBorder(),
                    ),
                  ),
                ),
                Expanded(
                  child: _filteredBooks.isNotEmpty
                      ? ListView.builder(
                          itemCount: _filteredBooks.length,
                          itemBuilder: (context, index) {
                            final book = _filteredBooks[index];
                            return BookCard(
                              book: book,
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (_) => BookDetailScreen(book: book),
                                  ),
                                );
                              },
                            );
                          },
                        )
                      : const Center(child: Text('No matching books found')),
                ),
              ],
            );
          }
        },
      ),
    );
  }
}
