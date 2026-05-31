import 'package:flutter/widgets.dart';
import 'package:google_sign_in_web/web_only.dart' as gsi_web;

/// Renders the Google Identity Services button. Clicking it drives the GIS
/// credential flow; completion is delivered via
/// `GoogleSignIn.onCurrentUserChanged`, which AuthController listens to on web.
Widget googleWebButton() => gsi_web.renderButton(
      configuration: gsi_web.GSIButtonConfiguration(
        theme: gsi_web.GSIButtonTheme.filledBlue,
        size: gsi_web.GSIButtonSize.large,
        text: gsi_web.GSIButtonText.continueWith,
        shape: gsi_web.GSIButtonShape.pill,
        logoAlignment: gsi_web.GSIButtonLogoAlignment.left,
      ),
    );
