import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/cart_provider.dart';
import '../providers/order_provider.dart';
import '../providers/partner_provider.dart';
import '../providers/address_provider.dart';
import '../providers/payment_method_provider.dart';
import 'main_screen.dart';
import '../theme.dart';

class CheckoutScreen extends StatefulWidget {
  const CheckoutScreen({super.key});

  @override
  State<CheckoutScreen> createState() => _CheckoutScreenState();
}

class _CheckoutScreenState extends State<CheckoutScreen> {
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
    'Рудный',
  ];
  int _currentStep = 0;
  String _selectedCity = 'Алматы';
  final _addressController = TextEditingController();
  final _phoneController = TextEditingController(text: '+7 ');
  final _commentController = TextEditingController();
  String _selectedPayment = 'card';
  bool _isLoading = false;
  final _promoController = TextEditingController();
  double _discount = 0;
  String? _promoMessage;

  @override
  void initState() {
    super.initState();
    // Загружаем адреса и карты при открытии чекаута — 
    // это исправляет баг «через раз» когда данные не загружены
    Future.microtask(() {
      Provider.of<AddressProvider>(context, listen: false).fetchAddresses();
      Provider.of<PaymentMethodProvider>(context, listen: false).fetchCards();
    });
  }

  @override
  void dispose() {
    _addressController.dispose();
    _phoneController.dispose();
    _commentController.dispose();
    _promoController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final cart = Provider.of<CartProvider>(context);

    return Scaffold(
      appBar: AppBar(title: const Text('Оформление заказа'), centerTitle: true),
      body: Column(
        children: [
          // Step indicators
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
            child: Row(
              children: [
                _buildStepIndicator(0, 'Адрес', Icons.location_on),
                _buildStepLine(0),
                _buildStepIndicator(1, 'Оплата', Icons.payment),
                _buildStepLine(1),
                _buildStepIndicator(2, 'Проверка', Icons.check_circle),
              ],
            ),
          ),
          const SizedBox(height: 16),
          // Step content
          Expanded(
            child: AnimatedSwitcher(
              duration: const Duration(milliseconds: 300),
              child: _buildStepContent(cart),
            ),
          ),
          // Bottom buttons
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: (Theme.of(context).cardTheme.color ?? Colors.white)
                  .withValues(alpha: 0.95),
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(24),
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.05),
                  blurRadius: 10,
                  offset: const Offset(0, -5),
                ),
              ],
            ),
            child: SafeArea(
              child: Row(
                children: [
                  if (_currentStep > 0)
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () {
                          setState(() => _currentStep--);
                        },
                        style: OutlinedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          side: const BorderSide(color: AppTheme.primaryColor),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                        ),
                        child: const Text('Назад'),
                      ),
                    ),
                  if (_currentStep > 0) const SizedBox(width: 16),
                  Expanded(
                    flex: 2,
                    child: ElevatedButton(
                      onPressed: () async => await _handleNext(cart),
                      child: _isLoading
                          ? const SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            )
                          : Text(
                              _currentStep == 2
                                  ? 'Оформить заказ'
                                  : 'Продолжить',
                            ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStepIndicator(int step, String label, IconData icon) {
    final isActive = _currentStep >= step;
    return Expanded(
      child: Column(
        children: [
          AnimatedContainer(
            duration: const Duration(milliseconds: 300),
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: isActive ? AppTheme.primaryColor : Colors.grey[200],
              shape: BoxShape.circle,
              boxShadow: isActive
                  ? [
                      BoxShadow(
                        color: AppTheme.primaryColor.withValues(alpha: 0.3),
                        blurRadius: 8,
                        offset: const Offset(0, 3),
                      ),
                    ]
                  : [],
            ),
            child: Icon(
              icon,
              color: isActive ? Colors.white : Colors.grey,
              size: 22,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              fontWeight: isActive ? FontWeight.bold : FontWeight.normal,
              color: isActive ? AppTheme.primaryColor : Colors.grey,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStepLine(int step) {
    final isActive = _currentStep > step;
    return Container(
      width: 30,
      height: 3,
      margin: const EdgeInsets.only(bottom: 20),
      decoration: BoxDecoration(
        color: isActive ? AppTheme.primaryColor : Colors.grey[300],
        borderRadius: BorderRadius.circular(2),
      ),
    );
  }

  Widget _buildStepContent(CartProvider cart) {
    switch (_currentStep) {
      case 0:
        return _buildAddressStep();
      case 1:
        return _buildPaymentStep();
      case 2:
        return _buildReviewStep(cart);
      default:
        return const SizedBox();
    }
  }

  Widget _buildAddressStep() {
    final addressProvider = Provider.of<AddressProvider>(context);
    final addresses = addressProvider.addresses;

    return SingleChildScrollView(
      key: const ValueKey('address'),
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Адрес доставки',
            style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),
          if (addresses.isNotEmpty) ...[
            const Text(
              'Выберите сохраненный адрес:',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            ...addresses.map(
              (addr) => GestureDetector(
                onTap: () {
                  setState(() {
                    _selectedCity = addr.city;
                    _addressController.text =
                        '${addr.street}, ${addr.house}-${addr.apartment}';
                  });
                },
                child: Container(
                  margin: const EdgeInsets.only(bottom: 8),
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: _addressController.text.contains(addr.street)
                        ? AppTheme.primaryColor.withOpacity(0.1)
                        : (Theme.of(context).cardTheme.color ?? Colors.white),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: _addressController.text.contains(addr.street)
                          ? AppTheme.primaryColor
                          : Colors.grey.withOpacity(0.2),
                    ),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        Icons.location_on,
                        color: _addressController.text.contains(addr.street)
                            ? AppTheme.primaryColor
                            : Colors.grey,
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          '${addr.title} (${addr.city})',
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            const SizedBox(height: 16),
          ],
          const Text(
            'Город Казахстана',
            style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
          ),
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            decoration: BoxDecoration(
              color: (Theme.of(context).cardTheme.color ?? Colors.white)
                  .withValues(alpha: 0.9),
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.03),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: DropdownButtonHideUnderline(
              child: DropdownButton<String>(
                value: _selectedCity,
                isExpanded: true,
                items: _kazakhstanCities
                    .map(
                      (city) =>
                          DropdownMenuItem(value: city, child: Text(city)),
                    )
                    .toList(),
                onChanged: (val) => setState(() => _selectedCity = val!),
              ),
            ),
          ),
          const SizedBox(height: 16),
          _buildTextField(
            controller: _addressController,
            label: 'Улица, дом, квартира',
            hint: 'например: ул. Абая, 52, кв. 10',
            icon: Icons.location_on_outlined,
            maxLines: 2,
          ),
          const SizedBox(height: 16),
          _buildTextField(
            controller: _phoneController,
            label: 'Номер телефона',
            hint: '+7 (7XX) XXX XX XX',
            icon: Icons.phone_outlined,
            keyboardType: TextInputType.phone,
          ),
          const SizedBox(height: 24),
        ],
      ),
    );
  }

  Widget _buildPaymentStep() {
    final paymentProvider = Provider.of<PaymentMethodProvider>(context);
    final cards = paymentProvider.cards;

    return SingleChildScrollView(
      key: const ValueKey('payment'),
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Способ оплаты',
            style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),
          if (cards.isNotEmpty) ...[
            const Text(
              'Ваши карты:',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            ...cards.map(
              (card) => _buildPaymentOption(
                'card_${card.id}',
                'Карта **** ${card.lastFour}',
                card.cardHolder,
                Icons.credit_card,
              ),
            ),
            const SizedBox(height: 16),
          ],
          _buildPaymentOption(
            'card',
            'Новая карта',
            'Visa / Mastercard',
            Icons.add_card,
          ),
          const SizedBox(height: 12),
          _buildPaymentOption(
            'kaspi',
            'Kaspi QR / Gold',
            'Через Kaspi Bank',
            Icons.qr_code_2,
          ),
          const SizedBox(height: 12),
          _buildPaymentOption(
            'cash',
            'Наличные',
            'Оплата при получении',
            Icons.money,
          ),
        ],
      ),
    );
  }

  Widget _buildPaymentOption(
    String value,
    String title,
    String subtitle,
    IconData icon,
  ) {
    final isSelected = _selectedPayment == value;
    return GestureDetector(
      onTap: () => setState(() => _selectedPayment = value),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: isSelected
              ? AppTheme.primaryColor.withValues(alpha: 0.1)
              : (Theme.of(context).cardTheme.color ?? Colors.white),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected
                ? AppTheme.primaryColor
                : Colors.grey.withValues(alpha: 0.2),
            width: isSelected ? 2 : 1,
          ),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: AppTheme.primaryColor.withValues(alpha: 0.1),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ]
              : [],
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: isSelected ? AppTheme.primaryColor : Colors.grey[100],
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: isSelected ? Colors.white : Colors.grey),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                  Text(
                    subtitle,
                    style: const TextStyle(
                      color: AppTheme.greyColor,
                      fontSize: 13,
                    ),
                  ),
                ],
              ),
            ),
            AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              width: 24,
              height: 24,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: isSelected ? AppTheme.primaryColor : Colors.transparent,
                border: Border.all(
                  color: isSelected ? AppTheme.primaryColor : Colors.grey,
                  width: 2,
                ),
              ),
              child: isSelected
                  ? const Icon(Icons.check, color: Colors.white, size: 16)
                  : null,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildReviewStep(CartProvider cart) {
    final paymentLabel = {
      'card': 'Банковская карта',
      'kaspi': 'Kaspi QR / Gold',
      'cash': 'Наличные',
    };

    return SingleChildScrollView(
      key: const ValueKey('review'),
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Проверка заказа',
            style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 24),
          // Address summary
          _buildSummaryCard(
            icon: Icons.location_on,
            title: 'Адрес',
            value: _addressController.text.isEmpty
                ? 'Не указан'
                : '$_selectedCity, ${_addressController.text}',
          ),
          const SizedBox(height: 12),
          _buildSummaryCard(
            icon: Icons.phone,
            title: 'Телефон',
            value: _phoneController.text,
          ),
          const SizedBox(height: 12),
          _buildSummaryCard(
            icon: Icons.payment,
            title: 'Способ оплаты',
            value: paymentLabel[_selectedPayment] ?? 'Карта',
          ),
          const SizedBox(height: 24),
          const Text(
            'Товары',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 12),
          ...cart.items.values.map(
            (item) => Container(
              margin: const EdgeInsets.only(bottom: 8),
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: (Theme.of(context).cardTheme.color ?? Colors.white)
                    .withValues(alpha: 0.9),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                children: [
                  if (item.product != null)
                    ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: Image.network(
                        item.product!.imageUrl,
                        width: 50,
                        height: 50,
                        fit: BoxFit.cover,
                        errorBuilder: (c, e, s) => Container(
                          width: 50,
                          height: 50,
                          color: Colors.grey[200],
                        ),
                      ),
                    )
                  else
                    Container(width: 50, height: 50, color: Colors.grey[200]),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      item.product?.name ?? 'Товар',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  Text(
                    '${item.quantity}x ₸${item.product?.price.toStringAsFixed(0) ?? '0'}',
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      color: AppTheme.primaryColor,
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          // Промокод
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: (Theme.of(context).cardTheme.color ?? Colors.white).withValues(alpha: 0.9),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Промокод', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14)),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: _promoController,
                        decoration: InputDecoration(
                          hintText: 'Введите промокод',
                          hintStyle: const TextStyle(color: AppTheme.greyColor, fontSize: 14),
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                          isDense: true,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    ElevatedButton(
                      onPressed: () {
                        final code = _promoController.text.trim().toUpperCase();
                        setState(() {
                          if (code == 'PETMOB10') {
                            _discount = 0.1;
                            _promoMessage = 'Скидка 10% применена! 🎉';
                          } else if (code == 'PETMOB20') {
                            _discount = 0.2;
                            _promoMessage = 'Скидка 20% применена! 🎉';
                          } else if (code.isNotEmpty) {
                            _discount = 0;
                            _promoMessage = 'Промокод не найден';
                          }
                        });
                      },
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                      ),
                      child: const Text('Применить'),
                    ),
                  ],
                ),
                if (_promoMessage != null) ...[
                  const SizedBox(height: 8),
                  Text(
                    _promoMessage!,
                    style: TextStyle(
                      fontSize: 13,
                      color: _discount > 0 ? Colors.green : Colors.red,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ],
            ),
          ),
          const SizedBox(height: 16),
          // Итого
          if (_discount > 0) ...[
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.green.withValues(alpha: 0.08),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text('Скидка:', style: TextStyle(fontSize: 16, color: Colors.green)),
                  Text(
                    '-₸${(cart.totalAmount * _discount).toStringAsFixed(0)}',
                    style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.green),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 8),
          ],
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppTheme.primaryColor.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Итого:',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
                Text(
                  '₸${(cart.totalAmount * (1 - _discount)).toStringAsFixed(0)}',
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: AppTheme.primaryColor,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
        ],
      ),
    );
  }

  Widget _buildSummaryCard({
    required IconData icon,
    required String title,
    required String value,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: (Theme.of(context).cardTheme.color ?? Colors.white).withValues(
          alpha: 0.9,
        ),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          Icon(icon, color: AppTheme.primaryColor),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 12,
                    color: AppTheme.greyColor,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  value,
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required String hint,
    required IconData icon,
    int maxLines = 1,
    TextInputType keyboardType = TextInputType.text,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
        ),
        const SizedBox(height: 8),
        Container(
          decoration: BoxDecoration(
            color: (Theme.of(context).cardTheme.color ?? Colors.white)
                .withValues(alpha: 0.9),
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.03),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: TextField(
            controller: controller,
            maxLines: maxLines,
            keyboardType: keyboardType,
            decoration: InputDecoration(
              hintText: hint,
              hintStyle: const TextStyle(
                color: AppTheme.greyColor,
                fontSize: 14,
              ),
              prefixIcon: Icon(icon, color: AppTheme.primaryColor),
              border: InputBorder.none,
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 20,
                vertical: 16,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Future<void> _handleNext(CartProvider cart) async {
    if (_currentStep == 0) {
      // Валидация адреса и телефона
      if (_addressController.text.trim().isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('Введите адрес доставки'),
            backgroundColor: Colors.red[400],
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
          ),
        );
        return;
      }
      if (_phoneController.text.trim().length < 8) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('Введите корректный номер телефона'),
            backgroundColor: Colors.red[400],
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
          ),
        );
        return;
      }
      setState(() => _currentStep = 1);
    } else if (_currentStep == 1) {
      setState(() => _currentStep = 2);
    } else {
      // Place order
      if (!mounted) return;

      setState(() => _isLoading = true);

      try {
        final orderProvider = Provider.of<OrderProvider>(
          context,
          listen: false,
        );
        final partnerProvider = Provider.of<PartnerProvider>(
          context,
          listen: false,
        );

        // Пополняем баланс партнёра за каждый его товар в корзине
        for (final item in cart.items.values) {
          if (item.product != null) {
            partnerProvider.simulateSale(item.product!.id, item.quantity);
          }
        }

        // Создаём заказ (с учётом скидки по промокоду)
        final discountedTotal = cart.totalAmount * (1 - _discount);
        await orderProvider.addOrder(
          cart.items.values.toList(),
          discountedTotal,
          _addressController.text,
          _selectedPayment,
        );

        // Загружаем все заказы из Supabase
        await orderProvider.fetchOrders();

        // Обновляем данные партнера
        await partnerProvider.refreshProductsFromSupabase();

        cart.clear();

        if (!mounted) return;

        setState(() => _isLoading = false);

        // Show success dialog
        showDialog(
          context: context,
          barrierDismissible: false,
          builder: (ctx) => AlertDialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(24),
            ),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Colors.green.withValues(alpha: 0.1),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.check_circle,
                    color: Colors.green,
                    size: 64,
                  ),
                ),
                const SizedBox(height: 24),
                const Text(
                  'Заказ принят! 🎉',
                  style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 12),
                const Text(
                  'Ваш заказ в пути.\nМы скоро свяжемся с вами!',
                  style: TextStyle(color: AppTheme.greyColor, fontSize: 15),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 24),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.of(ctx).pop();
                      Navigator.of(context).pushAndRemoveUntil(
                        MaterialPageRoute(
                          builder: (context) => const MainScreen(),
                        ),
                        (route) => false,
                      );
                    },
                    child: const Text('На главную'),
                  ),
                ),
              ],
            ),
          ),
        );
      } catch (e) {
        if (!mounted) return;

        setState(() => _isLoading = false);

        debugPrint('Order error: $e');

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Ошибка заказа: ${e.toString()}'),
            backgroundColor: Colors.red[400],
            behavior: SnackBarBehavior.floating,
            duration: const Duration(seconds: 5),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
          ),
        );
      }
    }
  }
}
