import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:multipurpose_mobile_manager/firestore_service.dart';
import 'package:multipurpose_mobile_manager/localizations.dart';
import 'package:multipurpose_mobile_manager/product.dart';
import 'add_product_page.dart';

class PersediaanBarangPage extends StatefulWidget {
  const PersediaanBarangPage({super.key});

  @override
  State<PersediaanBarangPage> createState() => _PersediaanBarangPageState();
}

class _PersediaanBarangPageState extends State<PersediaanBarangPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(AppLocalizations.of(context).translate('productList'))),
      body: StreamBuilder<List<Product>>(
        stream: FirestoreService().getProductsStream(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(
              child: Text(AppLocalizations.of(context)
                  .translate('errorLoadingData')
                  .replaceFirst('{error}', snapshot.error.toString())),
            );
          }
          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return Center(child: Text(AppLocalizations.of(context).translate('noProducts')));
          }

          final products = snapshot.data!;
          return ListView.builder(
            itemCount: products.length,
            itemBuilder: (context, index) {
              final product = products[index];
              return ListTile(
                leading: product.imageBase64 != null
                    ? Image.memory(
                        base64Decode(product.imageBase64!),
                        height: 50,
                        width: 50,
                        fit: BoxFit.cover,
                      )
                    : const Icon(
                        Icons.image_not_supported,
                        size: 50,
                        color: Colors.grey,
                      ),
                title: Text(product.namaBarang),
                subtitle: Text(
                  '${AppLocalizations.of(context).translate('quantity')}: ${product.jumlahBarang}, '
                  '${AppLocalizations.of(context).translate('price')}: ${product.price.toStringAsFixed(2)}',
                ),
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(
                      icon: const Icon(Icons.edit),
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => AddProductPage(product: product),
                          ),
                        );
                      },
                    ),
                    IconButton(
                      icon: const Icon(Icons.shopping_cart, color: Colors.green),
                      onPressed: () => _showPurchaseDialog(product),
                    ),
                  ],
                ),
                onLongPress: () async {
                  final confirm = await _showDeleteConfirmationDialog(product);
                  if (confirm == true) {
                    await FirestoreService.deleteProduct(product.id!);
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text(AppLocalizations.of(context).translate('productDeleted'))),
                    );
                  }
                },
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        child: const Icon(Icons.add),
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const AddProductPage()),
          );
        },
      ),
    );
  }

  Future<bool?> _showDeleteConfirmationDialog(Product product) {
    return showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(AppLocalizations.of(context).translate('deleteProduct')),
          content: Text(AppLocalizations.of(context)
              .translate('deleteConfirmation')
              .replaceFirst('{product}', product.namaBarang)),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: Text(AppLocalizations.of(context).translate('cancel')),
            ),
            TextButton(
              onPressed: () => Navigator.of(context).pop(true),
              child: Text(AppLocalizations.of(context).translate('delete')),
            ),
          ],
        );
      },
    );
  }

  void _showPurchaseDialog(Product product) {
    final TextEditingController buyerController = TextEditingController();
    final TextEditingController quantityController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(AppLocalizations.of(context).translate('purchaseItem')),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextFormField(
                controller: buyerController,
                decoration: InputDecoration(
                    labelText: AppLocalizations.of(context).translate('buyerName')),
              ),
              TextFormField(
                controller: quantityController,
                decoration: InputDecoration(
                    labelText: AppLocalizations.of(context).translate('quantity')),
                keyboardType: TextInputType.number,
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text(AppLocalizations.of(context).translate('cancel')),
            ),
            TextButton(
              onPressed: () {
                final int purchaseQuantity =
                    int.tryParse(quantityController.text) ?? 0;
                if (purchaseQuantity <= 0 ||
                    purchaseQuantity > (product.jumlahBarang ?? 0)) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(AppLocalizations.of(context).translate('invalidQuantity')),
                    ),
                  );
                  return;
                }

                _processPurchase(product, buyerController.text.trim(), purchaseQuantity);
                Navigator.of(context).pop();
              },
              child: Text(AppLocalizations.of(context).translate('purchase')),
            ),
          ],
        );
      },
    );
  }

  Future<void> _processPurchase(Product product, String buyer, int quantity) async {
    final int remainingQuantity = (product.jumlahBarang ?? 0) - quantity;

    await FirestoreService().updateProductQuantity(product.id!, remainingQuantity);

    await FirestoreService().addPurchaseToRevenue({
      'customer_name': buyer,
      'description': product.namaBarang,
      'quantity': quantity,
      'unit_price': product.price,
      'total_price': product.price * quantity,
      'timestamp': DateTime.now(),
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(AppLocalizations.of(context).translate('purchaseSuccess'))),
    );
  }
}
