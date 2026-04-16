import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../main_screen.dart';
import '../../l10n/translation.dart';
import '../../providers/locale_provider.dart';
import '../../providers/auth_provider.dart';

class UserRegisterScreen extends StatefulWidget {
  const UserRegisterScreen({super.key});

  @override
  State<UserRegisterScreen> createState() => _UserRegisterScreenState();
}

class _UserRegisterScreenState extends State<UserRegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _phoneController = TextEditingController();
  bool _isLoading = false;

  Future<void> _register(Map<String, String> t) async {
    if (!(_formKey.currentState?.validate() ?? false)) return;

    setState(() => _isLoading = true);
    try {
      final auth = Provider.of<AuthProvider>(context, listen: false);
      final email = _emailController.text.trim();
      final needsOtp = await auth.register(
        email,
        _passwordController.text.trim(),
        _nameController.text.trim(),
      );

      if (mounted) {
        if (needsOtp) {
          _showOtpDialog(email, t);
        } else {
          _showSuccess(t);
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Ошибка: $e')));
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  void _showOtpDialog(String email, Map<String, String> t) {
    final otpController = TextEditingController();
    bool isVerifying = false;

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => StatefulBuilder(
        builder: (context, setStateDialog) => AlertDialog(
          title: Text(t['email_confirm'] ?? 'Подтверждение Email'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(t['email_code_sent'] ?? 'Мы отправили код подтверждения на ваш email. Введите его ниже:'),
              const SizedBox(height: 16),
              TextField(
                controller: otpController,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(
                  labelText: t['code_from_email'] ?? 'Код из Email',
                  border: OutlineInputBorder(),
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: isVerifying ? null : () => Navigator.pop(ctx),
              child: Text(t['cancel'] ?? 'Отмена'),
            ),
            ElevatedButton(
              onPressed: isVerifying
                  ? null
                  : () async {
                      setStateDialog(() => isVerifying = true);
                      try {
                         final auth = Provider.of<AuthProvider>(context, listen: false);
                         await auth.verifyOTP(email, otpController.text.trim());
                         if (mounted) {
                           Navigator.pop(ctx);
                           _showSuccess(t);
                         }
                      } catch (e) {
                        setStateDialog(() => isVerifying = false);
                        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Ошибка кода: $e')));
                      }
                    },
              child: isVerifying ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator()) : Text(t['confirm'] ?? 'Подтвердить'),
            ),
          ],
        ),
      ),
    );
  }

  void _showSuccess(Map<String, String> t) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(t['success']!),
        content: Text(t['reg_user_success']!),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(ctx);
              Navigator.of(context).pushAndRemoveUntil(
                MaterialPageRoute(builder: (context) => const MainScreen()),
                (route) => false,
              );
            },
            child: Text(t['ok']!),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final localeProvider = Provider.of<LocaleProvider>(context);
    final langCode = localeProvider.locale.languageCode;
    final t = AppTranslation.translations[langCode] ?? AppTranslation.translations['ru']!;

    return Scaffold(
      appBar: AppBar(
        title: Text(t['reg_user_title']!),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                t['reg_create_account']!,
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              Text(
                t['reg_user_desc']!,
                textAlign: TextAlign.center,
                style: const TextStyle(color: Colors.grey),
              ),
              const SizedBox(height: 32),
              TextFormField(
                controller: _nameController,
                textInputAction: TextInputAction.next,
                decoration: InputDecoration(
                  labelText: t['full_name']!,
                  prefixIcon: const Icon(Icons.person),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                validator: (value) => value!.isEmpty ? t['enter_name'] : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _phoneController,
                textInputAction: TextInputAction.next,
                decoration: InputDecoration(
                  labelText: t['phone_number']!,
                  prefixIcon: const Icon(Icons.phone),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                keyboardType: TextInputType.phone,
                validator: (value) => value!.isEmpty ? t['enter_phone'] : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _emailController,
                textInputAction: TextInputAction.next,
                decoration: InputDecoration(
                  labelText: t['email']!,
                  prefixIcon: const Icon(Icons.email),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                keyboardType: TextInputType.emailAddress,
                validator: (value) => value!.isEmpty ? t['enter_email'] : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _passwordController,
                textInputAction: TextInputAction.done,
                onFieldSubmitted: (_) => _register(t),
                decoration: InputDecoration(
                  labelText: t['password']!,
                  prefixIcon: const Icon(Icons.lock),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                obscureText: true,
                validator: (value) => value!.length < 6 ? t['pass_min_6'] : null,
              ),
              const SizedBox(height: 32),
              SizedBox(
                height: 50,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : () => _register(t),
                  style: ElevatedButton.styleFrom(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: _isLoading 
                      ? const CircularProgressIndicator() 
                      : Text(t['register_btn']!, style: const TextStyle(fontSize: 16)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
