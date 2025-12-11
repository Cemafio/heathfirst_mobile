import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:heathfirst_mobile/page/home/homePage.dart';
import 'package:heathfirst_mobile/page/login/login.dart';
import 'package:heathfirst_mobile/page/map/addCabinet.dart';
import 'package:heathfirst_mobile/page/profile/editProfil.dart';
import 'package:heathfirst_mobile/page/profile/editProfilDoc.dart';
import 'package:heathfirst_mobile/page/setting/settingPage.dart';
import 'package:heathfirst_mobile/service/data.dart';
import 'package:provider/provider.dart';
import 'package:table_calendar/table_calendar.dart';

class ProfilSection extends StatefulWidget {
  // Map<String, dynamic> infoUser;
  // Future<List<dynamic>> listDemd ;
  const ProfilSection({super.key});

  @override
  State<ProfilSection> createState() => _ProfilSectionState();
}

class _ProfilSectionState extends State<ProfilSection> {
  // Map<String, dynamic> get _infoUser => widget.infoUser;
  Future<Map<String, dynamic>> _infoUser = userInfo();
  // Future<List<dynamic>> get _listDemd => widget.listDemd;
  Future<List<dynamic>> _listDemd = rdvUserData();

  DateTime dayNow = DateTime.now();
  int justDay = DateTime.now().day;
  int justMonth = DateTime.now().month;
  int patientConsulter = 0;
  int patientNonConsulter = 0;
  String _contains = "Auccun programme";
  bool _isExist = false;
  List<Widget> _widget =[];
  

  void _selectedDay (DateTime day, DateTime focusedDay) {
  
    _widget = [];

    setState (() {
      dayNow = day;
      justDay = day.day;
      // _contains = tmp;
    });
  }
  // Définir une liste de jours fériés
  final List<DateTime> _holidays = [
    DateTime.utc(2024, 7, 10),
    DateTime.utc(2024, 7, 25),
    DateTime.utc(2024, 7, 14),
  ];

  @override
  void initState() {
    super.initState();
    // _countDemdType();
    // _infoUser = userInfo();
  }

