import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AddCostPage extends StatefulWidget {
  final VoidCallback onCostAdded;

  const AddCostPage({super.key, required this.onCostAdded});

  @override
  _AddCostPageState createState() => _AddCostPageState();
}

class _AddCostPageState extends State<AddCostPage> {
  final _formKey = GlobalKey<FormState>();
  final _clientNameController = TextEditingController();
  final _productNameController = TextEditingController();
  final _quantityController = TextEditingController();
  final _unitPriceController = TextEditingController();
  double _totalPrice = 0.0;

  void _calculateTotalPrice() {
    final quantity = int.tryParse(_quantityController.text) ?? 0;
    final unitPrice = double.tryParse(_unitPriceController.text) ?? 0.0;
    setState(() {
      _totalPrice = quantity * unitPrice;
    });
  }

  Future<void> _addCost() async {
    if (_formKey.currentState!.validate()) {
      await FirebaseFirestore.instance.collection('costs').add({
        'client_name': _clientNameController.text,
        'product_name': _productNameController.text,
        'quantity': int.tryParse(_quantityController.text) ?? 0,
        'unit_price': double.tryParse(_unitPriceController.text) ?? 0.0,
        'total_price': _totalPrice,
        'timestamp': FieldValue.serverTimestamp(),
      });

      widget.onCostAdded();
      Navigator.of(context).pop();
    }
  }

  @override
  void dispose() {
    _clientNameController.dispose();
    _productNameController.dispose();
    _quantityController.dispose();
    _unitPriceController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Add Cost'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              TextFormField(
                controller: _clientNameController,
                decoration: const InputDecoration(labelText: 'Client Name'),
                validator: (value) =>
                    value == null || value.isEmpty ? 'Please enter client name' : null,
              ),
              TextFormField(
                controller: _productNameController,
                decoration: const InputDecoration(labelText: 'Product Name'),
                validator: (value) =>
                    value == null || value.isEmpty ? 'Please enter product name' : null,
              ),
              TextFormField(
                controller: _quantityController,
                decoration: const InputDecoration(labelText: 'Quantity'),
                keyboardType: TextInputType.number,
                validator: (value) =>
                    value == null || int.tryParse(value) == null ? 'Please enter a valid quantity' : null,
                onChanged: (value) => _calculateTotalPrice(),
              ),
              TextFormField(
                controller: _unitPriceController,
                decoration: const InputDecoration(labelText: 'Unit Price'),
                keyboardType: TextInputType.number,
                validator: (value) =>
                    value == null || double.tryParse(value) == null ? 'Please enter a valid price' : null,
                onChanged: (value) => _calculateTotalPrice(),
              ),
              const SizedBox(height: 20),
              Text(
                'Total Price: Rp. $_totalPrice',
                style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: _addCost,
                child: const Text('Add Cost'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
