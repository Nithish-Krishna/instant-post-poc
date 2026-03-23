import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import 'core/config/app_environment.dart';
import 'core/theme/app_theme.dart';
import 'features/magic_post/presentation/screens/magic_generator_screen.dart';

void main() {
  // Only apply SystemUIOverlayStyle on mobile (iOS/Android) to avoid web console warnings
  if (!kIsWeb) {
    SystemChrome.setSystemUIOverlayStyle(
      const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.light,
      ),
    );
  }
  
  runApp(
    ChangeNotifierProvider(
      create: (_) => AppEnvironment(),
      child: const AIMagicApp(),
    ),
  );
}

class AIMagicApp extends StatelessWidget {
  const AIMagicApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'AI Instagram Generator',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.darkTheme,
      home: Scaffold(
        backgroundColor: AppTheme.darkTheme.scaffoldBackgroundColor,
        body: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 480),
            // The constraint ensures web PWA feels like mobile
            child: const MagicGeneratorScreen(),
          ),
        ),
      ),
    );
  }
}
