import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:heathfirst_mobile/provider/app_provider.dart';
import 'package:jwt_decoder/jwt_decoder.dart';

class SessionNotifier extends Notifier<void> {
  Timer? _timer;
  late Ref ref;

  @override
  void build() {
    _startWatcher();

    ref.onDispose(() {
      _timer?.cancel();
    });
  }

  void _startWatcher() {
    _timer?.cancel();

    _timer = Timer.periodic(
      const Duration(minutes: 1),
      (_) {
        final token = ref.read(accessTokenProvider);

        if (token.isEmpty) return;

        if (JwtDecoder.isExpired(token)) {
          _timer?.cancel();

          ref.read(accessTokenProvider.notifier).state = '';

          ref.read(sessionExpiredProvider.notifier).state = true;
        }
      },
    );
  }
}