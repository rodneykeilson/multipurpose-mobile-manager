import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:multipurpose_mobile_manager/firestore_service.dart';
import 'package:multipurpose_mobile_manager/localizations.dart';
import 'package:multipurpose_mobile_manager/product.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:image/image.dart' as img;

class AddProductPage extends StatefulWidget {
  final Product? product;

  const AddProductPage({super.key, this.product});

  @override
  State<AddProductPage> createState() => _AddProductPageState();
}

class _AddProductPageState extends State<AddProductPage> {
  final _formKey = GlobalKey<FormState>();
  late String _namaBarang;
  late int _jumlahBarang;
  late double _price;
  String? _imageBase64; // Store image as base64 string
  File? _selectedImage;

  final ImagePicker _picker = ImagePicker();

  @override
  void initState() {
    super.initState();
    _namaBarang = widget.product?.namaBarang ?? '';
    _jumlahBarang = widget.product?.jumlahBarang ?? 0;
    _price = widget.product?.price ?? 0.0;
    _imageBase64 = widget.product?.imageBase64;
  }

  Future<void> _pickImage(ImageSource source) async {
    final status = await _requestPermission(source);
    if (status.isGranted) {
      final pickedFile = await _picker.pickImage(source: source);
      if (pickedFile != null) {
        final compressedImage = await _compressImage(File(pickedFile.path));
        setState(() {
          _selectedImage = compressedImage;
          _imageBase64 = base64Encode(_selectedImage!.readAsBytesSync()); // Convert to base64
        });
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(AppLocalizations.of(context).translate('permissionDenied'))),
      );
    }
  }

  Future<PermissionStatus> _requestPermission(ImageSource source) async {
    if (source == ImageSource.camera) {
      return await Permission.camera.request();
    } else {
      return await Permission.photos.request();
    }
  }

  Future<File> _compressImage(File file) async {
    final imageBytes = await file.readAsBytes();
    final originalImage = img.decodeImage(imageBytes);
    final compressedImage = img.encodeJpg(originalImage!, quality: 50);

    final tempDir = await getTemporaryDirectory();
    final compressedFile = File('${tempDir.path}/compressed_image.jpg');
    await compressedFile.writeAsBytes(compressedImage);

    return compressedFile;
  }

  Future<void> _saveProduct() async {
    if (_formKey.currentState!.validate()) {
      final now = DateTime.now();
      final product = Product(
        id: widget.product?.id,
        namaBarang: _namaBarang,
        jumlahBarang: _jumlahBarang,
        price: _price,
        imageBase64: _imageBase64,
        createdAt: widget.product?.createdAt ?? now,
        updatedAt: now,
      );

      try {
        if (product.id != null) {
          await FirestoreService.updateProduct(product);
        } else {
          await FirestoreService.addProduct(product);
        }
        Navigator.of(context).pop();
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('${AppLocalizations.of(context).translate('error')}: ${e.toString()}')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.product != null
            ? AppLocalizations.of(context).translate('edit_product')
            : AppLocalizations.of(context).translate('add_product')),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(
                initialValue: _namaBarang,
                decoration: InputDecoration(labelText: AppLocalizations.of(context).translate('product_name')),
                onChanged: (value) => _namaBarang = value,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return AppLocalizations.of(context).translate('error_product_name');
                  }
                  return null;
                },
              ),
              TextFormField(
                initialValue: _jumlahBarang.toString(),
                decoration: InputDecoration(labelText: AppLocalizations.of(context).translate('quantity')),
                keyboardType: TextInputType.number,
                onChanged: (value) => _jumlahBarang = int.tryParse(value) ?? 0,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return AppLocalizations.of(context).translate('error_quantity');
                  }
                  return null;
                },
              ),
              TextFormField(
                initialValue: _price.toString(),
                decoration: InputDecoration(labelText: AppLocalizations.of(context).translate('price')),
                keyboardType: TextInputType.number,
                onChanged: (value) => _price = double.tryParse(value) ?? 0.0,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return AppLocalizations.of(context).translate('error_price');
                  }
                  return null;
                },
              ),
              const SizedBox(height: 10),
              if (_imageBase64 != null)
                Image.memory(
                  base64Decode(_imageBase64!),
                  height: 100,
                  width: 100,
                  fit: BoxFit.cover,
                )
              else
                Text(AppLocalizations.of(context).translate('no_image')),
              const SizedBox(height: 10),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  ElevatedButton.icon(
                    onPressed: () => _pickImage(ImageSource.camera),
                    icon: const Icon(Icons.camera),
                    label: Text(AppLocalizations.of(context).translate('camera')),
                  ),
                  ElevatedButton.icon(
                    onPressed: () => _pickImage(ImageSource.gallery),
                    icon: const Icon(Icons.photo_library),
                    label: Text(AppLocalizations.of(context).translate('gallery')),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: _saveProduct,
                child: Text(widget.product != null
                    ? AppLocalizations.of(context).translate('save_changes')
                    : AppLocalizations.of(context).translate('add_product')),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
