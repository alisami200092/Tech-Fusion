import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'shopping_cart_product_provider.dart';
import 'product.dart';

class ManageNewArrivalsPage extends StatefulWidget {
  const ManageNewArrivalsPage({super.key});

  @override
  // ignore: library_private_types_in_public_api
  _ManageNewArrivalsPageState createState() => _ManageNewArrivalsPageState();
}

class _ManageNewArrivalsPageState extends State<ManageNewArrivalsPage> {
  final TextEditingController titleController = TextEditingController();
  final TextEditingController descriptionController = TextEditingController();
  final TextEditingController priceController = TextEditingController();
  final TextEditingController imageUrlController = TextEditingController();

  String? editingProductId;

  @override
  void initState() {
    super.initState();
    // Fetch the products from Firestore when the admin opens this page
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<ProductProvider>(context, listen: false).loadProducts();
    });
  }

  // FIXED: Removed duplicate 'Monitor' to prevent Dropdown crash
  final List<String> categories = [
    'Cabinet',
    'Monitor',
    'Console',
    'Headphones',
    'Keyboard',
    'Mouse',
    'Chair'
  ];
  String selectedCategory = 'Cabinet'; // Default selection

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      appBar: AppBar(
        title: const Text('Manage New Arrivals'),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 1,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: <Widget>[
            // ==========================================
            // ADMIN INPUT FORM
            // ==========================================
            Expanded(
              flex: 4,
              child: SingleChildScrollView(
                child: Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [
                      BoxShadow(
                          color: Colors.black.withValues(alpha: 0.05),
                          blurRadius: 10)
                    ],
                  ),
                  child: Column(
                    children: [
                      TextField(
                        controller: titleController,
                        decoration: const InputDecoration(
                            labelText: 'Product Title',
                            border: OutlineInputBorder()),
                      ),
                      const SizedBox(height: 12),
                      TextField(
                        controller: descriptionController,
                        decoration: const InputDecoration(
                            labelText: 'Description',
                            border: OutlineInputBorder()),
                        maxLines: 2,
                      ),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          Expanded(
                            child: TextField(
                              controller: priceController,
                              decoration: const InputDecoration(
                                  labelText: 'Price (\$)',
                                  border: OutlineInputBorder()),
                              keyboardType: TextInputType.number,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: DropdownButtonFormField<String>(
                              initialValue: selectedCategory,
                              decoration: const InputDecoration(
                                  labelText: 'Category',
                                  border: OutlineInputBorder()),
                              items: categories.map((String category) {
                                return DropdownMenuItem<String>(
                                  value: category,
                                  child: Text(category),
                                );
                              }).toList(),
                              onChanged: (String? newValue) {
                                if (newValue != null) {
                                  setState(() {
                                    selectedCategory = newValue;
                                  });
                                }
                              },
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      TextField(
                        controller: imageUrlController,
                        decoration: const InputDecoration(
                            labelText: 'Image URL',
                            border: OutlineInputBorder()),
                      ),
                      const SizedBox(height: 20),
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: editingProductId != null
                                ? Colors.orange
                                : const Color(0xFF000033),
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8)),
                          ),
                          onPressed: () async {
                            final title = titleController.text;
                            final description = descriptionController.text;
                            final price =
                                double.tryParse(priceController.text) ?? 0.0;
                            final imageUrl = imageUrlController.text;

                            // Validation check
                            if (title.isEmpty || imageUrl.isEmpty) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                      content: Text(
                                          'Please fill in title and image URL'),
                                      backgroundColor: Colors.red));
                              return;
                            }

                            final product = Product(
                              title: title,
                              description: description,
                              price: price,
                              imageUrl: imageUrl,
                              category: selectedCategory,
                              id: editingProductId ?? '',
                            );

                            // Cache context variables BEFORE async gap
                            final scaffoldMessenger =
                                ScaffoldMessenger.of(context);
                            final isUpdating = editingProductId != null;

                            if (mounted) {
                              await Provider.of<ProductProvider>(context,
                                      listen: false)
                                  .addNewArrival(product);

                              // Clear Form
                              titleController.clear();
                              descriptionController.clear();
                              priceController.clear();
                              imageUrlController.clear();

                              setState(() {
                                editingProductId = null;
                                selectedCategory = categories.first;
                              });

                              // Show Success Notification
                              scaffoldMessenger.hideCurrentSnackBar();
                              scaffoldMessenger.showSnackBar(
                                SnackBar(
                                  content: Text(isUpdating
                                      ? '✅ Product updated successfully!'
                                      : '✅ New product added!'),
                                  backgroundColor: Colors.green,
                                  behavior: SnackBarBehavior.floating,
                                  duration: const Duration(seconds: 2),
                                ),
                              );
                            }
                          },
                          child: Text(
                            editingProductId != null
                                ? 'UPDATE PRODUCT'
                                : 'ADD NEW ARRIVAL',
                            style: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),

            const SizedBox(height: 16),
            const Align(
              alignment: Alignment.centerLeft,
              child: Text('Current Inventory:',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            ),
            const SizedBox(height: 8),

            // ==========================================
            // PRODUCT LIST
            // ==========================================
            Expanded(
              flex: 5,
              child: Consumer<ProductProvider>(
                builder: (context, productProvider, child) {
                  if (productProvider.newArrivals.isEmpty) {
                    return Center(
                        child: Text("No products added yet.",
                            style: TextStyle(color: Colors.grey.shade500)));
                  }

                  return ListView.builder(
                    itemCount: productProvider.newArrivals.length,
                    itemBuilder: (context, index) {
                      final product = productProvider.newArrivals[index];
                      return Card(
                        margin: const EdgeInsets.only(bottom: 8.0),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12)),
                        child: ListTile(
                          contentPadding: const EdgeInsets.all(8),
                          leading: ClipRRect(
                            borderRadius: BorderRadius.circular(8),
                            child: Image.network(
                              product.imageUrl,
                              width: 60,
                              height: 60,
                              fit: BoxFit.cover,
                              errorBuilder: (context, error, stackTrace) =>
                                  Container(
                                width: 60,
                                height: 60,
                                color: Colors.grey.shade200,
                                child: const Icon(Icons.image_not_supported,
                                    color: Colors.grey),
                              ),
                            ),
                          ),
                          title: Text(product.title,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style:
                                  const TextStyle(fontWeight: FontWeight.bold)),
                          subtitle: Text(
                              '\$${product.price.toStringAsFixed(2)} • ${product.category}',
                              style: TextStyle(color: Colors.grey.shade600)),
                          trailing: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              IconButton(
                                icon: const Icon(Icons.edit_outlined,
                                    color: Colors.blue),
                                onPressed: () {
                                  setState(() {
                                    titleController.text = product.title;
                                    descriptionController.text =
                                        product.description;
                                    priceController.text =
                                        product.price.toString();
                                    imageUrlController.text = product.imageUrl;
                                    editingProductId = product.id;

                                    if (categories.contains(product.category)) {
                                      selectedCategory = product.category;
                                    } else {
                                      selectedCategory = categories.first;
                                    }
                                  });
                                },
                              ),
                              IconButton(
                                icon: const Icon(Icons.delete_outline,
                                    color: Colors.red),
                                onPressed: () async {
                                  final scaffoldMessenger =
                                      ScaffoldMessenger.of(context);
                                  await Provider.of<ProductProvider>(context,
                                          listen: false)
                                      .deleteProduct(product, 'newArrivals');

                                  if (mounted) {
                                    scaffoldMessenger.hideCurrentSnackBar();
                                    scaffoldMessenger.showSnackBar(
                                      SnackBar(
                                        content: Text(
                                            '🗑️ ${product.title} deleted.'),
                                        backgroundColor: Colors.red.shade800,
                                        behavior: SnackBarBehavior.floating,
                                        duration: const Duration(seconds: 2),
                                      ),
                                    );
                                  }
                                },
                              ),
                            ],
                          ),
                        ),
                      );
                    },
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
