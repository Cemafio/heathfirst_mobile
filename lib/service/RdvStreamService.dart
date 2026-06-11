import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:heathfirst_mobile/provider/app_provider.dart';
import 'package:heathfirst_mobile/service/data.dart';

class RdvStreamService {
  final Ref ref; // ← ajoute ça

  RdvStreamService(this.ref); // ← constructeur

  final StreamController<List<dynamic>> _controller = StreamController<List<dynamic>>.broadcast();
  Stream<List<dynamic>> get stream => _controller.stream;
  Timer? _timer;
  String _lastHash = "";

  void start() {
    // Vérifie toutes les 5 secondes
    _timer = Timer.periodic(Duration(seconds: 5), (timer) async {
      final token = ref.read(accessTokenProvider);
      final base_url = ref.read(baseUrl);
      final List<dynamic> dmd = await rdvUserData(token: token, baseUrl: base_url); // Ton fetch backend
      final newHash = dmd.toString(); // Signature des données

      if (newHash != _lastHash) {
        print("🔔 Changement détecté !");
        _lastHash = newHash;
        _controller.add(dmd); // Envoie au StreamBuilder
      }
    });
  }

  void stop() {
    _timer?.cancel();
    _controller.close();
  }
}
