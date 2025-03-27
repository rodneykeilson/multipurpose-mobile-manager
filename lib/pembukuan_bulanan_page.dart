import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:multipurpose_mobile_manager/add_pengeluaran_page.dart';
import 'package:multipurpose_mobile_manager/localizations.dart';

class PembukuanBulananPage extends StatefulWidget {
  const PembukuanBulananPage({super.key});

  @override
  State<PembukuanBulananPage> createState() => _PembukuanBulananPageState();
}

class _PembukuanBulananPageState extends State<PembukuanBulananPage> {
  int _currentIndex = 0;

  final List<Widget> _pages = [const RevenuePage(), const CostPage()];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(AppLocalizations.of(context)!.translate('monthly_bookkeeping')),
      ),
      body: _pages[_currentIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        items: [
          BottomNavigationBarItem(
            icon: const Icon(Icons.attach_money),
            label: AppLocalizations.of(context)!.translate('revenue'),
          ),
          BottomNavigationBarItem(
            icon: const Icon(Icons.money_off),
            label: AppLocalizations.of(context)!.translate('expenses'),
          ),
        ],
        onTap: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
      ),
    );
  }
}

class RevenuePage extends StatefulWidget {
  const RevenuePage({super.key});

  @override
  State<RevenuePage> createState() => _RevenuePageState();
}

class _RevenuePageState extends State<RevenuePage> {
  final CollectionReference _revenueCollection =
      FirebaseFirestore.instance.collection('revenue');

  double _totalRevenue = 0.0;

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
      stream: _revenueCollection.snapshots(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(child: CircularProgressIndicator());
        }
        if (snapshot.hasError) {
          return Center(child: Text(AppLocalizations.of(context)!.translate('error_fetching_data')));
        }
        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
          return Center(child: Text(AppLocalizations.of(context)!.translate('no_revenue_recorded')));
        }

        final transactions = snapshot.data!.docs;

        // Calculate total revenue
        _totalRevenue = transactions.fold<double>(
          0.0,
          (sum, doc) {
            final data = doc.data() as Map<String, dynamic>;
            return sum + (data['total_price'] ?? 0.0);
          },
        );

        return Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Text(
                '${AppLocalizations.of(context)!.translate('total_monthly_revenue')}: Rp. $_totalRevenue',
                style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold),
              ),
            ),
            Expanded(
              child: SingleChildScrollView(
                child: DataTable(
                  columnSpacing: MediaQuery.of(context).size.width * 0.05,
                  columns: [
                    DataColumn(label: Text(AppLocalizations.of(context)!.translate('customer'), style: const TextStyle(fontSize: 11))),
                    DataColumn(label: Text(AppLocalizations.of(context)!.translate('product'), style: const TextStyle(fontSize: 11))),
                    DataColumn(label: Text(AppLocalizations.of(context)!.translate('quantity'), style: const TextStyle(fontSize: 11))),
                    DataColumn(label: Text(AppLocalizations.of(context)!.translate('unit_price'), style: const TextStyle(fontSize: 11))),
                    DataColumn(label: Text(AppLocalizations.of(context)!.translate('total_price'), style: const TextStyle(fontSize: 11))),
                  ],
                  rows: transactions.map((transaction) {
                    final data = transaction.data() as Map<String, dynamic>;
                    return DataRow(cells: [
                      DataCell(Text(data['customer_name'] ?? AppLocalizations.of(context)!.translate('no_name'), style: const TextStyle(fontSize: 11))),
                      DataCell(Text(data['description'] ?? '', style: const TextStyle(fontSize: 11))),
                      DataCell(Text('${data['quantity'] ?? 0}', style: const TextStyle(fontSize: 11))),
                      DataCell(Text('Rp. ${data['unit_price']?.toStringAsFixed(2) ?? '0.00'}', style: const TextStyle(fontSize: 11))),
                      DataCell(Text('Rp. ${data['total_price']?.toStringAsFixed(2) ?? '0.00'}', style: const TextStyle(fontSize: 11))),
                    ]);
                  }).toList(),
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}

class CostPage extends StatefulWidget {
  const CostPage({super.key});

  @override
  State<CostPage> createState() => _CostPageState();
}

class _CostPageState extends State<CostPage> {
  final CollectionReference _costsCollection =
      FirebaseFirestore.instance.collection('costs');

  double _totalCost = 0.0;
  List<QueryDocumentSnapshot<Map<String, dynamic>>> _costs = [];

  @override
  void initState() {
    super.initState();
    _loadCosts();
  }

  Future<void> _loadCosts() async {
    final snapshot = await _costsCollection.get();

    double totalCost = 0.0;
    final documents =
        snapshot.docs.cast<QueryDocumentSnapshot<Map<String, dynamic>>>();

    for (var doc in documents) {
      final costData = doc.data();
      totalCost += costData['total_price'] ?? 0.0;
    }

    setState(() {
      _costs = documents;
      _totalCost = totalCost;
    });
  }

  void _addCost() {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => AddCostPage(onCostAdded: _loadCosts),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Text(
              '${AppLocalizations.of(context)!.translate('total_monthly_cost')}: Rp. $_totalCost',
              style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold),
            ),
          ),
          Expanded(
            child: _costs.isEmpty
                ? Center(child: Text(AppLocalizations.of(context)!.translate('no_costs_found')))
                : SingleChildScrollView(
                    child: DataTable(
                      columnSpacing: MediaQuery.of(context).size.width * 0.07,
                      columns: [
                        DataColumn(label: Text(AppLocalizations.of(context)!.translate('client'), style: const TextStyle(fontSize: 11))),
                        DataColumn(label: Text(AppLocalizations.of(context)!.translate('product'), style: const TextStyle(fontSize: 11))),
                        DataColumn(label: Text(AppLocalizations.of(context)!.translate('quantity'), style: const TextStyle(fontSize: 11))),
                        DataColumn(label: Text(AppLocalizations.of(context)!.translate('unit_price'), style: const TextStyle(fontSize: 11))),
                        DataColumn(label: Text(AppLocalizations.of(context)!.translate('total_price'), style: const TextStyle(fontSize: 11))),
                      ],
                      rows: _costs.map((doc) {
                        final cost = doc.data();
                        return DataRow(cells: [
                          DataCell(Text(cost['client_name'] ?? AppLocalizations.of(context)!.translate('no_name'), style: const TextStyle(fontSize: 11))),
                          DataCell(Text(cost['product_name'] ?? '', style: const TextStyle(fontSize: 11))),
                          DataCell(Text('${cost['quantity'] ?? 0}', style: const TextStyle(fontSize: 11))),
                          DataCell(Text('Rp. ${cost['unit_price'] ?? 0}', style: const TextStyle(fontSize: 11))),
                          DataCell(Text('Rp. ${cost['total_price'] ?? 0}', style: const TextStyle(fontSize: 11))),
                        ]);
                      }).toList(),
                    ),
                  ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _addCost,
        child: const Icon(Icons.add),
      ),
    );
  }
}
