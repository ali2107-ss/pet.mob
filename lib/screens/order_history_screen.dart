import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/order_provider.dart';
import '../theme.dart';

class OrderHistoryScreen extends StatelessWidget {
  const OrderHistoryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final orderProvider = Provider.of<OrderProvider>(context);
    final orders = orderProvider.orders;

    return Scaffold(
      appBar: AppBar(
        title: const Text('История заказов'),
        centerTitle: true,
      ),
      body: orders.isEmpty
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.receipt_long_outlined, size: 80, color: AppTheme.greyColor.withValues(alpha: 0.5)),
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
                final dateStr = '${date.day.toString().padLeft(2, '0')}.${date.month.toString().padLeft(2, '0')}.${date.year}';
                final timeStr = '${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}';

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

                return Container(
                  margin: const EdgeInsets.only(bottom: 16),
                  decoration: BoxDecoration(
                    color: Theme.of(context).cardTheme.color ?? Colors.white,
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.04),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      )
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
                                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
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
                            const Icon(Icons.calendar_today, size: 14, color: AppTheme.greyColor),
                            const SizedBox(width: 6),
                            Text(
                              '$dateStr, $timeStr',
                              style: const TextStyle(color: AppTheme.greyColor, fontSize: 14),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            const Icon(Icons.location_on_outlined, size: 14, color: AppTheme.greyColor),
                            const SizedBox(width: 6),
                            Expanded(
                              child: Text(
                                order.address,
                                style: const TextStyle(color: AppTheme.greyColor, fontSize: 14),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            const Icon(Icons.payment, size: 14, color: AppTheme.greyColor),
                            const SizedBox(width: 6),
                            Text(
                              paymentLabel[order.paymentMethod] ?? order.paymentMethod,
                              style: const TextStyle(color: AppTheme.greyColor, fontSize: 14),
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
                                  child: Image.network(
                                    order.items[j].product.imageUrl,
                                    fit: BoxFit.cover,
                                    errorBuilder: (c, e, s) => Container(color: Colors.grey[200]),
                                  ),
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
                              style: const TextStyle(color: AppTheme.greyColor, fontSize: 14),
                            ),
                            Text(
                              '₸${order.totalAmount.toStringAsFixed(0)}',
                              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18, color: AppTheme.primaryColor),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
    );
  }
}
