import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:image/image.dart' as img;
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import 'package:multipurpose_mobile_manager/localizations.dart';
import 'package:permission_handler/permission_handler.dart';

class DataKaryawanPage extends StatefulWidget {
  @override
  _DataKaryawanPageState createState() => _DataKaryawanPageState();
}

class _DataKaryawanPageState extends State<DataKaryawanPage> {
  final _firestore = FirebaseFirestore.instance;

  Future<String?> _resizeAndEncodeImage(Uint8List imageBytes) async {
    final decodedImage = img.decodeImage(imageBytes);
    if (decodedImage == null) return null;

    final resizedImage = img.copyResize(decodedImage, width: 200, height: 200);
    final resizedBytes = img.encodePng(resizedImage);
    return base64Encode(resizedBytes);
  }

  Future<void> _addKaryawan(String nama, String posisi,
      String tanggalMulaiKerja, String? imageBase64) async {
    await _firestore.collection('employees').add({
      'nama_karyawan': nama,
      'posisi': posisi,
      'tanggal_mulai_kerja': tanggalMulaiKerja,
      'imageBase64': imageBase64,
      'attendance': {},
      'gaji_per_hari': 0.0, // Add empty gaji_per_hari field
    });
  }

  Future<void> _editAttendance(
      String employeeId, String date, String status) async {
    final employeeDoc = _firestore.collection('employees').doc(employeeId);
    final employeeSnapshot = await employeeDoc.get();
    final currentAttendance = employeeSnapshot.data()?['attendance'] ?? {};
    currentAttendance[date] = status;

    await employeeDoc.update({'attendance': currentAttendance});
  }

