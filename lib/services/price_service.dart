class PriceService {
  // Contoh data harga buku dalam USD per id buku
  static Map<int, double> _bookPricesUSD = {
    1: 12.5,
    2: 8.75,
    3: 15.0,
    4: 9.99,
    5: 11.0,
    // Tambah sesuai kebutuhan...
  };

  static double getPriceUSD(int bookId) {
    return _bookPricesUSD[bookId] ?? 10.0; // default harga 10 USD jika id tidak ditemukan
  }

  // Kurs konversi statis, contoh sederhana
  static Map<String, double> exchangeRates = {
    'USD': 1.0,
    'IDR': 15000.0,
    'EUR': 0.92,
    'JPY': 135.0,
  };

  static double convertCurrency(double amountUSD, String toCurrency) {
    if (!exchangeRates.containsKey(toCurrency)) {
      return amountUSD; // fallback ke USD
    }
    return amountUSD * exchangeRates[toCurrency]!;
  }
}
