import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:heathfirst_mobile/service/RdvStreamService.dart';

final rdvStreamServiceProvider = Provider<RdvStreamService>((ref) {
  final service = RdvStreamService(ref);
  ref.onDispose(() => service.stop());
  return service;
});