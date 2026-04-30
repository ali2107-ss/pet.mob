import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/order_provider.dart';
import '../providers/product_provider.dart';
import '../theme.dart';
import '../widgets/network_or_base64_image.dart';

class OrderHistoryScreen extends StatefulWidget {
  const OrderHistoryScreen({super.key});

  @override
  State<OrderHistoryScreen> createState() => _OrderHistoryScreenState();
}

class _OrderHistoryScreenState extends State<OrderHistoryScreen> {
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadOrders();
  }

  Future<void> _loadOrders() async {
    try {
      if (!mounted) return;
      setState(() {
        _isLoading = true;
        _error = null;
      });

      final orderProvider = Provider.of<OrderProvider>(context, listen: false);
      final productProvider = Provider.of<ProductProvider>(context, listen: false);
      await orderProvider.fetchOrders(productProvider.items);

      if (!mounted) return;
      setState(() => _isLoading = false);
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _isLoading = false;
        _error = e.toString();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final orderProvider = Provider.of<OrderProvider>(context);
    final orders = orderProvider.orders;

    return Scaffold(
      appBar: AppBar(
        title: const Text('История заказов'),
        centerTitle: true,
        actions: [
          if (!_isLoading)
            IconButton(icon: const Icon(Icons.refresh), onPressed: _loadOrders),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _error != null
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.error_outline,
                    size: 80,
                    color: Colors.red.withValues(alpha: 0.5),
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'Ошибка загрузки',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24),
                    child: Text(
                      _error!,
                      textAlign: TextAlign.center,
                      style: const TextStyle(color: AppTheme.greyColor),
                    ),
                  ),
                  const SizedBox(height: 24),
                  ElevatedButton(
                    onPressed: _loadOrders,
                    child: const Text('Попробовать снова'),
                  ),
                ],
              ),
            )
          : orders.isEmpty
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.receipt_long_outlined,
                    size: 80,
                    color: AppTheme.greyColor.withValues(alpha: 0.5),
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'Заказов пока нет',
                    style: TextStyle(fontSize: 18, color: AppTheme.greyColor),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Сделайте свой первый заказ!',
                    style: TextStyle(fontSize: 14, color: AppTheme.greyColor),
                  ),
                ],
              ),
            )
          : ListView.builder(
              padding: const EdgeInsets.all(20),
              itemCount: orders.length,
              itemBuilder: (ctx, i) {
                final order = orders[i];
                final date = order.dateTime;
                final dateStr =
                    '${date.day.toString().padLeft(2, '0')}.${date.month.toString().padLeft(2, '0')}.${date.year}';
                final timeStr =
                    '${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}';

                final paymentLabel = {
                  'card': 'Банковская карта',
                  'kaspi': 'Kaspi QR / Gold',
                  'cash': 'Наличные',
                };

                // Status from Supabase backend
                final String rawStatus = order.status;
                String status;
                Color statusColor;
                switch (rawStatus) {
                  case 'processing':
                    status = 'Обработка';
                    statusColor = Colors.orange;
                    break;
                  case 'confirmed':
                    status = 'Подтверждён';
                    statusColor = Colors.blue;
                    break;
                  case 'shipping':
                    status = 'В пути';
                    statusColor = Colors.indigo;
                    break;
                  case 'delivered':
                    status = 'Доставлен';
                    statusColor = Colors.green;
                    break;
                  case 'cancelled':
                    status = 'Отменён';
                    statusColor = Colors.red;
                    break;
                  default:
                    status = 'Обработка';
                    statusColor = Colors.orange;
                }

                return GestureDetector(
                  onTap: () => _showOrderTracking(context, order, status),
                  child: Container(
                  margin: const EdgeInsets.only(bottom: 16),
                  decoration: BoxDecoration(
                    color: Theme.of(context).cardTheme.color ?? Colors.white,
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.04),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 6,
                              ),
                              decoration: BoxDecoration(
                                color: statusColor.withValues(alpha: 0.1),
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: Text(
                                status,
                                style: TextStyle(
                                  color: statusColor,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 12,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        Row(
                          children: [
                            const Icon(
                              Icons.calendar_today,
                              size: 14,
                              color: AppTheme.greyColor,
                            ),
                            const SizedBox(width: 6),
                            Text(
                              '$dateStr, $timeStr',
                              style: const TextStyle(
                                color: AppTheme.greyColor,
                                fontSize: 14,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            const Icon(
                              Icons.location_on_outlined,
                              size: 14,
                              color: AppTheme.greyColor,
                            ),
                            const SizedBox(width: 6),
                            Expanded(
                              child: Text(
                                order.address,
                                style: const TextStyle(
                                  color: AppTheme.greyColor,
                                  fontSize: 14,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            const Icon(
                              Icons.payment,
                              size: 14,
                              color: AppTheme.greyColor,
                            ),
                            const SizedBox(width: 6),
                            Expanded(
                              child: Text(
                                () {
                                  final method = order.paymentMethod;
                                  if (method.startsWith('card_')) {
                                    // Это сохранённая карта, но у нас нет доступа к последним цифрам
                                    return 'Банковская карта';
                                  }
                                  return paymentLabel[method] ?? method;
                                }(),
                                style: const TextStyle(
                                  color: AppTheme.greyColor,
                                  fontSize: 14,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        // Товары с фото и названиями
                        ...order.items.map((item) {
                          return Container(
                            margin: const EdgeInsets.only(bottom: 8),
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: Colors.grey.withValues(alpha: 0.05),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Row(
                              children: [
                                ClipRRect(
                                  borderRadius: BorderRadius.circular(8),
                                  child: item.product != null
                                      ? NetworkOrBase64Image(
                                          imageUrl: item.product!.imageUrl,
                                          width: 50,
                                          height: 50,
                                          fit: BoxFit.cover,
                                          errorWidget: Container(
                                            width: 50,
                                            height: 50,
                                            color: Colors.grey[200],
                                          ),
                                        )
                                      : Container(
                                          width: 50,
                                          height: 50,
                                          color: Colors.grey[200],
                                        ),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        item.product?.name ?? 'Товар',
                                        style: const TextStyle(
                                          fontWeight: FontWeight.w600,
                                          fontSize: 14,
                                        ),
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        '${item.quantity} шт × ₸${item.product?.price.toStringAsFixed(0) ?? '0'}',
                                        style: const TextStyle(
                                          color: AppTheme.greyColor,
                                          fontSize: 12,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          );
                        }).toList(),
                        const SizedBox(height: 12),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              '${order.items.length} товар(ов)',
                              style: const TextStyle(
                                color: AppTheme.greyColor,
                                fontSize: 14,
                              ),
                            ),
                            Row(
                              children: [
                                Text(
                                  '₸${order.totalAmount.toStringAsFixed(0)}',
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 18,
                                    color: AppTheme.primaryColor,
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Icon(
                                  Icons.chevron_right,
                                  color: AppTheme.greyColor,
                                  size: 20,
                                ),
                              ],
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
                );
              },
            ),
    );
  }

  void _showOrderTracking(BuildContext context, dynamic order, String status) {
    final rawStatus = order.status as String;
    final statusIndex = {
      'processing': 0,
      'confirmed': 1,
      'shipping': 2,
      'delivered': 3,
    };
    final currentStep = statusIndex[rawStatus] ?? 0;
    final isCancelled = rawStatus == 'cancelled';

    final steps = [
      {'title': 'Заказ принят', 'icon': Icons.receipt_long, 'done': currentStep >= 0 && !isCancelled},
      {'title': 'Подтверждён', 'icon': Icons.check_circle, 'done': currentStep >= 1 && !isCancelled},
      {'title': 'В пути', 'icon': Icons.local_shipping, 'done': currentStep >= 2 && !isCancelled},
      {'title': 'Доставлен', 'icon': Icons.home, 'done': currentStep >= 3 && !isCancelled},
    ];

    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) => Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 40, height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey[300],
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 16),
            const Text(
              'Отслеживание заказа',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 4),
            Text(
              '₸${order.totalAmount.toStringAsFixed(0)} • ${order.items.length} товар(ов)',
              style: const TextStyle(color: AppTheme.greyColor, fontSize: 14),
            ),
            const SizedBox(height: 24),
            ...List.generate(steps.length, (i) {
              final step = steps[i];
              final done = step['done'] as bool;
              final isLast = i == steps.length - 1;
              return Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Column(
                    children: [
                      Container(
                        width: 36, height: 36,
                        decoration: BoxDecoration(
                          color: done ? AppTheme.primaryColor : Colors.grey[200],
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          step['icon'] as IconData,
                          color: done ? Colors.white : Colors.grey,
                          size: 18,
                        ),
                      ),
                      if (!isLast)
                        Container(
                          width: 2, height: 32,
                          color: done ? AppTheme.primaryColor : Colors.grey[300],
                        ),
                    ],
                  ),
                  const SizedBox(width: 16),
                  Padding(
                    padding: const EdgeInsets.only(top: 8),
                    child: Text(
                      step['title'] as String,
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: done ? FontWeight.bold : FontWeight.normal,
                        color: done ? AppTheme.textColor : AppTheme.greyColor,
                      ),
                    ),
                  ),
                ],
              );
            }),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }
}
