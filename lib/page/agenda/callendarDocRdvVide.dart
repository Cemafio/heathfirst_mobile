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
  final TextEditingController _reasonController = TextEditingController();
  bool isLoaded = false;

  int get id_user => widget.idUser;
  double get height => widget.heigh;
  String get _page => widget.page;
  Map<String, dynamic> get _infoUser => widget.infoUser;
  

  DateTime dayNow = DateTime.now();
  int justDay = DateTime.now().day;
  int justMonth = DateTime.now().month;

  late Future<void> _dataCallendar;

  @override
  void initState() {
    super.initState();
    _dataCallendar = _loadData();
  }
  void _reloadDataCallendar(){
    setState(() {
      _dataCallendar = _loadData();
      isLoaded = false;
    });
    resetForm();
  }
  Future<void> _loadData() async{
    try {
      print('callendar doc vide page');
      List<dynamic> daysNoWork = await getDayNoWork(id_user);
      if(daysNoWork.isNotEmpty){
        setState(() {
          _markedDays = daysNoWork.map<DateTime>((e) {
            return DateTime.parse(e['date']);
          }).toList();
        });
      }  
    } catch (e) {
      _markedDays = [];
      print("daysNoWork vide ${e}");
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
                        color: Colors.red.withOpacity(0.5),
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
              setState(() {
                dayNow = selectedDay;
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
                      TextButton(
                        onPressed: (_reason != null && _reason!.trim().isNotEmpty)
                          ? () {
                              setState((){
                                isLoaded = true;
                              });

                              if (_formKey.currentState!.validate()) {
                                try {
                                  addDayNoWork(dayNow, _reason!.trim());
                                  _reloadDataCallendar();
                                } catch (e) {
                                  setState(() {
                                    isLoaded = false;
                                  });  
                                }
                              }else{
                                setState(() {
                                  isLoaded = false;
                                });
                              }
                            }
                          : null,

                        child: (isLoaded)
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
                      )
                    ],
                  ),
                )
              ],
            ),
          )
    ],);
  }
} 