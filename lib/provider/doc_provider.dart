import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:heathfirst_mobile/provider/app_provider.dart';
import 'package:heathfirst_mobile/service/data.dart';

final docAsyncProvider = FutureProvider(
  (ref) async {
    final token = ref.read(accessTokenProvider);
    final base_url = ref.read(baseUrl);
    
    return await fetchDataDoc(token: token, urlBase: base_url);
  }
);