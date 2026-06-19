import 'dart:async';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:heathfirst_mobile/page/appointment/take_appointment.dart';
import 'package:heathfirst_mobile/page/login/login.dart';
import 'package:heathfirst_mobile/page/map/googlemap.dart';
import 'package:heathfirst_mobile/page/widget/clientFormRdv.dart';
import 'package:heathfirst_mobile/page/widget/expanded_widget.dart';
import 'package:heathfirst_mobile/page/widget/simple_btn.dart';
import 'package:heathfirst_mobile/provider/app_provider.dart';
import 'package:heathfirst_mobile/provider/rdvProvider.dart';
import 'package:heathfirst_mobile/provider/userProvider.dart';
import 'package:heathfirst_mobile/service/data.dart';
import 'package:easy_date_timeline/easy_date_timeline.dart';
import 'package:hugeicons/hugeicons.dart';
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

  bool isLoaded = false;
  DateTime selectedDay = DateTime.now();
  String selectedTime = '';

  List<DateTime> dates = List.generate(
    30,
    (index) => DateTime.now().add(Duration(days: index)),
  );

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
        'text': 'Accepté',
        'color': const Color.fromARGB(255, 139, 195, 74),
        'borderColor': Color.fromARGB(0, 101, 133, 102),
      },
      'refused': {
        'text': 'Refusé',
        'color': const Color.fromARGB(0, 255, 82, 82),
      },
      'pending': {
        'text': 'En attente ...',
        'color': Colors.grey,
        'borderColor': Colors.grey,
      },
    };

    
    // 🔒 Sécurisation totale du state
    final existe = state['existe'];
    final response = state['response'];
    final item = buttons[response] ?? buttons['none']!;

    return SimpelBtn(
      // h: 60,
      w: 170,
      t: item['text']??'vide',
      txc: item['color']??Colors.red,
      st: item['borderColor'],
      bold: true,
      c: Colors.transparent,
      sizetx: 15,
      action: (){
        if(existe == false) {
          showBottomForm();        
        }
      }
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

  void selectedDayAction(DateTime date){
    setState(() {
      selectedDay = date;
    });
  }
  void selectedTimeAction(String time){
    setState(() {
      selectedTime = time;
    });
  }
  void showBottomForm(){
    showModalBottomSheet(
      context: context, 
       isScrollControlled: true, // IMPORTANT
      builder: (context){
        return ClientFormRdv(docInfo: _apropos,);
      }
    );
  }

  Widget build(BuildContext context) {
    final verrifRdv = ref.watch(verrifRdvAsync);
    return Scaffold(
      backgroundColor: Color.fromARGB(255, 241, 241, 241),
      appBar: AppBar(
        backgroundColor: Colors.white,
        title: const Text("Apropos", style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: Color.fromARGB(171, 0, 0, 0),),),
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
                    height: 150,
                    padding: const EdgeInsets.all(10),

                    child: Row(
                      children: [

                        // Photo
                        Container(
                          width: 110,
                          height: 130,

                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(
                              width: 1,
                              color: const Color(0xFF81C784),
                            ),

                            boxShadow: [
                              BoxShadow(
                                blurRadius: 15,
                                offset: Offset(0, 5),
                                color: Colors.black12,
                              )
                            ],

                            image: DecorationImage(
                              image: NetworkImage(
                                "${ref.watch(baseUrl)}/images/photos/${_apropos['photo_doc']}",
                              ),
                              fit: BoxFit.cover,
                            ),
                          ),
                        ),

                        const SizedBox(width: 20),

                        // Informations
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisAlignment: MainAxisAlignment.center,

                            children: [

                              Text(
                                "Dr ${_apropos['last_name']} ${_apropos['first_name']}",
                                style: const TextStyle(
                                  fontSize: 22,
                                  fontWeight: FontWeight.bold,
                                ),

                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                              ),

                              const SizedBox(height: 6),

                              Row(
                                children: [
                                  Icon(
                                    Icons.add_chart_rounded,
                                    color: Color(0xFF548856),
                                    size: 15
                                  ),
                                  const SizedBox(width: 5),

                                  
                                  Expanded(
                                    child: Text(
                                      _apropos['speciality'] ?? '',
                                      maxLines: 2,
                                      style: TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.w600,
                                        color: Colors.green.shade700,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 6),
                              Row(
                                children: [
                                  Icon(
                                    Icons.star,
                                    size: 16,
                                    color: Colors.amber,
                                  ),

                                  SizedBox(width: 5),

                                  Text("4.8"),
                                ],
                              ),

                              const SizedBox(height: 6),
                              Row(
                                children: [

                                  const Icon(
                                    Icons.location_on_outlined,
                                    size: 18,
                                    color: Colors.grey,
                                  ),

                                  const SizedBox(width: 5),

                                  Expanded(
                                    child: Text(
                                      _apropos['addressCabinet'] ?? '',
                                      maxLines: 2,
                                      overflow: TextOverflow.ellipsis,

                                      style: const TextStyle(
                                        color: Colors.grey,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),

                      ],
                    ),
                  ),
                  
                ]
              ),
              const SizedBox(height: 6,),
              Row(
                children: [
                  verrifRdv.when(
                    loading: ()=> SizedBox(
                      width: double.infinity,
                      child: Center(child:const CircularProgressIndicator(strokeWidth: 3.0,))
                    ),

                    error: (error, stackTrace) {
                      if (error.toString().contains("unauthorized")) {
                        Future.microtask(() {
                          Navigator.pushReplacement(
                            context,
                            MaterialPageRoute(builder: (_) => LoginMobile()),
                          );
                        });
                      }
                      return Center(child: Text('Erreur : $error'));
                    },

                    data: (verrifRdv){
                      if (verrifRdv.isEmpty) {
                        return const Text("Aucune donnée disponible");
                      }

                      final _etaRdv = verrifRdv;
                      
                      return Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
                        child: _buildBottomButton(_etaRdv)
                      );
                    }
                  ),

                  const SizedBox(width: 6,),
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
                ],
              ),
              const SizedBox(height: 6,),
              Column(
                children: [
                  MyExpandedWidget(textShow: 'Présentation', hide: Text('Voici le contenu qui sera affiché lorsque le widget est ouvert.')),
                  MyExpandedWidget(
                    textShow: 'Information', 
                    hide: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
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
                          ],
                        ),
                        const SizedBox(height: 7,),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text("email"),
                            Text("${_apropos['email']}", style: TextStyle(fontWeight: FontWeight.bold),)
                          ],
                        ),
                      ],
                    ),
                  ),

                // Container(
                //   width: double.infinity,
                //   margin: EdgeInsets.all(10),
                //   padding: EdgeInsets.all(10),
                //   // height: 300,
                //   decoration: BoxDecoration(
                //     color: Colors.white,
                //     borderRadius: BorderRadius.all(Radius.circular(10)),
                //     // border: Border.all()
                //   ),
                //   child: Row(
                //     mainAxisAlignment: MainAxisAlignment.spaceBetween,
                //     children: [
                //       Container(
                //         height: 100.w,
                //         width: 100.w,

                //         decoration: BoxDecoration(
                //           borderRadius: BorderRadius.all(Radius.circular(10)),
                //           image: DecorationImage(
                //             image: AssetImage("assets/images/map_img.jpg"),
                //             fit: BoxFit.cover,
                //           ),
                //         ),
                //       ),
                //       const SizedBox(width: 10,),
                //       ConstrainedBox(
                //         constraints: BoxConstraints(
                //           maxWidth: 180
                //         ),
                //         child: Column(
                //           crossAxisAlignment: CrossAxisAlignment.start,
                //           children: [
                //             Text('Localisation du cabinet'),
                //             Text('${_apropos['addressCabinet']}'),
                //           ],
                //         ),
                //       ),
                //       const SizedBox(width: 10,),
                //       GestureDetector(
                //         onTap: (){
                //           if(_apropos['location'] != null) _navigation(GoogleMapPage(allDoc: [_listDoc, _apropos['lastName']]));
                //         },
                //         child: Container(
                //           width: 40,
                //           height: 40,
                //           decoration: BoxDecoration(
                //             // color: const Color.fromARGB(255, 241, 241, 241),
                //             borderRadius: BorderRadius.circular(25),
                //             border: Border.all(color: Colors.black26)
                //           ),

                //           child: Center(child: (_apropos['location'] != null)
                //             ?Icon(Icons.location_searching_sharp)
                //             :Icon(Icons.location_disabled, color: Colors.grey,)
                //           ),
                //         ),
                //       ),
                //     ]
                //   )
                // ),
                  

                ],
              )
            ]) 
        ),
    ); 
      
  }
}