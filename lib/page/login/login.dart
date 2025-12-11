// import 'dart:nativewrappers/_internal/vm/lib/core_patch.dart';

import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:heathfirst_mobile/page/home/homePage.dart';
import 'package:heathfirst_mobile/page/singIn/incription_doc.dart';
import 'package:heathfirst_mobile/page/singIn/inscription_patient.dart';
import 'package:heathfirst_mobile/provider/userProvider.dart';
import 'package:heathfirst_mobile/service/data.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;

class LoginMobile extends StatefulWidget {
  const LoginMobile({super.key});

  @override
  State<LoginMobile> createState() => _LoginMobileState();
}

class _LoginMobileState extends State<LoginMobile> {
  final _formKey = GlobalKey<FormState>();
  String _email = '';
  String _pass = '';
  bool isLoading = false;
  Widget? error;
  Widget? loader;
  Icon? icon;
  late Map<String, dynamic> _infoUser;

  Future<void> authentification(String email, String pass) async{
    final url = Uri.parse("http://172.27.136.28:8000/api/authentication");

    setState(() => isLoading = true);

    try {
      // Timeout de 10 secondes
      final response = await http.post(
        url,
        body: {
          '_username': email,
          '_password': pass,
        },
      ).timeout(Duration(seconds: 20));

      // ======== SI LE SERVEUR RÉPOND ========
      if (response.statusCode == 200) {
        Map<String, dynamic> data;

        // Sécuriser jsonDecode
        try {
          data = jsonDecode(response.body);
        } catch (e) {
          throw FormatException("Réponse JSON invalide");
        }

        final token = data['tokenss'];
        if (token == null) throw Exception("Token introuvable");

        // Stockage local
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('token', token);

        print("✅ Authentification réussie !");
        print(response.body);

        // Récupération info user
        _infoUser = await userInfo();

        setState(() {
          isLoading = false;
          icon = null;
          error = null;
        });

        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => HomePage(user: _infoUser)),
        );
        return;
      }

      // ======== ERREUR CÔTÉ SERVEUR 4xx / 5xx ========
      print("❌ ERREUR ${response.statusCode} : ${response.body}");

