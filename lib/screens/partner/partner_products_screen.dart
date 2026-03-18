import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/partner_provider.dart';
import '../../theme.dart';

class PartnerProductsScreen extends StatelessWidget {
  const PartnerProductsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final partner = context.watch<PartnerProvider>();

    return Scaffold(
      backgroundColor: Colors.transparent,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        automaticallyImplyLeading: false,
        title: const Text('Мои товары', style: TextStyle(fontWeight: FontWeight.bold)),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showAddProductSheet(context),
        backgroundColor: AppTheme.primaryColor,
        icon: const Icon(Icons.add, color: Colors.white),
        label: const Text('Добавить товар', style: TextStyle(color: Colors.white)),
      ),
      body: partner.products.isEmpty
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.inventory_2_outlined, size: 80, color: AppTheme.greyColor.withOpacity(0.4)),
                  const SizedBox(height: 16),
                  const Text('У вас пока нет товаров', style: TextStyle(fontSize: 18, color: AppTheme.greyColor)),
                  const SizedBox(height: 8),
                  const Text('Нажмите + чтобы добавить', style: TextStyle(color: AppTheme.greyColor)),
                ],
              ),
            )
          : ListView.builder(
              padding: const EdgeInsets.fromLTRB(20, 20, 20, 100),
              itemCount: partner.products.length,
              itemBuilder: (context, index) {
                final p = partner.products[index];
                return Container(
                  margin: const EdgeInsets.only(bottom: 16),
                  decoration: BoxDecoration(
                    color: Theme.of(context).cardTheme.color ?? Colors.white,
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, 4))],
                  ),
                  child: Row(
                    children: [
                      ClipRRect(
                        borderRadius: const BorderRadius.horizontal(left: Radius.circular(20)),
                        child: Image.network(p.imageUrl, width: 100, height: 100, fit: BoxFit.cover,
                            errorBuilder: (_, _, _) => Container(width: 100, height: 100, color: Colors.grey[200],
                                child: const Icon(Icons.image_not_supported, color: Colors.grey))),
                      ),
                      Expanded(
                        child: Padding(
                          padding: const EdgeInsets.all(12),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(p.name, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15), maxLines: 1, overflow: TextOverflow.ellipsis),
                              const SizedBox(height: 4),
                              Text('₸${p.price.toStringAsFixed(0)}', style: const TextStyle(color: AppTheme.primaryColor, fontWeight: FontWeight.bold)),
                              const SizedBox(height: 4),
                              Row(
                                children: [
                                  _Badge(label: 'Склад: ${p.stock}', color: Colors.orange),
                                  const SizedBox(width: 6),
                                  _Badge(label: 'Продано: ${p.sold}', color: Colors.green),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.delete_outline, color: Colors.red),
                        onPressed: () {
                          showDialog(
                            context: context,
                            builder: (_) => AlertDialog(
                              title: const Text('Удалить товар?'),
                              content: Text('Удалить "${p.name}"?'),
                              actions: [
                                TextButton(onPressed: () => Navigator.pop(context), child: const Text('Отмена')),
                                TextButton(
                                  onPressed: () {
                                    context.read<PartnerProvider>().deleteProduct(p.id);
                                    Navigator.pop(context);
                                  },
                                  child: const Text('Удалить', style: TextStyle(color: Colors.red)),
                                ),
                              ],
                            ),
                          );
                        },
                      ),
                    ],
                  ),
                );
              },
            ),
    );
  }

  void _showAddProductSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (_) => const _AddProductSheet(),
    );
  }
}

class _Badge extends StatelessWidget {
  final String label;
  final Color color;
  const _Badge({required this.label, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(color: color.withOpacity(0.1), borderRadius: BorderRadius.circular(8)),
      child: Text(label, style: TextStyle(fontSize: 11, color: color, fontWeight: FontWeight.w600)),
    );
  }
}

class _AddProductSheet extends StatefulWidget {
  const _AddProductSheet();

  @override
  State<_AddProductSheet> createState() => _AddProductSheetState();
}

class _AddProductSheetState extends State<_AddProductSheet> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _descController = TextEditingController();
  final _priceController = TextEditingController();
  final _imageController = TextEditingController();
  final _stockController = TextEditingController();
  String _selectedCategory = 'Тамақ';

  final List<String> _categories = ['Тамақ', 'Ойыншықтар', 'Аксессуарлар', 'Гигиена', 'Киімдер'];

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom, left: 20, right: 20, top: 24),
      child: Form(
        key: _formKey,
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text('Новый товар', style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
              const SizedBox(height: 20),
              TextFormField(
                controller: _nameController,
                decoration: _inputDecoration('Название товара', Icons.label_outline),
                validator: (v) => v!.isEmpty ? 'Введите название' : null,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _descController,
                decoration: _inputDecoration('Описание', Icons.description_outlined),
                maxLines: 2,
                validator: (v) => v!.isEmpty ? 'Введите описание' : null,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _priceController,
                decoration: _inputDecoration('Цена (₸)', Icons.attach_money),
                keyboardType: TextInputType.number,
                validator: (v) => v!.isEmpty ? 'Введите цену' : null,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _stockController,
                decoration: _inputDecoration('Количество на складе', Icons.warehouse_outlined),
                keyboardType: TextInputType.number,
                validator: (v) => v!.isEmpty ? 'Введите количество' : null,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _imageController,
                decoration: _inputDecoration('Ссылка на фото (URL)', Icons.image_outlined),
                validator: (v) => v!.isEmpty ? 'Введите ссылку на фото' : null,
              ),
              const SizedBox(height: 12),
              DropdownButtonFormField<String>(
                initialValue: _selectedCategory,
                decoration: _inputDecoration('Категория', Icons.category_outlined),
                items: _categories.map((c) => DropdownMenuItem(value: c, child: Text(c))).toList(),
                onChanged: (v) => setState(() => _selectedCategory = v!),
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: _submit,
                style: ElevatedButton.styleFrom(padding: const EdgeInsets.symmetric(vertical: 16)),
                child: const Text('Добавить товар', style: TextStyle(fontSize: 16)),
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  InputDecoration _inputDecoration(String label, IconData icon) {
    return InputDecoration(
      labelText: label,
      prefixIcon: Icon(icon),
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
    );
  }

  void _submit() {
    if (_formKey.currentState?.validate() ?? false) {
      context.read<PartnerProvider>().addProduct(
            PartnerProduct(
              id: 'pp_${DateTime.now().millisecondsSinceEpoch}',
              name: _nameController.text,
              description: _descController.text,
              price: double.tryParse(_priceController.text) ?? 0,
              category: _selectedCategory,
              imageUrl: _imageController.text,
              stock: int.tryParse(_stockController.text) ?? 0,
            ),
          );
      Navigator.pop(context);
    }
  }
}