  Future<void> _showAddKaryawanDialog() async {
    final nameController = TextEditingController();
    final positionController = TextEditingController();
    DateTime? selectedDate;
    String? imageBase64;

    showDialog(
      context: context,
      builder: (_) => StatefulBuilder(
        builder: (context, setState) {
          return AlertDialog(
            title: Text(AppLocalizations.of(context).translate('add_employee')),
            content: SingleChildScrollView(
              child: Column(
                children: [
                  TextField(
                    controller: nameController,
                    decoration: InputDecoration(labelText: AppLocalizations.of(context).translate('employee_name')),
                  ),
                  TextField(
                    controller: positionController,
                    decoration: InputDecoration(labelText: AppLocalizations.of(context).translate('position')),
                  ),
                  TextFormField(
                    readOnly: true,
                    decoration: InputDecoration(
                      labelText: AppLocalizations.of(context).translate('start_date'),
                      hintText: selectedDate == null
                          ? AppLocalizations.of(context).translate('select_date')
                          : DateFormat('yyyy-MM-dd').format(selectedDate!),
                    ),
                    onTap: () async {
                      final pickedDate = await showDatePicker(
                        context: context,
                        initialDate: selectedDate ?? DateTime.now(),
                        firstDate: DateTime(2000),
                        lastDate: DateTime.now(),
                      );
                      if (pickedDate != null) {
                        setState(() {
                          selectedDate = pickedDate;
                        });
                      }
                    },
                  ),
                  const SizedBox(height: 10),
                  ElevatedButton.icon(
                    onPressed: () async {
                      final status = await _requestPermission();
                      if (status.isGranted) {
                        final pickedFile = await ImagePicker()
                            .pickImage(source: ImageSource.gallery);
                        if (pickedFile != null) {
                          final bytes = await pickedFile.readAsBytes();
                          final resizedImage = await _resizeAndEncodeImage(bytes);
                          setState(() {
                            imageBase64 = resizedImage;
                          });
                        }
                      } else {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text(AppLocalizations.of(context).translate('permissionDenied'))),
                        );
                      }
                    },
                    icon: const Icon(Icons.image),
                    label: Text(AppLocalizations.of(context).translate('pick_image')),
                  ),
                  if (imageBase64 != null)
                    Image.memory(
                      base64Decode(imageBase64!),
                      height: 100,
                      width: 100,
                    ),
                ],
              ),
            ),
            actions: [
              TextButton(
                onPressed: () async {
                  if (selectedDate != null &&
                      nameController.text.isNotEmpty &&
                      positionController.text.isNotEmpty) {
                    await _addKaryawan(
                      nameController.text,
                      positionController.text,
                      DateFormat('yyyy-MM-dd').format(selectedDate!),
                      imageBase64,
                    );
                    Navigator.of(context).pop();
                  }
                },
                child: Text(AppLocalizations.of(context).translate('add')),
              ),
            ],
          );
        },
      ),
    );
  }

  Future<PermissionStatus> _requestPermission() async {
    return await Permission.photos.request();
  }

  void _showAttendanceCalendar(String employeeId) {
    final currentDate = DateTime.now();
    final firstDayOfMonth = DateTime(currentDate.year, currentDate.month, 1);
    final lastDayOfMonth = DateTime(currentDate.year, currentDate.month + 1, 0);

    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Text(AppLocalizations.of(context).translate('edit_attendance')),
        content: SingleChildScrollView(
          child: Column(
            children: List.generate(
              lastDayOfMonth.day,
              (index) {
                final date = DateFormat('yyyy-MM-dd')
                    .format(firstDayOfMonth.add(Duration(days: index)));
                return ListTile(
                  title: Text(date),
                  trailing: DropdownButton<String>(
                    value: "Present",
                    items: ["Present", "Absent"].map((String status) {
                      return DropdownMenuItem<String>(
                        value: status,
                        child: Text(AppLocalizations.of(context).translate(status.toLowerCase())),
                      );
                    }).toList(),
                    onChanged: (newStatus) {
                      if (newStatus != null) {
                        _editAttendance(employeeId, date, newStatus);
                      }
                    },
                  ),
                );
              },
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _updateKaryawan(String employeeId, String nama, String posisi,
      String tanggalMulaiKerja, String? imageBase64) async {
    await _firestore.collection('employees').doc(employeeId).update({
      'nama_karyawan': nama,
      'posisi': posisi,
      'tanggal_mulai_kerja': tanggalMulaiKerja,
      'imageBase64': imageBase64,
    });
  }

  Future<void> _deleteKaryawan(String employeeId) async {
    await _firestore.collection('employees').doc(employeeId).delete();
  }

  void _showEditKaryawanDialog(DocumentSnapshot employee) {
    final nameController =
        TextEditingController(text: employee['nama_karyawan']);
    final positionController = TextEditingController(text: employee['posisi']);
    DateTime selectedDate = DateTime.parse(employee['tanggal_mulai_kerja']);
    String? imageBase64 = employee['imageBase64'];

    showDialog(
      context: context,
      builder: (_) => StatefulBuilder(
        builder: (context, setState) {
          return AlertDialog(
            title: Text(AppLocalizations.of(context).translate('edit_employee')),
            content: SingleChildScrollView(
              child: Column(
                children: [
                  TextField(
                    controller: nameController,
                    decoration: InputDecoration(labelText: AppLocalizations.of(context).translate('employee_name')),
                  ),
                  TextField(
                    controller: positionController,
                    decoration: InputDecoration(labelText: AppLocalizations.of(context).translate('position')),
                  ),
                  TextFormField(
                    readOnly: true,
                    decoration: InputDecoration(
                      labelText: AppLocalizations.of(context).translate('start_date'),
                      hintText: DateFormat('yyyy-MM-dd').format(selectedDate),
                    ),
                    onTap: () async {
                      final pickedDate = await showDatePicker(
                        context: context,
                        initialDate: selectedDate,
                        firstDate: DateTime(2000),
                        lastDate: DateTime.now(),
                      );
                      if (pickedDate != null) {
                        setState(() {
                          selectedDate = pickedDate;
                        });
                      }
                    },
                  ),
                  const SizedBox(height: 10),
                  ElevatedButton.icon(
                    onPressed: () async {
                      final status = await _requestPermission();
                      if (status.isGranted) {
                        final pickedFile = await ImagePicker()
                            .pickImage(source: ImageSource.gallery);
                        if (pickedFile != null) {
                          final bytes = await pickedFile.readAsBytes();
                          final resizedImage = await _resizeAndEncodeImage(bytes);
                          setState(() {
                            imageBase64 = resizedImage;
                          });
                        }
                      } else {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text(AppLocalizations.of(context).translate('permissionDenied'))),
                        );
                      }
                    },
                    icon: const Icon(Icons.image),
                    label: Text(AppLocalizations.of(context).translate('pick_new_image')),
                  ),
                  if (imageBase64 != null)
                    Image.memory(
                      base64Decode(imageBase64!),
                      height: 100,
                      width: 100,
                    ),
                ],
              ),
            ),
            actions: [
              TextButton(
                onPressed: () async {
                  if (nameController.text.isNotEmpty &&
                      positionController.text.isNotEmpty) {
                    await _updateKaryawan(
                      employee.id,
                      nameController.text,
                      positionController.text,
                      DateFormat('yyyy-MM-dd').format(selectedDate),
                      imageBase64,
                    );
                    Navigator.of(context).pop();
                  }
                },
                child: Text(AppLocalizations.of(context).translate('update')),
              ),
            ],
          );
        },
      ),
    );
  }

  void _confirmDeleteKaryawan(String employeeId) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Text(AppLocalizations.of(context).translate('confirm_delete')),
        content: Text(AppLocalizations.of(context).translate('confirm_delete_message')),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text(AppLocalizations.of(context).translate('cancel')),
          ),
          TextButton(
            onPressed: () async {
              await _deleteKaryawan(employeeId);
              Navigator.of(context).pop();
            },
            child: Text(AppLocalizations.of(context).translate('delete')),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(AppLocalizations.of(context).translate('employee_list'))),
      body: StreamBuilder<QuerySnapshot>(
        stream: _firestore.collection('employees').snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }
          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return Center(child: Text(AppLocalizations.of(context).translate('no_employees_found')));
          }

          final employees = snapshot.data!.docs;
          return ListView.builder(
            itemCount: employees.length,
            itemBuilder: (context, index) {
              final employee = employees[index].data() as Map<String, dynamic>;
              final lamaBekerja = DateTime.now()
                      .difference(
                          DateTime.parse(employee['tanggal_mulai_kerja']))
                      .inDays ~/
                  365;

              return Card(
                child: ListTile(
                  leading: employee['imageBase64'] != null
                      ? Image.memory(
                          base64Decode(employee['imageBase64']),
                          height: 50,
                          width: 50,
                          fit: BoxFit.cover,
                        )
                      : const Icon(Icons.person, size: 50, color: Colors.grey),
                  title: Text(employee['nama_karyawan']),
                  subtitle: Text(
                      "${AppLocalizations.of(context).translate('position')}: ${employee['posisi']}\n${AppLocalizations.of(context).translate('work_duration')}: $lamaBekerja ${AppLocalizations.of(context).translate('years')}"),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon: Icon(Icons.edit, color: Colors.blue),
                        onPressed: () =>
                            _showEditKaryawanDialog(employees[index]),
                      ),
                      IconButton(
                        icon: Icon(Icons.delete, color: Colors.red),
                        onPressed: () =>
                            _confirmDeleteKaryawan(employees[index].id),
                      ),
                    ],
                  ),
                  onTap: () => {}, // Placeholder for additional functionality
                ),
              );
            },
          );
        },

      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          await _showAddKaryawanDialog();
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}
