import 'dart:async';

import 'package:heathfirst_mobile/service/data.dart';

class RdvStreamService {
  final StreamController<List<dynamic>> _controller =
      StreamController<List<dynamic>>.broadcast();

  Stream<List<dynamic>> get stream => _controller.stream;

  Timer? _timer;
  String _lastHash = "";

  void start() {
    // Vérifie toutes les 5 secondes
    _timer = Timer.periodic(Duration(seconds: 5), (timer) async {
      final List<dynamic> dmd = await rdvUserData(); // Ton fetch backend

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
