import 'dart:math';

import 'package:flutter/material.dart';
import 'package:heathfirst_mobile/service/data.dart';
import 'package:table_calendar/table_calendar.dart';

class CallendarClient extends StatefulWidget {
  final Map<String, dynamic> user;

  const CallendarClient({super.key, required this.user});

  @override
  State<CallendarClient> createState() => _CallendarClientState();
}

class _CallendarClientState extends State<CallendarClient> {
  Map<String, dynamic> get _infoUser => widget.user;
  late List<dynamic> _appointment;

  DateTime dayNow = DateTime.now();
  int justDay = DateTime.now().day;
  int justMonth = DateTime.now().month;

  Map<DateTime, List<String>> data = {};

  List<String> _getEventsForDay  (DateTime day){
    return data[DateTime(day.year, day.month, day.day)] ?? [];
  }

  @override
  void initState(){
    super.initState();
    _seeAptClient();
  }

  void _seeAptClient() async{
    try {
      _appointment  = await seeStatusClientRdv(_infoUser['id']);

      for (var item in _appointment[0]) {
        final dateStr = item['date'].split(' ')[0];
        final doctor = "${item['doctorLastName']} ${item['doctorFirstName']}";
        final docAdr = item['docAdr'];
        final date = DateTime.parse(dateStr);
        final hour = item['info']['hour'];
        final text = "$hour - Dr. $doctor - $docAdr";

        if (data.containsKey(date)) {
          setState(() {
            data[date]!.add(text);
          });
        } else {
          setState(() {
            data[date] = [text];
          });
        }
      }      
    } catch (e, status){
      print("$e");
    }
// [{id: 14, doctor: /api/doctors/4, patient: /api/patients/18, date: 2025-08-19T18:16:00+00:00, status: pend
// ing, information: {hour: 18:16, information: {symptome: tucv}}}

  }

  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Agenda',style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold, letterSpacing: 2.0),),
        backgroundColor: Colors.white,
      ),
      body: Container(
        padding: EdgeInsets.all(15),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(10),
          color: const Color.fromARGB(0, 255, 255, 255)
        ),

        child: SingleChildScrollView(
          child: Column(
            children: [
              if(data.isEmpty)
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(70), 
                  child: const Center(
                    child:CircularProgressIndicator(
                      strokeWidth: 3.0,
                    )
                  )
                ),


              if(data.isNotEmpty)
              Stack(
                children: [
                  AbsorbPointer(
                    absorbing: false,
                    child: TableCalendar(
                      locale: 'en_US',
                      rowHeight: 60,
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
                        });
                      },
                      eventLoader: _getEventsForDay,
                    ),
                  ),
                ],
              ),
                const SizedBox(height: 10),
                Container(
                  padding: const EdgeInsets.all(20),
                  width: double.infinity,

                    decoration: BoxDecoration(
                      color: const Color.fromARGB(255, 241, 241, 241),
                      borderRadius: BorderRadius.circular(15),
                      border: Border.all(color: Colors.black26)
                    ),
                  child: Column(
                    children: [
                      if(_getEventsForDay(dayNow).isEmpty)
                        const Text("Aucun planing trouver", style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, letterSpacing: 2, color: Colors.black54),),
                      
                      if(_getEventsForDay(dayNow).isNotEmpty)
                        const Row(
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: [
                            Text("Programe du jours", style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, letterSpacing: 2, color: Colors.black45),)
                          ],
                        ),
                    
                    if(_getEventsForDay(dayNow).isNotEmpty)
                      const SizedBox(height: 20,),
                      ..._getEventsForDay(dayNow).map(
                        (event) => Row(
                          children: [
                            Row(
                              children: [
                                const Icon(Icons.adjust_rounded,color: Color.fromRGBO(0, 0, 0, 1), size: 15,),
                                const SizedBox(width: 10,),
                                Text(event,
                                style: const TextStyle(
                                  fontSize: 15
                                ),),
                              ],
                            )
                          ],
                        )
                      ),
                  ],
                ) ,
              ),
            ],
          ),
        ) ,
          
      )
    );
  }
}