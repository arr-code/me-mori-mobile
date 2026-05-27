import 'package:flutter/material.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';

import '../../theme/mori_spacing.dart';
import '../extensions/context_theme.dart';

class MErrorBanner extends StatelessWidget {
  final String message;
  final VoidCallback? onDismiss;

  const MErrorBanner({
    super.key,
    required this.message,
    this.onDismiss,
  });

  @override
  Widget build(BuildContext context) {
    final err = context.cs.error;
    final fg = HSLColor.fromColor(err)
        .withLightness(0.72)
        .withSaturation(0.85)
        .toColor();

    return ClipRRect(
      borderRadius: BorderRadius.circular(MoriRadius.md),
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: err.withValues(alpha: 0.08),
          border: Border.all(color: err.withValues(alpha: 0.3)),
          borderRadius: BorderRadius.circular(MoriRadius.md),
        ),
        child: IntrinsicHeight(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // 3px left accent stripe — runs the full height of the banner.
              Container(width: 3, color: err),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: MoriSpacing.s4,
                    vertical: MoriSpacing.s3,
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Icon(
                        PhosphorIconsRegular.warningCircle,
                        size: 16,
                        color: fg,
                      ),
                      const SizedBox(width: MoriSpacing.s2),
                      Expanded(
                        child: Text(
                          message,
                          style: context.text.bodyMedium?.copyWith(
                            color: fg,
                            height: 1.4,
                          ),
                        ),
                      ),
                      if (onDismiss != null) ...[
                        const SizedBox(width: MoriSpacing.s2),
                        GestureDetector(
                          onTap: onDismiss,
                          behavior: HitTestBehavior.opaque,
                          child: Padding(
                            padding: const EdgeInsets.all(2),
                            child: Icon(
                              Icons.close_rounded,
                              size: 14,
                              color: fg,
                            ),
                          ),
                        ),
                      ],
                    ],
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