  Future<void> _openEditProfil() async {
    final Map<String,dynamic> user = await _infoUser;
    final updated = await Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => (user['roles'][0] == 'ROLE_PATIENT')? Editprofil(infoUser: user): EditprofilDoc(infoUser: user)),
    );

    if (updated == true) {
      // Recharger les données depuis l'API
      // await fetchUserData();
      setState(() {
        _infoUser = userInfo();
      });
    }
  }

  Future<void> _navigation(Widget materialPage) async {
    final opened = await Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => materialPage),
    );

    if (opened == true) {
      setState(() {
        _infoUser = userInfo();
      });
    }
  }


  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 229, 229, 229),
      body: SingleChildScrollView(
        child: FutureBuilder(
          future: _infoUser, 
          builder: (context, snapshot){
            if (snapshot.connectionState == ConnectionState.waiting) {
              print("En attente");
              return SafeArea(child: Container(
                width: double.infinity,
                child: Center(child:const CircularProgressIndicator(strokeWidth: 3.0,)))) ;
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

            final infoUser = snapshot.data!;
            return 
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Stack(
                    clipBehavior: Clip.none,

                    children: [
                      Container(
                        width: double.infinity,
                        height: 300,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.only(bottomLeft: Radius.circular(30), bottomRight: Radius.circular(30)),
                          color: Colors.white,
                          image: DecorationImage(
                            image: NetworkImage("http://172.27.136.28:8000/images/photos/${infoUser['photo_profil']}"),
                            fit: BoxFit.cover,
                          ),
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
                              image: NetworkImage("http://172.27.136.28:8000/images/photos/${infoUser['photo_profil']}"),
                              fit: BoxFit.cover,
                            ),
                          ),
                        ),
                      ),
                      Positioned(
                        top: 40,
                        left: 10,
                        child: GestureDetector(
                          onTap: (){
                            // Navigator.pop(context);
                            Navigator.of(context).push(MaterialPageRoute(builder: (context)=>HomePage(user: infoUser)));
                          },
                          child: Container(
                            padding: const EdgeInsets.all(10),
                            margin: const EdgeInsets.only(bottom: 5),

                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(6),
                              color: const Color.fromARGB(57, 255, 255, 255)
                            ),

                            child: const Icon(Icons.arrow_back_ios_new_rounded, color: Color.fromARGB(255, 46, 46, 46),),
                          ),
                        )
                        
                      ),
                    ]
                  ),
                  const SizedBox(height: 60,),
                  Container(  
                    width: double.infinity,
                    margin: const EdgeInsets.symmetric(horizontal:0, vertical: 17),

                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Center(
                          child: Text(
                            '${infoUser['LastName']} ${infoUser['FirstName']}',
                            style: const TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                              letterSpacing: 2.0
                            ),
                          ),
                        ),
                        Text("${infoUser['email']}"),   
                        if((infoUser['roles'] as List?)?.contains('ROLE_DOCTOR') ?? false)
                          Text("${infoUser['Specialty']}"),   
                        if((infoUser['roles'] as List?)?.contains('ROLE_DOCTOR') ?? false)
                          Text("${infoUser['AddressCabinet']}"),  
                        if((infoUser['roles'] as List?)?.contains('ROLE_PATIENT') ?? false)
                          Text("${infoUser['Address']}"),   
        
                        const SizedBox(height: 20,),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            if((infoUser['roles'] as List?)?.contains('ROLE_DOCTOR') ?? false)
                            GestureDetector(
                              onTap: (){
                                _navigation(AjouterCabinetPage(user: infoUser,));
                              },
                              child: Container(
                                  width: 50,
                                  height: 50,
                                  decoration: BoxDecoration(
                                    // color: const Color.fromARGB(255, 241, 241, 241),
                                    borderRadius: BorderRadius.circular(6),
                                    border: Border.all(color: Colors.black26)
                                  ),

                                  child: Center(child: Icon(Icons.location_searching_sharp),),
                                ),
                            ),
                            Material(
                              color: Colors.transparent,
                              child: InkWell(
                                onTap: (){
                                  _openEditProfil();
                                  // Navigator.of(context).push(MaterialPageRoute(builder: (context) => (infoUser['roles'][0] == 'ROLE_PATIENT') ?Editprofil(infoUser: infoUser,) :EditprofilDoc(infoUser: infoUser)));
                                },
                                child: 
                                  Container(
                                    width: 160,
                                    height: 50,
                                    margin: const EdgeInsets.symmetric(horizontal: 10),
                                    decoration: BoxDecoration(
                                      // color: const Color.fromARGB(255, 241, 241, 241),
                                      borderRadius: BorderRadius.circular(6),
                                      border: Border.all(color: Colors.black26)
                                    ),

                                    child: const Center(
                                      child: Text('MODIFIER PROFIL', 
                                      style: TextStyle(
                                        fontSize: 13, 
                                        fontWeight: FontWeight.bold, 
                                        color: Colors.black38
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                            // const SizedBox(width: 10,),
                            GestureDetector(
                              onTap: (){
                                _navigation(Settingpage(user: infoUser));
                              },
                              child: Container(
                                  width: 50,
                                  height: 50,
                                  decoration: BoxDecoration(
                                    // color: const Color.fromARGB(255, 241, 241, 241),
                                    borderRadius: BorderRadius.circular(6),
                                    border: Border.all(color: Colors.black26)
                                  ),

                                  child: Center(child: Icon(Icons.settings),),
                                ),
                            ),
                          ],
                        ),
                            
                        if((infoUser['roles'] as List?)?.contains('ROLE_DOCTOR') ?? false)
                          Container(
                            width: double.infinity,
                            height: 70,
                            margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(6),
                              border: Border.all(color: Colors.black26)
                            ),

                            child: FutureBuilder(
                              future: _listDemd, 
                              builder: (context, snapshot){
                                if (snapshot.connectionState == ConnectionState.waiting) {
                                  return Container(
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

                                final rdv = snapshot.data;
                                int nbrPatient = 0;
                                int nbrDemd = 0;
                                if(rdv!=null){
                                  for (var list in rdv) {
                                    if(list['status'] != "pending" && list['status'] != "refused"){
                                      nbrPatient++;
                                    }else if(list['status'] == "pending"){
                                      nbrDemd++;
                                    }      
                                  }
                                }
                                
                                patientConsulter = nbrPatient;
                                patientNonConsulter = nbrDemd;
                              
                                return Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                  children: [
                                    Container(
                                      height: 50,
                                      padding: EdgeInsets.symmetric(horizontal: 10),
                                      decoration: const BoxDecoration(
                                        border: Border(
                                          top: BorderSide.none,
                                          bottom: BorderSide.none,
                                          left: BorderSide.none,
                                          right: BorderSide.none
                                        ),
                                      ),  

                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.center,
                                        children: [
                                          Text("$patientConsulter", style: TextStyle(fontWeight: FontWeight.bold,fontSize: 22, color: Colors.black45),),
                                          const Text("patient", style: TextStyle(fontWeight: FontWeight.bold,fontSize: 13, color: Colors.black45),),
                                        ],
                                      ),  
                                    ),
                                    Container(
                                      height: 50,
                                      padding: EdgeInsets.symmetric(horizontal: 10),
                                      decoration: const BoxDecoration(
                                        // color: const Color.fromARGB(255, 241, 241, 241),
                                        border: Border(
                                          top: BorderSide.none,
                                          bottom: BorderSide.none,
                                          left: BorderSide(color: Colors.black26),
                                          right: BorderSide(color: Colors.black26)
                                        ),
                                      ),  

                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.center,
                                        children: [
                                          Text("$patientNonConsulter", style: TextStyle(fontWeight: FontWeight.bold,fontSize: 22, color: Colors.black45),),
                                          Text("demande", style: TextStyle(fontWeight: FontWeight.bold,fontSize: 13, color: Colors.black45),),
                                        ],
                                      ),  
                                    ),
                                    Container(
                                      height: 50,
                                      padding: EdgeInsets.symmetric(horizontal: 10),

                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.center,
                                        children: [
                                          Text("10.000 Ar", style: TextStyle(fontWeight: FontWeight.bold,fontSize: 22, color: Colors.black45),),
                                          Text("consultation", style: TextStyle(fontWeight: FontWeight.bold,fontSize: 13, color: Colors.black45),),
                                        ],
                                      ),  
                                    ),
                                  ],
                                );
                              }
                              
                            
                            ), 
                              
                          ),
                        
                        // Container(
                        //   padding: const EdgeInsets.symmetric(
                        //     vertical: 10,
                        //     horizontal: 5 
                        //   ),
                        //   width: double.infinity,
                        //   margin: const EdgeInsets.all(20),

                        //   decoration: BoxDecoration(
                        //     borderRadius: BorderRadius.circular(10),
                        //     border: Border.all(color: Colors.black26)
                        //   ),
                        //   child: Column(
                        //     children: [
                        //       const Row(
                        //         mainAxisAlignment: MainAxisAlignment.start,
                        //         children: [
                        //           Icon(Icons.calendar_month),
                        //           SizedBox(width: 10,),
                        //           Text(
                        //             'Apropos',
                        //             style: TextStyle(
                        //               fontSize: 16,
                        //               fontWeight: FontWeight.bold,
                        //               letterSpacing: 1,
                        //               color:  Color.fromARGB(158, 0, 0, 0)
                        //             ),
                        //           ),
                        //         ],
                        //       ),
                        //       Container(
                        //         width: 350,
                        //         margin: const EdgeInsets.only(left: 10, top: 10),
                        //         child: Text(
                        //           "    Yhhighohhrsg uhbvfruf jjksjkef ujrvjfvvjv jfjksj ufhdfv hfvhf fhihoospdfkjjdf pplmmmmgùg kjeùùmmlhgh ùù;z;;p^^pk,epporktg ,kpogtkbp ojgojbobin,n itio,joi,ndbkkb ,fnb,b,fk, fopjnfojhjfjh oithoiiojfhj ifigojifojh oiopsojrpg çrerhgio uugiuguisif rgoizeyugrgeriuger usheufhurg ushuihsdrvoirogidf seufgurguhrg suhruifhuhrg shfuhruhrog",
                        //           style: TextStyle(letterSpacing: 1),
                        //         ),
                        //       ),
                        //     ]
                        //   ),
                        // ),

                        // if((infoUser['roles'] as List?)?.contains('ROLE_DOCTOR') ?? false)
                        // Container(
                        //     // height: 60,
                        //     padding: const EdgeInsets.symmetric(
                        //     vertical: 10,
                        //     horizontal: 5 
                        //   ),
                        //   width: double.infinity,
                        //   margin: const EdgeInsets.all(20),

                        //   decoration: BoxDecoration(
                        //     // color: const Color.fromARGB(255, 241, 241, 241),
                        //     borderRadius: BorderRadius.circular(10),
                        //     border: Border.all(color: Colors.black26)
                        //   ),
                        //   child: Column(
                        //     children: [
                        //       const Row(
                        //         mainAxisAlignment: MainAxisAlignment.start,
                        //         children: [
                        //           Icon(Icons.calendar_month),
                        //           SizedBox(width: 10,),
                        //           Text(
                        //             'Experience',
                        //               style: TextStyle(
                        //               fontSize: 16,
                        //               fontWeight: FontWeight.bold,
                        //               letterSpacing: 1,
                        //               color:  Color.fromARGB(158, 0, 0, 0)
                        //             ),
                        //           ),
                        //         ],
                        //       ),
                        //       Container(
                        //         width: 350,
                        //         margin: const EdgeInsets.only(left: 10, top: 10),
                        //         child: Text(
                        //             "    Yhhighohhrsg uhbvfruf jjksjkef ujrvjfvvjv jfjksj ufhdfv hfvhf fhihoospdfkjjdf pplmmmmgùg kjeùùmmlhgh ùù;z;;p^^pk,epporktg ,kpogtkbp ojgojbobin,n itio,joi,ndbkkb",
                        //             style: TextStyle(letterSpacing: 1),
                        //         ),
                        //       ),
                        //     ]
                        //   ),
                        // ),
                    ],
                  ),
                ),
              ]
            );
          }
        ),
      )
    );
  }
}

