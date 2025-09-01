import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;

// {@context: /api/contexts/Patient, @id: /api/patients/18, @type: Patient, HistoryMedical: xjfu, allergy: fju, MedicationInProgress: cju, id: 18, email: itadori@gmail.com, roles: [ROLE_PATIENT], LastName: ITADORY , FirstName: Yuji , DateOfBird: 2000-01-31T00:00:00+00:00, photo_profil: 1001354998-682da7e4e561f536585918.jpg, Address: Jdu 135, phone: 1468634863}

class User {
  final int id;
  final String firstname;
  final String lastname;
  final String email;
  final String roles;
  final String adress;

  User({required this.id, required this.firstname, required this.lastname, required this.email,required this.roles,required this.adress});

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'],
      firstname: json['FirstName'],
      lastname: json['LastName'],
      email: json['email'],
      roles: json['roles'][0],
      adress: json['Address']

    );
  }

  User copyWith({String? firstname, String? lastname,String? email,String? roles, String? adress}) {
    return User(
      id: id,
      firstname: firstname ?? this.firstname,
      lastname: lastname ?? this.lastname,
      email: email ?? this.email,
      roles: roles ?? this.roles,
      adress: adress ?? this.adress
    );
  }
}

class UserProvider extends ChangeNotifier {
  User? user;
  
  Future<void> userInfo()  async{
    final url = Uri.parse("http://192.168.1.148:8000/api/user");
    final pers = await SharedPreferences.getInstance();
    final token = pers.getString('token');
    final response = await http.get(
      url,
      headers: {
        'Authorization': 'Bearer $token', 
      },
    );
    if(response.statusCode == 200){
      print('Info user recuperer avec succée ..... (>_<)');
      final Map<String, dynamic> data = jsonDecode(response.body);
      user = User.fromJson(data); // Passe un Map, pas une String
      notifyListeners();
    }else{
      throw Exception('Erreur lors du chargement des info user (O_o)');
    }
  }

  void updateUser(User updated) {
    user = updated;
    notifyListeners(); // Notifie toutes les pages que l'état a changé
  }
}
