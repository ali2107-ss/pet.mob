import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/partner_provider.dart';
import '../../theme.dart';

class PartnerDashboardScreen extends StatelessWidget {
  const PartnerDashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final partner = context.watch<PartnerProvider>();

    return Scaffold(
      backgroundColor: Colors.transparent,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        automaticallyImplyLeading: false,
        title: const Text('Панель партнёра', style: TextStyle(fontWeight: FontWeight.bold)),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [AppTheme.primaryColor, Color(0xFFFFB385)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(24),
                boxShadow: [
                  BoxShadow(color: AppTheme.primaryColor.withOpacity(0.3), blurRadius: 15, offset: const Offset(0, 8)),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Общий баланс', style: TextStyle(color: Colors.white70, fontSize: 14)),
                  const SizedBox(height: 8),
                  Text('₸${partner.totalRevenue.toStringAsFixed(0)}',
                      style: const TextStyle(color: Colors.white, fontSize: 36, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 4),
                  const Text('от всех продаж', style: TextStyle(color: Colors.white70, fontSize: 12)),
                ],
              ),
            ),
            const SizedBox(height: 24),
            const Text('Статистика', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: AppTheme.textColor)),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(child: _StatCard(icon: Icons.inventory_2_outlined, label: 'Товаров', value: partner.products.length.toString(), color: Colors.blue)),
                const SizedBox(width: 12),
                Expanded(child: _StatCard(icon: Icons.shopping_bag_outlined, label: 'Продано', value: partner.totalSold.toString(), color: Colors.green)),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(child: _StatCard(icon: Icons.warehouse_outlined, label: 'На складе', value: partner.totalStock.toString(), color: Colors.orange)),
                const SizedBox(width: 12),
                Expanded(child: _StatCard(icon: Icons.trending_up, label: 'Выручка', value: '₸${partner.totalRevenue.toStringAsFixed(0)}', color: AppTheme.primaryColor)),
              ],
            ),
            const SizedBox(height: 24),
            const Text('Мои товары', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: AppTheme.textColor)),
            const SizedBox(height: 16),
            if (partner.products.isEmpty)
              Center(
                child: Padding(
                  padding: const EdgeInsets.all(32),
                  child: Column(
                    children: [
                      Icon(Icons.inventory_2_outlined, size: 64, color: AppTheme.greyColor.withOpacity(0.5)),
                      const SizedBox(height: 12),
                      const Text('Нет товаров. Добавьте первый!', style: TextStyle(color: AppTheme.greyColor)),
                    ],
                  ),
                ),
              )
            else
              ...partner.products.map((p) => _ProductAnalyticsCard(product: p)),
          ],
        ),
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final Color color;
  const _StatCard({required this.icon, required this.label, required this.value, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).cardTheme.color ?? Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, 4))],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(color: color.withOpacity(0.1), borderRadius: BorderRadius.circular(10)),
            child: Icon(icon, color: color, size: 20),
          ),
          const SizedBox(height: 12),
          Text(value, style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: color)),
          const SizedBox(height: 4),
          Text(label, style: const TextStyle(fontSize: 12, color: AppTheme.greyColor)),
        ],
      ),
    );
  }
}

class _ProductAnalyticsCard extends StatelessWidget {
  final PartnerProduct product;
  const _ProductAnalyticsCard({required this.product});

  @override
  Widget build(BuildContext context) {
    final soldPercent = (product.stock + product.sold) > 0 ? product.sold / (product.stock + product.sold) : 0.0;
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).cardTheme.color ?? Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, 4))],
      ),
      child: Row(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: Image.network(product.imageUrl, width: 60, height: 60, fit: BoxFit.cover,
                errorBuilder: (_, _, _) => Container(width: 60, height: 60, color: Colors.grey[200])),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(product.name, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14), maxLines: 1, overflow: TextOverflow.ellipsis),
                const SizedBox(height: 4),
                Text('₸${product.price.toStringAsFixed(0)} · Продано: ${product.sold} · Склад: ${product.stock}',
                    style: const TextStyle(fontSize: 12, color: AppTheme.greyColor)),
                const SizedBox(height: 8),
                ClipRRect(
                  borderRadius: BorderRadius.circular(4),
                  child: LinearProgressIndicator(
                    value: soldPercent,
                    backgroundColor: Colors.grey[200],
                    color: AppTheme.primaryColor,
                    minHeight: 6,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          Text('₸${product.revenue.toStringAsFixed(0)}',
              style: const TextStyle(fontWeight: FontWeight.bold, color: AppTheme.primaryColor, fontSize: 13)),
        ],
      ),
    );
  }
}
