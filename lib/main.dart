import 'package:flutter/material.dart';

import 'models/makeup_product.dart';
import 'screens/collection_screen.dart';
import 'screens/discover_screen.dart';
import 'screens/home_screen.dart';
import 'services/storage_service.dart';

void main() {
  runApp(const MakeupRecollectionApp());
}

class MakeupRecollectionApp extends StatelessWidget {
  const MakeupRecollectionApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Makeup Recollection',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFFC2185B),
          brightness: Brightness.light,
        ),
        scaffoldBackgroundColor: const Color(0xFFFFF7FA),
        useMaterial3: true,
      ),
      home: const MakeupHomePage(),
    );
  }
}

class MakeupHomePage extends StatefulWidget {
  const MakeupHomePage({super.key});

  @override
  State<MakeupHomePage> createState() => _MakeupHomePageState();
}

class _MakeupHomePageState extends State<MakeupHomePage> {
  final StorageService _storageService = StorageService();
  List<MakeupProduct> _products = [];
  int _selectedIndex = 0;
  bool _isLoading = true;
  Object? _loadError;
  Future<void> _draftWriteQueue = Future<void>.value();

  @override
  void initState() {
    super.initState();
    _loadProducts();
  }

  Future<void> _loadProducts() async {
    setState(() {
      _isLoading = true;
      _loadError = null;
    });

    try {
      final products = await _storageService.loadProducts();
      final selectedPage = await _storageService.loadSelectedPage();
      final productDraft = await _storageService.loadProductDraft();
      if (!mounted) return;
      setState(() {
        _products = products;
        _selectedIndex = selectedPage;
        _isLoading = false;
      });
      if (productDraft != null) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (mounted) _resumeProductDraft(productDraft);
        });
      }
    } catch (error) {
      if (!mounted) return;
      setState(() {
        _loadError = error;
        _isLoading = false;
      });
    }
  }

  Future<bool> _saveProducts(List<MakeupProduct> updatedProducts) async {
    try {
      await _storageService.saveProducts(updatedProducts);
      if (!mounted) return false;
      setState(() => _products = updatedProducts);
      return true;
    } catch (error) {
      _showMessage('Could not save your collection: $error');
      return false;
    }
  }

  Future<void> _selectPage(int index) async {
    setState(() => _selectedIndex = index);
    try {
      await _storageService.saveSelectedPage(index);
    } catch (error) {
      _showMessage('Could not save your selected page: $error');
    }
  }

  Future<void> _addProduct([
    MakeupProduct? product,
    Map<String, String>? draftValues,
  ]) async {
    final result = await _showProductDialog(
      product: product,
      draftValues: draftValues,
    );
    if (result == null) return;

    if (_products.any((existing) => existing.id == result.id)) {
      _showMessage('This product is already in your collection.');
      return;
    }

    if (await _saveProducts([result, ..._products])) {
      await _clearProductDraft();
    }
  }

  Future<void> _editProduct(
    MakeupProduct product, {
    Map<String, String>? draftValues,
  }) async {
    final updated = await _showProductDialog(
      product: product,
      draftValues: draftValues,
    );
    if (updated == null) return;

    if (await _saveProducts(
      _products.map((item) => item.id == product.id ? updated : item).toList(),
    )) {
      await _clearProductDraft();
    }
  }

  Future<void> _resumeProductDraft(Map<String, String> draft) async {
    final productId = draft['productId'];
    if (productId == null) {
      await _addProduct(null, draft);
      return;
    }

    MakeupProduct? product;
    for (final item in _products) {
      if (item.id == productId) {
        product = item;
        break;
      }
    }
    if (product == null) {
      await _clearProductDraft();
      return;
    }

    await _editProduct(product, draftValues: draft);
  }

  Future<void> _deleteProduct(MakeupProduct product) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete product?'),
        content: Text('Remove "${product.name}" from your collection?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      await _saveProducts(
        _products.where((item) => item.id != product.id).toList(),
      );
    }
  }

  Future<void> _toggleFavorite(MakeupProduct product) async {
    await _saveProducts(
      _products
          .map(
            (item) => item.id == product.id
                ? item.copyWith(isFavorite: !item.isFavorite)
                : item,
          )
          .toList(),
    );
  }

  Future<MakeupProduct?> _showProductDialog({
    MakeupProduct? product,
    Map<String, String>? draftValues,
  }) async {
    final result = await showDialog<MakeupProduct>(
      context: context,
      barrierDismissible: false,
      builder: (context) => _ProductFormDialog(
        product: product,
        draftValues: draftValues,
        onDraftChanged: _saveProductDraft,
      ),
    );
    if (result == null) await _clearProductDraft();
    return result;
  }

  Future<void> _saveProductDraft(Map<String, String> draft) async {
    _draftWriteQueue = _draftWriteQueue.then((_) async {
      try {
        await _storageService.saveProductDraft(draft);
      } catch (error) {
        _showMessage('Could not save your unsaved draft: $error');
      }
    });
    await _draftWriteQueue;
  }

  Future<void> _clearProductDraft() async {
    await _draftWriteQueue;
    try {
      await _storageService.clearProductDraft();
    } catch (error) {
      _showMessage('Could not clear your saved draft: $error');
    }
  }

  void _showMessage(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(message)));
  }

  Widget _buildSelectedScreen() {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_loadError != null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.error_outline, size: 48, color: Colors.pink),
              const SizedBox(height: 12),
              const Text(
                'Could not load your collection',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              Text('$_loadError', textAlign: TextAlign.center),
              const SizedBox(height: 16),
              FilledButton.icon(
                onPressed: _loadProducts,
                icon: const Icon(Icons.refresh),
                label: const Text('Try Again'),
              ),
            ],
          ),
        ),
      );
    }

    switch (_selectedIndex) {
      case 1:
        return CollectionScreen(
          products: _products,
          onAdd: _addProduct,
          onEdit: _editProduct,
          onDelete: _deleteProduct,
          onFavorite: _toggleFavorite,
        );
      case 2:
        return DiscoverScreen(
          collectionIds: _products.map((product) => product.id).toSet(),
          onAdd: (product) => _addProduct(product),
        );
      default:
        return HomeScreen(
          productCount: _products.length,
          favoriteCount: _products
              .where((product) => product.isFavorite)
              .length,
          categoryCount: _products
              .map((product) => product.category)
              .toSet()
              .length,
          onOpenCollection: () => _selectPage(1),
          onOpenDiscover: () => _selectPage(2),
          onAddProduct: _addProduct,
        );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _buildSelectedScreen(),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _selectedIndex,
        onDestinationSelected: _selectPage,
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.home_outlined),
            selectedIcon: Icon(Icons.home),
            label: 'Home',
          ),
          NavigationDestination(
            icon: Icon(Icons.inventory_2_outlined),
            selectedIcon: Icon(Icons.inventory_2),
            label: 'Collection',
          ),
          NavigationDestination(
            icon: Icon(Icons.explore_outlined),
            selectedIcon: Icon(Icons.explore),
            label: 'Discover',
          ),
        ],
      ),
    );
  }
}

