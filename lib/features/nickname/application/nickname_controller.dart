import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../auth/application/auth_controller.dart';
import '../../profile/data/dto/account_requests.dart';
import '../../profile/data/users_repository.dart';
import 'nickname_prompt_seen.dart';

final nicknameControllerProvider =
    Provider<NicknameController>((ref) => NicknameController(ref));

class NicknameController {
  final Ref ref;
  NicknameController(this.ref);

  /// Save the nickname server-side and mark the prompt as seen. The
  /// router watches `nicknamePromptSeenProvider` and moves the user on
  /// to `/onboarding` automatically.
  Future<void> save(String nickname) async {
    final trimmed = nickname.trim();
    if (trimmed.isEmpty) {
      throw Exception('Nickname tidak boleh kosong.');
    }
    final user = await ref
        .read(usersRepositoryProvider)
        .patchMe(AccountPatchRequest(name: trimmed));
    await ref.read(authControllerProvider.notifier).updateUser(user);
    ref.read(nicknamePromptSeenProvider.notifier).state = true;
  }

  /// Skip the prompt without changing the name. The user can still edit
  /// their nickname later from the profile screen.
  void skip() {
    ref.read(nicknamePromptSeenProvider.notifier).state = true;
  }
}
