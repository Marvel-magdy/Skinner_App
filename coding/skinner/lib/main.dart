import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:provider/provider.dart';
import 'package:skinner/theme/theme_provider.dart';
import 'package:skinner/l10n/app_translations.dart';
import 'package:skinner/splashScreen.dart';

void main() async {
  // Must be called before any platform-channel code (SharedPreferences, etc.)
  WidgetsFlutterBinding.ensureInitialized();

  // Pre-load providers so the first frame already has the correct theme/locale
  // and the splash screen renders immediately without a blank flash.
  final themeProvider  = ThemeProvider();
  final localeProvider = LocaleProvider();

  // Wait for both providers to finish reading from SharedPreferences
  await Future.wait([
    themeProvider.loadFromPrefs(),
    localeProvider.loadFromPrefs(),
  ]);

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider<ThemeProvider>.value(value: themeProvider),
        ChangeNotifierProvider<LocaleProvider>.value(value: localeProvider),
      ],
      child: const Skinner(),
    ),
  );
}

class Skinner extends StatelessWidget {
  const Skinner({super.key});

  @override
  Widget build(BuildContext context) {
    final themeProvider  = context.watch<ThemeProvider>();
    final localeProvider = context.watch<LocaleProvider>();

    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme:      ThemeProvider.lightTheme,
      darkTheme:  ThemeProvider.darkTheme,
      themeMode:  themeProvider.isDark ? ThemeMode.dark : ThemeMode.light,
      locale:     localeProvider.locale,
      supportedLocales: const [
        Locale('en'),
        Locale('ar'),
      ],
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      builder: (context, child) => LocaleScope(
        localeCode: localeProvider.locale.languageCode,
        child: Directionality(
          textDirection: localeProvider.locale.languageCode == 'ar'
              ? TextDirection.rtl
              : TextDirection.ltr,
          child: child!,
        ),
      ),
      home: const Splashscreen(),
    );
  }
}
