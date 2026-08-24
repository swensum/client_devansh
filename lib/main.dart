import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:devansh/Router/router.dart';
import 'package:devansh/firebase_options.dart';
import 'package:devansh/utils/whatsappfloating.dart';
import 'package:devansh/widgets/scrolltotop_widgets.dart';
import 'package:firebase_core/firebase_core.dart';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_web_plugins/flutter_web_plugins.dart';
import 'package:go_router/go_router.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  GoRouter.optionURLReflectsImperativeAPIs = true;
  usePathUrlStrategy();

  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Color(0xFF0A1929),
      statusBarIconBrightness: Brightness.light,
    ),
  );

  try {
    await dotenv.load(fileName: ".env");

    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );

    FirebaseFirestore.instance.settings = const Settings(
      persistenceEnabled: true,
    );

    runApp(const MyApp());
  } catch (error, stack) {
    if (kDebugMode) {
      debugPrint('CAUGHT ERROR: $error');
      debugPrint('STACK: $stack');
    }

    runApp(
      const MaterialApp(
        debugShowCheckedModeBanner: false,
        home: Scaffold(
          backgroundColor: Color(0xFF0A1929),
          body: Center(
            child: Text(
              'Unable to initialize application.',
              style: TextStyle(color: Colors.white),
            ),
          ),
        ),
      ),
    );
  }
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  late final GoRouter _appRouter;

  @override
  void initState() {
    super.initState();
    _appRouter = createAppRouter();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'Devansh Suppliers',
      debugShowCheckedModeBanner: false,
      routerConfig: _appRouter,
      builder: (context, child) {
        return ScrollToTopOverlay(
          margin: const EdgeInsets.only(right: 24, bottom: 24),
          child: Stack(
            children: [
              ?child,
              const WhatsAppFloatButton(
                phoneNumber: "9779857033614",
                message: "Hi, I have a question about your products",
                alignment: Alignment.bottomLeft,
                margin: EdgeInsets.only(left: 24, bottom: 24),
              ),
            ],
          ),
        );
      },
    );
  }
}
