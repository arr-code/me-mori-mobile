import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';

import '../../core/theme_mode_controller.dart';
import '../../l10n/copy_id.dart';
import '../../shared/extensions/context_theme.dart';
import '../../shared/extensions/date_id.dart';
import '../../shared/widgets/m_avatar.dart';
import '../../shared/widgets/m_button.dart';
import '../../shared/widgets/m_tag.dart';
import '../../shared/widgets/m_text_field.dart';
import '../../theme/mori_spacing.dart';

/// Temporary Phase 0 debug surface — exercises every shared widget against
/// the active theme. Remove or hide behind a /debug route in later phases.
class DebugThemeScreen extends ConsumerWidget {
  const DebugThemeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final mode = ref.watch(themeModeControllerProvider);
    final mori = context.mori;
    final now = DateTime.now();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Me Mori — Phase 0'),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: MoriSpacing.s4),
            child: MAvatar(name: 'Noia', size: 32),
          ),
        ],
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(
            MoriSpacing.s4,
            MoriSpacing.s2,
            MoriSpacing.s4,
            MoriSpacing.s8,
          ),
          children: [
            Text(DateId.longDate(now), style: context.text.headlineMedium),
            const SizedBox(height: MoriSpacing.s1),
            Text(
              'Phase 0 sanity check — toggle tema di bawah.',
              style: context.text.bodyMedium?.copyWith(color: mori.muted),
            ),
            const SizedBox(height: MoriSpacing.s6),

            _SectionLabel('Tema'),
            const SizedBox(height: MoriSpacing.s2),
            SegmentedButton<ThemeMode>(
              segments: const [
                ButtonSegment(
                  value: ThemeMode.light,
                  label: Text(CopyId.themeTerang),
                  icon: Icon(PhosphorIconsRegular.sun),
                ),
                ButtonSegment(
                  value: ThemeMode.dark,
                  label: Text(CopyId.themeGelap),
                  icon: Icon(PhosphorIconsRegular.moon),
                ),
                ButtonSegment(
                  value: ThemeMode.system,
                  label: Text(CopyId.themeOtomatis),
                  icon: Icon(PhosphorIconsRegular.circleHalf),
                ),
              ],
              selected: {mode},
              onSelectionChanged: (s) => ref
                  .read(themeModeControllerProvider.notifier)
                  .set(s.first),
            ),
            const SizedBox(height: MoriSpacing.s8),

            _SectionLabel('Tombol'),
            const SizedBox(height: MoriSpacing.s3),
            MButton(label: CopyId.daftar, onPressed: () {}),
            const SizedBox(height: MoriSpacing.s2),
            MButton(
              label: CopyId.login,
              onPressed: () {},
              variant: MButtonVariant.secondary,
            ),
            const SizedBox(height: MoriSpacing.s2),
            MButton(
              label: CopyId.lanjutGoogle,
              onPressed: () {},
              variant: MButtonVariant.ghost,
              leadingIcon: PhosphorIconsRegular.googleLogo,
            ),
            const SizedBox(height: MoriSpacing.s2),
            MButton(
              label: CopyId.ganti,
              onPressed: () {},
              variant: MButtonVariant.warn,
            ),
            const SizedBox(height: MoriSpacing.s2),
            MButton(
              label: CopyId.tetapTambah,
              onPressed: () {},
              variant: MButtonVariant.danger,
            ),
            const SizedBox(height: MoriSpacing.s2),
            MButton(
              label: CopyId.memuat,
              onPressed: () {},
              loading: true,
            ),
            const SizedBox(height: MoriSpacing.s2),
            const MButton(label: 'Disabled', onPressed: null),
            const SizedBox(height: MoriSpacing.s8),

            _SectionLabel('Input'),
            const SizedBox(height: MoriSpacing.s3),
            const MTextField(
              label: 'Username',
              hint: 'misal: noia',
              monospace: true,
              autofillHints: [AutofillHints.username],
            ),
            const SizedBox(height: MoriSpacing.s4),
            const MTextField(
              label: 'Password',
              obscureText: true,
              autofillHints: [AutofillHints.password],
            ),
            const SizedBox(height: MoriSpacing.s4),
            const MTextField(
              label: 'Tujuan',
              hint: 'Apa yang ingin dicapai 6 bulan ke depan?',
              maxLines: 3,
              minLines: 2,
            ),
            const SizedBox(height: MoriSpacing.s8),

            _SectionLabel('Tag kategori'),
            const SizedBox(height: MoriSpacing.s3),
            Wrap(
              spacing: MoriSpacing.s2,
              runSpacing: MoriSpacing.s2,
              children: [
                MTag.category(category: 'kerja'),
                MTag.category(category: 'klien'),
                MTag.category(category: 'fokus'),
                MTag.category(category: 'pribadi'),
                MTag.category(category: 'rutin'),
              ],
            ),
            const SizedBox(height: MoriSpacing.s8),

            _SectionLabel('Tipografi'),
            const SizedBox(height: MoriSpacing.s3),
            Text('Display 36', style: context.text.displayMedium),
            Text('Title 28', style: context.text.headlineMedium),
            Text('Heading 20', style: context.text.titleLarge),
            Text('Heading 17', style: context.text.titleMedium),
            Text('Body 15 — default copy line.', style: context.text.bodyLarge),
            Text('Body 14 — secondary.', style: context.text.bodyMedium),
            Text('CAPTION 12', style: context.text.bodySmall),
            Text('LABEL_SMALL_MONO', style: context.text.labelSmall),
          ],
        ),
      ),
    );
  }
}

class _SectionLabel extends StatelessWidget {
  final String text;
  const _SectionLabel(this.text);

  @override
  Widget build(BuildContext context) {
    return Text(
      text.toUpperCase(),
      style: context.text.labelSmall?.copyWith(color: context.mori.dim),
    );
  }
}
