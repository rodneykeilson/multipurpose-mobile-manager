import 'package:cloud_firestore/cloud_firestore.dart';
import 'product.dart';

class FirestoreService {
  static final FirebaseFirestore _db = FirebaseFirestore.instance;

  // Products Collection Reference
  static final CollectionReference productCollection =
      _db.collection('products');

  // Add Product
  static Future<void> addProduct(Product product) async {
    try {
      await productCollection.add(product.toMap());
    } catch (e) {
      throw Exception('Failed to add product: $e');
    }
  }

  // Fetch All Products
  static Future<List<Product>> fetchAllProducts() async {
    try {
      final querySnapshot = await productCollection.get();
      return querySnapshot.docs
          .map((doc) =>
              Product.fromMap(doc.data() as Map<String, dynamic>)..id = doc.id)
          .toList();
    } catch (e) {
      throw Exception('Failed to fetch products: $e');
    }
  }

  // Update Product
  static Future<void> updateProduct(Product product) async {
    try {
      await productCollection.doc(product.id).update(product.toMap());
    } catch (e) {
      throw Exception('Failed to update product: $e');
    }
  }

  // Delete Product
  static Future<void> deleteProduct(String id) async {
    try {
      await productCollection.doc(id).delete();
    } catch (e) {
      throw Exception('Failed to delete product: $e');
    }
  }

  // Stream Products
  Stream<List<Product>> getProductsStream() {
    return productCollection.snapshots().map((snapshot) {
      return snapshot.docs
          .map((doc) =>
              Product.fromMap(doc.data() as Map<String, dynamic>)..id = doc.id)
          .toList();
    });
  }

  Future<void> updateProductQuantity(
      String productId, int remainingQuantity) async {
    try {
      print('Updating product with ID: $productId');
      print('Remaining Quantity: $remainingQuantity');

      await _db.collection('products').doc(productId).update({
        'jumlah_barang': remainingQuantity,
      });

      print('Product quantity updated successfully!');
    } catch (e) {
      print("Error updating product quantity: $e");
    }
  }

  Future<void> addPurchaseToRevenue(Map<String, dynamic> purchaseData) async {
    try {
      await _db.collection('revenue').add({
        'customer_name': purchaseData['customer_name'],
        'description': purchaseData['description'],
        'quantity': purchaseData['quantity'],
        'unit_price': purchaseData['unit_price'],
        'total_price': purchaseData['total_price'],
        'timestamp': purchaseData['timestamp'],
      });
    } catch (e) {
      print("Error adding purchase to revenue: $e");
    }
  }
}
