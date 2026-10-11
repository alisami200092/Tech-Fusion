import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'shopping_cart_product_provider.dart';
import 'product.dart';

class ManageRecommendedPage extends StatefulWidget {
  const ManageRecommendedPage({super.key});

  @override
  // ignore: library_private_types_in_public_api
  _ManageRecommendedPageState createState() => _ManageRecommendedPageState();
}

class _ManageRecommendedPageState extends State<ManageRecommendedPage> {
  final TextEditingController titleController = TextEditingController();
  final TextEditingController descriptionController = TextEditingController();
  final TextEditingController priceController = TextEditingController();
  final TextEditingController imageUrlController = TextEditingController();
  String? editingProductId;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Manage Recommended Products')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: <Widget>[
            TextField(
              controller: titleController,
              decoration: InputDecoration(labelText: 'Product Title'),
            ),
            TextField(
              controller: descriptionController,
              decoration: InputDecoration(labelText: 'Description'),
            ),
            TextField(
              controller: priceController,
              decoration: InputDecoration(labelText: 'Price'),
              keyboardType: TextInputType.number,
            ),
            TextField(
              controller: imageUrlController,
              decoration: InputDecoration(labelText: 'Image URL'),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () async {
                final title = titleController.text;
                final description = descriptionController.text;
                final price = double.tryParse(priceController.text) ?? 0.0;
                final imageUrl = imageUrlController.text;

                final product = Product(
                  title: title,
                  description: description,
                  price: price,
                  imageUrl: imageUrl,
                  id: editingProductId ?? '',
                );

                if (mounted) {
                  if (editingProductId != null) {
                    await Provider.of<ProductProvider>(context, listen: false)
                        .addRecommended(product);
                    setState(() {
                      editingProductId = null;
                    });
                  } else {
                    await Provider.of<ProductProvider>(context, listen: false)
                        .addRecommended(product);
                  }

                  titleController.clear();
                  descriptionController.clear();
                  priceController.clear();
                  imageUrlController.clear();
                }
              },
              child: Text(editingProductId != null ? 'Update Recommended Product' : 'Add Recommended Product'),
            ),
            SizedBox(height: 20),
            Text('Recommended Products in Firestore:'),
            Expanded(
              child: Consumer<ProductProvider>(
                builder: (context, productProvider, child) {
                  return ListView.builder(
                    itemCount: productProvider.recommended.length,
                    itemBuilder: (context, index) {
                      final product = productProvider.recommended[index];
                      return Card(
                        margin: EdgeInsets.all(8.0),
                        child: ListTile(
                          leading: Image.network(
                            product.imageUrl,
                            width: 50,
                            height: 50,
                            fit: BoxFit.cover,
                          ),
                          title: Text(product.title),
                          subtitle: Text('\$${product.price.toString()}'),
                          trailing: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              IconButton(
                                icon: Icon(Icons.edit, color: Colors.blue),
                                onPressed: () {
                                  setState(() {
                                    titleController.text = product.title;
                                    descriptionController.text = product.description;
                                    priceController.text = product.price.toString();
                                    imageUrlController.text = product.imageUrl;
                                    editingProductId = product.id;
                                  });
                                },
                              ),
                              IconButton(
                                icon: Icon(Icons.delete, color: Colors.red),
                                onPressed: () async {
                                  final scaffoldMessenger = ScaffoldMessenger.of(context);

                                  await Provider.of<ProductProvider>(context, listen: false)
                                      .deleteProduct(product, 'recommended');

                                  if (mounted) {
                                    scaffoldMessenger.showSnackBar(
                                      SnackBar(
                                        content: Text('${product.title} has been deleted.'),
                                        duration: Duration(seconds: 2),
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