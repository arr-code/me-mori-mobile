import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'core/router/app_router.dart';
import 'core/theme_mode_controller.dart';
import 'theme/mori_theme.dart';

class MeMoriApp extends ConsumerWidget {
  const MeMoriApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final mode = ref.watch(themeModeControllerProvider);
    final router = ref.watch(appRouterProvider);

    return MaterialApp.router(
      title: 'Me Mori',
      debugShowCheckedModeBanner: false,
      themeMode: mode,
      theme: MoriTheme.light(),
      darkTheme: MoriTheme.dark(),
      locale: const Locale('id', 'ID'),
      supportedLocales: const [Locale('id', 'ID'), Locale('en', 'US')],
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      routerConfig: router,
      builder: (context, child) {
        final overlay =
            Theme.of(context).extension<MoriColorsExtension>()?.systemOverlay;
        return AnnotatedRegion<SystemUiOverlayStyle>(
          value: overlay ?? SystemUiOverlayStyle.dark,
          child: MediaQuery.withClampedTextScaling(
            minScaleFactor: 0.9,
            maxScaleFactor: 1.3,
            child: child ?? const SizedBox.shrink(),
          ),
        );
      },
    );
  }
}
