import 'dart:async';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:heathfirst_mobile/page/appointment/take_appointment.dart';
import 'package:heathfirst_mobile/page/login/login.dart';
import 'package:heathfirst_mobile/page/map/googlemap.dart';
import 'package:heathfirst_mobile/service/data.dart';
import 'package:intl/intl.dart';
import 'package:table_calendar/table_calendar.dart';


class InfoUser extends StatefulWidget {
  final List<dynamic> data;

  const InfoUser({super.key, required this.data});

  @override
  State<InfoUser> createState() => _InfoUserState();
}

class _InfoUserState extends State<InfoUser> {

  final _formKey = GlobalKey<FormState>();
  Map<String, dynamic> get _apropos => widget.data[0];
  Map<String, dynamic> get _infoUser => widget.data[1]; 
  Future<List<dynamic>> get _listDoc => widget.data[2];

  DateTime dayNow = DateTime.now();
  int justDay = DateTime.now().day;
  int justMonth = DateTime.now().month;
  final Future<List<dynamic>> _listDemd = rdvUserData();
  // DateTime? _selectedDate;
  // String _time = '';
  // String _symptome = '';
  bool isWaiting = false;
  late Future<Map<String,dynamic>> _etatRdv ;

  final TextEditingController _dateController = TextEditingController();
  final TextEditingController _symptomeController = TextEditingController();
  bool isLoaded = false;



  // void resetForm() {
  //   _formKey.currentState?.reset();
  //   _dateController.clear();
  //   _symptomeController.clear();
  // }
  
  @override
  void initState(){
    super.initState();
    _etatRdv = verrifAppointment(_apropos['id'], _infoUser['id']);
  }
  // void sendRdv() async{
    // await takeAppointmentSimple(_apropos['id'],_selectedDate!, _symptome, _time, _apropos['id'], _infoUser['id']);
  //   await takeAppointmentSimple(
  //     nom: "Rakoto",
  //     prenom: "Jean",
  //     birthday: "2001-05-20",
  //     sexe: "Homme",
  //     tel: "0341234567",
  //     email: "rakoto@gmail.com",
  //     password: "1234",
  //     address: "Lot II...",
  //     city: "Antananarivo",
  //     hour: "15:00",
  //     date: "2025-12-12",
  //     symptome: "Toux",
  //     idDoctor: "3",
  //   );

  //   print('Try to reload');
  //   setState(() {
  //     _etatRdv = verrifAppointment(_apropos['id'], _infoUser['id']);
  //   });
  //   Navigator.pop(context);
  // }

Widget _buildBottomButton(Map<String, dynamic> state) {
  final Map<String, dynamic> buttons = {
    'none': {
      'text': 'Prendre rendez-vous',
      'color': Color(0xFF548856),
    },
    'accepted': {
      'text': 'Rendez-vous accepté',
      'color': const Color.fromARGB(0, 139, 195, 74),
    },
    'refused': {
      'text': 'Rendez-vous refusé',
      'color': const Color.fromARGB(0, 255, 82, 82),
    },
    'pending': {
      'text': 'Rendez-vous en attente',
      'color': Colors.grey,
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
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: item['color']),
      ),
      child: Center(
        child: Text(
          item['text'],
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: item['color'],
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
      _etatRdv = verrifAppointment(_apropos['id'], _infoUser['id']);
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
      bottomNavigationBar: 
     
          FutureBuilder(
            future: _etatRdv, 
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
                        // Container(
                        //   height: 50,
                        //   child: Column(
                        //     children: [
                        //       Text("1000+", style: TextStyle(fontWeight: FontWeight.bold, color: Colors.green)),
                        //       Text("patient"),
                        //     ],
                        //   ),
                        // ),
                        // Container(
                        //   height: 50,
                        //   child: Column(
                        //     children: [
                        //       Text("5ans", style: TextStyle(fontWeight: FontWeight.bold, color: Colors.green),),
                        //       Text("experience"),
                        //     ],
                        //   ),
                        // ),
                        // Container(
                        //   height: 50,
                        //   child: Column(
                        //     children: [
                        //       Text("9.000ar", style: TextStyle(fontWeight: FontWeight.bold, color: Colors.green),),
                        //       Text("Consultation"),
                        //     ],
                        //   ),
                        // ),
                        
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
                            image: NetworkImage("http://172.27.136.28:8000/images/photos/${_apropos['photoProfil']}"),
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
                    '${_apropos['lastName']} ${_apropos['firstName']}',
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
                          Text("${_apropos['specialty']}", style: TextStyle(fontWeight: FontWeight.bold),)
                        ],),
                        const SizedBox(height: 7,),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                          Text("Adress"),
                          Text("${_apropos['Address']}", style: TextStyle(fontWeight: FontWeight.bold),)
                        ],),
                        const SizedBox(height: 7,),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                          Text("Adess cabinet"),
                          Text("${_apropos['AddressCabinet']}", style: TextStyle(fontWeight: FontWeight.bold),)
                        ],),
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
                            Text('Antananarivo - ${_apropos['AddressCabinet']}'),
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