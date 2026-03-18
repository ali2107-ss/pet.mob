import 'package:flutter/material.dart';
import '../theme.dart';

class PaymentMethodsScreen extends StatefulWidget {
  const PaymentMethodsScreen({super.key});

  @override
  State<PaymentMethodsScreen> createState() => _PaymentMethodsScreenState();
}

class _PaymentMethodsScreenState extends State<PaymentMethodsScreen> {
  int _primaryIndex = 0;
  final List<Map<String, String>> _cards = [
    {
      'type': 'Kaspi Gold',
      'number': '**** 4567',
    },
    {
      'type': 'Halyk Bank',
      'number': '**** 8901',
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Төлем тәсілдері'),
        centerTitle: true,
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(20),
        itemCount: _cards.length,
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
                Icons.credit_card,
                color: isPrimary ? AppTheme.primaryColor : AppTheme.greyColor,
              ),
              title: Text(
                _cards[i]['type']!,
                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
              ),
              subtitle: Text(
                _cards[i]['number']!,
                style: const TextStyle(color: AppTheme.greyColor),
              ),
              trailing: IconButton(
                icon: const Icon(Icons.delete_outline),
                color: Colors.red,
                onPressed: () {
                  // Delete card
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
          // Add card
        },
        backgroundColor: AppTheme.primaryColor,
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }
}
