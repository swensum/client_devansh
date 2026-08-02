import 'dart:async';

import 'package:devansh/Router/router.dart';
import 'package:devansh/firebase_options.dart';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_web_plugins/flutter_web_plugins.dart';
import 'package:go_router/go_router.dart';

Future<void> main() async {
  runZonedGuarded(
    () async {
      WidgetsFlutterBinding.ensureInitialized();

      GoRouter.optionURLReflectsImperativeAPIs = true;
      usePathUrlStrategy();

      await dotenv.load(fileName: ".env");

      SystemChrome.setSystemUIOverlayStyle(
        const SystemUiOverlayStyle(
          statusBarColor: Color(0xFF0A1929),
          statusBarIconBrightness: Brightness.light,
        ),
      );

      await Firebase.initializeApp(
        options: DefaultFirebaseOptions.currentPlatform,
      );

      FirebaseFirestore.instance.settings = const Settings(
        persistenceEnabled: true,
        webExperimentalForceLongPolling: true,
      );

      runApp(const MyApp());
    },
    (error, stack) {
      if (kDebugMode) {
        debugPrint('CAUGHT ERROR: $error');
        debugPrint('STACK: $stack');
      }
    },
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'Devansh Hardware',
      debugShowCheckedModeBanner: false,
      routerConfig: appRouter,
    );
  }
}
