import 'package:flutter/material.dart';
import '../theme.dart';
import 'addresses_screen.dart';
import 'payment_methods_screen.dart';
import 'order_history_screen.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Профиль'),
        centerTitle: true,
        automaticallyImplyLeading: false,
        actions: [
          IconButton(
            icon: const Icon(Icons.settings_outlined),
            onPressed: () {
              // Settings implementation
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          children: [
            const CircleAvatar(
              radius: 50,
              backgroundImage: NetworkImage('https://images.unsplash.com/photo-1535713875002-d1d0cf377fde?ixlib=rb-4.0.3&auto=format&fit=crop&w=100&q=80'),
            ),
            const SizedBox(height: 16),
            const Text(
              'Айдар Нұрғалиев',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: AppTheme.textColor),
            ),
            const SizedBox(height: 4),
            Text(
              'aydarn@example.com',
              style: TextStyle(fontSize: 16, color: AppTheme.greyColor),
            ),
            const SizedBox(height: 4),
            Text(
              '+7 (705) 123 45 67',
              style: TextStyle(fontSize: 14, color: AppTheme.greyColor),
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: () {},
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.accentColor,
                foregroundColor: AppTheme.primaryColor,
                minimumSize: const Size(double.infinity, 50),
              ),
              child: const Text('Профильді өңдеу'),
            ),
            const SizedBox(height: 32),
            _buildProfileMenuItem(
              context,
              icon: Icons.location_on_outlined,
              title: 'Жеткізу мекенжайлары',
              onTap: () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => const AddressesScreen())),
            ),
            _buildProfileMenuItem(
              context,
              icon: Icons.payment_outlined,
              title: 'Төлем тәсілдері',
              onTap: () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => const PaymentMethodsScreen())),
            ),
            _buildProfileMenuItem(
              context,
              icon: Icons.history_outlined,
              title: 'Тапсырыстар тарихы',
              onTap: () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => const OrderHistoryScreen())),
            ),
            _buildProfileMenuItem(
              context,
              icon: Icons.local_offer_outlined,
              title: 'Промокодтар',
              onTap: () {},
            ),
            const SizedBox(height: 24),
            _buildProfileMenuItem(
              context,
              icon: Icons.logout,
              title: 'Шығу',
              textColor: Colors.red,
              iconColor: Colors.red,
              showChevron: false,
              onTap: () {},
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProfileMenuItem(
    BuildContext context, {
    required IconData icon,
    required String title,
    required VoidCallback onTap,
    Color textColor = AppTheme.textColor,
    Color iconColor = AppTheme.primaryColor,
    bool showChevron = true,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Theme.of(context).cardTheme.color ?? Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 10,
            offset: const Offset(0, 4),
          )
        ],
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
        leading: Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: iconColor.withOpacity(0.1),
            shape: BoxShape.circle,
          ),
          child: Icon(icon, color: iconColor),
        ),
        title: Text(
          title,
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: textColor,
          ),
        ),
        trailing: showChevron ? const Icon(Icons.chevron_right, color: AppTheme.greyColor) : null,
        onTap: onTap,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      ),
    );
  }
}
