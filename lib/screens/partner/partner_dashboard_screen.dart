import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/partner_provider.dart';
import '../../theme.dart';
import '../../widgets/network_or_base64_image.dart';

class PartnerDashboardScreen extends StatelessWidget {
  const PartnerDashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final partner = context.watch<PartnerProvider>();

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(20, 8, 20, 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Приветствие
            const Text(
              '👋 Привет, партнёр!',
              style: TextStyle(fontSize: 26, fontWeight: FontWeight.bold, color: AppTheme.textColor),
            ),
            const SizedBox(height: 4),
            Text(
              'Вот как идут ваши дела сегодня',
              style: TextStyle(fontSize: 14, color: AppTheme.greyColor),
            ),
            const SizedBox(height: 20),

            // Карточка баланса с градиентом
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
                  BoxShadow(color: AppTheme.primaryColor.withOpacity(0.35), blurRadius: 20, offset: const Offset(0, 10)),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text('💰 Общая выручка', style: TextStyle(color: Colors.white70, fontSize: 14)),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: const Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.trending_up, color: Colors.white, size: 14),
                            SizedBox(width: 4),
                            Text('Live', style: TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.bold)),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Text(
                    '₸${partner.totalRevenue.toStringAsFixed(0)}',
                    style: const TextStyle(color: Colors.white, fontSize: 40, fontWeight: FontWeight.bold, letterSpacing: 1),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Баланс: ₸${partner.balance.toStringAsFixed(0)}',
                    style: const TextStyle(color: Colors.white70, fontSize: 13),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Статистика 2x2
            const Text('📊 Статистика', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: AppTheme.textColor)),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: _AnimatedStatCard(
                    icon: Icons.inventory_2_outlined,
                    label: 'Товаров',
                    value: partner.products.length.toString(),
                    color: Colors.blue,
                    delay: 0,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _AnimatedStatCard(
                    icon: Icons.shopping_bag_outlined,
                    label: 'Продано',
                    value: partner.totalSold.toString(),
                    color: Colors.green,
                    delay: 100,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: _AnimatedStatCard(
                    icon: Icons.warehouse_outlined,
                    label: 'На складе',
                    value: partner.totalStock.toString(),
                    color: Colors.orange,
                    delay: 200,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _AnimatedStatCard(
                    icon: Icons.visibility,
                    label: 'Активных',
                    value: partner.activeProducts.toString(),
                    color: Colors.purple,
                    delay: 300,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),

            // Подсказки для партнёра
            if (partner.products.isEmpty) ...[
              _TipCard(
                icon: Icons.lightbulb_outline,
                title: 'Начните с товаров',
                subtitle: 'Перейдите на вкладку "Товары" и добавьте свой первый товар. Он сразу появится у покупателей!',
                color: Colors.amber,
              ),
              const SizedBox(height: 12),
            ],

            if (partner.products.isNotEmpty && partner.totalSold == 0) ...[
              _TipCard(
                icon: Icons.trending_up,
                title: 'Симулируйте продажи',
                subtitle: 'Нажмите кнопку 📈 в правом верхнем углу, чтобы симулировать покупки клиентов.',
                color: Colors.green,
              ),
              const SizedBox(height: 12),
            ],

            // Последние операции
            if (partner.transactions.isNotEmpty) ...[
              const Text('🕐 Последние действия', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: AppTheme.textColor)),
              const SizedBox(height: 16),
              ...partner.transactions.reversed.take(5).map((tx) => _TransactionRow(transaction: tx)),
            ],

            const SizedBox(height: 24),

            // Топ товары
            if (partner.products.isNotEmpty) ...[
              const Text('🏆 Мои товары', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: AppTheme.textColor)),
              const SizedBox(height: 16),
              ...partner.products.map((p) => _ProductAnalyticsCard(product: p)),
            ],
          ],
        ),
      ),
    );
  }
}

