import 'package:flutter/material.dart';
import '../models/book_model.dart';
import 'package:url_launcher/url_launcher.dart';
import '../main.dart'; // Import navigatorKey dari main.dart

class BookDetailScreen extends StatelessWidget {
  final Book book;

  const BookDetailScreen({super.key, required this.book});

  Future<void> _launchURL(String urlString) async {
    final Uri url = Uri.parse(urlString);

    if (await canLaunchUrl(url)) {
      await launchUrl(url);
    } else {
      ScaffoldMessenger.of(navigatorKey.currentContext!).showSnackBar(
        SnackBar(content: Text('Could not launch $url')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    String authors = book.authors.isNotEmpty ? book.authors.join(', ') : 'Unknown Author';
    String description = book.description ?? 'No description available';
    final Map<String, String> downloadLinks = book.downloadLinks;

    return Scaffold(
      appBar: AppBar(
        title: Text(book.title),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                book.title,
                style: Theme.of(context).textTheme.headlineMedium,
              ),
              const SizedBox(height: 8),
              Text(
                'Author(s): $authors',
                style: Theme.of(context).textTheme.titleMedium,
              ),
              const SizedBox(height: 16),
              Text(
                'Description:',
                style: Theme.of(context).textTheme.titleMedium,
              ),
              const SizedBox(height: 8),
              Text(description),
              const SizedBox(height: 24),
              if (downloadLinks.isNotEmpty)
                ...downloadLinks.entries.map((entry) {
                  final format = entry.key;
                  final url = entry.value;
                  return Padding(
                    padding: const EdgeInsets.symmetric(vertical: 4),
                    child: ElevatedButton(
                      onPressed: () => _launchURL(url),
                      child: Text(format),
                    ),
                  );
                }).toList()
              else
                const Text('No download links available'),
            ],
          ),
        ),
      ),
    );
  }
}
