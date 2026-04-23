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

                // Determine status based on time
                final minutesSince = DateTime.now().difference(date).inMinutes;
                String status;
                Color statusColor;
                if (minutesSince < 5) {
                  status = 'Обработка';
                  statusColor = Colors.orange;
                } else if (minutesSince < 30) {
                  status = 'В пути';
                  statusColor = Colors.blue;
                } else {
                  status = 'Доставлен';
                  statusColor = Colors.green;
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
                            Expanded(
                              child: Text(
                                order.id,
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 14,
                                ),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
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
                            Text(
                              paymentLabel[order.paymentMethod] ??
                                  order.paymentMethod,
                              style: const TextStyle(
                                color: AppTheme.greyColor,
                                fontSize: 14,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        // Items preview
                        SizedBox(
                          height: 40,
                          child: ListView.builder(
                            scrollDirection: Axis.horizontal,
                            itemCount: order.items.length,
                            itemBuilder: (ctx, j) {
                              return Container(
                                width: 40,
                                height: 40,
                                margin: const EdgeInsets.only(right: 4),
                                child: ClipRRect(
                                  borderRadius: BorderRadius.circular(8),
                                  child: order.items[j].product != null
                                      ? NetworkOrBase64Image(
                                          imageUrl: order.items[j].product!.imageUrl,
                                          fit: BoxFit.cover,
                                          errorWidget: Container(
                                            color: Colors.grey[200],
                                          ),
                                        )
                                      : Container(color: Colors.grey[200]),
                                ),
                              );
                            },
                          ),
                        ),
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
    final steps = [
      {'title': 'Заказ принят', 'icon': Icons.receipt_long, 'done': true},
      {'title': 'Подтверждён', 'icon': Icons.check_circle, 'done': status != 'Обработка'},
      {'title': 'В пути', 'icon': Icons.local_shipping, 'done': status == 'В пути' || status == 'Доставлен'},
      {'title': 'Доставлен', 'icon': Icons.home, 'done': status == 'Доставлен'},
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
