import 'dart:async';

import 'package:flutter_riverpod/legacy.dart';
import 'package:jwt_decoder/jwt_decoder.dart';

final baseUrl = StateProvider<String>((ref) => 'https://salmaapi-production.up.railway.app');
final accessTokenProvider = StateProvider<String>((ref) => '');
final sessionExpiredProvider = StateProvider<bool>((ref) => false);


final timer = StateProvider(
  (ref) {
    final expiration = JwtDecoder.getExpirationDate(ref.read(accessTokenProvider));
    final duration = expiration.difference(DateTime.now());

   return Timer(duration, () {
      ref.read(sessionExpiredProvider.notifier).state = true;
    });

  }
);