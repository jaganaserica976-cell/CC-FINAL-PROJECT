import 'package:flutter/material.dart';

import '../models/makeup_product.dart';
import '../services/makeup_api_service.dart';

class DiscoverScreen extends StatefulWidget {
  final Set<String> collectionIds;
  final ValueChanged<MakeupProduct> onAdd;

  const DiscoverScreen({
    super.key,
    required this.collectionIds,
    required this.onAdd,
  });

  @override
  State<DiscoverScreen> createState() => _DiscoverScreenState();
}

class _DiscoverScreenState extends State<DiscoverScreen> {
  final MakeupApiService _apiService = MakeupApiService();
  List<MakeupProduct> _products = [];
  Object? _error;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadProducts();
  }

  Future<void> _loadProducts() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final products = await _apiService.fetchProducts();
      if (!mounted) return;
      setState(() {
        _products = products;
        _isLoading = false;
      });
    } catch (error) {
      if (!mounted) return;
      setState(() {
        _error = error;
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFFF7FA),
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 20, 12, 12),
              child: Row(
                children: [
                  const Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Discover',
                          style: TextStyle(
                            fontSize: 25,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        SizedBox(height: 4),
                        Text(
                          'Find your next beauty favorite',
                          style: TextStyle(color: Colors.black54),
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    tooltip: 'Refresh products',
                    onPressed: _isLoading ? null : _loadProducts,
                    icon: const Icon(Icons.refresh),
                  ),
                ],
              ),
            ),
            Expanded(child: _buildBody()),
          ],
        ),
      ),
    );
  }

  Widget _buildBody() {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_error != null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.wifi_off, size: 48, color: Colors.pink),
              const SizedBox(height: 12),
              const Text(
                'Could not load beauty products',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              Text(
                '$_error',
                textAlign: TextAlign.center,
                style: const TextStyle(color: Colors.black54),
              ),
              const SizedBox(height: 16),
              ElevatedButton.icon(
                onPressed: _loadProducts,
                icon: const Icon(Icons.refresh),
                label: const Text('Try Again'),
              ),
            ],
          ),
        ),
      );
    }

    if (_products.isEmpty) {
      return const Center(child: Text('No beauty products are available.'));
    }

    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
      itemCount: _products.length,
      itemBuilder: (context, index) {
        final product = _products[index];
        final isCollected = widget.collectionIds.contains(product.id);

        return Card(
          color: Colors.white,
          elevation: 2,
          margin: const EdgeInsets.only(bottom: 14),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          clipBehavior: Clip.antiAlias,
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Row(
              children: [
                _ProductImage(imageUrl: product.imageUrl),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        product.name,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        product.brand,
                        style: const TextStyle(color: Colors.black54),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        product.category,
                        style: TextStyle(
                          color: Colors.pink.shade700,
                          fontSize: 12,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        '₱${product.price.toStringAsFixed(2)}',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Colors.pink.shade700,
                        ),
                      ),
                      const SizedBox(height: 8),
                      FilledButton.tonalIcon(
                        onPressed: isCollected
                            ? null
                            : () => widget.onAdd(product),
                        icon: Icon(isCollected ? Icons.check : Icons.add),
                        label: Text(isCollected ? 'In Collection' : 'Add'),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _ProductImage extends StatelessWidget {
  final String imageUrl;

  const _ProductImage({required this.imageUrl});

  @override
  Widget build(BuildContext context) {
    final placeholder = Container(
      width: 95,
      height: 120,
      decoration: BoxDecoration(
        color: Colors.pink.shade50,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Icon(Icons.spa_outlined, size: 40, color: Colors.pink.shade300),
    );

    if (imageUrl.isEmpty) return placeholder;

    return ClipRRect(
      borderRadius: BorderRadius.circular(12),
      child: Image.network(
        imageUrl,
        width: 95,
        height: 120,
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) => placeholder,
      ),
    );
  }
}
