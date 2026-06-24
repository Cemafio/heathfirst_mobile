import 'package:flutter_riverpod/legacy.dart';

final baseUrl = StateProvider<String>((ref) => 'https://salmaapi-production.up.railway.app');
final accessTokenProvider = StateProvider<String>((ref) => '');