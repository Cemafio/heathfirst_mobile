import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:heathfirst_mobile/page/login/login.dart';
  
class DocInscription extends StatefulWidget {
  const DocInscription({super.key});

  @override
  State<DocInscription> createState() => _DocInscriptionState();
}

class _DocInscriptionState extends State<DocInscription> {
  final _formKey = GlobalKey<FormState>();
  DateTime? _selectedDate;
  File? _selectedImage;
  final TextEditingController _dateController = TextEditingController();

  String _nom = '';
  String _prenom = '';
  String _photo = '';
  String _roles = 'ROLE_DOCTOR';
  String _tel = '';
  String _sexe = '';
  String _identifiant = '';
  String _pass = '';
  String _adress = '';
  String _adress_cabinet = '';
  String _date_de_naissance = '';
  String _speciality = '';


  Future<void> inscriptionPatient(String nom,String prenom,String date_de_naissance,String photo,String sexe,String tel,String  ident, String pass, String adress, String roles, String speciality, String  adressCabinet) async {
    final url = Uri.parse("http://192.168.4.28:8000/api/registration");

    var request = http.MultipartRequest("POST", url);

    request.fields['nom'] = nom;
    request.fields['prenom'] = prenom;
    request.fields['DateDeNaissance'] = date_de_naissance;
    request.fields['Sexe'] = sexe;
    request.fields['sex'] = sexe;
    request.fields['telephone'] = tel;
    // request.fields['roles'] = jsonEncode([roles]);
    request.fields['roles'] = roles;
    request.fields['email'] = ident;
    request.fields['password'] = pass;
    request.fields['Adresse'] = adress;
    request.fields['AddressCabinet'] = adressCabinet;

    // Fichier image
    request.files.add(await http.MultipartFile.fromPath(
      'photo_profil',
      photo, // exemple: "/data/user/0/com.example.project_1/cache/temp.jpg"
    ));
    request.fields['Speciality'] = speciality;

    var response = await request.send();
    final responseData = await http.Response.fromStream(response);

    if(response.statusCode == 200){
      // Inscription réussie
      print("✅ Utilisateur inscrit !  (>_<)");
      print(responseData.body);
      Navigator.of(context).push(MaterialPageRoute(builder: (context) => const LoginMobile()));
    }else{
      // Erreur (ex: validation)
      print("❌ Erreur : ${response.statusCode} (O_o)");
      print(responseData.body);
      throw Exception('Erreur lors de l’inscription  (O_o)');
    }
  }
  
