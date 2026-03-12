import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../main_screen.dart';
import '../../l10n/translation.dart';
import '../../providers/locale_provider.dart';

class DeveloperRegisterScreen extends StatefulWidget {
  const DeveloperRegisterScreen({Key? key}) : super(key: key);

  @override
  State<DeveloperRegisterScreen> createState() => _DeveloperRegisterScreenState();
}

class _DeveloperRegisterScreenState extends State<DeveloperRegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  
  final _companyNameController = TextEditingController();
  final _representativeNameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _websiteController = TextEditingController();
  final _apiIntentController = TextEditingController();
  final _passwordController = TextEditingController();
  
  bool _agreedToTerms = false;
  bool _agreedToApiGuidelines = false;

  void _register(Map<String, String> t) {
    if (_formKey.currentState?.validate() ?? false) {
      if (!_agreedToTerms || !_agreedToApiGuidelines) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(t['need_agree']!)),
        );
        return;
      }
      
      showDialog(
        context: context,
        builder: (ctx) => AlertDialog(
          title: Text(t['app_sent']!, style: const TextStyle(color: Colors.green)),
          content: Text(t['app_sent_desc']!),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(ctx);
                Navigator.of(context).pushAndRemoveUntil(
                  MaterialPageRoute(builder: (context) => const MainScreen()),
                  (route) => false,
                );
              },
              child: Text(t['understood']!),
            ),
          ],
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final localeProvider = Provider.of<LocaleProvider>(context);
    final langCode = localeProvider.locale.languageCode;
    final t = AppTranslation.translations[langCode] ?? AppTranslation.translations['ru']!;

    return Scaffold(
      appBar: AppBar(
        title: Text(t['reg_dev_title']!),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Icon(Icons.code, size: 60, color: Colors.deepPurple),
              const SizedBox(height: 16),
              Text(
                t['partner_program']!,
                style: const TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: Colors.deepPurple,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              Text(
                t['reg_dev_desc']!,
                textAlign: TextAlign.center,
                style: const TextStyle(color: Colors.grey),
              ),
              const SizedBox(height: 32),
              
              Text(t['main_info']!, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
              const SizedBox(height: 16),
              TextFormField(
                controller: _companyNameController,
                decoration: InputDecoration(
                  labelText: t['company_name']!,
                  prefixIcon: const Icon(Icons.business),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                ),
                validator: (value) => value!.isEmpty ? t['enter_name'] : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _representativeNameController,
                decoration: InputDecoration(
                  labelText: t['rep_name']!,
                  prefixIcon: const Icon(Icons.person),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                ),
                validator: (value) => value!.isEmpty ? t['enter_name'] : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _websiteController,
                decoration: InputDecoration(
                  labelText: t['website']!,
                  prefixIcon: const Icon(Icons.language),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                ),
                keyboardType: TextInputType.url,
              ),
              
              const SizedBox(height: 32),
              Text(t['contact_data']!, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
              const SizedBox(height: 16),
              TextFormField(
                controller: _phoneController,
                decoration: InputDecoration(
                  labelText: t['work_phone']!,
                  prefixIcon: const Icon(Icons.phone),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                ),
                keyboardType: TextInputType.phone,
                validator: (value) => value!.isEmpty ? t['enter_phone'] : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _emailController,
                decoration: InputDecoration(
                  labelText: t['corp_email']!,
                  prefixIcon: const Icon(Icons.email),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                ),
                keyboardType: TextInputType.emailAddress,
                validator: (value) => value!.isEmpty ? t['enter_email'] : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _passwordController,
                decoration: InputDecoration(
                  labelText: t['dev_password']!,
                  prefixIcon: const Icon(Icons.lock),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                ),
                obscureText: true,
                validator: (value) => value!.length < 8 ? t['pass_min_6'] : null,
              ),
              
              const SizedBox(height: 32),
              Text(t['integration_details']!, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
              const SizedBox(height: 16),
              TextFormField(
                controller: _apiIntentController,
                decoration: InputDecoration(
                  labelText: t['api_intent']!,
                  alignLabelWithHint: true,
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                ),
                maxLines: 4,
                validator: (value) => value!.isEmpty ? 'error' : null,
              ),
              
              const SizedBox(height: 24),
              CheckboxListTile(
                contentPadding: EdgeInsets.zero,
                title: Text(t['agree_terms']!, style: const TextStyle(fontSize: 14)),
                value: _agreedToTerms,
                onChanged: (val) {
                  setState(() => _agreedToTerms = val ?? false);
                },
              ),
              CheckboxListTile(
                contentPadding: EdgeInsets.zero,
                title: Text(t['agree_api']!, style: const TextStyle(fontSize: 14)),
                value: _agreedToApiGuidelines,
                onChanged: (val) {
                  setState(() => _agreedToApiGuidelines = val ?? false);
                },
              ),
              
              const SizedBox(height: 32),
              SizedBox(
                height: 50,
                child: ElevatedButton(
                  onPressed: () => _register(t),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.deepPurple,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: Text(t['submit_app']!, style: const TextStyle(fontSize: 16)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
