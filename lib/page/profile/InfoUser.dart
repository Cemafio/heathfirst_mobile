import 'dart:async';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:heathfirst_mobile/page/appointment/take_appointment.dart';
import 'package:heathfirst_mobile/page/login/login.dart';
import 'package:heathfirst_mobile/page/map/googlemap.dart';
import 'package:heathfirst_mobile/provider/app_provider.dart';
import 'package:heathfirst_mobile/provider/userProvider.dart';
import 'package:heathfirst_mobile/service/data.dart';
import 'package:intl/intl.dart';
import 'package:table_calendar/table_calendar.dart';


class InfoUser extends ConsumerStatefulWidget {
  final List<dynamic> data;

  const InfoUser({super.key, required this.data});

  @override
  ConsumerState<InfoUser> createState() => _InfoUserState();
}

class _InfoUserState extends ConsumerState<InfoUser> {

  final _formKey = GlobalKey<FormState>();
  Map<String, dynamic> get _apropos => widget.data[0];
  Future<List<dynamic>> get _listDoc => widget.data[2];

  DateTime dayNow = DateTime.now();
  int justDay = DateTime.now().day;
  int justMonth = DateTime.now().month;
  bool isWaiting = false;
  late Future<Map<String,dynamic>> _etatRdv ;

  final TextEditingController _dateController = TextEditingController();
  final TextEditingController _symptomeController = TextEditingController();
  bool isLoaded = false;



  void initRdState() async {
    _etatRdv = verrifAppointment(idDoc: _apropos['id'],patientId: ref.read(userDataStatic).id!, baseUrl: ref.read(baseUrl),token: ref.read(accessTokenProvider));
  }
  
  
  @override
  void initState(){
    super.initState();
    initRdState();
  }

Widget _buildBottomButton(Map<String, dynamic> state) {
  final Map<String, dynamic> buttons = {
    'none': {
      'text': 'Prendre rendez-vous',
      'color': Color(0xFF548856),
      'borderColor': Color(0xFF548856),
    },
    'accepted': {
      'text': 'Rendez-vous accepté',
      'color': const Color.fromARGB(255, 139, 195, 74),
      'borderColor': Color.fromARGB(0, 101, 133, 102),
    },
    'refused': {
      'text': 'Rendez-vous refusé',
      'color': const Color.fromARGB(0, 255, 82, 82),
    },
    'pending': {
      'text': 'Rendez-vous en attente',
      'color': Colors.grey,
      'borderColor': Color.fromARGB(0, 84, 136, 86),
    },
  };
  
  // 🔒 Sécurisation totale du state
  final existe = state['existe'];
  final response = state['response'];
  final item = buttons[response] ?? buttons['none']!;

  return InkWell(
    onTap: (){
      if(existe == false) {
        _navigation(TakeAppointment(docInfo: _apropos));
      }
    },
    child: Container(
      height: 60,
      margin: EdgeInsets.only(bottom: 20),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: item['borderColor']),
      ),
      child: Center(
        child: Text(
          item['text']??'vide',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: item['color']??Colors.red,
          ),
        ),
      ),
    ),
  );
}

