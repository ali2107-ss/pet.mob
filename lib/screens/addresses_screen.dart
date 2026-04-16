import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../providers/address_provider.dart';
import '../models/address_model.dart';
import '../theme.dart';

class AddressesScreen extends StatefulWidget {
  const AddressesScreen({super.key});

  @override
  State<AddressesScreen> createState() => _AddressesScreenState();
}

class _AddressesScreenState extends State<AddressesScreen> {
  static const List<String> _kazakhstanCities = [
    'Алматы',
    'Астана',
    'Шымкент',
    'Караганда',
    'Актобе',
    'Тараз',
    'Павлодар',
    'Усть-Каменогорск',
    'Семей',
    'Атырау',
    'Костанай',
    'Кызылорда',
    'Уральск',
    'Петропавловск',
    'Туркестан',
    'Актау',
    'Темиртау',
    'Талдыкорган',
    'Экибастуз',
    'Рудны',
  ];

  @override
  void initState() {
    super.initState();
    Future.microtask(
      () =>
          Provider.of<AddressProvider>(context, listen: false).fetchAddresses(),
    );
  }

  @override
  Widget build(BuildContext context) {
    final addressProvider = Provider.of<AddressProvider>(context);
    final addresses = addressProvider.addresses;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Жеткізу мекенжайлары'),
        centerTitle: true,
      ),
      body: addresses.isEmpty
          ? const Center(child: Text('У вас пока нет сохраненных адресов'))
          : ListView.builder(
              padding: const EdgeInsets.all(20),
              itemCount: addresses.length,
              itemBuilder: (ctx, i) {
                final address = addresses[i];
                final isPrimary = address.isDefault;
                return Container(
                  margin: const EdgeInsets.only(bottom: 16),
                  decoration: BoxDecoration(
                    color: Theme.of(context).cardTheme.color ?? Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: isPrimary
                          ? AppTheme.primaryColor
                          : Colors.transparent,
                      width: 2,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.04),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: ListTile(
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 20,
                      vertical: 12,
                    ),
                    leading: Icon(
                      Icons.location_on,
                      color: isPrimary
                          ? AppTheme.primaryColor
                          : AppTheme.greyColor,
                    ),
                    title: Text(
                      address.title,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                    subtitle: Text(
                      '${address.city}, ${address.street}, ${address.house}-${address.apartment}',
                      style: const TextStyle(color: AppTheme.greyColor),
                    ),
                    trailing: PopupMenuButton<String>(
                      onSelected: (value) {
                        if (value == 'delete') {
                          addressProvider.deleteAddress(address.id!);
                        } else if (value == 'default') {
                          addressProvider.setDefaultAddress(address.id!);
                        }
                      },
                      itemBuilder: (BuildContext context) => [
                        const PopupMenuItem(
                          value: 'default',
                          child: Row(
                            children: [
                              Icon(
                                Icons.check_circle_outline,
                                color: AppTheme.primaryColor,
                              ),
                              SizedBox(width: 8),
                              Text('Сделать основным'),
                            ],
                          ),
                        ),
                        const PopupMenuItem(
                          value: 'delete',
                          child: Row(
                            children: [
                              Icon(Icons.delete_outline, color: Colors.red),
                              SizedBox(width: 8),
                              Text(
                                'Удалить',
                                style: TextStyle(color: Colors.red),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    onTap: () {
                      addressProvider.setDefaultAddress(address.id!);
                    },
                  ),
                );
              },
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showAddAddressDialog(context),
        backgroundColor: AppTheme.primaryColor,
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }

  void _showAddAddressDialog(BuildContext context) {
    final titleController = TextEditingController();
    String? selectedCity = _kazakhstanCities[0];
    final streetController = TextEditingController();
    final houseController = TextEditingController();
    final aptController = TextEditingController();

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: const Text('Новый адрес'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: titleController,
                  decoration: const InputDecoration(
                    labelText: 'Название (напр. Дом)',
                  ),
                ),
                const SizedBox(height: 16),
                DropdownButtonFormField<String>(
                  value: selectedCity,
                  decoration: const InputDecoration(labelText: 'Город'),
                  items: _kazakhstanCities
                      .map(
                        (city) =>
                            DropdownMenuItem(value: city, child: Text(city)),
                      )
                      .toList(),
                  onChanged: (val) => setDialogState(() => selectedCity = val),
                ),
                TextField(
                  controller: streetController,
                  decoration: const InputDecoration(labelText: 'Улица'),
                ),
                TextField(
                  controller: houseController,
                  decoration: const InputDecoration(labelText: 'Дом'),
                ),
                TextField(
                  controller: aptController,
                  decoration: const InputDecoration(labelText: 'Квартира'),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('Отмена'),
            ),
            TextButton(
              onPressed: () {
                final address = AddressModel(
                  user_id: Supabase.instance.client.auth.currentUser!.id,
                  title: titleController.text,
                  city: selectedCity ?? '',
                  street: streetController.text,
                  house: houseController.text,
                  apartment: aptController.text,
                );
                Provider.of<AddressProvider>(
                  context,
                  listen: false,
                ).addAddress(address);
                Navigator.pop(ctx);
              },
              child: const Text('Добавить'),
            ),
          ],
        ),
      ),
    );
  }
}
