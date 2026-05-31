import 'package:flutter/widgets.dart';

import 'google_web_button_stub.dart'
    if (dart.library.js_interop) 'google_web_button_web.dart' as impl;

/// Google's official Identity Services sign-in button. Only meaningful on
/// web (where the deprecated `signIn()` popup no longer works); on native it
/// returns an empty box and the app's own button drives `signInWithGoogle()`.
Widget googleWebButton() => impl.googleWebButton();
