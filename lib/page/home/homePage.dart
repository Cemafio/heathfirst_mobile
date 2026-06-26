import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:heathfirst_mobile/model/user_model.dart';
import 'package:heathfirst_mobile/page/agenda/calendar.dart';
import 'package:heathfirst_mobile/page/agenda/callendarClient.dart';
import 'package:heathfirst_mobile/page/appointment/RdvStream.dart';
import 'package:heathfirst_mobile/page/appointment/demandeRendeVous.dart';
import 'package:heathfirst_mobile/page/home/acceuilDoc.dart';
import 'package:heathfirst_mobile/page/home/categorie.dart';
import 'package:heathfirst_mobile/page/home/searchSection.dart';
import 'package:heathfirst_mobile/page/home/liste_doc_alentour.dart';
import 'package:heathfirst_mobile/page/login/login.dart';
import 'package:heathfirst_mobile/page/map/googlemap.dart';
import 'package:heathfirst_mobile/page/map/mapTest.dart';
import 'package:heathfirst_mobile/page/profile/profil.dart';
import 'package:heathfirst_mobile/provider/app_provider.dart';
import 'package:heathfirst_mobile/provider/userProvider.dart';
import 'package:heathfirst_mobile/service/data.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:jwt_decoder/jwt_decoder.dart';
import 'package:heathfirst_mobile/utils/string_extension.dart';

class HomePage extends ConsumerStatefulWidget {
  HomePage({super.key});

  @override
  ConsumerState<HomePage> createState() => _HomepageState();
}

class _HomepageState extends ConsumerState<HomePage> {
  late Future<List<dynamic>> _listDoc;
  late Future<List<dynamic>> _listDemd;

  void loadRdvUserData() async{
    final token = ref.read(accessTokenProvider);
    final base_url = ref.read(baseUrl);
    _listDemd = rdvUserData(token: token,baseUrl: base_url);
    _listDoc = fetchDataDoc(token: token, urlBase: base_url);
  }

  @override
  void initState() {
    super.initState();
    loadRdvUserData();

    print(ref.watch(user_data));
    WidgetsBinding.instance.addPostFrameCallback((_) {
      startSessionWatcher(context);
    });
  }
  Future<void> _navigation(Widget materialPage) async {
    final opened = await Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => materialPage),
    );

    if (opened == true) {
      setState(() {
        // _infoUser = userInfo();
      });
    }
  }
  // -------------------Verrif SESSION---------------------
  void startSessionWatcher(BuildContext context) {
    Timer.periodic(const Duration(minutes: 5), (timer) async {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      final token = prefs.getString("token");

      if (token != null && JwtDecoder.isExpired(token)) {
        timer.cancel(); // stop timer

        // Supprimer token
        await prefs.remove("token");

        print("⚠ Token expiré automatiquement");

        // Afficher popup
        if (context.mounted) {
          showDialog(
            context: context,
            barrierDismissible: false, // l'utilisateur ne peut pas fermer sans cliquer sur OK
            builder: (context) => AlertDialog(
              title: const Text("Session Expirée"),
              content: const Text(
                "Votre session a expiré pour des raisons de sécurité.\n\nVeuillez vous reconnecter."
              ),
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.of(context).pop(); // fermer popup

                    // 👉 Redirection vers la page Login
                    // Navigator.pushReplacementNamed(context, "/login");
                    _navigation(LoginMobile());
                  },
                  child: const Text("OK"),
                )
              ],
            ),
          );
        }
      }
    });
  }

  @override
    Widget build(BuildContext context) {
    final _userDataAsync = ref.watch(user_data);
    final _userDataStatic = ref.watch(userDataStatic);
    final profil = ref.watch(userDataStatic).profil;

    final hasPhoto = profil != null &&
        profil.toString().trim().isNotEmpty &&
        profil.toString() != 'null';

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
            )
          ),
        ),
        actions: [
          GestureDetector(
            onTap:(){
              Navigator.of(context).push(MaterialPageRoute(builder: (context) =>  SearchPage(listDoc: _listDoc)));
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
        child: Container(
          width: double.infinity,
          color: Color.fromARGB(0, 237, 237, 237),
          padding: EdgeInsets.symmetric(
            horizontal: 20,
            vertical: MediaQuery.of(context).padding.top + 20,
          ),

          child: Column(
            children: [
              SizedBox(
                height: 150,
                width: double.infinity,
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
                      'Salma',
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
                  ],
                ),
              ),
              

              const SizedBox(height: 25,),
              SizedBox(
                width: MediaQuery.of(context).size.width,
                height: MediaQuery.of(context).size.height - 300,

                child: ref.watch(userDataStatic).roles == 'ROLE_PATIENT'
                  ? ListDocSection(listDoc: _listDoc) 
                  : Acceuildoc()
              ),
              
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
                  GestureDetector(
                    onTap:(){
                      //  print(profil);
                      Navigator.of(context).push(MaterialPageRoute(builder: (context) =>  ProfilSection()));
                    },

                    child: Container(
                      width: 80,
                      height: 80,
                      margin: const EdgeInsets.only(bottom: 5),

                      decoration: BoxDecoration(
                        color: const Color(0xFF81C784),
                        borderRadius: BorderRadius.circular(100),
                        border: Border.all(
                          width: sqrt1_2,
                          color: const Color(0xFF81C784),
                        ),
                      ),

                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            _userDataStatic.lastname.toString().uperFirstChart(),
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold
                            ),
                          )
                        ],
                      ),
                    ),
                    // (hasPhoto)
                    // ? Container(
                    //     width: 80,
                    //     height: 80,
                    //     margin: const EdgeInsets.only(bottom: 5),

                    //     decoration: BoxDecoration(
                    //       borderRadius: BorderRadius.circular(100),
                    //       border: Border.all(
                    //         width: sqrt1_2,
                    //         color: const Color(0xFF81C784),
                    //       ),
                    //       image: DecorationImage(
                    //         image: NetworkImage('${ref.watch(baseUrl)}/images/photos/${_userDataStatic.profil}'),
                    //         fit: BoxFit.cover,
                    //       ),
                    //     ),
                    //   )
                    // : 
                    
                  ),
              
                  const SizedBox(width: 5,),
                  Text("${_userDataStatic.lastname} ${_userDataStatic.firstname}",
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 14
                    ),
                  )
            
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
                      Navigator.of(context).push(MaterialPageRoute(builder: (context) => HomePage()));
                    }
                  ),
                  ListTile(
                    leading: const Icon(Icons.event),
                    title: const Text("Agenda"),
                    onTap: (){
                      Navigator.of(context).push(MaterialPageRoute(builder: (context) => (ref.watch(userDataStatic).roles == 'ROLE_DOCTOR') ? CalendarSection() : CallendarClient()));
                    }
                  ),
                  if(_userDataStatic.roles == 'ROLE_PATIENT')...[
                    ListTile(
                      leading: const Icon(Icons.map_outlined),
                      title: const Text("Localisation"),
                      onTap: (){
                        Navigator.of(context).push(MaterialPageRoute(builder: (context) => GoogleMapPage(allDoc: [_listDoc,''])));
                      }
                    ),

                  ],
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