import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'product.dart';
import 'package:logger/logger.dart';

class ProductProvider with ChangeNotifier {
  List<Product> _recommended = [];
  List<Product> _deals = [];
  List<Product> _newArrivals = [];

  List<Product> get recommended => _recommended;
  List<Product> get deals => _deals;
  List<Product> get newArrivals => _newArrivals;

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final Logger _logger = Logger();

  // Method to load products from Firestore
  // Method to load products from Firestore
  Future<void> loadProducts() async {
    try {
      // Load Recommended Products
      final recommendedSnapshot =
          await _firestore.collection('recommended').get();
      _recommended = recommendedSnapshot.docs.map((doc) {
        final data = doc.data();
        data['id'] = doc.id; // <-- INJECTS THE FIRESTORE ID
        return Product.fromMap(data);
      }).toList();

      // Load Deals
      final dealsSnapshot = await _firestore.collection('deals').get();
      _deals = dealsSnapshot.docs.map((doc) {
        final data = doc.data();
        data['id'] = doc.id; // <-- INJECTS THE FIRESTORE ID
        return Product.fromMap(data);
      }).toList();

      // Load New Arrivals
      final newArrivalsSnapshot =
          await _firestore.collection('newArrivals').get();
      _newArrivals = newArrivalsSnapshot.docs.map((doc) {
        final data = doc.data();
        data['id'] = doc.id; // <-- INJECTS THE FIRESTORE ID
        return Product.fromMap(data);
      }).toList();

      notifyListeners();
    } catch (error) {
      _logger.e("Error loading products: $error");
    }
  }

  // Method to save products to Firestore (if needed)
  Future<void> saveProducts() async {
    try {
      // Save Recommended Products
      for (var product in _recommended) {
        await _firestore.collection('recommended').add(product.toMap());
      }

      // Save Deals
      for (var product in _deals) {
        await _firestore.collection('deals').add(product.toMap());
      }

      // Save New Arrivals
      for (var product in _newArrivals) {
        await _firestore.collection('newArrivals').add(product.toMap());
      }

      notifyListeners();
    } catch (error) {
      _logger.e("Error saving products: $error");
    }
  }

  // Updated method to add or update a product in the recommended list
  Future<void> addRecommended(Product product) async {
    try {
      if (product.id.isNotEmpty) {
        // Update scenario: use product.id to update the existing document.
        await _firestore
            .collection('recommended')
            .doc(product.id)
            .update(product.toMap());
        int index = _recommended.indexWhere((p) => p.id == product.id);
        if (index != -1) {
          _recommended[index] = product;
        }
      } else {
        // Add scenario: product.id is empty. Check by title first.
        final existingProductQuery = await _firestore
            .collection('recommended')
            .where('title', isEqualTo: product.title)
            .get();
        if (existingProductQuery.docs.isNotEmpty) {
          // Product exists; update using found document id.
          final docId = existingProductQuery.docs.first.id;
          await _firestore
              .collection('recommended')
              .doc(docId)
              .update(product.toMap());
          int index = _recommended.indexWhere((p) => p.title == product.title);
          if (index != -1) {
            // Use copyWith to set the id if available.
            _recommended[index] = product.copyWith(id: docId);
          }
        } else {
          // New product: add it.
          DocumentReference docRef =
              await _firestore.collection('recommended').add(product.toMap());
          final newProduct = product.copyWith(id: docRef.id);
          _recommended.add(newProduct);
        }
      }
      notifyListeners();
    } catch (error) {
      _logger.e("Error adding recommended product: $error");
    }
  }

  // Updated method to add or update a product in the deals list
  Future<void> addDeal(Product product) async {
    try {
      if (product.id.isNotEmpty) {
        // Update scenario: use product.id to update.
        await _firestore
            .collection('deals')
            .doc(product.id)
            .update(product.toMap());
        int index = _deals.indexWhere((p) => p.id == product.id);
        if (index != -1) {
          _deals[index] = product;
        }
      } else {
        // Add scenario: product.id empty; check for duplicate by title.
        final existingProductQuery = await _firestore
            .collection('deals')
            .where('title', isEqualTo: product.title)
            .get();
        if (existingProductQuery.docs.isNotEmpty) {
          final docId = existingProductQuery.docs.first.id;
          await _firestore
              .collection('deals')
              .doc(docId)
              .update(product.toMap());
          int index = _deals.indexWhere((p) => p.title == product.title);
          if (index != -1) {
            _deals[index] = product.copyWith(id: docId);
          }
        } else {
          DocumentReference docRef =
              await _firestore.collection('deals').add(product.toMap());
          final newProduct = product.copyWith(id: docRef.id);
          _deals.add(newProduct);
        }
      }
      notifyListeners();
    } catch (error) {
      _logger.e("Error adding deal: $error");
    }
  }

  // Updated method to add or update a product in the new arrivals list
  Future<void> addNewArrival(Product product) async {
    try {
      if (product.id.isNotEmpty) {
        // Update scenario: update by product.id.
        await _firestore
            .collection('newArrivals')
            .doc(product.id)
            .update(product.toMap());
        int index = _newArrivals.indexWhere((p) => p.id == product.id);
        if (index != -1) {
          _newArrivals[index] = product;
        }
      } else {
        // Add scenario: check by title if product.id is empty.
        final existingProductQuery = await _firestore
            .collection('newArrivals')
            .where('title', isEqualTo: product.title)
            .get();
        if (existingProductQuery.docs.isNotEmpty) {
          final docId = existingProductQuery.docs.first.id;
          await _firestore
              .collection('newArrivals')
              .doc(docId)
              .update(product.toMap());
          int index = _newArrivals.indexWhere((p) => p.title == product.title);
          if (index != -1) {
            _newArrivals[index] = product.copyWith(id: docId);
          }
        } else {
          DocumentReference docRef =
              await _firestore.collection('newArrivals').add(product.toMap());
          final newProduct = product.copyWith(id: docRef.id);
          _newArrivals.add(newProduct);
        }
      }
      notifyListeners();
    } catch (error) {
      _logger.e("Error in addNewArrival: $error");
    }
  }

  // Method to delete a product from the list
  Future<void> deleteProduct(Product product, String category) async {
    try {
      if (category == 'recommended') {
        _recommended.removeWhere((p) => p.id == product.id);
      } else if (category == 'deals') {
        _deals.removeWhere((p) => p.id == product.id);
      } else if (category == 'newArrivals') {
        _newArrivals.removeWhere((p) => p.id == product.id);
      }

      // Delete the product from Firestore using its id if available.
      if (product.id.isNotEmpty) {
        await _firestore.collection(category).doc(product.id).delete();
      } else {
        final collection = _firestore.collection(category);
        final productDocs =
            await collection.where('title', isEqualTo: product.title).get();
        if (productDocs.docs.isNotEmpty) {
          await productDocs.docs.first.reference.delete();
        }
      }
      notifyListeners();
    } catch (error) {
      _logger.e("Error deleting product: $error");
    }
  }
}
