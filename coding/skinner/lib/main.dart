import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:provider/provider.dart';
import 'package:skinner/theme/theme_provider.dart';
import 'package:skinner/l10n/app_translations.dart';
import 'package:skinner/splashScreen.dart';

void main() {
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => ThemeProvider()),
        ChangeNotifierProvider(create: (_) => LocaleProvider()),
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
      // Inject the locale code into the entire widget tree
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
