import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../shared/extensions/context_theme.dart';
import '../../../theme/mori_spacing.dart';

/// Layout shell shared by register & login screens:
///   ┌─ AppBar with rounded back tile
///   │  Header (title + subtitle)
///   │  Scrollable body content
///   ├──────── divider ─────────
///   │  Sticky footer (CTA + secondary actions)
///   └────────────────────────
class AuthShell extends StatelessWidget {
  final String title;
  final String subtitle;
  final List<Widget> body;
  final Widget footer;

  const AuthShell({
    super.key,
    required this.title,
    required this.subtitle,
    required this.body,
    required this.footer,
  });

  @override
  Widget build(BuildContext context) {
    final mori = context.mori;
    return Scaffold(
      body: SafeArea(
        bottom: false,
        child: Column(
          children: [
            _BackBar(),
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 16, 24, 0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: context.text.headlineMedium),
                  const SizedBox(height: 6),
                  Text(
                    subtitle,
                    style: context.text.bodyMedium?.copyWith(
                      color: mori.muted,
                      fontSize: 14,
                      height: 1.45,
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: ListView(
                padding: const EdgeInsets.fromLTRB(24, 20, 24, 16),
                children: body,
              ),
            ),
            DecoratedBox(
              decoration: BoxDecoration(
                color: Theme.of(context).scaffoldBackgroundColor,
                border: Border(
                  top: BorderSide(color: mori.borderSo, width: 1),
                ),
              ),
              child: SafeArea(
                top: false,
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(
                    24,
                    12,
                    24,
                    MoriSpacing.s4,
                  ),
                  child: footer,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _BackBar extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final mori = context.mori;
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
      child: Align(
        alignment: Alignment.centerLeft,
        child: Semantics(
          button: true,
          label: 'Kembali',
          child: GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTap: () {
              if (context.canPop()) context.pop();
            },
            child: Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.surface,
                border: Border.all(color: mori.border, width: 1),
                borderRadius: BorderRadius.circular(10),
              ),
              alignment: Alignment.center,
              child: Icon(
                Icons.arrow_back_ios_new_rounded,
                size: 16,
                color: mori.muted,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
