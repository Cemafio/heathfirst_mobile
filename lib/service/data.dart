import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:heathfirst_mobile/page/login/login.dart';
import 'package:http/http.dart' as http;
// import 'package:project_1/First_Health/screen/mobile/widget/calendar.dart';
import 'package:shared_preferences/shared_preferences.dart';

Future<List<dynamic>> rdvUserData() async{
  final url = Uri.parse('http://10.244.91.28:8000/api/get_appointment'); // L'URL de votre API
  final perfs = await SharedPreferences.getInstance();
  final token = perfs.getString('token');
  final response = await http.get(
    url,
    headers: {
      'Authorization': 'Bearer $token',
    }
  );

  // print('Response body: ${jsonDecode(response.body)['appointments']}');
  if (response.statusCode == 401) {
    throw Exception("unauthorized");
  }
  if(response.statusCode == 200){
    final data = jsonDecode(response.body)['appointments'];
    print('Reussie ..... (>_<)');
    if(data != null){
      return data;
    }else{
      return [];
    }
  }else{
    throw Exception('Erreur lors du chargement des rendez-vous (O_o)');
  } 
}  
Future<Map<String, dynamic>> userInfo()  async{
  final url = Uri.parse("http://10.244.91.28:8000/api/user");

  
  final pers = await SharedPreferences.getInstance();
  final token = pers.getString('token');

  final response = await http.get(
    url,
    headers: {
      'Authorization': 'Bearer $token', 
    },
  );
  if (response.statusCode == 401) {
    throw Exception("unauthorized");
  }
  if(response.statusCode == 200){
    print('Info user recuperer avec succée ..... (>_<)');
    final data = jsonDecode(response.body);
    return data;
  }else{
    throw Exception('Erreur lors du chargement des info user (O_o)');
  }
}
Future<Map<String, dynamic>> getProfilUser(id) async {
    final url = Uri.parse("http://10.244.91.28:8000/api/get_user_id/$id");
    final pers = await SharedPreferences.getInstance();
      final token = pers.getString('token');

      final response = await http.get(
        url,
        headers: {
          'Authorization': 'Bearer $token', 
        },
      );
      if (response.statusCode == 401) {
        throw Exception("unauthorized");
      }
      if(response.statusCode == 200){
        print('Info user id recuperer avec succée ..... (>_<)');
        final data = jsonDecode(response.body);
        return data;
      }else{
        throw Exception('Erreur lors du chargement des info user id (O_o)');
      }
  }
