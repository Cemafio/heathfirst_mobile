import 'package:flutter_riverpod/legacy.dart';

final baseUrl = StateProvider<String>((ref) => 'http://172.25.69.28:8000');
final accessTokenProvider = StateProvider<String>((ref) => '');