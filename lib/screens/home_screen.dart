import 'package:flutter/material.dart';

import '../widgets/summary_card.dart';

class HomeScreen extends StatelessWidget {
  final int productCount;
  final int favoriteCount;
  final int categoryCount;
  final VoidCallback onOpenCollection;
  final VoidCallback onOpenDiscover;
  final VoidCallback onAddProduct;

  const HomeScreen({
    super.key,
    required this.productCount,
    required this.favoriteCount,
    required this.categoryCount,
    required this.onOpenCollection,
    required this.onOpenDiscover,
    required this.onAddProduct,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFFF7FA),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(20),
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.pink.shade100,
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: const Icon(
                    Icons.auto_awesome,
                    color: Colors.pink,
                    size: 28,
                  ),
                ),
                const SizedBox(width: 12),
                const Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Makeup Recollection',
                        style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(height: 3),
                      Text(
                        'Your personal beauty collection',
                        style: TextStyle(color: Colors.black54, fontSize: 13),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 26),
            Container(
              padding: const EdgeInsets.all(22),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFFF8BBD0), Color(0xFFFCE4EC)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(22),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Your Beauty, Your Collection',
                    style: TextStyle(
                      fontSize: 23,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF7B1F48),
                    ),
                  ),
                  const SizedBox(height: 10),
                  const Text(
                    'Organize your favorite makeup products, '
                    'keep track of your collection, and discover '
                    'new beauty finds.',
                    style: TextStyle(
                      fontSize: 14,
                      height: 1.5,
                      color: Color(0xFF63364A),
                    ),
                  ),
                  const SizedBox(height: 18),
                  Wrap(
                    spacing: 10,
                    runSpacing: 10,
                    children: [
                      ElevatedButton.icon(
                        onPressed: onOpenCollection,
                        icon: const Icon(Icons.inventory_2_outlined),
                        label: const Text('My Collection'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFFC2185B),
                          foregroundColor: Colors.white,
                        ),
                      ),
                      OutlinedButton.icon(
                        onPressed: onOpenDiscover,
                        icon: const Icon(Icons.explore_outlined),
                        label: const Text('Discover'),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: const Color(0xFF880E4F),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 26),
            const Text(
              'Collection Overview',
              style: TextStyle(fontSize: 19, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            LayoutBuilder(
              builder: (context, constraints) {
                final cardWidth = (constraints.maxWidth - 12) / 2;
                return Wrap(
                  spacing: 12,
                  runSpacing: 12,
                  children: [
                    SizedBox(
                      width: cardWidth,
                      child: SummaryCard(
                        title: 'Total Products',
                        value: productCount.toString(),
                        icon: Icons.inventory_2_outlined,
                        color: Colors.pink,
                      ),
                    ),
                    SizedBox(
                      width: cardWidth,
                      child: SummaryCard(
                        title: 'Favorites',
                        value: favoriteCount.toString(),
                        icon: Icons.favorite_outline,
                        color: Colors.redAccent,
                      ),
                    ),
                    SizedBox(
                      width: cardWidth,
                      child: SummaryCard(
                        title: 'Categories',
                        value: categoryCount.toString(),
                        icon: Icons.category_outlined,
                        color: Colors.deepPurple,
                      ),
                    ),
                  ],
                );
              },
            ),
            const SizedBox(height: 26),
            const Text(
              'Quick Actions',
              style: TextStyle(fontSize: 19, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            Card(
              elevation: 1,
              color: Colors.white,
              child: ListTile(
                leading: const CircleAvatar(
                  backgroundColor: Color(0xFFFCE4EC),
                  child: Icon(Icons.add, color: Colors.pink),
                ),
                title: const Text(
                  'Add a Makeup Product',
                  style: TextStyle(fontWeight: FontWeight.w600),
                ),
                subtitle: const Text('Record a product in your collection'),
                trailing: const Icon(Icons.chevron_right),
                onTap: onAddProduct,
              ),
            ),
            Card(
              elevation: 1,
              color: Colors.white,
              child: ListTile(
                leading: const CircleAvatar(
                  backgroundColor: Color(0xFFF3E5F5),
                  child: Icon(Icons.explore, color: Colors.deepPurple),
                ),
                title: const Text(
                  'Explore Beauty Products',
                  style: TextStyle(fontWeight: FontWeight.w600),
                ),
                subtitle: const Text(
                  'Discover products through the online API',
                ),
                trailing: const Icon(Icons.chevron_right),
                onTap: onOpenDiscover,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
