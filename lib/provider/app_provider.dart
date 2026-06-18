import 'package:flutter_riverpod/legacy.dart';

final baseUrl = StateProvider<String>((ref) => 'http://10.78.163.28:8000');
final accessTokenProvider = StateProvider<String>((ref) => '');