class _ProductFormDialog extends StatefulWidget {
  final MakeupProduct? product;
  final Map<String, String>? draftValues;
  final ValueChanged<Map<String, String>> onDraftChanged;

  const _ProductFormDialog({
    this.product,
    this.draftValues,
    required this.onDraftChanged,
  });

  @override
  State<_ProductFormDialog> createState() => _ProductFormDialogState();
}

class _ProductFormDialogState extends State<_ProductFormDialog> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _nameController;
  late final TextEditingController _brandController;
  late final TextEditingController _categoryController;
  late final TextEditingController _priceController;
  late final TextEditingController _imageController;

  @override
  void initState() {
    super.initState();
    final product = widget.product;
    final draft = widget.draftValues;
    _nameController = TextEditingController(
      text: draft?['name'] ?? product?.name ?? '',
    );
    _brandController = TextEditingController(
      text: draft?['brand'] ?? product?.brand ?? '',
    );
    _categoryController = TextEditingController(
      text: draft?['category'] ?? product?.category ?? '',
    );
    _priceController = TextEditingController(
      text:
          draft?['price'] ??
          (product == null ? '' : product.price.toStringAsFixed(2)),
    );
    _imageController = TextEditingController(
      text: draft?['imageUrl'] ?? product?.imageUrl ?? '',
    );
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) _queueDraftSave();
    });
  }

  @override
  void dispose() {
    _nameController.dispose();
    _brandController.dispose();
    _categoryController.dispose();
    _priceController.dispose();
    _imageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final product = widget.product;

    return AlertDialog(
      title: Text(product == null ? 'Add Makeup Product' : 'Edit Product'),
      content: Form(
        key: _formKey,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _textInput(
                _nameController,
                'Product name',
                onChanged: _queueDraftSave,
              ),
              _textInput(_brandController, 'Brand', onChanged: _queueDraftSave),
              _textInput(
                _categoryController,
                'Category',
                onChanged: _queueDraftSave,
              ),
              _textInput(
                _priceController,
                'Price',
                keyboardType: const TextInputType.numberWithOptions(
                  decimal: true,
                ),
                validator: (value) {
                  final price = double.tryParse(value?.trim() ?? '');
                  if (price == null || !price.isFinite || price < 0) {
                    return 'Enter a valid non-negative price';
                  }
                  return null;
                },
                onChanged: _queueDraftSave,
              ),
              _textInput(
                _imageController,
                'Image URL (optional)',
                required: false,
                keyboardType: TextInputType.url,
                onChanged: _queueDraftSave,
              ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
        FilledButton(onPressed: _save, child: const Text('Save')),
      ],
    );
  }

  Widget _textInput(
    TextEditingController controller,
    String label, {
    bool required = true,
    TextInputType? keyboardType,
    String? Function(String?)? validator,
    VoidCallback? onChanged,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: TextFormField(
        controller: controller,
        keyboardType: keyboardType,
        onChanged: onChanged == null ? null : (_) => onChanged(),
        decoration: InputDecoration(
          labelText: label,
          border: const OutlineInputBorder(),
        ),
        validator:
            validator ??
            (value) {
              if (required && (value == null || value.trim().isEmpty)) {
                return 'This field is required';
              }
              return null;
            },
      ),
    );
  }

  void _queueDraftSave() {
    final product = widget.product;
    widget.onDraftChanged({
      if (product != null) 'productId': product.id,
      'name': _nameController.text,
      'brand': _brandController.text,
      'category': _categoryController.text,
      'price': _priceController.text,
      'imageUrl': _imageController.text,
    });
  }

  void _save() {
    if (!_formKey.currentState!.validate()) return;

    final product = widget.product;
    Navigator.pop(
      context,
      MakeupProduct(
        id: product?.id ?? 'local-${DateTime.now().microsecondsSinceEpoch}',
        name: _nameController.text.trim(),
        brand: _brandController.text.trim(),
        category: _categoryController.text.trim(),
        price: double.parse(_priceController.text.trim()),
        imageUrl: _imageController.text.trim(),
        isFavorite: product?.isFavorite ?? false,
      ),
    );
  }
}
