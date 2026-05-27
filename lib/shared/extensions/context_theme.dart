import 'package:flutter/material.dart';

import '../../theme/mori_theme.dart';

extension MoriContext on BuildContext {
  ThemeData get theme => Theme.of(this);
  ColorScheme get cs => Theme.of(this).colorScheme;
  TextTheme get text => Theme.of(this).textTheme;
  MoriColorsExtension get mori =>
      Theme.of(this).extension<MoriColorsExtension>()!;
}
