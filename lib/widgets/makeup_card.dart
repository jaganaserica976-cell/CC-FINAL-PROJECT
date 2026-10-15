import 'package:flutter/material.dart';

import '../models/makeup_product.dart';

class MakeupCard extends StatelessWidget {
  final MakeupProduct product;
  final VoidCallback onFavorite;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const MakeupCard({
    super.key,
    required this.product,
    required this.onFavorite,
    required this.onEdit,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      color: Colors.white,
      elevation: 2,
      margin: const EdgeInsets.only(bottom: 14),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      clipBehavior: Clip.antiAlias,
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildProductImage(),
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
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.pink.shade50,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      product.category,
                      style: TextStyle(
                        fontSize: 11,
                        color: Colors.pink.shade700,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '₱${product.price.toStringAsFixed(2)}',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.pink.shade700,
                    ),
                  ),
                  Row(
                    children: [
                      IconButton(
                        tooltip: product.isFavorite
                            ? 'Remove from favorites'
                            : 'Add to favorites',
                        onPressed: onFavorite,
                        icon: Icon(
                          product.isFavorite
                              ? Icons.favorite
                              : Icons.favorite_border,
                          color: product.isFavorite ? Colors.pink : Colors.grey,
                        ),
                      ),
                      IconButton(
                        tooltip: 'Edit product',
                        onPressed: onEdit,
                        icon: const Icon(
                          Icons.edit_outlined,
                          color: Colors.blueGrey,
                        ),
                      ),
                      IconButton(
                        tooltip: 'Delete product',
                        onPressed: onDelete,
                        icon: const Icon(
                          Icons.delete_outline,
                          color: Colors.redAccent,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProductImage() {
    if (product.imageUrl.isEmpty) {
      return _imagePlaceholder();
    }

    return ClipRRect(
      borderRadius: BorderRadius.circular(12),
      child: Image.network(
        product.imageUrl,
        width: 95,
        height: 120,
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) => _imagePlaceholder(),
      ),
    );
  }

  Widget _imagePlaceholder() {
    return Container(
      width: 95,
      height: 120,
      decoration: BoxDecoration(
        color: Colors.pink.shade50,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Icon(Icons.spa_outlined, size: 40, color: Colors.pink.shade300),
    );
  }
}
