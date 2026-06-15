import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:heathfirst_mobile/provider/app_provider.dart';
import 'package:heathfirst_mobile/service/data.dart';

final dmdAsyncProvider = FutureProvider(
  (ref) async {
    return await rdvUserData(token: ref.read(accessTokenProvider), baseUrl: ref.read(baseUrl));
  }
);