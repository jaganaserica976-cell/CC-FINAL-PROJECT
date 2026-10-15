import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:makeup_recollection/main.dart';
import 'package:makeup_recollection/services/storage_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  test('adds default images to previously saved sample products', () async {
    SharedPreferences.setMockInitialValues({
      'makeup_collection': jsonEncode([
        {
          'id': 'sample-1',
          'name': 'Velvet Matte Lipstick',
          'brand': 'Beauty Essentials',
          'category': 'Lipstick',
          'price': 299.00,
          'imageUrl': '',
          'isFavorite': false,
        },
      ]),
    });

    final products = await StorageService().loadProducts();

    expect(products.single.imageUrl, startsWith('https://'));
  });

  testWidgets('shows collection overview and navigates to products', (
    tester,
  ) async {
    SharedPreferences.setMockInitialValues({});

    await tester.pumpWidget(const MakeupRecollectionApp());
    await tester.pumpAndSettle();

    expect(find.text('Makeup Recollection'), findsOneWidget);
    expect(find.text('Total Products'), findsOneWidget);

    await tester.tap(find.text('Collection'));
    await tester.pumpAndSettle();

    expect(find.text('My Collection'), findsOneWidget);
    expect(find.text('Essence Mascara Lash Princess'), findsOneWidget);
    expect(find.byType(Image), findsWidgets);
  });

  testWidgets('saves a manually added product to the collection', (
    tester,
  ) async {
    SharedPreferences.setMockInitialValues({});

    await tester.pumpWidget(const MakeupRecollectionApp());
    await tester.pumpAndSettle();
    await tester.tap(find.text('Collection'));
    await tester.pumpAndSettle();
    await tester.tap(find.byTooltip('Add product'));
    await tester.pumpAndSettle();

    await tester.enterText(find.byType(TextFormField).at(0), 'Test Lipstick');
    await tester.enterText(find.byType(TextFormField).at(1), 'Test Brand');
    await tester.enterText(find.byType(TextFormField).at(2), 'Lipstick');
    await tester.enterText(find.byType(TextFormField).at(3), '10.50');
    await tester.tap(find.text('Save'));
    await tester.pumpAndSettle();

    final prefs = await SharedPreferences.getInstance();
    final encodedData = prefs.getString('makeup_collection');
    expect(find.text('Add Makeup Product'), findsNothing);
    expect(encodedData, isNotNull);
    final savedData = jsonDecode(encodedData!);
    expect(savedData, hasLength(4));
    expect(savedData.first['name'], 'Test Lipstick');
    expect(find.text('Test Lipstick'), findsOneWidget);
  });

  testWidgets('restores edits and the selected collection page after restart', (
    tester,
  ) async {
    SharedPreferences.setMockInitialValues({});

    await tester.pumpWidget(const MakeupRecollectionApp());
    await tester.pumpAndSettle();
    await tester.tap(find.text('Collection'));
    await tester.pumpAndSettle();
    await tester.tap(find.byTooltip('Edit product').first);
    await tester.pumpAndSettle();

    await tester.enterText(find.byType(TextFormField).at(0), 'Edited Mascara');
    await tester.tap(find.text('Save'));
    await tester.pumpAndSettle();

    await tester.pumpWidget(const SizedBox());
    await tester.pumpAndSettle();
    await tester.pumpWidget(const MakeupRecollectionApp());
    await tester.pumpAndSettle();

    expect(find.text('My Collection'), findsOneWidget);
    expect(find.text('Edited Mascara'), findsOneWidget);

    final prefs = await SharedPreferences.getInstance();
    final savedData = jsonDecode(prefs.getString('makeup_collection')!);
    expect(savedData.first['name'], 'Edited Mascara');
    expect(prefs.getInt('selected_page'), 1);
  });

  testWidgets('restores an unsaved product edit after app restart', (
    tester,
  ) async {
    SharedPreferences.setMockInitialValues({});

    await tester.pumpWidget(const MakeupRecollectionApp());
    await tester.pumpAndSettle();
    await tester.tap(find.text('Collection'));
    await tester.pumpAndSettle();
    await tester.tap(find.byTooltip('Edit product').first);
    await tester.pumpAndSettle();
    await tester.enterText(find.byType(TextFormField).at(0), 'Unfinished edit');
    await tester.pumpAndSettle();

    final prefs = await SharedPreferences.getInstance();
    final draft = jsonDecode(prefs.getString('makeup_product_draft')!);
    expect(draft['name'], 'Unfinished edit');

    await tester.pumpWidget(const SizedBox());
    await tester.pumpAndSettle();
    await tester.pumpWidget(const MakeupRecollectionApp());
    await tester.pumpAndSettle();

    expect(find.text('Edit Product'), findsOneWidget);
    expect(
      tester
          .widget<TextFormField>(find.byType(TextFormField).first)
          .controller!
          .text,
      'Unfinished edit',
    );
    await tester.tap(find.text('Save'));
    await tester.pumpAndSettle();

    final savedProducts = jsonDecode(prefs.getString('makeup_collection')!);
    expect(savedProducts.first['name'], 'Unfinished edit');
    expect(prefs.getString('makeup_product_draft'), isNull);
  });
}
