import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/partner_provider.dart';
import '../../theme.dart';
import '../../widgets/network_or_base64_image.dart';

class PartnerProductsScreen extends StatefulWidget {
  const PartnerProductsScreen({super.key});

  @override
  State<PartnerProductsScreen> createState() => _PartnerProductsScreenState();
}

class _PartnerProductsScreenState extends State<PartnerProductsScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _fabAnimController;

  @override
  void initState() {
    super.initState();
    _fabAnimController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
    _fabAnimController.forward();
  }

  @override
  void dispose() {
    _fabAnimController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final partner = context.watch<PartnerProvider>();

    return Scaffold(
      backgroundColor: Colors.transparent,
      floatingActionButton: ScaleTransition(
        scale: CurvedAnimation(
          parent: _fabAnimController,
          curve: Curves.elasticOut,
        ),
        child: FloatingActionButton.extended(
          onPressed: () => _showAddProductSheet(context),
          backgroundColor: AppTheme.primaryColor,
          icon: const Icon(Icons.add_rounded, color: Colors.white, size: 24),
          label: const Text(
            'Добавить',
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
          ),
          elevation: 8,
        ),
      ),
      body: partner.products.isEmpty
          ? _buildEmptyState()
          : _buildProductList(partner),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(32),
            decoration: BoxDecoration(
              color: AppTheme.primaryColor.withOpacity(0.08),
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.inventory_2_outlined,
              size: 80,
              color: AppTheme.primaryColor.withOpacity(0.5),
            ),
          ),
          const SizedBox(height: 24),
          const Text(
            'У вас пока нет товаров',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: AppTheme.textColor,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'Добавьте первый товар и он появится\nу покупателей в каталоге!',
            textAlign: TextAlign.center,
            style: TextStyle(color: AppTheme.greyColor, fontSize: 14),
          ),
          const SizedBox(height: 32),
          ElevatedButton.icon(
            onPressed: () => _showAddProductSheet(context),
            icon: const Icon(Icons.add_rounded),
            label: const Text('Добавить первый товар'),
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProductList(PartnerProvider partner) {
    return Column(
      children: [
        // Мини-статистика сверху
        Container(
          margin: const EdgeInsets.fromLTRB(20, 8, 20, 4),
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                AppTheme.primaryColor.withOpacity(0.1),
                AppTheme.primaryColor.withOpacity(0.05),
              ],
            ),
            borderRadius: BorderRadius.circular(16),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _MiniStat(
                label: 'Всего',
                value: '${partner.products.length}',
                icon: Icons.inventory_2,
              ),
              Container(
                width: 1,
                height: 30,
                color: AppTheme.greyColor.withOpacity(0.2),
              ),
              _MiniStat(
                label: 'Активных',
                value: '${partner.activeProducts}',
                icon: Icons.check_circle_outline,
              ),
              Container(
                width: 1,
                height: 30,
                color: AppTheme.greyColor.withOpacity(0.2),
              ),
              _MiniStat(
                label: 'Продано',
                value: '${partner.totalSold}',
                icon: Icons.shopping_bag_outlined,
              ),
            ],
          ),
        ),
        // Список товаров
        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.fromLTRB(20, 8, 20, 100),
            itemCount: partner.products.length,
            itemBuilder: (context, index) {
              final p = partner.products[index];
              return _ProductCard(
                product: p,
                index: index,
                onEdit: () => _showEditProductSheet(context, p),
                onDelete: () => _confirmDelete(context, p),
                onToggleActive: () {
                  context
                      .read<PartnerProvider>()
                      .toggleProductActiveWithSupabase(p.id);
                },
              );
            },
          ),
        ),
      ],
    );
  }

  void _showAddProductSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => const _ProductFormSheet(),
    );
  }

  void _showEditProductSheet(BuildContext context, PartnerProduct product) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => _ProductFormSheet(product: product),
    );
  }

  void _confirmDelete(BuildContext context, PartnerProduct product) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.red.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.delete_outline,
                color: Colors.red,
                size: 20,
              ),
            ),
            const SizedBox(width: 12),
            const Expanded(child: Text('Удалить товар?')),
          ],
        ),
        content: Text(
          'Товар "${product.name}" будет удалён из вашего магазина и каталога покупателей.',
          style: const TextStyle(fontSize: 14),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text(
              'Отмена',
              style: TextStyle(color: AppTheme.greyColor),
            ),
          ),
          ElevatedButton(
            onPressed: () async {
              await context.read<PartnerProvider>().deleteProductWithSupabase(
                product.id,
              );
              Navigator.pop(ctx);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Row(
                    children: [
                      const Icon(Icons.delete_outline, color: Colors.white),
                      const SizedBox(width: 8),
                      Text('«${product.name}» удалён'),
                    ],
                  ),
                  backgroundColor: Colors.red,
                  behavior: SnackBarBehavior.floating,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: const Text('Удалить'),
          ),
        ],
      ),
    );
  }
}

