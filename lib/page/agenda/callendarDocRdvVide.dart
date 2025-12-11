import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'dart:convert';
import 'dart:ffi';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:heathfirst_mobile/service/data.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:http/http.dart' as http;

class CallendardocrdvVide extends StatefulWidget {
    final Map<String, dynamic> infoUser;
  final int idUser;
  final double heigh;
  final String page;
  const CallendardocrdvVide({super.key, required this.infoUser, required this.idUser, required this.heigh, required this.page});

  @override
  State<CallendardocrdvVide> createState() => _CallendardocrdvVideState();
}

class _CallendardocrdvVideState extends State<CallendardocrdvVide> {
  Map<DateTime, List<String>> programmes = {};
  List<DateTime> _markedDays = [];
  String? _reason;
  final _formKey = GlobalKey<FormState>();
  Key keyForm = UniqueKey();
  final TextEditingController _dateController = TextEditingController();
  TextEditingController _reasonController = TextEditingController();
  bool isLoaded = false;

  int get id_user => widget.idUser;
  double get height => widget.heigh;
  String get _page => widget.page;
  Map<String, dynamic> get _infoUser => widget.infoUser;
  bool isdaySelectedMarked = false;
  bool isMarkedRealyEmpty = false;
  // bool isLoaded = false;
  bool isLoadedDel = false;

  DateTime dayNow = DateTime.now();
  int justDay = DateTime.now().day;
  int justMonth = DateTime.now().month;

  late Future<Map<String, dynamic>> _dataCallendar;

  @override
  void initState() {
    super.initState();
    _dataCallendar = _loadData();
  }
void _reloadDataCallendar() async {
  final newData = await _loadData();

  setState(() {
    /// Convertir List<dynamic> -> List<DateTime>
    _markedDays = (newData["markedDays"] as List<dynamic>)
        .map<DateTime>((e) => e as DateTime)
        .toList();

    _formKey.currentState?.reset();
    _dateController.clear();
    _reasonController.clear();
    _reason = null;
    isdaySelectedMarked = false;
  });
}
  Future<Map<String, dynamic>> _loadData() async{
    List<dynamic> daysNoWork = await getDayNoWork(id_user); 
    print('daysNoworck => $daysNoWork');
    if(daysNoWork.isNotEmpty){
      // setState(() {
        final marked = daysNoWork.map<DateTime>((e) {
          return DateTime.parse(e['date']);
        }).toList();

      return {
        "markedDays": marked,
      };
      // });
    }else{
      print('Pas de jours feré');
      setState(() {
        isMarkedRealyEmpty = true;
      });
      return {
        "markedDays": [],
      };    
    }
  }
  List<String> weekDays = ['Jan','Fév','Mar','Avr','Mai','Juin','Jul','Août','Sep','Oct','Nov','Déc'];
   void resetForm() {
    _formKey.currentState?.reset();
    _dateController.clear();
    _reasonController.clear();
  } 
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,

      children: [
        Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(10),
            color: const Color.fromARGB(0, 255, 255, 255)
          ),

          child: TableCalendar(
            locale: 'en_US',
            rowHeight: height,
            headerStyle: const HeaderStyle(
              formatButtonVisible: false,
              titleCentered: true
            ),
            focusedDay: dayNow, 
            firstDay: DateTime.utc(2000,1,1), 
            lastDay: DateTime.utc(2030,1,30),

            selectedDayPredicate: (day) {
              return isSameDay(day, dayNow);
            },

            calendarBuilders: CalendarBuilders(
              defaultBuilder: (context, day, focusedDay) {

                if(_markedDays.isNotEmpty){
                  // Vérifie si le jour doit être marqué
                  final isMarked = _markedDays.any((d) => isSameDay(d, day));
                  if (isMarked) {
                    return Container(
                      margin: const EdgeInsets.all(6),
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: const Color.fromARGB(255, 71, 150, 82).withOpacity(0.5),
                      ),
                      child: Center(
                        child: Text(
                          '${day.day}',
                          style: const TextStyle(color: Colors.white),
                        ),
                      ),
                    );
                  }
                }
                
                return null; // jour normal
              },
            ),

