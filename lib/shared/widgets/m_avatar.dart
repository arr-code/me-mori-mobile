import 'package:flutter/material.dart';

import '../../theme/mori_colors.dart';
import '../extensions/context_theme.dart';

class MAvatar extends StatelessWidget {
  final String? name;
  final String? imageUrl;
  final double size;
  final VoidCallback? onTap;

  const MAvatar({
    super.key,
    this.name,
    this.imageUrl,
    this.size = 36,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final initials = _initialsFromName(name);

    final avatar = Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: MoriColors.accent.withValues(alpha: 0.18),
        border: Border.all(color: context.mori.border, width: 1),
        image: imageUrl != null
            ? DecorationImage(
                image: NetworkImage(imageUrl!),
                fit: BoxFit.cover,
              )
            : null,
      ),
      alignment: Alignment.center,
      child: imageUrl != null
          ? null
          : Text(
              initials,
              style: TextStyle(
                color: MoriColors.accent,
                fontWeight: FontWeight.w700,
                fontSize: size * 0.4,
              ),
            ),
    );

    if (onTap == null) return avatar;
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: avatar,
    );
  }

  static String _initialsFromName(String? name) {
    if (name == null || name.trim().isEmpty) return '·';
    final parts = name.trim().split(RegExp(r'\s+'));
    if (parts.length == 1) {
      return parts.first.characters.take(2).toString().toUpperCase();
    }
    return (parts.first.characters.first + parts.last.characters.first)
        .toUpperCase();
  }
}
