import 'package:flutter/material.dart';

import '../models/makeup_product.dart';
import '../widgets/makeup_card.dart';

class CollectionScreen extends StatefulWidget {
  final List<MakeupProduct> products;
  final VoidCallback onAdd;
  final ValueChanged<MakeupProduct> onEdit;
  final ValueChanged<MakeupProduct> onDelete;
  final ValueChanged<MakeupProduct> onFavorite;

  const CollectionScreen({
    super.key,
    required this.products,
    required this.onAdd,
    required this.onEdit,
    required this.onDelete,
    required this.onFavorite,
  });

  @override
  State<CollectionScreen> createState() => _CollectionScreenState();
}

class _CollectionScreenState extends State<CollectionScreen> {
  String searchText = '';
  String selectedCategory = 'All';
  bool favoritesOnly = false;

  @override
  Widget build(BuildContext context) {
    final categories = <String>{
      'All',
      ...widget.products.map((product) => product.category),
    }.toList()..sort();

    if (!categories.contains(selectedCategory)) {
      selectedCategory = 'All';
    }

    final query = searchText.toLowerCase();
    final filteredProducts = widget.products.where((product) {
      final matchesSearch =
          product.name.toLowerCase().contains(query) ||
          product.brand.toLowerCase().contains(query) ||
          product.category.toLowerCase().contains(query);
      final matchesCategory =
          selectedCategory == 'All' || product.category == selectedCategory;
      final matchesFavorite = !favoritesOnly || product.isFavorite;

      return matchesSearch && matchesCategory && matchesFavorite;
    }).toList();

    return Scaffold(
      backgroundColor: const Color(0xFFFFF7FA),
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 20, 20, 10),
              child: Row(
                children: [
                  const Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'My Collection',
                          style: TextStyle(
                            fontSize: 25,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        SizedBox(height: 4),
                        Text(
                          'Manage your personal makeup products',
                          style: TextStyle(color: Colors.black54),
                        ),
                      ],
                    ),
                  ),
                  IconButton.filled(
                    onPressed: widget.onAdd,
                    icon: const Icon(Icons.add),
                    tooltip: 'Add product',
                    style: IconButton.styleFrom(
                      backgroundColor: Colors.pink,
                      foregroundColor: Colors.white,
                    ),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: TextField(
                decoration: InputDecoration(
                  hintText: 'Search products, brands, or categories',
                  prefixIcon: const Icon(Icons.search),
                  filled: true,
                  fillColor: Colors.white,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(14),
                    borderSide: BorderSide.none,
                  ),
                ),
                onChanged: (value) => setState(() => searchText = value),
              ),
            ),
            const SizedBox(height: 10),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Row(
                children: [
                  Expanded(
                    child: DropdownButtonFormField<String>(
                      initialValue: selectedCategory,
                      isExpanded: true,
                      decoration: InputDecoration(
                        labelText: 'Category',
                        filled: true,
                        fillColor: Colors.white,
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 10,
                        ),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide.none,
                        ),
                      ),
                      items: categories.map((category) {
                        return DropdownMenuItem(
                          value: category,
                          child: Text(
                            category,
                            overflow: TextOverflow.ellipsis,
                          ),
                        );
                      }).toList(),
                      onChanged: (value) {
                        if (value != null) {
                          setState(() => selectedCategory = value);
                        }
                      },
                    ),
                  ),
                  const SizedBox(width: 10),
                  FilterChip(
                    label: const Text('Favorites'),
                    selected: favoritesOnly,
                    selectedColor: Colors.pink.shade100,
                    onSelected: (value) =>
                        setState(() => favoritesOnly = value),
                    avatar: const Icon(Icons.favorite, size: 18),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),
            Expanded(
              child: filteredProducts.isEmpty
                  ? Center(
                      child: Padding(
                        padding: const EdgeInsets.all(24),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              Icons.inventory_2_outlined,
                              size: 60,
                              color: Colors.pink.shade200,
                            ),
                            const SizedBox(height: 12),
                            const Text(
                              'No products found',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 6),
                            const Text(
                              'Try another search or add a new product.',
                              textAlign: TextAlign.center,
                              style: TextStyle(color: Colors.black54),
                            ),
                            const SizedBox(height: 14),
                            ElevatedButton.icon(
                              onPressed: widget.onAdd,
                              icon: const Icon(Icons.add),
                              label: const Text('Add Product'),
                            ),
                          ],
                        ),
                      ),
                    )
                  : ListView.builder(
                      padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
                      itemCount: filteredProducts.length,
                      itemBuilder: (context, index) {
                        final product = filteredProducts[index];
                        return MakeupCard(
                          key: ValueKey(product.id),
                          product: product,
                          onFavorite: () => widget.onFavorite(product),
                          onEdit: () => widget.onEdit(product),
                          onDelete: () => widget.onDelete(product),
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }
}
