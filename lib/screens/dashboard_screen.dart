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
      backgroundColor: Colors.grey.shade50,
      appBar: AppBar(
        title: const Text('E-Book Dashboard'),
        backgroundColor: Colors.deepPurple,
        elevation: 6,
        centerTitle: true,
      ),
      body: FutureBuilder<List<Book>>(
        future: _booksFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
                child: CircularProgressIndicator(color: Colors.deepPurple));
          } else if (snapshot.hasError) {
            return Center(
                child: Text(
              'Error: ${snapshot.error}',
              style: const TextStyle(color: Colors.red),
            ));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(
                child: Text('No books found',
                    style: TextStyle(fontSize: 18, color: Colors.grey)));
          } else {
            return Column(
              children: [
                Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                  child: TextField(
                    controller: _searchController,
                    decoration: InputDecoration(
                      hintText: 'Search books...',
                      prefixIcon: const Icon(Icons.search),
                      filled: true,
                      fillColor: Colors.white,
                      contentPadding: const EdgeInsets.symmetric(vertical: 12),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(30),
                        borderSide: BorderSide.none,
                      ),
                    ),
                  ),
                ),
                Expanded(
                  child: _filteredBooks.isNotEmpty
                      ? ListView.separated(
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          itemCount: _filteredBooks.length,
                          separatorBuilder: (context, index) =>
                              const SizedBox(height: 10),
                          itemBuilder: (context, index) {
                            final book = _filteredBooks[index];
                            return Material(
                              color: Colors.white,
                              elevation: 2,
                              borderRadius: BorderRadius.circular(12),
                              child: InkWell(
                                borderRadius: BorderRadius.circular(12),
                                onTap: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (_) =>
                                          BookDetailScreen(book: book),
                                    ),
                                  );
                                },
                                child: Padding(
                                  padding: const EdgeInsets.all(16.0),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        book.title,
                                        style: const TextStyle(
                                            fontSize: 18,
                                            fontWeight: FontWeight.bold),
                                      ),
                                      const SizedBox(height: 6),
                                      Text(
                                        book.authors.join(', '),
                                        style: TextStyle(
                                          fontSize: 14,
                                          color: Colors.grey.shade700,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            );
                          },
                        )
                      : const Center(
                          child: Text(
                          'No matching books found',
                          style: TextStyle(fontSize: 16, color: Colors.grey),
                        )),
                ),
              ],
            );
          }
        },
      ),
    );
  }
}