// ----------Requette pour recuperer les list des docteurs--------
Future<List<dynamic>> fetchData() async {
  final url = Uri.parse('http://10.244.91.28:8000/api/users'); // L'URL de votre API
  final pers = await SharedPreferences.getInstance();
  final token = pers.getString('token');

  final response = await http.get(
    url,
    headers: {
      'Authorization': 'Bearer $token'
    },
  );
  int status = response.statusCode; 
  
  if (response.statusCode == 401) {
    throw Exception("unauthorized");
  }
  if(status == 200 ){
    final doctor = jsonDecode(response.body)['data'];
    print("Data => ${doctor}");

    return doctor;
  }else{
    print("Echec $status");
    throw Exception('Erreur lors du chargement des list doc (O_o)');
  }
}
//----------------------------------------------------------------- 
Future<bool> addDayNoWork(DateTime date,String reason) async {
  final url = Uri.parse("http://10.244.91.28:8000/api/unavailabledays/add");
  final pers = await SharedPreferences.getInstance();
  final token = pers.getString('token');
  final body = {
    'date': date.toIso8601String(),
    'reason': reason,
  };

  print("📤 Envoi JSON : ${jsonEncode(body)}");

  final response = await http.post(
    url,
    headers: {
      'Authorization': 'Bearer $token', 
      'content-type':'application/json'
    },
    
    body: jsonEncode(body)
  );

  if (response.statusCode == 401) {
    throw Exception("unauthorized");
  }
  if(response.statusCode == 200 || response.statusCode == 201){
    print("✅ unvailable day add   (>_<)");
    print("📬 Corps retour : ${response.body}");
    return true;
  }else{
    print("❌ Erreur to add $date | $reason : status ${response.statusCode} ${response.body} (O_o)");
    return false;
  }
}
Future<List<dynamic>> getDayNoWork(int id) async {
  final url = Uri.parse("http://10.244.91.28:8000/api/get_unvailable_days/get/$id");
  final pers = await SharedPreferences.getInstance();
  final token = pers.getString('token');
  final response = await http.get(
    url,
    headers: {
      'Authorization': 'Bearer $token', 
    },
  );
  
  if (response.statusCode == 401) {
    throw Exception("unauthorized");
  }

  if(response.statusCode == 200){
    print("✅ unvailable day obtained   (>_<)");
    final data = jsonDecode(response.body);
    return data;
  }else{
    throw Exception("❌ Erreur to get unvalaible day : status ${response.statusCode} ${response.body}  (O_o)");
  }
}
Future<void> deleteDaysNoWork (int idDoc, DateTime date) async {
  final pers = await SharedPreferences.getInstance();
  final token = pers.getString('token');
  final url = Uri.parse('http://10.244.91.28:8000/api/unavailable_days/delete');
  final response = await http.delete(
    url,
    headers: {
      'Authorization': 'Bearer $token',
      'Content-Type': 'application/json',
    },
    body: jsonEncode({
      'doctor_id': idDoc,
      'date': date.toIso8601String()
    })
  );
  
  if (response.statusCode == 401) {
    throw Exception("unauthorized");
  }

  if(response.statusCode == 200 || response.statusCode == 204){
    print("✅ unvailable day $idDoc [$date] deleted   (>_<)");
  }else{
    throw Exception("❌ Erreur to delete unvalaible day $idDoc [$date] : status ${response.statusCode} ${response.body}  (O_o)");
  }
}
Future<void> responseAppointment(int appointment, String status) async {
  final pers = await SharedPreferences.getInstance();
  final token = pers.getString('token');
  final url = Uri.parse('http://10.244.91.28:8000/api/${(status == 'accepted')? 'accept_appointment': 'refused_appointment'}');
  final response = await http.patch(
    url,
    headers: {
      'Authorization': 'Bearer $token',
      'Content-Type': 'application/json',
    },
    body: jsonEncode(
      {
        "id": appointment,
      }
    )
  );

  if (response.statusCode == 401) {
    throw Exception("unauthorized");
  }

  if(response.statusCode == 200 || response.statusCode == 204){
    print("✅ Rdv updated  (>_<)");
  }else{
    throw Exception("❌ ${response.statusCode} ${response.body}  (O_o)");
  }  
}
Future<void> takeAppointment(int docId, String symptome, DateTime date,String hour) async{
  final pers = await SharedPreferences.getInstance();
  final token = pers.getString('token');
  final url = Uri.parse('http://10.244.91.28:8000/api/validate/get_appointement');
  // print('Date => ${date.toIso8601String().split(' ')[0]}');

  final response = await http.post(
    url,
    headers: {
      'Authorization': 'Bearer $token',
      'Content-Type': 'application/json',
    },
    body: jsonEncode(
      {
        'idDoctor': docId,
        // 'patientId': patientId,
        'information': {'symptome': symptome},
        'date': date.toString().split(' ')[0],
        'hour': hour.toString()
      }
    )
  );

  
  if(response.statusCode == 200 || response.statusCode == 201){
    print("✅ Rdv [$date] $hour envoyer  (>_<)");
  }else{
    throw Exception("❌ ${response.statusCode} ${response.body}  (O_o)");
  }  
}
Future<Map<String, dynamic>> verrifAppointment(int idDoc, int patientId) async {
  final url = Uri.parse("http://10.244.91.28:8000/api/verrifRdvExist");
  final pers = await SharedPreferences.getInstance();
  final token = pers.getString('token');
  final response = await http.post(
    url,
    headers: {
      'Authorization': 'Bearer $token', 
      'Content-Type': 'application/json',
    },
    body: jsonEncode({
      'idDoc': idDoc,
      'idUser': patientId
    })
  );
  print('idDoc: $idDoc, idUser: $patientId');
  
  if (response.statusCode == 401) {
    throw Exception("unauthorized");
  }

  if(response.statusCode == 200){
    final data = jsonDecode(response.body);
    print("✅ (>_<)  $data");
    return data;
  }else{
    throw Exception("❌ Erreur to verrif this appointment: status ${response.statusCode} ${response.body}  (O_o)");
  }
}
Future<void> editProfil(int id, String nom,String prenom,String date_de_naissance,String? photo,String sexe,String tel,String ant_medoc,String allergie,String  ident, String adress, String medoc_en_cours, String roles) async {
  final url = Uri.parse("http://10.244.91.28:8000/api/edit_profil");
  final pers = await SharedPreferences.getInstance();
  final token = pers.getString('token');
  var request = http.MultipartRequest("POST", url);

  request.fields['id'] = id.toString();
  request.fields['firstname'] = prenom;
  request.fields['lastname'] = nom;  
  request.fields['date'] = date_de_naissance;
  request.fields['sexe'] = sexe;
  request.fields['tel'] = tel;
  request.fields['roles'] = roles;
  request.fields['email'] = ident;
  request.fields['adress'] = adress;
  request.fields['anteMedoc'] = ant_medoc;
  request.fields['allergie'] = allergie;
  request.fields['medocProg'] = medoc_en_cours;

 if (photo != null && photo.isNotEmpty && File(photo).existsSync()) {
    request.fields['isChangeProfile'] = 'true';
    request.files.add(await http.MultipartFile.fromPath(
      'photo_profil',
      photo,
    ));
  }else{
    request.fields['isChangeProfile'] = 'false';
  }

  var response = await request.send();
  final responseData = await http.Response.fromStream(response);
  
  // print("Donner recue: $id,$nom,$prenom, $date_de_naissance, $photo, $sexe, $tel, $ant_medoc, $allergie,$ident, $adress,$medoc_en_cours, $roles");
  if (response.statusCode == 401) {
    throw Exception("unauthorized");
  }
  if(response.statusCode == 200){
    final data = jsonDecode(responseData.body);
    print("✅ (>_<)  $data");
    return data;
  }else{
    throw Exception("❌ ${response.statusCode} ${responseData.body}  (O_o)");
  }
}
Future<void> editProfilDoc(int id, String nom,String prenom,String date_de_naissance,String? photo,String sexe,String tel,String  ident, String adress,String speciality, String  adressCabinet ,String roles) async {
  final url = Uri.parse("http://10.244.91.28:8000/api/edit_profil");
  final pers = await SharedPreferences.getInstance();
  final token = pers.getString('token');

  var request = http.MultipartRequest("POST", url);

  request.fields['id'] = id.toString();
  request.fields['firstname'] = prenom;
  request.fields['lastname'] = nom;  
  request.fields['date'] = date_de_naissance;
  request.fields['sexe'] = sexe;
  request.fields['tel'] = tel;
  request.fields['roles'] = roles;
  request.fields['email'] = ident;
  request.fields['adress'] = adress;
  request.fields['adressCabinet'] = adressCabinet;

  if (photo != null && photo.isNotEmpty && File(photo).existsSync()) {
    request.fields['isChangeProfile'] = 'true';
    request.files.add(await http.MultipartFile.fromPath(
      'photo_profil',
      photo,
    ));
  }else{
    request.fields['isChangeProfile'] = 'false';
  }
  
  request.fields['speciality'] = speciality;
  
  var response = await request.send();
  final responseData = await http.Response.fromStream(response);
  
  print("Donner recue: $id,$nom,$prenom, $date_de_naissance, $photo, $sexe, $tel, $speciality ,$ident, $adress,$adressCabinet, $roles");
  
  if (response.statusCode == 401) {
    throw Exception("unauthorized");
  }
  if(response.statusCode == 200){
    final data = jsonDecode(responseData.body);
    print("✅ (>_<)  $data");
  }else{
    print("❌ ${response.statusCode} ${responseData.body}  (O_o)");
    throw Exception("❌ ${response.statusCode} ${responseData.body}  (O_o)");
  }
}
Future<List<dynamic>> seeStatusClientRdv(int patientId) async {
  final url = Uri.parse("http://10.244.91.28:8000/api/see_status_client_rdv");
  final pers = await SharedPreferences.getInstance();
  final token = pers.getString('token');
  final response = await http.post(
    url,
    headers: {
      'Authorization': 'Bearer $token', 
      'Content-Type': 'application/json',
    },
    body: jsonEncode({
      'idUser': patientId
    })
  );
  
  if (response.statusCode == 401) {
    throw Exception("unauthorized");
  }

  if(response.statusCode == 200){
    final data = jsonDecode(response.body);
    print("✅ (>_<) ");
    return data;
  }else{
    throw Exception("❌ Erreur to see status appointment client: status ${response.statusCode} ${response.body}  (O_o)");
  }
}
Future<void> editLocation(int idDoc, String lat, String long, String role) async {
  final url = Uri.parse("http://10.244.91.28:8000/api/edit_location");
  final pers = await SharedPreferences.getInstance();
  final token = pers.getString('token');
  final response = await http.patch(
    url,
    headers: {
      'Authorization': 'Bearer $token', 
      'Content-Type': 'application/json',
    },
    body: jsonEncode({
      'idDoc': idDoc,
      'latitude': lat,
      'longitude': long,
      'role': role
    })
  );
  
  if (response.statusCode == 401) {
    throw Exception("unauthorized");
  }

  if(response.statusCode == 200){
    print("✅ (>_<) ");
  }else{
    throw Exception("❌ Erreur status ${response.statusCode} ${response.body}  (O_o)");
  }
}