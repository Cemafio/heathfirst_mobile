import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:heathfirst_mobile/provider/app_provider.dart';
import 'package:heathfirst_mobile/provider/doc_provider.dart';
import 'package:heathfirst_mobile/provider/userProvider.dart';
import 'package:heathfirst_mobile/service/RdvStreamService.dart';
import 'package:heathfirst_mobile/service/data.dart';

final rdvStreamServiceProvider = Provider<RdvStreamService>((ref) {
  final service = RdvStreamService(ref);
  ref.onDispose(() => service.stop());
  return service;
});

final rdvAsyncProvider = FutureProvider(
  (ref) async {
    return await rdvUserData(token: ref.watch(accessTokenProvider), baseUrl: ref.watch(baseUrl));
  }
);

final verrifRdvAsync = FutureProvider(
  (ref) async {

    final doctor = await ref.read(docAsyncProvider.future);

    return verrifAppointment(
      idDoc: doctor[0]['id'],
      patientId: ref.read(userDataStatic).id!,
      baseUrl: ref.read(baseUrl),
      token: ref.read(accessTokenProvider),
    );
  },
);