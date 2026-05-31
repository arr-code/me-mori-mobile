import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/date_symbol_data_local.dart';

import 'app.dart';
import 'firebase_options.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  // Firebase is only initialized for native platforms; web has no
  // DefaultFirebaseOptions configured yet, and nothing else in the app
  // depends on Firebase, so a failure here must not block startup.
  try {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
  } catch (e) {
    if (kDebugMode) debugPrint('Firebase init skipped: $e');
  }
  await initializeDateFormatting('id_ID');

  runApp(const ProviderScope(child: MeMoriApp()));
}
