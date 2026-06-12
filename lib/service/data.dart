import 'dart:convert';
import 'dart:io';
import 'package:heathfirst_mobile/provider/app_provider.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';


Future<void> sendEmailReminder(List<dynamic> tabEmail, String type, String baseUrl) async {
  final url = Uri.parse("$baseUrl/api/sendEmail"); 
  // Sur Android Emulator → backend local = 10.0.2.2

  final body = jsonEncode({
    // "email": emailReceiver,
    "type": type,
    "list_email_rappel": tabEmail
  });

  final response = await http.post(
    url,
    headers: {
      "Content-Type": "application/json",
    },
    body: body,
  );

  if (response.statusCode == 200) {
    print("✔ Email envoyé : ${response.body}");
  } else {
    print("❌ Erreur : ${response.body}");
  }
}
Future<List<dynamic>> rdvUserData({required String token, required String baseUrl}) async{
  final url = Uri.parse('$baseUrl/api/get_appointment'); // L'URL de votre API
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

Future<Map<String, dynamic>> userInfo(String baseUrl, String token)  async{
  final url = Uri.parse("$baseUrl/api/user");
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
Future<Map<String, dynamic>> getProfilUser({required int id,required String baseUrl, required String token}) async {
    final url = Uri.parse("$baseUrl/api/get_user_id/$id");

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
Future<List<dynamic>> fetchDataDoc({required String token, required String urlBase}) async {
  final url = Uri.parse('$urlBase/api/users');

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
    final doctor = jsonDecode(response.body)['dataNoPagination'];
    return doctor;
  }else{
    print("Echec $status");
    throw Exception('Erreur lors du chargement des list doc (O_o)');
  }
}
//----------------------------------------------------------------- 
Future<bool> addDayNoWork(DateTime date,String reason) async {
  final url = Uri.parse("$baseUrl/api/unavailabledays/add");
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
Future<List<dynamic>> getDayNoWork({required int id, required String baseUrl, required String token,}) async {
  final url = Uri.parse("$baseUrl/api/get_unvailable_days/get/$id");
  // final pers = await SharedPreferences.getInstance();
  // final token = pers.getString('token');
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
    print("❌ : status ${response.statusCode} ${response.body}  (O_o)");
    return [];
  }
}
Future<void> deleteDaysNoWork (int idDoc, DateTime date, String baseUrl, String token) async {
  // final pers = await SharedPreferences.getInstance();
  // final token = pers.getString('token');
  final url = Uri.parse('$baseUrl/api/unavailable_days/delete');
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
    print(response);
    print("✅ unvailable day $idDoc [$date] deleted   (>_<)");
  }else{
    throw Exception("❌ Erreur to delete unvalaible day $idDoc [$date] : status ${response.statusCode} ${response.body}  (O_o)");
  }
}
Future<void> responseAppointment(int appointment, String status, int idPatient, int idDoc, String baseUrl, String token) async {
  // final pers = await SharedPreferences.getInstance();
  // final token = pers.getString('token');
  final url = Uri.parse('$baseUrl/api/${(status == 'accepted')? 'accept_appointment': 'refused_appointment'}');
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
    sendEmailReminder([idPatient,idDoc, status] ,'res_rdv', baseUrl);
  }else{
    throw Exception("❌ ${response.statusCode} ${response.body}  (O_o)");
  }  
}

Future<void> takeAppointmentSimple({
  required String nom,
  required String prenom,
  required String birthday,
  required String sexe,
  required String tel,
  required String email,
  required String address,
  required String city,
  required String hour,
  required String date,
  required String symptome,
  required int idDoctor,
  required String baseUrl,
  required String token,
}) async {

  final url = Uri.parse("$baseUrl/api/validate/get_appointement");

  final body = {
    "idDoctor": idDoctor,
    "date": date,
    "hour": hour,

    "nom": nom,
    "prenom": prenom,
    "birthday": birthday,
    "sexe": sexe,
    "numberphone": tel,
    "email": email,
    "address": address,
    "city": city,
    "symptome": symptome,
  };

  final response = await http.post(
    url,
    headers: {
      "Authorization": "Bearer $token",
      "Content-Type": "application/json",
    },
    body: jsonEncode(body),
  );

  if (response.statusCode == 201) {
    print("✅ Demande de rendez-vous envoyée !");
  } else {
    print("❌ Erreur (${response.statusCode}) : ${response.body}");
  }
}
Future<void> takeAppointment({required int docId, required String symptome, required DateTime date, required String hour, required int idDoc, required int patientid, required String token, required String baseUrl}) async{
  final url = Uri.parse('$baseUrl/api/validate/get_appointement');
  print('Date => ${date.toIso8601String().split(' ')[0]}');

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
    sendEmailReminder([patientid, idDoc], 'env_rdv', baseUrl);
  }else{
    throw Exception("❌ ${response.statusCode} ${response.body}  (O_o)");
  }  
}
Future<Map<String, dynamic>> verrifAppointment({required int idDoc, required int patientId, required String baseUrl, required String token}) async {
  final url = Uri.parse("$baseUrl/api/verrifRdvExist");
  // final pers = await SharedPreferences.getInstance();
  // final token = pers.getString('token');
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
  final url = Uri.parse("$baseUrl/api/edit_profil");
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

  // print("Photo isChangedProfile in API= ${request.fields['isChangeProfile']}");

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
  final url = Uri.parse("$baseUrl/api/edit_profil");
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
Future<List<dynamic>> seeStatusClientRdv(int patientId, String baseUrl, String token) async {
  final url = Uri.parse("$baseUrl/api/see_status_client_rdv");
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
  final url = Uri.parse("$baseUrl/api/edit_location");
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
    throw Exception("❌ Erreur ${response.statusCode} ${response.body}  (O_o)");
  }
}

Future<List<dynamic>> recherche(
  String searchTerm,
  String specialty,
  String address,
  int page,
  String baseUrl,
  String token
) async {
  // final prefs = await SharedPreferences.getInstance();
  // final token = prefs.getString('token');

  String Url = "$baseUrl/api/search";

  // Paramètres dynamiques
  Map<String, String> queryParams = {
    "page": page.toString(),
  };

  // Ajout des filtres uniquement si non vides
  if (searchTerm.isNotEmpty) {
    queryParams["search"] = searchTerm;
  }
  if (specialty.isNotEmpty) {
    queryParams["specialty"] = specialty;
  }
  if (address.isNotEmpty) {
    queryParams["address"] = address;
  }

  // Construction automatique de l'URL propre
  final uri = Uri.parse(Url).replace(queryParameters: queryParams);

  print("🌐 URL finale = $uri");

  final response = await http.get(
    uri,
    headers: {
      'Authorization': 'Bearer $token',
      'Content-Type': 'application/json',
    },
  );

  if (response.statusCode == 401) {
    throw Exception("unauthorized");
  }

  if (response.statusCode == 200) {
    final data = jsonDecode(response.body)['data'];
    // for (var list in data) {
    //   print("✅ (>_<) Success with: ${list['LastName']} ${list['FirstName']}");
    // }
    return data;
  } else {
    throw Exception("❌ Erreur ${response.statusCode} ${response.body}");
  }
}
