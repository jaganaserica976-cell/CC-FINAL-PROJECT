import 'dart:convert';

import 'package:http/http.dart' as http;

import '../models/makeup_product.dart';

class MakeupApiService {
  static final Uri _apiUri = Uri.https(
    'dummyjson.com',
    '/products/category/beauty',
    {'limit': '30'},
  );

  Future<List<MakeupProduct>> fetchProducts() async {
    final response = await http
        .get(_apiUri)
        .timeout(const Duration(seconds: 20));

    if (response.statusCode != 200) {
      throw Exception(
        'Unable to load makeup products. '
        'Server status: ${response.statusCode}',
      );
    }

    final decoded = jsonDecode(response.body);
    if (decoded is! Map<String, dynamic>) {
      throw const FormatException('Unexpected response from makeup API.');
    }
    final productsJson = decoded['products'];
    if (productsJson is! List) {
      throw const FormatException('Makeup API response has no product list.');
    }

    return productsJson.map((item) {
      final product = Map<String, dynamic>.from(item as Map);
      final title = product['title']?.toString() ?? 'Unknown Product';

      return MakeupProduct(
        id: 'api-${product['id'] ?? title.hashCode}',
        name: title,
        brand: product['brand']?.toString() ?? 'Beauty Brand',
        category: product['category']?.toString() ?? 'Beauty',
        price: (product['price'] as num?)?.toDouble() ?? 0.0,
        imageUrl: product['thumbnail']?.toString() ?? '',
      );
    }).toList();
  }
}