  Future<void> _selectDate(BuildContext context) async{
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime(2000, 1),
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
    );
    if (picked != null) {
      setState(() {
        _selectedDate = picked;
        _dateController.text = DateFormat('yyyy-MM-dd').format(picked); // format ISO
        _date_de_naissance =_dateController.text;
      });
    }
  }

  Future<void> _pickImage() async {
    final ImagePicker picker = ImagePicker();
    final XFile? image = await picker.pickImage(source: ImageSource.gallery);

    if (image != null) {
      setState(() {
        _selectedImage = File(image.path);
        // List<String> photoName = image.path.split('/');
        _photo = image.path;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      resizeToAvoidBottomInset: true,

      body: SingleChildScrollView(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            // const SizedBox(height: 60),
            
            const SizedBox(height: 80),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                GestureDetector(
                  onTap: _pickImage,
                  child: _selectedImage != null
                      ? ClipOval(child:Image.file(_selectedImage!, width: 100, height: 100, fit: BoxFit.cover))
                      : Container(
                          width: 100,
                          height: 100,
                          child: const Icon(Icons.camera_alt),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.all(Radius.circular(50.w)),
                            color: Colors.grey[300],
                          ),
                        ),
                ),
                const SizedBox(height: 10),
                const Text('Photo de profil'),
              ],
            ),
            const SizedBox(height: 30,),
            Container(
              padding: EdgeInsets.symmetric(horizontal: 50.w),
              child: Form(
                key: _formKey,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: <Widget>[
                    TextFormField(
                      decoration: InputDecoration(
                        labelText: 'Nom',
                        prefixIcon: Icon(Icons.account_circle),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Veuillez entrer votre nom';
                        }
                        return null;
                      },
                      onSaved: (newValue) => _nom = newValue!,
                    ),
                    const SizedBox(height: 30),
                    TextFormField(
                      decoration: InputDecoration(
                        labelText: 'Prenom',
                        prefixIcon: Icon(Icons.account_box),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Veuillez entrer votre prenom';
                        }
                        return null;
                      },
                      onSaved: (newValue) => _prenom = newValue!,
                    ),
                    const SizedBox(height: 30),
                    DropdownButtonFormField(
                      decoration: const InputDecoration(
                        labelText: 'Sexe',
                        prefixIcon: Icon(Icons.wc),
                      ),
                      items: ['Homme', 'Femme']
                        .map((label) => DropdownMenuItem(
                          value: label,
                          child: Text(label),
                        ))
                        .toList(), 
                      
                      onChanged: (value){
                        setState(() {
                          _sexe = value!;
                        });
                      },
                      validator: (value) => value == null ? 'Veuillez sélectionner une option' : null,
                      onSaved: (newValue) {
                        _sexe = newValue!;
                      },
                    ),
                    const SizedBox(height: 30),
                    TextFormField(
                      decoration: const InputDecoration(
                        labelText: 'Mail',
                        prefixIcon: Icon(Icons.email),
                      ),
                      keyboardType: TextInputType.emailAddress,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Veuillez entrer votre email';
                        }
                        return null;
                      },
                      onSaved: (newValue) => _identifiant = newValue!,
                    ),
                    const SizedBox(height: 30),
                    TextFormField(
                      decoration: const InputDecoration(
                        labelText: 'Numero de télephone',
                        prefixIcon: Icon(Icons.phone_android_outlined),
                      ),
                      keyboardType: TextInputType.phone,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Veuillez entrer votre numero de télephone';
                        }
                        return null;
                      },
                      onSaved: (newValue) => _tel = newValue!,
                    ),
                    
                    const SizedBox(height: 30),
                    TextFormField(
                      obscureText: true,
                      decoration: InputDecoration(
                        labelText: 'Mot de passe',
                        prefixIcon: Icon(Icons.password),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Veuillez entrer votre mot de passe';
                        }
                        return null;
                      },
                      onSaved: (newValue) => _pass = newValue!,
                    ),
                    const SizedBox(height: 30),
                    TextFormField(
                      decoration: InputDecoration(
                        labelText: 'Votre adresse',
                        prefixIcon: Icon(Icons.location_on_outlined),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Veuillez entrer votre adresse';
                        }
                        return null;
                      },
                      onSaved: (newValue) => _adress = newValue!,
                    ),
                    const SizedBox(height: 30),
                    TextFormField(
                      decoration: InputDecoration(
                        labelText: 'Votre adresse de cabinet',
                        prefixIcon: Icon(Icons.location_on_outlined),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Veuillez entrer votre adresse de cabinet';
                        }
                        return null;
                      },
                      onSaved: (newValue) => _adress_cabinet = newValue!,
                    ),
                    const SizedBox(height: 30),
                    TextFormField(
                      decoration: const InputDecoration(
                        labelText: 'Votre Specialiter',
                        prefixIcon: Icon(Icons.folder_special_outlined),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Veuillez entrer votre specialité';
                        }
                        return null;
                      },
                      onSaved: (newValue) => _speciality = newValue!,
                    ),
                    const SizedBox(height: 30),
                    TextFormField(
                      controller: _dateController,
                      decoration: InputDecoration(
                        labelText: 'Date de naissance',
                        prefixIcon: Icon(Icons.calendar_today),
                        border: OutlineInputBorder(),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Veuillez entrer votre date de naissance';
                        }
                        return null;
                      },
                      readOnly: true,
                      onTap: () => _selectDate(context),
                    ),
                    
                    const SizedBox(height: 80),
                    Material(
                      color: Colors.transparent,
                      child: InkWell(
                        onTap: () async {
                          // Action
                          final isValide = _formKey.currentState!.validate();
                          if (isValide) {
                            // Save data in texFormField
                            _formKey.currentState!.save();
                            
                            // Call function future
                            try {
                              await inscriptionPatient(  _nom,_prenom, _date_de_naissance, _photo, _sexe, _tel,_identifiant, _pass, _adress, _roles, _speciality, _adress_cabinet);

                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(content: Text('Inscription réussie')),
                              );

                              // Redirection ou autre
                            } catch (e) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(content: Text('Erreur : ${e.toString()}')),
                              );
                            }
                          }
                        },

                        borderRadius: BorderRadius.circular(10),
                        child: Container(
                          padding: const EdgeInsets.symmetric(vertical: 15),
                          margin:const EdgeInsets.only(bottom: 30),
                          decoration: BoxDecoration(
                            border: Border.all(color: Color(0xFF548856), width: 2),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: const Center(child: Text(
                            "S'inscrire",
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF548856),
                            ),
                          )),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );

  }
}