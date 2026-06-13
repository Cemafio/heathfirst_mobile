import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:heathfirst_mobile/provider/app_provider.dart';
import 'package:heathfirst_mobile/provider/userProvider.dart';
import 'package:heathfirst_mobile/service/data.dart';

final daysNoWorkAsync = FutureProvider((ref) async {
  return await getDayNoWork(id: ref.read(userDataStatic).id!, baseUrl: ref.read(baseUrl), token: ref.read(accessTokenProvider));
});