import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/date_symbol_data_local.dart';

import 'package:me_mori/app.dart';
import 'package:me_mori/core/storage/secure_storage.dart';
import 'package:me_mori/features/nickname/application/nickname_suggestions.dart';

class _FakeSecureStorage extends SecureStorage {
  @override
  Future<String?> readToken() async => null;

  @override
  Future<void> writeToken(String token) async {}

  @override
  Future<String?> readUserJson() async => null;

  @override
  Future<void> writeUserJson(String json) async {}

  @override
  Future<void> clearSession() async {}

  @override
  Future<void> clearAll() async {}
}

void main() {
  setUpAll(() async {
    GoogleFonts.config.allowRuntimeFetching = false;
    await initializeDateFormatting('id_ID');
  });

  testWidgets(
      'Me Mori boots to Welcome and advances to signin-select via Mulai',
      (tester) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          secureStorageProvider.overrideWithValue(_FakeSecureStorage()),
        ],
        child: const MeMoriApp(),
      ),
    );
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 200));

    // Welcome shows brand pillars + Mulai CTA.
    expect(find.text('Mulai'), findsOneWidget);
    expect(find.text('Atur jadwal lewat obrolan'), findsOneWidget);

    await tester.tap(find.text('Mulai'));
    await tester.pumpAndSettle();

    expect(find.text('Lanjut dengan Google'), findsOneWidget);
    expect(find.text('Daftar dengan Email'), findsOneWidget);
  });

  group('suggestNicknames', () {
    test('three parts: middle, first, first + last initial', () {
      expect(
        suggestNicknames('Ahmad Surya Wijaya'),
        equals(['Surya', 'Ahmad', 'Ahmad W.']),
      );
    });

    test('two parts: second, first', () {
      expect(suggestNicknames('Sri Lestari'), equals(['Lestari', 'Sri', 'Sri L.']));
    });

    test('single token returns just itself', () {
      expect(suggestNicknames('Aru'), equals(['Aru']));
    });

    test('empty / null returns no suggestions', () {
      expect(suggestNicknames(''), isEmpty);
      expect(suggestNicknames(null), isEmpty);
      expect(suggestNicknames('   '), isEmpty);
    });

    test('deduplicates when collisions occur', () {
      // "Aru Aru" → middle = "Aru", first = "Aru" (dedup), initial form
      // stays distinct as "Aru A.".
      expect(suggestNicknames('Aru Aru'), equals(['Aru', 'Aru A.']));
    });
  });
}
