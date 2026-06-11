import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:heathfirst_mobile/model/user_model.dart';
import 'package:heathfirst_mobile/provider/app_provider.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final user_data = FutureProvider<UserModel>((ref) async {
  final token = ref.watch(accessTokenProvider);
  final _baseUrl = ref.watch(baseUrl);
  final url = Uri.parse("$_baseUrl/api/user");
  
  final response = await http.get(
    url,
    headers: {'Authorization': 'Bearer $token'},
  );

  if (response.statusCode == 401) {
    throw Exception("unauthorized");
  }
  
  if (response.statusCode == 200) {
    final data = jsonDecode(response.body);
    return UserModel.fromJson(data);
  } else {
    throw Exception('Erreur lors du chargement des infos user');
  }
});