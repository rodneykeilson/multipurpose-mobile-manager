import 'package:flutter/material.dart';

class ChangePinPage extends StatefulWidget {
  @override
  _ChangePinPageState createState() => _ChangePinPageState();
}

class _ChangePinPageState extends State<ChangePinPage> {
  final TextEditingController oldPinController = TextEditingController();
  final TextEditingController newPinController = TextEditingController();
  final TextEditingController confirmPinController = TextEditingController();

  String currentPin =
      '123456'; // Simulasi PIN saat ini, nanti bisa diambil dari storage.

  void changePin() {
    if (oldPinController.text != currentPin) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('PIN lama salah')),
      );
    } else if (newPinController.text != confirmPinController.text) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Konfirmasi PIN baru tidak cocok')),
      );
    } else if (newPinController.text.length != 6) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('PIN harus 6 digit')),
      );
    } else {
      setState(() {
        currentPin = newPinController.text;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('PIN berhasil diubah')),
      );
      Navigator.pop(context); // Kembali ke halaman sebelumnya.
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Ganti PIN'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TextField(
              controller: oldPinController,
              obscureText: true,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(labelText: 'Masukkan PIN lama'),
            ),
            TextField(
              controller: newPinController,
              obscureText: true,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(labelText: 'Masukkan PIN baru'),
            ),
            TextField(
              controller: confirmPinController,
              obscureText: true,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(labelText: 'Konfirmasi PIN baru'),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: changePin,
              child: Text('Simpan'),
            ),
          ],
        ),
      ),
    );
  }
}
