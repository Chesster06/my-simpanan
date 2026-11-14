import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'providers/savings_provider.dart';
import 'repositories/savings_repository.dart';
import 'screens/splash_screen.dart';
import 'services/locale_service.dart';
import 'theme/app_theme.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize SharedPreferences & LocaleService
  await SharedPreferences.getInstance();
  await LocaleService.instance.initialize();

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
    return ListenableBuilder(
      listenable: LocaleService.instance,
      builder: (context, _) {
        return MaterialApp(
          title: 'MySimpanan',
          debugShowCheckedModeBanner: false,
          theme: AppTheme.lightTheme,
          builder: (context, child) {
            return AnimatedSwitcher(
              duration: const Duration(milliseconds: 350),
              switchInCurve: Curves.easeOut,
              switchOutCurve: Curves.easeIn,
              transitionBuilder: (child, animation) {
                return FadeTransition(opacity: animation, child: child);
              },
              child: KeyedSubtree(
                key: ValueKey(LocaleService.instance.langCode),
                child: child ?? const SizedBox.shrink(),
              ),
            );
          },
          home: SplashScreen(savingsProvider: savingsProvider),
        );
      },
    );
  }
}