Future<void> _navigation(Widget materialPage) async {
  final opened = await Navigator.push(
    context,
    MaterialPageRoute(builder: (_) => materialPage),
  );

  if (opened == true) {
    setState(() {
      _etatRdv = verrifAppointment(idDoc: _apropos['id'],patientId: ref.read(userDataStatic).id!, baseUrl: ref.read(baseUrl), token: ref.read(accessTokenProvider));
    });
  }
}
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color.fromARGB(255, 241, 241, 241),
      appBar: AppBar(
        backgroundColor: Colors.white,
        title: const Text("Apropos", style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: Color.fromARGB(171, 0, 0, 0),),),
      ),

      // 🔒 Bouton fixé en bas
      bottomNavigationBar: FutureBuilder(
        future: verrifAppointment(idDoc: _apropos['id'],patientId: ref.read(userDataStatic).id!, baseUrl: ref.read(baseUrl), token: ref.read(accessTokenProvider)), 

        builder: (context, snapshot){
          if (snapshot.connectionState == ConnectionState.waiting) {
            return SizedBox(
              width: double.infinity,
              child: Center(child:const CircularProgressIndicator(strokeWidth: 3.0,)));
          }
          if (snapshot.hasError) {
            if (snapshot.error.toString().contains("unauthorized")) {
              Future.microtask(() {
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (_) => LoginMobile()),
                );
              });
            }
            return Center(child: Text('Erreur : ${snapshot.error}'));
          }
          // 3️⃣ Si aucune data
          if (!snapshot.hasData || snapshot.data == null) {
            return const Text("Aucune donnée disponible");
          }

          print('====> Reaload detected');
          final _etaRdv = snapshot.data ?? {};
          
          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
            child: _buildBottomButton(_etaRdv)
          );
        }
      ), 

      body: SingleChildScrollView(
        scrollDirection: Axis.vertical,

        child: Column(
          children: [
              Stack(
                clipBehavior: Clip.none,

                children: [
                  Container(
                    width: double.infinity,
                    height: 200,
                    decoration: const BoxDecoration(
                      borderRadius: BorderRadius.only(bottomLeft: Radius.circular(50), bottomRight: Radius.circular(50)),
                      color: Colors.white,
                    ),

                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                    
                      children: [
                        
                      ],
                    ),
                  ),
                  Positioned(
                    bottom: -70,
                    left: 130,
                    child: Container(
                      width: 130,
                      height: 130,
                      margin: const EdgeInsets.only(bottom: 5),

                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(100),
                        border: Border.all(
                          width: sqrt1_2,
                          color: const Color(0xFF81C784),
                        ),
                          image: DecorationImage(
                            image: NetworkImage("${ref.watch(baseUrl)}/images/photos/${_apropos['photo_doc']}"),
                            fit: BoxFit.cover,
                          ),
                      ),
                    ),
                  ),
                ]
              ),
              const SizedBox(height: 80,),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    '${_apropos['last_name']} ${_apropos['first_name']}',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 2.0
                    ),
                  ),
              ],),
              Column(
                children: [
                  Container(
                    width: double.infinity,
                    margin: EdgeInsets.all(10),
                    padding: EdgeInsets.all(15),
                    // height: 300,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.all(Radius.circular(10))
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text("Information",
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.normal,
                            letterSpacing: 2.0
                          )
                        ),
                        const SizedBox(height: 20,),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text("Specialisation"),
                            Text("${_apropos['speciality']}", style: TextStyle(fontWeight: FontWeight.bold),)
                          ],
                        ),
                        const SizedBox(height: 7,),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text("Adess cabinet"),
                            Text("${_apropos['addressCabinet']}", style: TextStyle(fontWeight: FontWeight.bold),)
                          ],
                        ),
                        const SizedBox(height: 7,),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                          Text("Numero de téléphone"),
                          Text("${_apropos['phone']}", style: TextStyle(fontWeight: FontWeight.bold),)
                        ],),
                        const SizedBox(height: 7,),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                          Text("email"),
                          Text("${_apropos['email']}", style: TextStyle(fontWeight: FontWeight.bold),)
                        ],),
                    ],),
                  ),

                   Container(
                    width: double.infinity,
                    margin: EdgeInsets.all(10),
                    padding: EdgeInsets.all(10),
                    // height: 300,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.all(Radius.circular(10)),
                      // border: Border.all()
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Container(
                          height: 100.w,
                          width: 100.w,

                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.all(Radius.circular(10)),
                            image: DecorationImage(
                              image: AssetImage("assets/images/map_img.jpg"),
                              fit: BoxFit.cover,
                            ),
                          ),
                        ),
                        const SizedBox(width: 10,),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Text('Localisation du cabinet'),
                            Text('Antananarivo - ${_apropos['addressCabinet']}'),
                          ],
                        ),
                        const SizedBox(width: 10,),
                        GestureDetector(
                          onTap: (){
                            if(_apropos['location'] != null) _navigation(GoogleMapPage(allDoc: [_listDoc, _apropos['lastName']]));
                          },
                          child: Container(
                            width: 40,
                            height: 40,
                            decoration: BoxDecoration(
                              // color: const Color.fromARGB(255, 241, 241, 241),
                              borderRadius: BorderRadius.circular(25),
                              border: Border.all(color: Colors.black26)
                            ),

                            child: Center(child: (_apropos['location'] != null)
                              ?Icon(Icons.location_searching_sharp)
                              :Icon(Icons.location_disabled, color: Colors.grey,)
                            ),
                          ),
                        ),
                    ])
                  )
                ],

              )
            ]) 
        ),
    ); 
      
  }
}