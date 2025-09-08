import 'dart:async';
import 'dart:convert';
import 'dart:ffi';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/widgets.dart';
import 'package:heathfirst_mobile/page/agenda/calendar.dart';
import 'package:heathfirst_mobile/page/appointment/demandeRendeVous.dart';
import 'package:heathfirst_mobile/page/home/acceuilDoc.dart';
import 'package:heathfirst_mobile/page/home/categorie.dart';
import 'package:heathfirst_mobile/page/home/searchSection.dart';
import 'package:heathfirst_mobile/page/home/liste_doc_alentour.dart';
import 'package:heathfirst_mobile/page/login/login.dart';
import 'package:heathfirst_mobile/page/map/googlemap.dart';
import 'package:heathfirst_mobile/page/profile/profil.dart';
import 'package:heathfirst_mobile/service/data.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class HomePage extends StatefulWidget {
  final Map<String, dynamic> user;
  HomePage({super.key, required this.user});

  @override
  State<HomePage> createState() => _HomepageState();
}

class _HomepageState extends State<HomePage> {
  Map<String, dynamic> get _infoUser => widget.user;
  Future<List<dynamic>> _listDoc = fetchData();
  late Future<List<dynamic>> _listDemd;

  @override
  void initState() {
    super.initState();
    _listDemd = rdvUserData();
  }
  
  @override
    Widget build(BuildContext context) {
    return Scaffold(
      // backgroundColor: Color.fromARGB(255, 237, 237, 237),
      appBar: AppBar(
        leading: 
          Builder(
            builder: (context) => GestureDetector(
              onTap: () {
              Scaffold.of(context).openDrawer();
            },
            child: const Icon(
              Icons.auto_awesome_mosaic_outlined,
            )),
          ),
        actions: [
          
          GestureDetector(
            onTap:(){
              Navigator.of(context).push(MaterialPageRoute(builder: (context) =>  SearchPage(user: _infoUser,)));
            },

            child: Container(
              width: 200,
              height: 35,
              padding: EdgeInsets.all(5),

              decoration: BoxDecoration(
                borderRadius: BorderRadius.all(Radius.circular(20)),
                border: Border.all( color: Colors.black38)
              ),
              child: Row(
                children: [
                  const Icon(Icons.search),
                  const SizedBox(width: 10,),
                  Text('Chercher'),
                ],
              ),
              
            ), 
          ),
          const SizedBox(width: 15),
        ],
      ),
      body: SingleChildScrollView(
        scrollDirection: Axis.vertical,
        child: 
            // ==================[Section aceuil]=================
              Container(
                width: double.infinity,
                color: Color.fromARGB(0, 237, 237, 237),
                padding: EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: MediaQuery.of(context).padding.top + 20,
                ),

                child: Column(
                  children: [
                    const Text(
                      'Bienvenue sur ',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 30,
                        letterSpacing: 3,
                        color: Color.fromARGB(171, 0, 0, 0),
                      ),
                    ),
                    const Text(
                      'Health First',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 30,
                        letterSpacing: 3,
                        color: Color(0xFF548856),
                      ),
                    ),
                    const SizedBox(height: 20,),
                    const Text(
                      'Vous aider à garder la forme est notre objectif.',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 15,
                        letterSpacing: 3,
                        color: Color.fromARGB(171, 0, 0, 0),
                        
                      ),
                    ),
                    const SizedBox(height: 70),
                    if((_infoUser['roles'] as List?)?.contains('ROLE_PATIENT') ?? false)
                      CategorieSection(),
                    
                    if((_infoUser['roles'] as List?)?.contains('ROLE_DOCTOR') ?? false)
                     Acceuildoc(listDemd: _listDemd, infoUser: _infoUser) ,

                    const SizedBox(height: 20,),
                    if((_infoUser['roles'] as List?)?.contains('ROLE_PATIENT') ?? false)
                      ListDocSection(listDoc: _listDoc, user: _infoUser,)


                  ],
                ),
              ), 
      ),
      drawer: Drawer(
        child: ListView(
          children:[
            Container(
              height: 200,
              padding: const EdgeInsets.only(
                top:  0,
                left: 15,
                right: 15,
                bottom: 15,
              ),

              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.center,

                children:[
                  Stack(
                    children: [
                      GestureDetector(
                        onTap:(){
                          Navigator.of(context).push(MaterialPageRoute(builder: (context) =>  ProfilSection()));
                        },

                        child: Container(
                          width: 80,
                          height: 80,
                          margin: const EdgeInsets.only(bottom: 5),

                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(100),
                            border: Border.all(
                              width: sqrt1_2,
                              color: const Color(0xFF81C784),
                            ),
                              image: DecorationImage(
                                image: NetworkImage('http://10.241.20.28:8000/images/photos/${_infoUser['photo_profil']}'),
                                fit: BoxFit.cover,
                              ),
                          ),
                        ),
                      ),
                    ],
                  ) ,
                  
                  const SizedBox(width: 5,),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                        Text("${_infoUser['LastName']} ${_infoUser['FirstName']}",
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 20
                            ),
                          )
                    ],
                  ),
              ]),
            ),

            Container(
              width: double.infinity,
              padding: const EdgeInsets.only(
                left: 70
              ),
              decoration: BoxDecoration(
                border: Border(
                  top: BorderSide(width: sqrt1_2)
                )
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,

                children: [
                  const SizedBox(height: 50,),
                  ListTile(
                    leading: const Icon(Icons.home_rounded),
                    title: const Text("Acceuil"),
                    onTap: (){
                      Navigator.of(context).push(MaterialPageRoute(builder: (context) => HomePage(user: _infoUser,)));
                    }
                  ),
                  ListTile(
                    leading: const Icon(Icons.event),
                    title: const Text("Agenda"),
                    onTap: (){
                      Navigator.of(context).push(MaterialPageRoute(builder: (context) => CalendarSection(user: _infoUser,)));
                    }
                  ),
                  if((_infoUser['roles'] as List?)?.contains('ROLE_PATIENT')?? false)

                    ListTile(
                      leading: const Icon(Icons.map_outlined),
                      title: const Text("Localisation"),
                      onTap: (){
                        Navigator.of(context).push(MaterialPageRoute(builder: (context) => const GoogleMapPage()));
                      }
                    ),
                  if((_infoUser['roles'] as List?)?.contains('ROLE_DOCTOR')?? false)
                    ListTile(
                      leading: const Icon(Icons.supervised_user_circle),
                      title: const Text("Rendez-vous"),
                      onTap: (){
                        Navigator.of(context).push(MaterialPageRoute(builder: (context) => RendezvousSection(user: _infoUser)));
                      }
                    ),
                  ListTile(
                    leading: const Icon(Icons.logout_outlined),
                    title: const Text("Déconnexion"),
                    onTap: () async{
                      final perfs = await SharedPreferences.getInstance();
                      await perfs.clear();

                      Navigator.of(context).push(MaterialPageRoute(builder: (context) => const LoginMobile()));
                    }
                  ),
                ],
              ),
            ),
            
        ]),
      ),
    ); 
  }
}