import 'package:flutter/material.dart';
import '../theme.dart';

class AddressesScreen extends StatefulWidget {
  const AddressesScreen({Key? key}) : super(key: key);

  @override
  State<AddressesScreen> createState() => _AddressesScreenState();
}

class _AddressesScreenState extends State<AddressesScreen> {
  int _primaryIndex = 0;
  final List<Map<String, String>> _addresses = [
    {
      'title': 'Үй',
      'address': 'Алматы қ., Абай даңғылы, 105',
    },
    {
      'title': 'Жұмыс',
      'address': 'Алматы қ., Сәтбаев көшесі, 90',
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Жеткізу мекенжайлары'),
        centerTitle: true,
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(20),
        itemCount: _addresses.length,
        itemBuilder: (ctx, i) {
          final isPrimary = _primaryIndex == i;
          return Container(
            margin: const EdgeInsets.only(bottom: 16),
            decoration: BoxDecoration(
              color: Theme.of(context).cardTheme.color ?? Colors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: isPrimary ? AppTheme.primaryColor : Colors.transparent,
                width: 2,
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.04),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                )
              ],
            ),
            child: ListTile(
              contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              leading: Icon(
                Icons.location_on,
                color: isPrimary ? AppTheme.primaryColor : AppTheme.greyColor,
              ),
              title: Text(
                _addresses[i]['title']!,
                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
              ),
              subtitle: Text(
                _addresses[i]['address']!,
                style: const TextStyle(color: AppTheme.greyColor),
              ),
              trailing: IconButton(
                icon: const Icon(Icons.edit_outlined),
                onPressed: () {
                  // Edit address
                },
              ),
              onTap: () {
                setState(() {
                  _primaryIndex = i;
                });
              },
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // Add address
        },
        backgroundColor: AppTheme.primaryColor,
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }
}
