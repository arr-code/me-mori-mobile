import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/theme_mode_controller.dart';
import '../../../l10n/copy_id.dart';
import '../../../shared/extensions/context_theme.dart';
import '../../../theme/mori_colors.dart';
import '../../auth/application/auth_controller.dart';
import '../../auth/application/auth_state.dart';
import '../../auth/data/models/user.dart';
import '../application/profile_controller.dart';
import '_edit_field_sheet.dart';
import '_settings_widgets.dart';

/// Design's `Profil & pengaturan` screen — 6 grouped sections plus a hero
/// header. Tappable rows open an [EditFieldSheet]; the theme row swaps in
/// a segmented control wired to [themeModeControllerProvider].
class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = switch (ref.watch(authControllerProvider)) {
      Authenticated(user: final u) => u,
      _ => null,
    };

    if (user == null) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      body: SafeArea(
        bottom: false,
        child: Column(
          children: [
            _TopBar(onBack: () =>
                context.canPop() ? context.pop() : context.go('/home')),
            _Hero(user: user),
            Expanded(
              child: ListView(
                padding: const EdgeInsets.fromLTRB(16, 4, 16, 32),
                children: [
                  _ProfilGroup(user: user),
                  _AkunGroup(user: user),
                  _PreferensiGroup(user: user),
                  const _PrivasiGroup(),
                  const _TentangGroup(),
                  _LogoutGroup(user: user),
                  const _Footer(),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Top bar ─────────────────────────────────────────────────────────────

class _TopBar extends StatelessWidget {
  final VoidCallback onBack;
  const _TopBar({required this.onBack});

  @override
  Widget build(BuildContext context) {
    final mori = context.mori;
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
      child: Row(
        children: [
          Semantics(
            button: true,
            label: 'Kembali',
            child: GestureDetector(
              behavior: HitTestBehavior.opaque,
              onTap: onBack,
              child: Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: context.cs.surface,
                  border: Border.all(color: mori.border),
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
          Expanded(
            child: Center(
              child: Text(
                CopyId.profileTitle,
                style: context.text.titleMedium?.copyWith(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  letterSpacing: -0.2,
                ),
              ),
            ),
          ),
          const SizedBox(width: 36),
        ],
      ),
    );
  }
}

// ── Hero ────────────────────────────────────────────────────────────────

class _Hero extends StatelessWidget {
  final User user;
  const _Hero({required this.user});

  @override
  Widget build(BuildContext context) {
    final mori = context.mori;
    final initial = (user.name.isEmpty ? '?' : user.name.characters.first).toUpperCase();
    final bg = Theme.of(context).scaffoldBackgroundColor;

    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 8, 20, 22),
      child: Column(
        children: [
          SizedBox(
            width: 100,
            height: 100,
            child: Stack(
              clipBehavior: Clip.none,
              children: [
                Container(
                  width: 88,
                  height: 88,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: const LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [MoriColors.accent, MoriColors.accentSo],
                    ),
                    image: user.pictureUrl == null
                        ? null
                        : DecorationImage(
                            image: NetworkImage(user.pictureUrl!),
                            fit: BoxFit.cover,
                          ),
                    boxShadow: [
                      BoxShadow(
                        color: MoriColors.accent.withValues(alpha: 0.55),
                        blurRadius: 14,
                        spreadRadius: -4,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  alignment: Alignment.center,
                  child: user.pictureUrl != null
                      ? null
                      : Text(
                          initial,
                          style: context.text.headlineMedium?.copyWith(
                            color: MoriColors.accentFg,
                            fontSize: 36,
                            fontWeight: FontWeight.w700,
                            letterSpacing: -0.5,
                          ),
                        ),
                ),
                Positioned(
                  bottom: -2,
                  right: -2,
                  child: Container(
                    width: 28,
                    height: 28,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: mori.panel2,
                      border: Border.all(color: bg, width: 2),
                    ),
                    alignment: Alignment.center,
                    child: Icon(
                      Icons.edit_outlined,
                      size: 12,
                      color: mori.muted,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          Text(
            user.name,
            style: context.text.titleLarge?.copyWith(
              fontSize: 22,
              fontWeight: FontWeight.w700,
              letterSpacing: -0.4,
            ),
          ),
          if ((user.username ?? '').isNotEmpty) ...[
            const SizedBox(height: 2),
            Text(
              '@${user.username}',
              style: context.text.bodySmall?.copyWith(
                fontSize: 13,
                color: mori.muted,
                fontFamily: 'JetBrainsMono',
              ),
            ),
          ],
        ],
      ),
    );
  }
}

// ── Profil group ────────────────────────────────────────────────────────

class _ProfilGroup extends ConsumerWidget {
  final User user;
  const _ProfilGroup({required this.user});

  Future<void> _edit(
    BuildContext context,
    WidgetRef ref, {
    required String title,
    required String subtitle,
    required ProfileField field,
    required String? currentValue,
    bool required = false,
    bool multiline = false,
  }) async {
    await EditFieldSheet.show(
      context,
      title: title,
      subtitle: subtitle,
      fieldLabel: title,
      initialValue: currentValue,
      required: required,
      multiline: multiline,
      onSave: (v) =>
          ref.read(profileControllerProvider).updateField(field, v),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final hasBio = (user.bio ?? '').isNotEmpty;
    return SettingsGroup(
      title: CopyId.profileGroupProfil,
      children: [
        SettingsRow(
          label: CopyId.profileRowProfesi,
          value: user.profession ?? CopyId.profileEmptyValue,
          onTap: () => _edit(
            context, ref,
            title: CopyId.profileRowProfesi,
            subtitle: 'Pekerjaan kamu sekarang.',
            field: ProfileField.profession,
            currentValue: user.profession,
            required: true,
          ),
        ),
        SettingsRow(
          label: CopyId.profileRowTujuan,
          value: user.goals ?? CopyId.profileEmptyValue,
          multiline: true,
          onTap: () => _edit(
            context, ref,
            title: CopyId.profileRowTujuan,
            subtitle: 'Apa yang ingin dicapai beberapa bulan ke depan.',
            field: ProfileField.goals,
            currentValue: user.goals,
            required: true,
            multiline: true,
          ),
        ),
        SettingsRow(
          label: CopyId.profileRowPolaKerja,
          value: user.workingPattern ?? CopyId.profileEmptyValue,
          multiline: true,
          onTap: () => _edit(
            context, ref,
            title: CopyId.profileRowPolaKerja,
            subtitle: 'Jam kerja, istirahat, ritme mingguan.',
            field: ProfileField.workingPattern,
            currentValue: user.workingPattern,
            required: true,
            multiline: true,
          ),
        ),
        SettingsRow(
          label: CopyId.profileRowAturan,
          value: user.personalRules?.isNotEmpty == true
              ? user.personalRules
              : 'Belum ada',
          multiline: true,
          onTap: () => _edit(
            context, ref,
            title: CopyId.profileRowAturan,
            subtitle: 'Batasan yang Mori harus hormati. Opsional.',
            field: ProfileField.personalRules,
            currentValue: user.personalRules,
            multiline: true,
          ),
        ),
        SettingsRow(
          label: CopyId.profileRowBio,
          value: hasBio ? user.bio : CopyId.profileBioEmpty,
          hint: hasBio ? null : CopyId.profileBioEmptyHint,
          multiline: hasBio,
          isLast: true,
          onTap: () => _edit(
            context, ref,
            title: CopyId.profileRowBio,
            subtitle: 'Sedikit cerita tentang kamu. Opsional.',
            field: ProfileField.bio,
            currentValue: user.bio,
            multiline: true,
          ),
        ),
      ],
    );
  }
}

// ── Akun group ──────────────────────────────────────────────────────────

class _AkunGroup extends ConsumerWidget {
  final User user;
  const _AkunGroup({required this.user});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isGoogle = user.authType == 'google';
    final hasEmail = (user.email ?? '').isNotEmpty;

    return SettingsGroup(
      title: CopyId.profileGroupAkun,
      children: [
        SettingsRow(
          label: CopyId.profileRowUsername,
          value: user.username ?? CopyId.profileEmptyValue,
          locked: true,
          monospaceValue: true,
          chevron: false,
          right: const Pill(
            label: CopyId.profileLockedPill,
            color: Color(0xFFA7A9BE),
            background: Color(0x1AA7A9BE),
          ),
        ),
        SettingsRow(
          label: CopyId.profileRowName,
          value: user.name,
          hint: CopyId.profileRowNameHint,
          onTap: () => EditFieldSheet.show(
            context,
            title: CopyId.profileRowName,
            subtitle: CopyId.profileRowNameHint,
            fieldLabel: CopyId.profileRowName,
            initialValue: user.name,
            required: true,
            maxLength: 60,
            onSave: (v) => ref
                .read(profileControllerProvider)
                .updateField(ProfileField.name, v),
          ),
        ),
        if (isGoogle)
          SettingsRow(
            label: CopyId.profileRowGoogle,
            value: user.email,
            chevron: false,
            isLast: true,
            right: const Pill(label: CopyId.profileGoogleConnectedPill),
          )
        else
          SettingsRow(
            label: CopyId.profileRowEmail,
            value: hasEmail ? user.email : CopyId.profileEmptyValue,
            hint: hasEmail ? null : CopyId.profileRowEmailHint,
            chevron: false,
            isLast: true,
          ),
      ],
    );
  }
}

// ── Preferensi group ────────────────────────────────────────────────────

class _PreferensiGroup extends ConsumerStatefulWidget {
  final User user;
  const _PreferensiGroup({required this.user});

  @override
  ConsumerState<_PreferensiGroup> createState() => _PreferensiGroupState();
}

class _PreferensiGroupState extends ConsumerState<_PreferensiGroup> {
  // Notifikasi toggle is local-only for now — backend doesn't expose a
  // notification-prefs endpoint yet. Persists to SharedPreferences later.
  bool _notifications = true;

  void _showComingSoon() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text(CopyId.profileComingSoon),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final user = widget.user;
    final timezone = user.timezone?.isNotEmpty == true
        ? user.timezone!
        : CopyId.profileEmptyValue;

    return SettingsGroup(
      title: CopyId.profileGroupPreferensi,
      children: [
        SettingsRow(
          label: CopyId.profileRowTimezone,
          value: timezone,
          onTap: () => EditFieldSheet.show(
            context,
            title: CopyId.profileRowTimezone,
            subtitle: 'Contoh: Asia/Jakarta',
            fieldLabel: CopyId.profileRowTimezone,
            fieldHint: 'Asia/Jakarta',
            initialValue: user.timezone,
            required: true,
            onSave: (v) => ref
                .read(profileControllerProvider)
                .updateField(ProfileField.timezone, v),
          ),
        ),
        SettingsRow(
          label: CopyId.profileRowNotification,
          value: _notifications ? CopyId.profileRowNotificationHint : 'Mati',
          chevron: false,
          right: MoriToggle(
            value: _notifications,
            onChanged: (v) => setState(() => _notifications = v),
          ),
        ),
        const _ThemeRow(),
        SettingsRow(
          label: CopyId.profileRowLanguage,
          value: CopyId.profileRowLanguageValue,
          chevron: false,
          isLast: true,
          onTap: _showComingSoon,
        ),
      ],
    );
  }
}

class _ThemeRow extends ConsumerWidget {
  const _ThemeRow();

  String _hintFor(ThemeMode mode) {
    switch (mode) {
      case ThemeMode.light:
        return CopyId.profileThemeLightHint;
      case ThemeMode.dark:
        return CopyId.profileThemeDarkHint;
      case ThemeMode.system:
        return CopyId.profileThemeAutoHint;
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final mori = context.mori;
    final current = ref.watch(themeModeControllerProvider);

    return DecoratedBox(
      decoration: BoxDecoration(
        border: Border(bottom: BorderSide(color: mori.borderSo)),
      ),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        CopyId.profileRowThemeTitle,
                        style: context.text.bodySmall?.copyWith(
                          fontSize: 12,
                          color: mori.muted,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        _hintFor(current),
                        style: context.text.bodySmall?.copyWith(
                          fontSize: 11.5,
                          color: mori.dim,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            _ThemeSegmented(
              current: current,
              onChanged: (v) => ref
                  .read(themeModeControllerProvider.notifier)
                  .set(v),
            ),
          ],
        ),
      ),
    );
  }
}

class _ThemeSegmented extends StatelessWidget {
  final ThemeMode current;
  final ValueChanged<ThemeMode> onChanged;

  const _ThemeSegmented({required this.current, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    final mori = context.mori;
    const opts = <(ThemeMode, String, IconData)>[
      (ThemeMode.light, CopyId.themeTerang, Icons.wb_sunny_outlined),
      (ThemeMode.dark, CopyId.themeGelap, Icons.dark_mode_outlined),
      (ThemeMode.system, CopyId.themeOtomatis, Icons.brightness_auto_outlined),
    ];

    return Container(
      padding: const EdgeInsets.all(3),
      decoration: BoxDecoration(
        color: mori.panel2,
        border: Border.all(color: mori.borderSo),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        children: [
          for (final o in opts) ...[
            Expanded(
              child: _ThemeSegment(
                active: o.$1 == current,
                label: o.$2,
                icon: o.$3,
                onTap: () => onChanged(o.$1),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _ThemeSegment extends StatelessWidget {
  final bool active;
  final String label;
  final IconData icon;
  final VoidCallback onTap;

  const _ThemeSegment({
    required this.active,
    required this.label,
    required this.icon,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final mori = context.mori;
    final fg = active ? MoriColors.accent : mori.muted;
    return Material(
      color: Colors.transparent,
      borderRadius: BorderRadius.circular(8),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(8),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 150),
          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 8),
          decoration: BoxDecoration(
            color: active ? context.cs.surface : Colors.transparent,
            border: Border.all(
              color: active ? mori.border : Colors.transparent,
            ),
            borderRadius: BorderRadius.circular(8),
            boxShadow: active
                ? [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.15),
                      blurRadius: 3,
                      offset: const Offset(0, 1),
                    ),
                  ]
                : null,
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, size: 16, color: fg),
              const SizedBox(width: 6),
              Flexible(
                child: Text(
                  label,
                  overflow: TextOverflow.ellipsis,
                  style: context.text.bodyMedium?.copyWith(
                    fontSize: 12.5,
                    color: fg,
                    fontWeight: active ? FontWeight.w600 : FontWeight.w500,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ── Privasi & data group ────────────────────────────────────────────────

class _PrivasiGroup extends StatelessWidget {
  const _PrivasiGroup();

  void _comingSoon(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text(CopyId.profileComingSoon),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return SettingsGroup(
      title: CopyId.profileGroupPrivasi,
      children: [
        SettingsRow(
          label: CopyId.profileRowChatHistory,
          value: CopyId.profileComingSoon,
          onTap: () => _comingSoon(context),
        ),
        SettingsRow(
          label: CopyId.profileRowExport,
          value: CopyId.profileRowExportHint,
          isLast: true,
          onTap: () => _comingSoon(context),
        ),
      ],
    );
  }
}

// ── Tentang group ───────────────────────────────────────────────────────

class _TentangGroup extends StatelessWidget {
  const _TentangGroup();

  void _comingSoon(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text(CopyId.profileComingSoon),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return SettingsGroup(
      title: CopyId.profileGroupTentang,
      children: [
        const SettingsRow(
          label: CopyId.profileRowVersion,
          value: '1.0.0',
          chevron: false,
        ),
        SettingsRow(
          label: CopyId.profileRowTerms,
          onTap: () => _comingSoon(context),
        ),
        SettingsRow(
          label: CopyId.profileRowPrivacy,
          onTap: () => _comingSoon(context),
        ),
        SettingsRow(
          label: CopyId.profileRowFeedback,
          isLast: true,
          onTap: () => _comingSoon(context),
        ),
      ],
    );
  }
}

// ── Logout group + footer ───────────────────────────────────────────────

class _LogoutGroup extends ConsumerWidget {
  final User user;
  const _LogoutGroup({required this.user});

  Future<void> _confirmLogout(BuildContext context, WidgetRef ref) async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text(CopyId.profileLogoutTitle),
        content: const Text(CopyId.profileLogoutBody),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: const Text(CopyId.batal),
          ),
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(true),
            child: Text(
              'Keluar',
              style: TextStyle(color: Theme.of(context).colorScheme.error),
            ),
          ),
        ],
      ),
    );
    if (ok != true) return;
    await ref.read(authControllerProvider.notifier).logout();
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Padding(
      padding: const EdgeInsets.only(top: 8),
      child: SettingsGroup(
        children: [
          SettingsRow(
            label: CopyId.profileRowLogout,
            value: user.username ?? user.name,
            danger: true,
            chevron: false,
            isLast: true,
            onTap: () => _confirmLogout(context, ref),
            right: Icon(
              Icons.logout_rounded,
              size: 16,
              color: Theme.of(context).colorScheme.error,
            ),
          ),
        ],
      ),
    );
  }
}

class _Footer extends StatelessWidget {
  const _Footer();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 20, 24, 8),
      child: Text(
        CopyId.profileFooter,
        textAlign: TextAlign.center,
        style: context.text.bodySmall?.copyWith(
          fontSize: 11.5,
          color: context.mori.dim,
          fontStyle: FontStyle.italic,
          height: 1.5,
        ),
      ),
    );
  }
}