// Подсказки для партнёра
class _TipCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final Color color;

  const _TipCard({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withOpacity(0.08),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color.withOpacity(0.2)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(color: color.withOpacity(0.15), shape: BoxShape.circle),
            child: Icon(icon, color: color, size: 20),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: TextStyle(fontWeight: FontWeight.bold, color: color, fontSize: 14)),
                const SizedBox(height: 4),
                Text(subtitle, style: TextStyle(fontSize: 12, color: color.withOpacity(0.8))),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// Анимированная карта статистики
class _AnimatedStatCard extends StatefulWidget {
  final IconData icon;
  final String label;
  final String value;
  final Color color;
  final int delay;

  const _AnimatedStatCard({
    required this.icon,
    required this.label,
    required this.value,
    required this.color,
    required this.delay,
  });

  @override
  State<_AnimatedStatCard> createState() => _AnimatedStatCardState();
}

class _AnimatedStatCardState extends State<_AnimatedStatCard> with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  late Animation<double> _scaleAnim;
  late Animation<double> _fadeAnim;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(vsync: this, duration: const Duration(milliseconds: 600));
    _scaleAnim = Tween<double>(begin: 0.8, end: 1.0).animate(CurvedAnimation(parent: _ctrl, curve: Curves.elasticOut));
    _fadeAnim = Tween<double>(begin: 0.0, end: 1.0).animate(CurvedAnimation(parent: _ctrl, curve: Curves.easeIn));
    Future.delayed(Duration(milliseconds: widget.delay), () {
      if (mounted) _ctrl.forward();
    });
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: _fadeAnim,
      child: ScaleTransition(
        scale: _scaleAnim,
        child: Container(
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(
            color: Theme.of(context).cardTheme.color ?? Colors.white,
            borderRadius: BorderRadius.circular(20),
            boxShadow: [BoxShadow(color: widget.color.withOpacity(0.1), blurRadius: 15, offset: const Offset(0, 5))],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: widget.color.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(widget.icon, color: widget.color, size: 22),
              ),
              const SizedBox(height: 14),
              Text(widget.value, style: TextStyle(fontSize: 26, fontWeight: FontWeight.bold, color: widget.color)),
              const SizedBox(height: 4),
              Text(widget.label, style: const TextStyle(fontSize: 13, color: AppTheme.greyColor)),
            ],
          ),
        ),
      ),
    );
  }
}

// Строка транзакции
class _TransactionRow extends StatelessWidget {
  final PartnerTransaction transaction;
  const _TransactionRow({required this.transaction});

  @override
  Widget build(BuildContext context) {
    Color bgColor;
    switch (transaction.type) {
      case TransactionType.sale:
        bgColor = Colors.green;
        break;
      case TransactionType.productAdded:
        bgColor = Colors.blue;
        break;
      case TransactionType.productRemoved:
        bgColor = Colors.red;
        break;
      case TransactionType.withdrawal:
        bgColor = Colors.purple;
        break;
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: Theme.of(context).cardTheme.color ?? Colors.white,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 8, offset: const Offset(0, 2))],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(color: bgColor.withOpacity(0.1), shape: BoxShape.circle),
            child: Text(
              transaction.type == TransactionType.sale
                  ? '💰'
                  : transaction.type == TransactionType.productAdded
                      ? '📦'
                      : transaction.type == TransactionType.productRemoved
                          ? '🗑️'
                          : '💳',
              style: const TextStyle(fontSize: 16),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  transaction.description,
                  style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                Text(
                  _formatTime(transaction.timestamp),
                  style: const TextStyle(fontSize: 11, color: AppTheme.greyColor),
                ),
              ],
            ),
          ),
          if (transaction.amount > 0)
            Text(
              '+₸${transaction.amount.toStringAsFixed(0)}',
              style: TextStyle(fontWeight: FontWeight.bold, color: Colors.green[700], fontSize: 13),
            ),
        ],
      ),
    );
  }

  String _formatTime(DateTime dt) {
    final now = DateTime.now();
    final diff = now.difference(dt);
    if (diff.inSeconds < 60) return 'Только что';
    if (diff.inMinutes < 60) return '${diff.inMinutes} мин назад';
    if (diff.inHours < 24) return '${diff.inHours} ч назад';
    return '${dt.day}.${dt.month.toString().padLeft(2, '0')}';
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
        borderRadius: BorderRadius.circular(18),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 12, offset: const Offset(0, 4))],
      ),
      child: Row(
        children: [
          Stack(
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(14),
                child: NetworkOrBase64Image(
                    imageUrl: product.imageUrl, width: 60, height: 60, fit: BoxFit.cover,
                    errorWidget: Container(width: 60, height: 60, color: Colors.grey[200])),
              ),
              if (!product.isActive)
                Positioned.fill(
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.black.withOpacity(0.5),
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: const Icon(Icons.visibility_off, color: Colors.white, size: 20),
                  ),
                ),
            ],
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(product.name, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14), maxLines: 1, overflow: TextOverflow.ellipsis),
                const SizedBox(height: 4),
                Text('₸${product.price.toStringAsFixed(0)} · Продано: ${product.sold} · Склад: ${product.stock}',
                    style: const TextStyle(fontSize: 11, color: AppTheme.greyColor)),
                const SizedBox(height: 8),
                ClipRRect(
                  borderRadius: BorderRadius.circular(10),
                  child: LinearProgressIndicator(
                    value: soldPercent,
                    backgroundColor: Colors.grey[200],
                    color: soldPercent > 0.7
                        ? Colors.green
                        : soldPercent > 0.3
                            ? AppTheme.primaryColor
                            : Colors.orange,
                    minHeight: 6,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          Column(
            children: [
              Text('₸${product.revenue.toStringAsFixed(0)}',
                  style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.green, fontSize: 14)),
              const SizedBox(height: 2),
              Text('доход', style: TextStyle(fontSize: 10, color: AppTheme.greyColor)),
            ],
          ),
        ],
      ),
    );
  }
}