// Мини-статистика
class _MiniStat extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;

  const _MiniStat({
    required this.label,
    required this.value,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Icon(icon, size: 18, color: AppTheme.primaryColor),
        const SizedBox(height: 4),
        Text(
          value,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 16,
            color: AppTheme.textColor,
          ),
        ),
        Text(
          label,
          style: const TextStyle(fontSize: 11, color: AppTheme.greyColor),
        ),
      ],
    );
  }
}

// Карточка товара
class _ProductCard extends StatelessWidget {
  final PartnerProduct product;
  final int index;
  final VoidCallback onEdit;
  final VoidCallback onDelete;
  final VoidCallback onToggleActive;

  const _ProductCard({
    required this.product,
    required this.index,
    required this.onEdit,
    required this.onDelete,
    required this.onToggleActive,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedOpacity(
      opacity: product.isActive ? 1.0 : 0.5,
      duration: const Duration(milliseconds: 300),
      child: Container(
        margin: const EdgeInsets.only(bottom: 16),
        decoration: BoxDecoration(
          color: Theme.of(context).cardTheme.color ?? Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.06),
              blurRadius: 15,
              offset: const Offset(0, 5),
            ),
          ],
          border: product.isActive
              ? null
              : Border.all(color: Colors.grey.withOpacity(0.3)),
        ),
        child: Column(
          children: [
            Row(
              children: [
                // Картинка товара
                Hero(
                  tag: 'product_${product.id}',
                  child: ClipRRect(
                    borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(20),
                      bottomLeft: Radius.circular(20),
                    ),
                    child: Stack(
                      children: [
                        NetworkOrBase64Image(
                          imageUrl: product.imageUrl,
                          width: 110,
                          height: 110,
                          fit: BoxFit.cover,
                          errorWidget: Container(
                            width: 110,
                            height: 110,
                            color: Colors.grey[200],
                            child: const Icon(
                              Icons.image_not_supported,
                              color: Colors.grey,
                              size: 32,
                            ),
                          ),
                        ),
                        if (!product.isActive)
                          Container(
                            width: 110,
                            height: 110,
                            color: Colors.black.withOpacity(0.4),
                            child: const Center(
                              child: Icon(
                                Icons.visibility_off,
                                color: Colors.white,
                                size: 28,
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),
                ),
                // Информация
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.all(14),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          product.name,
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 15,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 4),
                        Text(
                          '₸${product.price.toStringAsFixed(0)}',
                          style: const TextStyle(
                            color: AppTheme.primaryColor,
                            fontWeight: FontWeight.bold,
                            fontSize: 17,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            _StatusBadge(
                              label: 'Склад: ${product.stock}',
                              color: product.stock > 0
                                  ? Colors.blue
                                  : Colors.red,
                              icon: Icons.warehouse_outlined,
                            ),
                            const SizedBox(width: 6),
                            _StatusBadge(
                              label: '${product.sold}',
                              color: Colors.green,
                              icon: Icons.shopping_bag_outlined,
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
                // Кнопки действий
                Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(
                      icon: Icon(
                        product.isActive
                            ? Icons.visibility
                            : Icons.visibility_off,
                        color: product.isActive ? Colors.green : Colors.grey,
                        size: 20,
                      ),
                      onPressed: onToggleActive,
                      tooltip: product.isActive ? 'Скрыть' : 'Показать',
                    ),
                    IconButton(
                      icon: const Icon(
                        Icons.edit_outlined,
                        color: AppTheme.primaryColor,
                        size: 20,
                      ),
                      onPressed: onEdit,
                      tooltip: 'Редактировать',
                    ),
                    IconButton(
                      icon: const Icon(
                        Icons.delete_outline,
                        color: Colors.red,
                        size: 20,
                      ),
                      onPressed: onDelete,
                      tooltip: 'Удалить',
                    ),
                  ],
                ),
              ],
            ),
            // Прогресс-бар продаж
            if (product.sold > 0 || product.stock > 0)
              Padding(
                padding: const EdgeInsets.fromLTRB(14, 0, 14, 12),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Выручка: ₸${product.revenue.toStringAsFixed(0)}',
                          style: TextStyle(
                            fontSize: 11,
                            color: Colors.green[700],
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        Text(
                          '${((product.sold / (product.sold + product.stock)) * 100).toStringAsFixed(0)}% продано',
                          style: const TextStyle(
                            fontSize: 11,
                            color: AppTheme.greyColor,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(10),
                      child: LinearProgressIndicator(
                        value: (product.stock + product.sold) > 0
                            ? product.sold / (product.stock + product.sold)
                            : 0,
                        backgroundColor: Colors.grey[200],
                        color: AppTheme.primaryColor,
                        minHeight: 6,
                      ),
                    ),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _StatusBadge extends StatelessWidget {
  final String label;
  final Color color;
  final IconData icon;
  const _StatusBadge({
    required this.label,
    required this.color,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 12, color: color),
          const SizedBox(width: 4),
          Text(
            label,
            style: TextStyle(
              fontSize: 11,
              color: color,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}

// ==========================================
// Форма добавления / редактирования товара
// ==========================================
class _ProductFormSheet extends StatefulWidget {
  final PartnerProduct? product;
  const _ProductFormSheet({this.product});

  @override
  State<_ProductFormSheet> createState() => _ProductFormSheetState();
}

class _ProductFormSheetState extends State<_ProductFormSheet> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _nameController;
  late final TextEditingController _descController;
  late final TextEditingController _priceController;
  late final TextEditingController _imageController;
  late final TextEditingController _stockController;
  late String _selectedCategory;

  bool get isEditing => widget.product != null;

  final List<Map<String, dynamic>> _categories = [
    {
      'name': 'Корм',
      'key': 'Корма',
      'icon': Icons.restaurant,
      'color': Colors.orange,
    },
    {
      'name': 'Игрушки',
      'key': 'Игрушки',
      'icon': Icons.toys,
      'color': Colors.purple,
    },
    {
      'name': 'Аксессуары',
      'key': 'Аксессуары',
      'icon': Icons.pets,
      'color': Colors.blue,
    },
    {
      'name': 'Гигиена',
      'key': 'Гигиена',
      'icon': Icons.cleaning_services,
      'color': Colors.teal,
    },
    {
      'name': 'Одежда',
      'key': 'Одежда',
      'icon': Icons.checkroom,
      'color': Colors.pink,
    },
  ];

  // Примеры фото для быстрого добавления
  final List<String> _quickImages = [
    'https://images.unsplash.com/photo-1589924691995-400dc9ecc119?w=500&q=80',
    'https://images.unsplash.com/photo-1587300003388-59208cc962cb?w=500&q=80',
    'https://images.unsplash.com/photo-1574158622682-e40e69881006?w=500&q=80',
    'https://images.unsplash.com/photo-1548199973-03cce0bbc87b?w=500&q=80',
    'https://images.unsplash.com/photo-1545249390-6bdfa286032f?w=500&q=80',
    'https://images.unsplash.com/photo-1583511655857-d19b40a7a54e?w=500&q=80',
  ];

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.product?.name ?? '');
    _descController = TextEditingController(
      text: widget.product?.description ?? '',
    );
    _priceController = TextEditingController(
      text: widget.product?.price.toStringAsFixed(0) ?? '',
    );
    _imageController = TextEditingController(
      text: widget.product?.imageUrl ?? '',
    );
    _stockController = TextEditingController(
      text: widget.product?.stock.toString() ?? '',
    );
    _selectedCategory = widget.product?.category ?? 'Корма';
  }

  @override
  void dispose() {
    _nameController.dispose();
    _descController.dispose();
    _priceController.dispose();
    _imageController.dispose();
    _stockController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).scaffoldBackgroundColor,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
      ),
      child: DraggableScrollableSheet(
        initialChildSize: 0.92,
        minChildSize: 0.5,
        maxChildSize: 0.95,
        expand: false,
        builder: (_, scrollController) {
          return Padding(
            padding: EdgeInsets.only(
              bottom: MediaQuery.of(context).viewInsets.bottom,
              left: 20,
              right: 20,
              top: 12,
            ),
            child: Form(
              key: _formKey,
              child: ListView(
                controller: scrollController,
                children: [
                  // Ручка для перетаскивания
                  Center(
                    child: Container(
                      width: 40,
                      height: 4,
                      decoration: BoxDecoration(
                        color: Colors.grey[300],
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Заголовок
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: AppTheme.primaryColor.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Icon(
                          isEditing ? Icons.edit : Icons.add_business,
                          color: AppTheme.primaryColor,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Text(
                        isEditing ? 'Редактировать товар' : 'Новый товар',
                        style: const TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),

                  // Название
                  _buildField(
                    controller: _nameController,
                    label: 'Название товара',
                    icon: Icons.label_outline,
                    hint: 'Например: Royal Canin для собак',
                    validator: (v) => v!.isEmpty ? 'Введите название' : null,
                  ),
                  const SizedBox(height: 16),

                  // Описание
                  _buildField(
                    controller: _descController,
                    label: 'Описание',
                    icon: Icons.description_outlined,
                    hint: 'Подробное описание товара...',
                    maxLines: 3,
                    validator: (v) => v!.isEmpty ? 'Введите описание' : null,
                  ),
                  const SizedBox(height: 16),

                  // Цена и количество в ряд
                  Row(
                    children: [
                      Expanded(
                        child: _buildField(
                          controller: _priceController,
                          label: 'Цена (₸)',
                          icon: Icons.attach_money,
                          hint: '5000',
                          keyboardType: TextInputType.number,
                          validator: (v) => v!.isEmpty ? 'Цена' : null,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _buildField(
                          controller: _stockController,
                          label: 'Кол-во',
                          icon: Icons.warehouse_outlined,
                          hint: '10',
                          keyboardType: TextInputType.number,
                          validator: (v) => v!.isEmpty ? 'Кол-во' : null,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),

                  // Ссылка на фото
                  _buildField(
                    controller: _imageController,
                    label: 'Ссылка на фото (URL)',
                    icon: Icons.image_outlined,
                    hint: 'https://example.com/photo.jpg',
                    validator: (v) => v!.isEmpty ? 'Укажите фото' : null,
                  ),
                  const SizedBox(height: 8),

                  // Быстрый выбор фото
                  const Text(
                    'Быстрый выбор фото:',
                    style: TextStyle(fontSize: 12, color: AppTheme.greyColor),
                  ),
                  const SizedBox(height: 8),
                  SizedBox(
                    height: 60,
                    child: ListView.builder(
                      scrollDirection: Axis.horizontal,
                      itemCount: _quickImages.length,
                      itemBuilder: (_, i) {
                        final url = _quickImages[i];
                        final isSelected = _imageController.text == url;
                        return GestureDetector(
                          onTap: () =>
                              setState(() => _imageController.text = url),
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 200),
                            margin: const EdgeInsets.only(right: 8),
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                color: isSelected
                                    ? AppTheme.primaryColor
                                    : Colors.transparent,
                                width: 2,
                              ),
                            ),
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(10),
                              child: Image.network(
                                url,
                                width: 56,
                                height: 56,
                                fit: BoxFit.cover,
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                  const SizedBox(height: 20),

                  // Выбор категории (чипами)
                  const Text(
                    'Категория',
                    style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
                  ),
                  const SizedBox(height: 10),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: _categories.map((cat) {
                      final isSelected = _selectedCategory == cat['key'];
                      return GestureDetector(
                        onTap: () => setState(
                          () => _selectedCategory = cat['key'] as String,
                        ),
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 200),
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 10,
                          ),
                          decoration: BoxDecoration(
                            color: isSelected
                                ? (cat['color'] as Color).withOpacity(0.15)
                                : Colors.grey.withOpacity(0.08),
                            borderRadius: BorderRadius.circular(30),
                            border: Border.all(
                              color: isSelected
                                  ? cat['color'] as Color
                                  : Colors.transparent,
                              width: 1.5,
                            ),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                cat['icon'] as IconData,
                                size: 16,
                                color: isSelected
                                    ? cat['color'] as Color
                                    : AppTheme.greyColor,
                              ),
                              const SizedBox(width: 6),
                              Text(
                                cat['name'] as String,
                                style: TextStyle(
                                  fontSize: 13,
                                  fontWeight: isSelected
                                      ? FontWeight.bold
                                      : FontWeight.normal,
                                  color: isSelected
                                      ? cat['color'] as Color
                                      : AppTheme.greyColor,
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                  const SizedBox(height: 28),

                  // Превью
                  if (_imageController.text.isNotEmpty &&
                      _nameController.text.isNotEmpty)
                    Container(
                      padding: const EdgeInsets.all(12),
                      margin: const EdgeInsets.only(bottom: 16),
                      decoration: BoxDecoration(
                        color: Colors.grey.withOpacity(0.05),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: Colors.grey.withOpacity(0.15),
                        ),
                      ),
                      child: Row(
                        children: [
                          ClipRRect(
                            borderRadius: BorderRadius.circular(10),
                            child: Image.network(
                              _imageController.text,
                              width: 50,
                              height: 50,
                              fit: BoxFit.cover,
                              errorBuilder: (_, _, _) => Container(
                                width: 50,
                                height: 50,
                                color: Colors.grey[200],
                                child: const Icon(Icons.broken_image, size: 20),
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  'Предпросмотр',
                                  style: TextStyle(
                                    fontSize: 10,
                                    color: AppTheme.greyColor,
                                  ),
                                ),
                                Text(
                                  _nameController.text,
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 13,
                                  ),
                                ),
                                Text(
                                  '₸${_priceController.text.isEmpty ? "0" : _priceController.text}',
                                  style: const TextStyle(
                                    color: AppTheme.primaryColor,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 12,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),

                  // Кнопка
                  ElevatedButton(
                    onPressed: _submit,
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 18),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(isEditing ? Icons.check : Icons.add_rounded),
                        const SizedBox(width: 8),
                        Text(
                          isEditing ? 'Сохранить изменения' : 'Добавить товар',
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 32),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    String? hint,
    int maxLines = 1,
    TextInputType? keyboardType,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      maxLines: maxLines,
      keyboardType: keyboardType,
      validator: validator,
      onChanged: (_) => setState(() {}),
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        prefixIcon: Icon(icon, color: AppTheme.primaryColor),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide(color: Colors.grey.withOpacity(0.3)),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide(color: Colors.grey.withOpacity(0.3)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: AppTheme.primaryColor, width: 2),
        ),
        filled: true,
        fillColor: Colors.grey.withOpacity(0.04),
      ),
    );
  }

  Future<void> _submit() async {
    if (_formKey.currentState?.validate() ?? false) {
      final partner = context.read<PartnerProvider>();

      if (isEditing) {
        await partner.updateProductWithSupabase(
          widget.product!.id,
          name: _nameController.text,
          description: _descController.text,
          price: double.tryParse(_priceController.text) ?? 0,
          category: _selectedCategory,
          imageUrl: _imageController.text,
          stock: int.tryParse(_stockController.text) ?? 0,
        );
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Row(
              children: [
                Icon(Icons.check_circle, color: Colors.white),
                SizedBox(width: 8),
                Text('Товар обновлён! ✅'),
              ],
            ),
            backgroundColor: Colors.green,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        );
      } else {
        await partner.addProductWithSupabase(
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
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Row(
              children: [
                Icon(Icons.celebration, color: Colors.white),
                SizedBox(width: 8),
                Text('Товар добавлен! 🎉 Он виден покупателям'),
              ],
            ),
            backgroundColor: Colors.green,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        );
      }
    }
  }
}
