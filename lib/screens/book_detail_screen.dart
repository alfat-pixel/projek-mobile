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
      appBar: AppBar(title: Text(book.title)),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: SingleChildScrollView(
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(book.title, style: Theme.of(context).textTheme.headlineMedium),
            const SizedBox(height: 8),
            Text('Author(s): $authors', style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 8),

            // Harga dan konversi
            Row(
              children: [
                ValueListenableBuilder<double>(
                  valueListenable: convertedPrice,
                  builder: (context, value, _) {
                    return Text(
                      '${value.toStringAsFixed(2)} ${selectedCurrency.value}',
                      style: Theme.of(context).textTheme.titleMedium,
                    );
                  },
                ),
                const SizedBox(width: 16),
                DropdownButton<String>(
                  value: selectedCurrency.value,
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

            const SizedBox(height: 16),
            Text('Description:', style: Theme.of(context).textTheme.titleMedium),
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
