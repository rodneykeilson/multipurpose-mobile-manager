import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:multipurpose_mobile_manager/localizations.dart';
import 'dart:convert'; // To decode the base64 string

class DataGajiKaryawanPage extends StatefulWidget {
  @override
  _DataGajiKaryawanPageState createState() => _DataGajiKaryawanPageState();
}

class _DataGajiKaryawanPageState extends State<DataGajiKaryawanPage> {
  List<Map<String, dynamic>> _karyawanList = [];
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    _fetchKaryawanList();
  }

  // Fetch employees from Firestore
  Future<void> _fetchKaryawanList() async {
    final snapshot =
        await FirebaseFirestore.instance.collection('employees').get();

    setState(() {
      _karyawanList = snapshot.docs.map((doc) {
        return {
          'id': doc.id,
          'nama_karyawan': doc['nama_karyawan'],
          'imageBase64': doc['imageBase64'], // Add imageBase64 if available
          'gaji_per_hari': doc['gaji_per_hari'] ?? 0.0, // Load daily salary if available
        };
      }).toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    final filteredKaryawanList = _karyawanList
        .where((karyawan) => karyawan['nama_karyawan']
            .toLowerCase()
            .contains(_searchQuery.toLowerCase()))
        .toList();

    return Scaffold(
      appBar: AppBar(
        title:
            Text(AppLocalizations.of(context).translate('data_gaji_karyawan')),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
              decoration: InputDecoration(
                labelText: AppLocalizations.of(context).translate('search'),
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.search),
              ),
              onChanged: (value) {
                setState(() {
                  _searchQuery = value;
                });
              },
            ),
          ),
          Expanded(
            child: ListView.builder(
              itemCount: filteredKaryawanList.length,
              itemBuilder: (context, index) {
                final karyawan = filteredKaryawanList[index];
                return EmployeeCard(karyawan: karyawan);
              },
            ),
          ),
        ],
      ),
    );
  }
}

class EmployeeCard extends StatefulWidget {
  final Map<String, dynamic> karyawan;

  EmployeeCard({required this.karyawan});

  @override
  _EmployeeCardState createState() => _EmployeeCardState();
}

class _EmployeeCardState extends State<EmployeeCard> {
  final attendanceController = TextEditingController();
  final gajiController = TextEditingController();
  double? calculatedSalary;

  @override
  void initState() {
    super.initState();
    gajiController.text = widget.karyawan['gaji_per_hari'].toString();
  }

  double _calculateSalary(int attendanceTotal, double gajiPerHari) {
    return attendanceTotal * gajiPerHari;
  }

  Future<void> _saveDailySalary(String employeeId, double gajiPerHari) async {
    try {
      await FirebaseFirestore.instance
          .collection('employees')
          .doc(employeeId)
          .update({'gaji_per_hari': gajiPerHari});
    } catch (e) {
      print("Error saving daily salary: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    final namaKaryawan = widget.karyawan['nama_karyawan'];
    final imageBase64 = widget.karyawan['imageBase64'];

    return Card(
      margin: EdgeInsets.all(8.0),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Row(
              children: [
                // Employee photo (decoded from base64)
                CircleAvatar(
                  radius: 20,
                  backgroundImage: imageBase64 != null
                      ? MemoryImage(base64Decode(
                          imageBase64)) // Decode and display base64 image
                      : AssetImage('assets/placeholder.png') as ImageProvider,
                  backgroundColor: Colors.grey[200],
                ),
                SizedBox(width: 16),
                // Employee name
                Text(
                  namaKaryawan,
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
              ],
            ),
            SizedBox(height: 16),
            // Row with two text fields
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: attendanceController,
                    decoration: InputDecoration(
                      labelText: AppLocalizations.of(context)
                          .translate('total_kehadiran'),
                      border: OutlineInputBorder(),
                    ),
                    keyboardType: TextInputType.number,
                  ),
                ),
                SizedBox(width: 16),
                Expanded(
                  child: TextField(
                    controller: gajiController,
                    decoration: InputDecoration(
                      labelText: AppLocalizations.of(context)
                          .translate('gaji_per_hari'),
                      border: OutlineInputBorder(),
                    ),
                    keyboardType: TextInputType.number,
                    onChanged: (value) {
                      final gajiPerHari = double.tryParse(value) ?? 0.0;
                      _saveDailySalary(widget.karyawan['id'], gajiPerHari);
                    },
                  ),
                ),
              ],
            ),
            SizedBox(height: 16),
            // Row with calculate button and calculated salary
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                ElevatedButton(
                  onPressed: () {
                    final attendanceTotal =
                        int.tryParse(attendanceController.text) ?? 0;
                    final gajiPerHari =
                        double.tryParse(gajiController.text) ?? 0;

                    setState(() {
                      calculatedSalary =
                          _calculateSalary(attendanceTotal, gajiPerHari);
                    });
                  },
                  child: Text(AppLocalizations.of(context).translate('hitung')),
                ),
                if (calculatedSalary != null)
                  Text(
                    "Rp ${calculatedSalary!.toStringAsFixed(2)}",
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class KaryawanSearchDelegate extends SearchDelegate {
  final Function(String) onQueryChanged;

  KaryawanSearchDelegate(this.onQueryChanged);

  @override
  List<Widget>? buildActions(BuildContext context) {
    return [
      IconButton(
        icon: Icon(Icons.clear),
        onPressed: () {
          query = '';
          onQueryChanged(query);
        },
      ),
    ];
  }

  @override
  Widget? buildLeading(BuildContext context) {
    return IconButton(
      icon: Icon(Icons.arrow_back),
      onPressed: () {
        close(context, null);
      },
    );
  }

  @override
  Widget buildResults(BuildContext context) {
    onQueryChanged(query);
    close(context, null);
    return Container();
  }

  @override
  Widget buildSuggestions(BuildContext context) {
    onQueryChanged(query);
    return Container();
  }
}
