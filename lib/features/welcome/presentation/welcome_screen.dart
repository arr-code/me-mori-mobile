import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../shared/extensions/context_theme.dart';
import '../../../shared/widgets/m_button.dart';
import '../../../shared/widgets/mori_icon.dart';
import '../../../shared/widgets/mori_wordmark.dart';
import '../../../theme/mori_colors.dart';
import '../../../theme/mori_spacing.dart';
import '../../auth/presentation/_auth_bg.dart';

/// Landing surface for first-time visitors / users without a live
/// session. Brand block + three value-prop pillars + "Mulai" CTA.
/// Replaces the boot-time splash visually — the Crest splash is now
/// a brand-only loader shown during AuthUnknown.
class WelcomeScreen extends StatelessWidget {
  const WelcomeScreen({super.key});

  static const _pillars = <(String, String)>[
    ('Atur jadwal lewat obrolan', 'Cukup ketik. Mori siapkan agenda.'),
    ('Pengingat yang ringkas', 'Tidak banyak notifikasi. Hanya yang penting.'),
    ('Kontrol penuh di tangan kamu', 'Setiap aksi butuh persetujuan kamu dulu.'),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: AuthGradientBg(
        child: SafeArea(
          minimum: const EdgeInsets.fromLTRB(
            MoriSpacing.s8,
            56,
            MoriSpacing.s8,
            MoriSpacing.s8,
          ),
          child: LayoutBuilder(
            builder: (context, c) {
              return SingleChildScrollView(
                physics: const ClampingScrollPhysics(),
                child: ConstrainedBox(
                  constraints: BoxConstraints(minHeight: c.maxHeight),
                  child: IntrinsicHeight(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        const Spacer(flex: 2),
                        const _BrandHeader(),
                        const Spacer(flex: 2),
                        const _PillarStack(items: _pillars),
                        const Spacer(flex: 2),
                        MButton(
                          label: 'Mulai',
                          size: MButtonSize.lg,
                          onPressed: () => context.go('/signin-select'),
                        ),
                        const SizedBox(height: MoriSpacing.s3),
                        Center(
                          child: Text(
                            'v1.0 · Bahasa Indonesia',
                            style: context.text.bodySmall
                                ?.copyWith(color: context.mori.dim),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}

class _BrandHeader extends StatelessWidget {
  const _BrandHeader();

  @override
  Widget build(BuildContext context) {
    final mori = context.mori;
    return Column(
      children: [
        const MoriIcon(size: 128, glow: true),
        const SizedBox(height: MoriSpacing.s6),
        const MoriWordmark(size: 40),
        const SizedBox(height: 10),
        Text(
          'Asisten jadwal & pengingat',
          style: context.text.bodyLarge?.copyWith(
            color: mori.muted,
            fontSize: 16,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }
}

class _PillarStack extends StatelessWidget {
  final List<(String, String)> items;
  const _PillarStack({required this.items});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        for (var i = 0; i < items.length; i++) ...[
          if (i != 0) const SizedBox(height: MoriSpacing.s3),
          _PillarCard(index: i + 1, title: items[i].$1, subtitle: items[i].$2),
        ],
      ],
    );
  }
}

class _PillarCard extends StatelessWidget {
  final int index;
  final String title;
  final String subtitle;

  const _PillarCard({
    required this.index,
    required this.title,
    required this.subtitle,
  });

  @override
  Widget build(BuildContext context) {
    final mori = context.mori;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: MoriSpacing.s4,
        vertical: 14,
      ),
      decoration: BoxDecoration(
        color: isDark
            ? Colors.white.withValues(alpha: 0.03)
            : Colors.white.withValues(alpha: 0.5),
        borderRadius: BorderRadius.circular(MoriRadius.lg),
        border: Border.all(color: mori.borderSo),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 28,
            height: 28,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(8),
              gradient: const LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [MoriColors.accent, MoriColors.accentSo],
              ),
            ),
            alignment: Alignment.center,
            child: Text(
              '$index',
              style: context.text.labelLarge?.copyWith(
                color: MoriColors.accentFg,
                fontSize: 13,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: context.text.bodyLarge?.copyWith(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    letterSpacing: -0.1,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  subtitle,
                  style: context.text.bodySmall?.copyWith(
                    fontSize: 12.5,
                    color: mori.muted,
                    height: 1.4,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
