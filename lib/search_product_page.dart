import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

// IMPORTANT: Make sure these paths match your folder structure!
import '../shoppingCart/shopping_cart_product_provider.dart';
import '../shoppingCart/product.dart';
import '../products/product_details_page.dart';

class SearchProductsPage extends StatefulWidget {
  final String initialQuery;

  const SearchProductsPage({this.initialQuery = '', super.key});

  @override
  State<SearchProductsPage> createState() => _SearchProductsPageState();
}

class _SearchProductsPageState extends State<SearchProductsPage> {
  late TextEditingController _searchController;
  String _searchQuery = '';

  // Filter States
  RangeValues _priceRange = const RangeValues(0, 2000); // Default $0 to $2000
  String _sortBy = 'Recommended'; // 'Recommended', 'Low to High', 'High to Low'

  @override
  void initState() {
    super.initState();
    _searchQuery = widget.initialQuery;
    _searchController = TextEditingController(text: widget.initialQuery);
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  // ==========================================
  // FILTER BOTTOM SHEET
  // ==========================================
  void _openFilterSheet() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return StatefulBuilder(
          builder: (BuildContext context, StateSetter setModalState) {
            return Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text('Filters',
                          style: TextStyle(
                              fontSize: 20, fontWeight: FontWeight.bold)),
                      IconButton(
                          icon: const Icon(Icons.close),
                          onPressed: () => Navigator.pop(context)),
                    ],
                  ),
                  const SizedBox(height: 20),

                  // Sort By Dropdown
                  const Text('Sort By',
                      style: TextStyle(fontWeight: FontWeight.bold)),
                  const SizedBox(height: 8),
                  DropdownButtonFormField<String>(
                    initialValue: _sortBy,
                    decoration: InputDecoration(
                      contentPadding:
                          const EdgeInsets.symmetric(horizontal: 12),
                      border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8)),
                    ),
                    items: [
                      'Recommended',
                      'Price: Low to High',
                      'Price: High to Low'
                    ]
                        .map((sort) =>
                            DropdownMenuItem(value: sort, child: Text(sort)))
                        .toList(),
                    onChanged: (value) {
                      setModalState(() => _sortBy = value!);
                      setState(() =>
                          _sortBy = value!); // Update main screen state too
                    },
                  ),
                  const SizedBox(height: 24),

                  // Price Range Slider
                  Text(
                      'Price Range: \$${_priceRange.start.toInt()} - \$${_priceRange.end.toInt()}',
                      style: const TextStyle(fontWeight: FontWeight.bold)),
                  RangeSlider(
                    values: _priceRange,
                    min: 0,
                    max: 2000,
                    divisions: 40,
                    activeColor: const Color(0xFF000033),
                    labels: RangeLabels('\$${_priceRange.start.toInt()}',
                        '\$${_priceRange.end.toInt()}'),
                    onChanged: (RangeValues values) {
                      setModalState(() => _priceRange = values);
                      setState(() => _priceRange = values);
                    },
                  ),
                  const SizedBox(height: 24),

                  // Apply Button
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF000033),
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12)),
                      ),
                      onPressed: () => Navigator.pop(context),
                      child: const Text('APPLY FILTERS',
                          style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold)),
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.black),
        title: Container(
          height: 40,
          decoration: BoxDecoration(
              color: Colors.grey[100], borderRadius: BorderRadius.circular(8)),
          child: TextField(
            controller: _searchController,
            autofocus:
                widget.initialQuery.isEmpty, // Auto-open keyboard if no query
            decoration: InputDecoration(
              hintText: 'Search for products...',
              border: InputBorder.none,
              prefixIcon:
                  const Icon(Icons.search, color: Colors.grey, size: 20),
              suffixIcon: _searchQuery.isNotEmpty
                  ? IconButton(
                      icon:
                          const Icon(Icons.clear, color: Colors.grey, size: 20),
                      onPressed: () {
                        _searchController.clear();
                        setState(() => _searchQuery = '');
                      },
                    )
                  : null,
            ),
            onChanged: (value) => setState(() => _searchQuery = value),
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.tune, color: Colors.black),
            onPressed: _openFilterSheet, // Opens the filter menu
          ),
        ],
      ),
      body: Consumer<ProductProvider>(
        builder: (context, productProvider, child) {
          // 1. Combine all products
          List<Product> allProducts = [
            ...productProvider.newArrivals,
            ...productProvider.deals,
            ...productProvider.recommended,
          ];

          // 2. Remove exact duplicates (if an item is in both Deals and New Arrivals)
          final uniqueProducts = <String, Product>{};
          for (var product in allProducts) {
            uniqueProducts[product.title] = product;
          }
          allProducts = uniqueProducts.values.toList();

          // 3. Apply Search Filter
          var filteredProducts = allProducts.where((product) {
            final matchesQuery = product.title
                    .toLowerCase()
                    .contains(_searchQuery.toLowerCase()) ||
                product.category
                    .toLowerCase()
                    .contains(_searchQuery.toLowerCase());
            final matchesPrice = product.price >= _priceRange.start &&
                product.price <= _priceRange.end;
            return matchesQuery && matchesPrice;
          }).toList();

          // 4. Apply Sorting
          if (_sortBy == 'Price: Low to High') {
            filteredProducts.sort((a, b) => a.price.compareTo(b.price));
          } else if (_sortBy == 'Price: High to Low') {
            filteredProducts.sort((a, b) => b.price.compareTo(a.price));
          }

          // 5. Display Results
          if (filteredProducts.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.search_off, size: 80, color: Colors.grey.shade300),
                  const SizedBox(height: 16),
                  Text('No products found',
                      style:
                          TextStyle(fontSize: 18, color: Colors.grey.shade600)),
                ],
              ),
            );
          }

          return Padding(
            padding: const EdgeInsets.all(16.0),
            child: GridView.builder(
              itemCount: filteredProducts.length,
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                childAspectRatio: 0.70,
                crossAxisSpacing: 16,
                mainAxisSpacing: 16,
              ),
              itemBuilder: (context, index) {
                return _buildProductCard(context, filteredProducts[index]);
              },
            ),
          );
        },
      ),
    );
  }

  // We reuse the product card design from your Category page!
  Widget _buildProductCard(BuildContext context, Product product) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
            context,
            MaterialPageRoute(
                builder: (context) => ProductDetailsPage(product: product)));
      },
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.grey.shade200),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Container(
                width: double.infinity,
                decoration: BoxDecoration(
                  color: Colors.grey.shade50,
                  borderRadius:
                      const BorderRadius.vertical(top: Radius.circular(16)),
                ),
                child: Center(
                  child: Padding(
                    padding: const EdgeInsets.all(12.0),
                    child: Image.network(
                      product.imageUrl,
                      fit: BoxFit.contain,
                      errorBuilder: (context, error, stackTrace) => const Icon(
                          Icons.image_not_supported,
                          color: Colors.grey),
                    ),
                  ),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(12.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('\$${product.price.toStringAsFixed(2)}',
                      style: const TextStyle(
                          fontWeight: FontWeight.bold, fontSize: 16)),
                  const SizedBox(height: 4),
                  Text(product.title,
                      style: const TextStyle(color: Colors.grey, fontSize: 14),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
