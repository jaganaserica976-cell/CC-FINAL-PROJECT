import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../models/makeup_product.dart';

class StorageService {
  static const String _storageKey = 'makeup_collection';
  static const String _selectedPageKey = 'selected_page';
  static const String _productDraftKey = 'makeup_product_draft';

  Future<Map<String, String>?> loadProductDraft() async {
    final prefs = await SharedPreferences.getInstance();
    final savedDraft = prefs.getString(_productDraftKey);
    if (savedDraft == null) return null;

    final decoded = jsonDecode(savedDraft);
    if (decoded is! Map) {
      throw const FormatException('Saved product draft is not an object.');
    }
    return decoded.map(
      (key, value) => MapEntry(key.toString(), value.toString()),
    );
  }

  Future<void> saveProductDraft(Map<String, String> draft) async {
    final prefs = await SharedPreferences.getInstance();
    final saved = await prefs.setString(_productDraftKey, jsonEncode(draft));
    if (!saved) {
      throw StateError('Could not save the product draft.');
    }
  }

  Future<void> clearProductDraft() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_productDraftKey);
  }

  Future<int> loadSelectedPage() async {
    final prefs = await SharedPreferences.getInstance();
    final selectedPage = prefs.getInt(_selectedPageKey) ?? 0;
    return selectedPage >= 0 && selectedPage <= 2 ? selectedPage : 0;
  }

  Future<void> saveSelectedPage(int index) async {
    if (index < 0 || index > 2) {
      throw ArgumentError.value(index, 'index', 'Must be a valid page index.');
    }

    final prefs = await SharedPreferences.getInstance();
    final saved = await prefs.setInt(_selectedPageKey, index);
    if (!saved) {
      throw StateError('Could not save the selected page.');
    }
  }

  Future<List<MakeupProduct>> loadProducts() async {
    final prefs = await SharedPreferences.getInstance();
    final savedData = prefs.getString(_storageKey);

    if (savedData == null) {
      return _sampleProducts();
    }

    final decodedData = jsonDecode(savedData);
    if (decodedData is! List) {
      throw const FormatException('Saved makeup collection is not a list.');
    }

    final products = decodedData
        .map(
          (item) =>
              MakeupProduct.fromJson(Map<String, dynamic>.from(item as Map)),
        )
        .toList();
    final sampleImages = {
      for (final product in _sampleProducts()) product.id: product.imageUrl,
    };

    return products.map((product) {
      final sampleImage = sampleImages[product.id];
      if (product.imageUrl.isEmpty && sampleImage != null) {
        return product.copyWith(imageUrl: sampleImage);
      }
      return product;
    }).toList();
  }

  Future<void> saveProducts(List<MakeupProduct> products) async {
    final prefs = await SharedPreferences.getInstance();
    final encodedData = jsonEncode(
      products.map((product) => product.toJson()).toList(),
    );

    final saved = await prefs.setString(_storageKey, encodedData);
    if (!saved) {
      throw StateError('Could not save the makeup collection.');
    }
  }

  List<MakeupProduct> _sampleProducts() {
    return const [
      MakeupProduct(
        id: 'sample-1',
        name: 'Essence Mascara Lash Princess',
        brand: 'Essence',
        category: 'Mascara',
        price: 9.99,
        imageUrl: 'https://cdn.dummyjson.com/product-images/beauty/essence-mascara-lash-princess/thumbnail.webp',
      ),
      MakeupProduct(
        id: 'sample-2',
        name: 'Eyeshadow Palette with Mirror',
        brand: 'Glamour Beauty',
        category: 'Eyeshadow',
        price: 19.99,
        imageUrl: 'https://cdn.dummyjson.com/product-images/beauty/eyeshadow-palette-with-mirror/thumbnail.webp',
      ),
      MakeupProduct(
        id: 'sample-3',
        name: 'Powder Canister',
        brand: 'Glamour Beauty',
        category: 'Powder',
        price: 14.99,
        imageUrl: 'https://cdn.dummyjson.com/product-images/beauty/powder-canister/thumbnail.webp',
      ),
    ];
  }
}