      setState(() {
        isLoading = false;
        icon = Icon(Icons.warning_amber_rounded, color: Colors.red);
        error = Text(
          'Email ou mot de passe incorrect.',
          style: TextStyle(color: Colors.redAccent, fontSize: 11),
        );
      });
    }

    // ========== TIMEOUT ==========
    on TimeoutException {
      print("⏳ Timeout : serveur ne répond pas.");

      setState(() {
        isLoading = false;
        icon = Icon(Icons.access_time_filled, color: Colors.orange);
        error = Text(
          'Temps de réponse dépassé (serveur lent ou hors ligne).',
          style: TextStyle(color: Colors.orangeAccent, fontSize: 11),
        );
      });
    }

    // ========== PROBLÈME DE RÉSEAU ==========
    on SocketException catch (e) {
      print("🌐 Problème réseau : $e");

      setState(() {
        isLoading = false;
        icon = Icon(Icons.wifi_off, color: Colors.red);
        error = Text(
          'Impossible de contacter le serveur.\n'
          '• IP incorrecte\n'
          '• Serveur éteint\n'
          '• Pas de connexion internet',
          style: TextStyle(color: Colors.redAccent, fontSize: 11),
        );
      });
    }

    // ========== JSON INVALIDE ==========
    on FormatException catch (e) {
      print("📛 JSON invalide : $e");

      setState(() {
        isLoading = false;
        icon = Icon(Icons.code_off, color: Colors.red);
        error = Text(
          "La réponse du serveur est invalide.",
          style: TextStyle(color: Colors.redAccent, fontSize: 11),
        );
      });
    }

    // ========== AUTRES ERREURS ==========
    catch (e) {
      print("❌ ERREUR inconnue : $e");

      setState(() {
        isLoading = false;
        icon = Icon(Icons.error_outline, color: Colors.red);
        error = Text(
          'Erreur inattendue. Réessayer.',
          style: TextStyle(color: Colors.redAccent, fontSize: 11),
        );
      });
    }
  }

  Future PopUp () => showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Center(child:  Text("Votre status", style: TextStyle(fontSize: 20),)),

        content: Row (
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            GestureDetector(
              onTap: (() => Navigator.of(context).push(MaterialPageRoute(builder: ((context)=> const PatientInscription())))),

              child: Container(
              height: 100,

              child: Column (children: [
                Container(
                  width: 70,
                  height: 70,
                  decoration: BoxDecoration(
                    border: Border.all( width: 1),
                    borderRadius: BorderRadius.circular(10)
                  ),

                  child: const Center(
                    child:  Icon(Icons.person,
                      size: 40,),
                  ),
                ),
                  const SizedBox(height: 10,),
                  const Text("Patien")
                ],),
              ),
            ),

            GestureDetector(
              onTap: (() => Navigator.of(context).push(MaterialPageRoute(builder: ((context)=> const DocInscription())))),

              child: Container(
                height: 100,
                child: Column (
                children: [
                  Container(
                    width: 70,
                    height: 70,
                    decoration: BoxDecoration(
                      border: Border.all( width: 1),
                      borderRadius: BorderRadius.circular(10)
                    ),
                    child: const Center(
                      child:  Icon(Icons.apartment_rounded,
                      size: 40,),
                    ),
                  ),
                  const SizedBox(height: 10,),
                  const Text("Docteur")
                ],),
                
              )
            ),
        ]),
      )
    );

  @override
  void initState() {
    super.initState();
  }
  
  Widget build(BuildContext context) {
  return Scaffold(
    body: Column(
      mainAxisAlignment: MainAxisAlignment.spaceAround,

      children: [
        const Text('HEALTH FIRST', style: TextStyle(
          color: Color(0xFF548856),
          fontWeight: FontWeight.bold,
          fontSize: 18,
          letterSpacing: 1.9
      )),

      Container(
        padding: EdgeInsets.symmetric(
          horizontal: 50.w
        ),
        child: Form(
          key: _formKey,
          child: Column(
            children: <Widget>[
              
              TextFormField(
                decoration: const InputDecoration(
                  hintText: 'Identifiant',
                  prefixIcon: Icon(Icons.person,),
                ),
                keyboardType: TextInputType.emailAddress,
                validator: (value){
                  if( value == null || value.isEmpty){
                    return 'Veuillez entrer votre email';
                  }
                  return null;
                },
                onSaved: (newValue) => _email = newValue!,
              ),
              const  SizedBox(height: 40,),
              TextFormField(
                obscureText: true,
                decoration: const InputDecoration(
                  hintText: 'Motde passe',
                  prefixIcon: Icon(Icons.password,),
                  
                ),
                keyboardType: TextInputType.visiblePassword,
                validator: (value){
                  if( value == null || value.isEmpty){
                    return 'Veuillez entrer votre Mot de passe';
                  }
                  return null;
                },
                onSaved: (newValue) => _pass = newValue! ,
              ),

              const SizedBox(height:  30),
              Container(
                width: double.infinity,
                child: Wrap(
                  spacing: 8,
                  runSpacing: 4,
                  children: [
                    if(icon != null) icon!,
                    const SizedBox(width: 10,),
                    if(icon != null) error!
                    
                  ]
                ),
              ),
              

              const SizedBox(height: 30),
              Material(
                color: Colors.transparent,
                child: Center (
                  child: InkWell(
                  onTap: isLoading? null : () async {
                    // Action
                    setState(() {
                      error = Text('');
                      icon = null;
                    });    
                    final isValide = _formKey.currentState!.validate();
                    if (isValide) {
                      // Save data in texFormField
                      _formKey.currentState!.save();
                      
                      // Call function future
                      try {
                        await authentification(_email, _pass);
                      } catch (e) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text('Erreur : ${e.toString()}')),
                        );
                      }
                    }
                  },

                  // borderRadius: BorderRadius.circular(10),
                  child: Container(
                    height: 60,
                    width: 250,
                    padding: const EdgeInsets.symmetric(vertical: 10),
                    margin:const EdgeInsets.only(bottom: 30),
                    decoration: BoxDecoration(
                      border: Border.all(color: Color(0xFF548856), width: 2),
                      borderRadius: BorderRadius.circular(10),
                      color: isLoading ? Colors.grey[300] : Colors.transparent,
                    ),
                    child: Stack(
                      // mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                      
                      if(!isLoading)
                        const Center(
                          child: Text(
                            "Se connecté",
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF548856),
                            ),
                          ),
                        ),
                      if(isLoading)
                        const Center(
                          child: SizedBox(
                            height: 15,
                            width: 15,
                            child: CircularProgressIndicator(
                              strokeWidth: 3.0,
                            ),
                          ),
                        )
                    ]),
                  ),
                ),
              ),
        )]),
        ),

      ),

        Container(
          child: Column(
            children: [
              GestureDetector(
                onTap: () {
                  // print('Pop up'); 
 
                  PopUp ();
                },
                child: Text("Pas encore isncrit? S'isncrire",
                  style: TextStyle(
                  fontSize: 13,
                  color:Colors.blue 
                ),),

              ),

              SizedBox(height: 10,),

              // Text('Mots de passe oublié', style: TextStyle(
              //   fontSize: 13,
              //   color: Colors.red
              // )),
            ],
          ),
        )
        
      ],
    ),
  );
  
  }
}