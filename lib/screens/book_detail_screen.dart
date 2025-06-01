import 'package:flutter/material.dart';
import '../models/book_model.dart';
import 'package:url_launcher/url_launcher.dart';
import '../main.dart';
import '../services/price_service.dart'; // import price service

class BookDetailScreen extends StatelessWidget {
  final Book book;

  const BookDetailScreen({super.key, required this.book});

  @override
  Widget build(BuildContext context) {
    String authors = book.authors.isNotEmpty ? book.authors.join(', ') : 'Unknown Author';
    String description = book.description ?? 'No description available';
    Map<String, String> downloadLinks = book.downloadLinks;

    double priceUSD = PriceService.getPriceUSD(book.id);
    ValueNotifier<String> selectedCurrency = ValueNotifier('USD');
    ValueNotifier<double> convertedPrice = ValueNotifier(priceUSD);

    void convert(String currency) {
      selectedCurrency.value = currency;
      convertedPrice.value = PriceService.convertCurrency(priceUSD, currency);
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(
          book.title,
          overflow: TextOverflow.ellipsis,
        ),
        backgroundColor: Colors.deepPurple,
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        child: SingleChildScrollView(
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(
              book.title,
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: Colors.deepPurple.shade700,
                  ),
            ),
            const SizedBox(height: 12),
            Text(
              'Author(s): $authors',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    color: Colors.grey.shade800,
                    fontStyle: FontStyle.italic,
                  ),
            ),
            const SizedBox(height: 20),

            // Harga dan konversi
            Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                ValueListenableBuilder<double>(
                  valueListenable: convertedPrice,
                  builder: (context, value, _) {
                    return Text(
                      '${value.toStringAsFixed(2)} ${selectedCurrency.value}',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.w600,
                            color: Colors.green.shade700,
                          ),
                    );
                  },
                ),
                const SizedBox(width: 16),
                DropdownButton<String>(
                  value: selectedCurrency.value,
                  elevation: 4,
                  style: TextStyle(color: Colors.deepPurple.shade700, fontWeight: FontWeight.w600),
                  underline: Container(
                    height: 2,
                    color: Colors.deepPurple.shade200,
                  ),
                  items: PriceService.exchangeRates.keys
                      .map((currency) => DropdownMenuItem(
                            value: currency,
                            child: Text(currency),
                          ))
                      .toList(),
                  onChanged: (val) {
                    if (val != null) convert(val);
                  },
                ),
              ],
            ),

            const SizedBox(height: 24),
            Text(
              'Description:',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(
              description,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(height: 1.5),
            ),
            const SizedBox(height: 32),

            if (downloadLinks.isNotEmpty)
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: downloadLinks.entries.map((entry) {
                  final format = entry.key;
                  final url = entry.value;
                  return ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.deepPurple.shade50,
                      foregroundColor: Colors.deepPurple.shade700,
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                      elevation: 0,
                    ),
                    onPressed: () => _launchURL(url),
                    child: Text(format, style: const TextStyle(fontSize: 14)),
                  );
                }).toList(),
              )
            else
              Text(
                'No download links available',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: Colors.redAccent),
              ),
          ]),
        ),
      ),
    );
  }

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
}
