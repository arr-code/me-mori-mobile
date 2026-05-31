import 'package:flutter/cupertino.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../features/auth/application/auth_controller.dart';
import '../../features/auth/application/auth_state.dart';
import '../../features/auth/presentation/google_loading_screen.dart';
import '../../features/auth/presentation/login_screen.dart';
import '../../features/auth/presentation/register_screen.dart';
import '../../features/auth/presentation/signin_select_screen.dart';
import '../../features/auth/presentation/splash_screen.dart';
import '../../features/chat/presentation/chat_screen.dart';
import '../../features/home/presentation/home_screen.dart';
import '../../features/nickname/application/nickname_prompt_seen.dart';
import '../../features/nickname/presentation/nickname_screen.dart';
import '../../features/onboarding/presentation/onboarding_screen.dart';
import '../../features/profile/presentation/profile_screen.dart';
import '../../features/welcome/presentation/welcome_screen.dart';

class AppRoutes {
  const AppRoutes._();

  static const splash = '/';
  static const welcome = '/welcome';
  static const signInSelect = '/signin-select';
  static const register = '/register';
  static const login = '/login';
  static const googleLoading = '/google-loading';
  static const nickname = '/nickname';
  static const onboarding = '/onboarding';
  static const home = '/home';
  static const chat = '/chat';
  static const profile = '/profile';
}

/// Listenable that re-fires the router's refreshListenable whenever auth
/// state OR the nickname-prompt flag changes. GoRouter calls `redirect`
/// each time, picking the right destination for the new state.
class _AuthRouterRefresh extends ChangeNotifier {
  _AuthRouterRefresh(Ref ref) {
    ref.listen<AuthState>(authControllerProvider, (_, __) => notifyListeners());
    ref.listen<bool>(nicknamePromptSeenProvider, (_, __) => notifyListeners());
  }
}

final appRouterProvider = Provider<GoRouter>((ref) {
  final refresh = _AuthRouterRefresh(ref);

  return GoRouter(
    initialLocation: AppRoutes.splash,
    refreshListenable: refresh,
    debugLogDiagnostics: false,
    redirect: (context, gstate) {
      final auth = ref.read(authControllerProvider);
      final path = gstate.matchedLocation;

      switch (auth) {
        case AuthUnknown():
          // Stay on splash; do not redirect anywhere yet.
          return path == AppRoutes.splash ? null : AppRoutes.splash;
        case Unauthenticated():
          // Splash (Crest) is brand-only — once auth resolves to
          // Unauthenticated, push the user to the Welcome landing page.
          // Auth screens stay reachable so back-navigation works.
          const allowed = {
            AppRoutes.welcome,
            AppRoutes.signInSelect,
            AppRoutes.register,
            AppRoutes.login,
            AppRoutes.googleLoading,
          };
          if (allowed.contains(path)) return null;
          return AppRoutes.welcome;
        case Authenticated(user: final user):
          final onboarded = user.hasCompletedOnboarding;
          final nicknameSeen = ref.read(nicknamePromptSeenProvider);

          if (!onboarded) {
            // Two-step onboarding: nickname prompt (06 Panggilan) first,
            // then the profile wizard (07 Onboarding profil). Once the
            // user dismisses/saves the nickname, the flag flips and they
            // move on to the profile wizard.
            if (!nicknameSeen) {
              return path == AppRoutes.nickname
                  ? null
                  : AppRoutes.nickname;
            }
            return path == AppRoutes.onboarding
                ? null
                : AppRoutes.onboarding;
          }

          // Authenticated + onboarded: keep them out of auth-only screens.
          const authOnlyPaths = {
            AppRoutes.splash,
            AppRoutes.welcome,
            AppRoutes.signInSelect,
            AppRoutes.register,
            AppRoutes.login,
            AppRoutes.googleLoading,
            AppRoutes.nickname,
            AppRoutes.onboarding,
          };
          if (authOnlyPaths.contains(path)) return AppRoutes.home;
          return null;
      }
    },
    routes: [
      _cupertino(AppRoutes.splash, const SplashScreen()),
      _cupertino(AppRoutes.welcome, const WelcomeScreen()),
      _cupertino(AppRoutes.signInSelect, const SignInSelectScreen()),
      _cupertino(AppRoutes.register, const RegisterScreen()),
      _cupertino(AppRoutes.login, const LoginScreen()),
      _cupertino(AppRoutes.googleLoading, const GoogleLoadingScreen()),
      _cupertino(AppRoutes.nickname, const NicknameScreen()),
      _cupertino(AppRoutes.onboarding, const OnboardingScreen()),
      _cupertino(AppRoutes.home, const HomeScreen()),
      _cupertino(AppRoutes.chat, const ChatScreen()),
      _cupertino(AppRoutes.profile, const ProfileScreen()),
    ],
  );
});

/// GoRoute factory that uses [CupertinoPage] for the page transition —
/// iOS-style horizontal slide on push, including on Android (per design
/// spec §5.6 page transitions).
GoRoute _cupertino(String path, Widget child) {
  return GoRoute(
    path: path,
    pageBuilder: (context, state) => CupertinoPage<void>(
      key: state.pageKey,
      child: child,
    ),
  );
}
