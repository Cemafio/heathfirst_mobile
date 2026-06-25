import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:heathfirst_mobile/page/widget/card_event_callendar.dart';
import 'package:heathfirst_mobile/page/widget/emptyWidget.dart';
import 'package:heathfirst_mobile/provider/app_provider.dart';
import 'package:heathfirst_mobile/provider/userProvider.dart';
import 'package:heathfirst_mobile/service/data.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:intl/intl.dart';
import 'package:table_calendar/table_calendar.dart';

class CallendarClient extends ConsumerStatefulWidget {
  // final Map<String, dynamic> user;

  const CallendarClient({super.key});

  @override
  ConsumerState<CallendarClient> createState() => _CallendarClientState();
}

class _CallendarClientState extends ConsumerState<CallendarClient> {
  List<dynamic> _appointment = [];
  List<dynamic> _selectedAppointment = [];
  bool isMarkedRealyEmpty = false;
  DateTime dayNow = DateTime.now();
  int justDay = DateTime.now().day;
  int justMonth = DateTime.now().month;
  bool isCallendarExpanded = false;
  Map<DateTime, List<String>> data = {};

  List<String> _getEventsForDay  (DateTime day){
    return data[DateTime(day.year, day.month, day.day)] ?? [];
  }

  @override
  void initState(){
    super.initState();
    _seeAptClient();
  }

  void _seeAptClient() async {
    try {
      if(ref.read(userDataStatic).id == null) return;
      
      _appointment = await seeStatusClientRdv(ref.read(userDataStatic).id!, ref.read(baseUrl), ref.read(accessTokenProvider));
      print(_appointment);
      for (var item in _appointment[0]) {
        final dateStr = item['date'].split(' ')[0];
        final doctor = "${item['doctorLastName']}";
        final docAdr = item['docAdr'];
        final date = DateTime.parse(dateStr);
        final hour = item['info']['hour'];

        final text = (item['status'] == 'pending')
            ? "$hour - Dr. $doctor - $docAdr - (attente)"
            : (item['status'] == 'accepted')
                ? "$hour - Dr. $doctor - $docAdr - (accepté)"
                : "$hour - Dr. $doctor - $docAdr - (refusé)";

        if (data.containsKey(date)) {
          data[date]!.add(text);
        } else {
          data[date] = [text];
        }
      }

      setState(() {});
    } catch (e) {
      if (e.toString().contains("404")) {
        print("Aucun rendez-vous trouvé (404). Affichage du calendrier vide.");

        setState(() {
          isMarkedRealyEmpty = true;
          data = {};
        });
        return;
      }

      print("Erreur: $e");
    }
  }

  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Agenda',style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold, letterSpacing: 2.0),),
        backgroundColor: Colors.white,
      ),
      body: Container(
        // padding: EdgeInsets.all(15),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(10),
          color: const Color.fromARGB(0, 255, 255, 255)
        ),

        child: SingleChildScrollView(
          child: Column(
            children: [
              if(data.isEmpty && (isMarkedRealyEmpty == false))
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(70), 
                  child: const Center(
                    child:CircularProgressIndicator(
                      strokeWidth: 3.0,
                    )
                  )
                ),


              if(data.isNotEmpty || (isMarkedRealyEmpty == true))
              AnimatedContainer(
                duration: Duration(milliseconds: 300),
                
                width: double.infinity,
                padding: EdgeInsets.only(left: 20, right: 20, bottom: 5),

                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.only(
                    bottomLeft: Radius.circular(40),
                    bottomRight: Radius.circular(40)
                  )
                ),

                child: Column(
                  children: [
                    AbsorbPointer(
                      absorbing: false,
                      child: TableCalendar(
                        locale: 'en_US',
                        rowHeight: 60,
                        calendarFormat: isCallendarExpanded ? CalendarFormat.week : CalendarFormat.month,
                    
                        headerStyle: HeaderStyle(
                          formatButtonVisible: false,
                          titleCentered: true,
                        ),
                        
                        focusedDay: dayNow,
                        firstDay: DateTime.utc(2000, 1, 1),
                        lastDay: DateTime.utc(2030, 1, 30),
                        selectedDayPredicate: (day) => isSameDay(day, dayNow),
                    
                        onDaySelected: (selectedDay, focusedDay) {
                          setState(() {
                            dayNow = selectedDay;
                            
                            print(dayNow);
                    
                            _selectedAppointment = _appointment[0].where(
                              (item)=> item['date'].toString().split(' ')[0] == dayNow.toString().split(' ')[0]
                            ).toList();
                    
                          });
                        },
                        eventLoader: _getEventsForDay,
                      ),
                    ),
                    IconButton(
                      onPressed: (){
                        setState(() {
                          isCallendarExpanded = !isCallendarExpanded;
                        });
                      }, 
                      icon: HugeIcon(icon: isCallendarExpanded ? HugeIcons.strokeRoundedArrowDown01 : HugeIcons.strokeRoundedArrowUp01, size: 30,)
                    )
                  ],
                ),
              ),



              const SizedBox(height: 10),
              if(_selectedAppointment.isNotEmpty)...[
                Container(
                  padding: const EdgeInsets.all(15),
                  width: double.infinity,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      Text("Programe le ${dayNow.day} ${DateFormat('MMM', 'fr_FR').format((dayNow))}", style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, letterSpacing: 2, color: Colors.black45),)
                    ],
                  ),
                
                ),

                const SizedBox(height: 10),
                ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: _selectedAppointment.length,
                  itemBuilder: (context, index) {
                    print(_selectedAppointment[index]['info']['hour']);
                    return CardEventCallendar(
                      name: '${_selectedAppointment[index]['doctorLastName']} ${_selectedAppointment[index]['doctorFirstName']}',
                      speciality: _selectedAppointment[index]['doctorSpeciality'],
                      heurRdv: _selectedAppointment[index]['info']['hour'],
                    );

                  },
                )
              ],
              if(_selectedAppointment.isEmpty)...[
                EmptyStateWidget(txtBold: 'Aucun rendez-vous', txt: 'Vous pouvez prendre rendez-vous se jour ci !',)
              ]

            ],
          ),
        ) ,
          
      )
    );
  }
}