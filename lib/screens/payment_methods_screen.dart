import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../providers/payment_method_provider.dart';
import '../models/payment_card_model.dart';
import '../theme.dart';

class PaymentMethodsScreen extends StatefulWidget {
  const PaymentMethodsScreen({super.key});

  @override
  State<PaymentMethodsScreen> createState() => _PaymentMethodsScreenState();
}

class _PaymentMethodsScreenState extends State<PaymentMethodsScreen> {
  @override
  void initState() {
    super.initState();
    Future.microtask(() => 
      Provider.of<PaymentMethodProvider>(context, listen: false).fetchCards()
    );
  }

  @override
  Widget build(BuildContext context) {
    final paymentProvider = Provider.of<PaymentMethodProvider>(context);
    final cards = paymentProvider.cards;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Төлем карталары'),
        centerTitle: true,
      ),
      body: cards.isEmpty
        ? const Center(child: Text('У вас пока нет сохраненных карт'))
        : ListView.builder(
            padding: const EdgeInsets.all(20),
            itemCount: cards.length,
            itemBuilder: (ctx, i) {
              final card = cards[i];
              return Container(
                margin: const EdgeInsets.only(bottom: 16),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      AppTheme.primaryColor,
                      AppTheme.primaryColor.withOpacity(0.8),
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: AppTheme.primaryColor.withOpacity(0.3),
                      blurRadius: 12,
                      offset: const Offset(0, 6),
                    ),
                  ],
                ),
                child: Padding(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            card.cardType,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              letterSpacing: 1.2,
                            ),
                          ),
                          IconButton(
                            icon: const Icon(Icons.delete_outline, color: Colors.white70),
                            onPressed: () => paymentProvider.deleteCard(card.id!),
                          ),
                        ],
                      ),
                      const SizedBox(height: 32),
                      Text(
                        '**** **** **** ${card.lastFour}',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 22,
                          letterSpacing: 4,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const SizedBox(height: 32),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'CARD HOLDER',
                                style: TextStyle(
                                  color: Colors.white70,
                                  fontSize: 10,
                                  letterSpacing: 1,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                card.cardHolder.toUpperCase(),
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 14,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'EXPIRES',
                                style: TextStyle(
                                  color: Colors.white70,
                                  fontSize: 10,
                                  letterSpacing: 1,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                card.expiryDate,
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 14,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showAddCardDialog(context),
        backgroundColor: AppTheme.primaryColor,
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }

  void _showAddCardDialog(BuildContext context) {
    final holderController = TextEditingController();
    final numberController = TextEditingController();
    final expiryController = TextEditingController();
    final typeController = TextEditingController(text: 'Visa');

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Новая карта'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(controller: holderController, decoration: const InputDecoration(labelText: 'Владелец (LATIN)')),
              TextField(controller: numberController, decoration: const InputDecoration(labelText: 'Номер (последние 4 цифры)')),
              TextField(controller: expiryController, decoration: const InputDecoration(labelText: 'Срок (MM/YY)')),
              TextField(controller: typeController, decoration: const InputDecoration(labelText: 'Тип (Visa/Mastercard)')),
            ],
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Отмена')),
          TextButton(
            onPressed: () {
              final card = PaymentCardModel(
                userId: Supabase.instance.client.auth.currentUser!.id,
                cardHolder: holderController.text,
                lastFour: numberController.text,
                expiryDate: expiryController.text,
                cardType: typeController.text,
              );
              Provider.of<PaymentMethodProvider>(context, listen: false).addCard(card);
              Navigator.pop(ctx);
            },
            child: const Text('Добавить'),
          ),
        ],
      ),
    );
  }
}
