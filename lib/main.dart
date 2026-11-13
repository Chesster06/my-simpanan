import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'providers/savings_provider.dart';
import 'repositories/savings_repository.dart';
import 'screens/dashboard_screen.dart';
import 'theme/app_theme.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize SharedPreferences
  await SharedPreferences.getInstance();

  const repository = SharedPrefsSavingsRepository();
  final savingsProvider = SavingsProvider(repository: repository);
  await savingsProvider.initialize();

  runApp(MySimpananApp(savingsProvider: savingsProvider));
}

class MySimpananApp extends StatelessWidget {
  final SavingsProvider savingsProvider;

  const MySimpananApp({
    super.key,
    required this.savingsProvider,
  });

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'MySimpanan',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      home: DashboardScreen(provider: savingsProvider),
    );
  }
}