            onDaySelected: (selectedDay, focusedDay) {
              if (isLoaded || isLoadedDel) return;

              setState(() {
                dayNow = selectedDay;
                if (_markedDays.isNotEmpty) {
                  final isdayMarked = _markedDays.any((d) => isSameDay(d, selectedDay));
                  if (isdayMarked) {
                    isdaySelectedMarked = true;
                    _reasonController = TextEditingController(text: 'Jours déjà marqué');
                  } else {
                    isdaySelectedMarked = false;
                    _reasonController = TextEditingController();
                  }
                }
              });
            },

              
            ),
          ),

        const SizedBox(height: 10,),
        //Ajout nouveaux temp libre
        if(_infoUser['roles'][0] != 'ROLE_PATIENT' && _page != 'home')
          Container(
            padding: EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Color.fromARGB(255, 241, 241, 241),
              borderRadius: BorderRadius.circular(15),
              border: Border.all(color: Colors.black26)
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    Text("Ajout jour d'indisponibilité", style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, letterSpacing: 2, color: Colors.black45),)
                  ],
                ),
                const SizedBox(height: 20,),
                Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      const SizedBox(height: 20,),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          Text("Date :", style: TextStyle(fontSize: 15, color: Colors.black),),
                          const SizedBox(width: 10,),
                          Text("${dayNow.year} ${weekDays[dayNow.month - 1]} ${dayNow.day}", style: TextStyle(fontSize: 18, color: Colors.black54),),
                        ]

                      ),
                      const SizedBox(height: 20,),
                      TextFormField(
                        controller: _reasonController,
                        decoration: const InputDecoration(
                          hintText: 'Raison',
                        ),
                        validator: (value){
                          if( value == null || value.trim().isEmpty){
                            return 'Veuillez entrer la raison';
                          }
                          return null;
                        },
                        onChanged: (val) {
                          setState(() => _reason = val);
                        },
                      ),
                      const SizedBox(height: 20,),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          TextButton(
                            onPressed: (_reason != null && _reason!.trim().isNotEmpty)
                              ? () async {
                                  if (_formKey.currentState!.validate()) {
                                    final startTime = DateTime.now();
                                    setState(() {
                                      isLoaded = true; // arrêter le loading
                                    });
                                    try {
                                      await addDayNoWork(dayNow, _reason!.trim());

                                      // Calcul du temps écoulé
                                      final elapsed = DateTime.now().difference(startTime).inMilliseconds;
                                      // Si moins de 2000ms écoulées → attendre le reste
                                      if (elapsed < 2000) {
                                        await Future.delayed(Duration(milliseconds: 2000 - elapsed));
                                      }

                                      _reloadDataCallendar();

                                    } catch (e) {
                                      print("Erreur : $e");
                                    }finally{
                                      setState(() {
                                        isLoaded = false; // arrêter le loading
                                      });
                                    }
                                  }
                                }
                              : null,

                            child: (isLoaded == true)
                            ? const SizedBox(
                                  height: 12,
                                  width: 12,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2.0,
                                  ),
                              )
                            : const Text(
                              'Ajouter',
                              style: TextStyle(
                                fontSize: 12,
                              ),
                            )
                          ),

                          const SizedBox(width: 5,),
                          TextButton(
                            onPressed: isdaySelectedMarked
                            ? () async {
                                final startTime = DateTime.now();

                                setState(() {
                                  isLoadedDel = true;
                                });
                                if (_formKey.currentState!.validate()) {
                                  try {
                                    await deleteDaysNoWork(_infoUser['id'], dayNow);
                                    
                                    // Calcul du temps écoulé
                                    final elapsed = DateTime.now().difference(startTime).inMilliseconds;
                                    // Si moins de 2000ms écoulées → attendre le reste
                                    if (elapsed < 2000){ 
                                      await Future.delayed(Duration(milliseconds: 2000 - elapsed));
                                    }
                                    print('--------- Supprimer ------');
                                    
                                    _reloadDataCallendar();


                                  } catch (e) {
                                      print("Erreur : $e");
                                  }finally{
                                    setState(() {
                                      isLoadedDel = false;
                                    });
                                  }
                                }
                              }
                            : null,

                            child: 
                            (isLoadedDel == true)
                            ? const SizedBox(
                                  height: 12,
                                  width: 12,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2.0,
                                  ),
                              )
                            :  Text(
                                'Suprimer',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: isdaySelectedMarked? Colors.red : Color.fromARGB(255, 253, 190, 186)
                                ),
                              ),
                          ),
                           
                        ]
                      ),
                    ],
                  ),
                )
              ],
            ),
          )
    ],);
  }
} 