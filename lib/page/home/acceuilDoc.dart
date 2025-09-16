import 'dart:ffi';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:heathfirst_mobile/page/agenda/callendarOnly.dart';
import 'package:heathfirst_mobile/page/appointment/demandeRendeVous.dart';
import 'package:heathfirst_mobile/page/login/login.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:table_calendar/table_calendar.dart';


class Acceuildoc extends StatefulWidget {
  Future<List<dynamic>> listDemd ;
  Map<String, dynamic> infoUser;

  Acceuildoc({super.key, required this.listDemd, required this.infoUser});

  @override
  State<Acceuildoc> createState() => _AcceuildocState();
}

class _AcceuildocState extends State<Acceuildoc> {
  Map<String, dynamic> get _infoUser => widget.infoUser;
  Future<List<dynamic>> get _listDemd => widget.listDemd;

  @override
  void initState(){
    super.initState();
  }

  
 
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.vertical,

        child: Column(
          children: [
            Container(
              width: MediaQuery.of(context).size.width,
              padding: EdgeInsets.all(10),

              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20)
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    height: 60,
                    padding: EdgeInsets.symmetric(
                      vertical: 10,
                      horizontal: 5 
                    ),
                    width: double.infinity,
                    margin: EdgeInsets.only(bottom: 5),

                    decoration: BoxDecoration(
                      border: Border(bottom: BorderSide(color: Colors.black12))
                    ),

                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Votre callendrier',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 1,
                            color: const Color.fromARGB(158, 0, 0, 0)
                          ),
                        ),
                        Icon(Icons.calendar_month)
                      ],
                    ),
                  ),
                  if(_listDemd != [])
                  FutureBuilder<List<dynamic>>(
                    future: _listDemd,
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return Container(
                              width: double.infinity,
                              padding: const EdgeInsets.all(70), child: Center(child:const CircularProgressIndicator(strokeWidth: 3.0,)));
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

                      final rdv = snapshot.data!;
                      if (rdv.isEmpty) {
                        return TableCalendar(
                          locale: 'en_US',
                          rowHeight: 43,
                          headerStyle: HeaderStyle(
                            formatButtonVisible: false,
                            titleCentered: true
                          ),
                          focusedDay: DateTime.now(),
                          firstDay: DateTime.utc(2000,1,1), 
                          lastDay: DateTime.utc(2030,1,30),

                          selectedDayPredicate: (day) {
                            return isSameDay(day, DateTime.now());
                          },
                        );
                      }

                      Map<DateTime, List<String>> data = {};
                      for (var item in rdv) {
                        final dateParts = item['date'].split(' ');
                        final dateStr = dateParts.isNotEmpty ? dateParts[0] : '';
                        final heure = dateParts.length > 1 ? dateParts[1] : '';

                        final patient = item['patient']['firstname'];
                        final date = DateTime.parse(dateStr);
                        final text = "$heure - $patient";

                        if (data.containsKey(date)) {
                          data[date]!.add(text);
                        } else {
                          data[date] = [text];
                        }
                      }

                      return Callendaronly(data: data, infoUser: _infoUser, idUser: rdv[0]['doctor']['id'], heigh: 35,page: 'home',);
                    },
                  ) 
              ])
            ),
            const SizedBox(height: 20,), 

            // ------------------------[List Rdv]-------------------------------
            Container(
              width: MediaQuery.of(context).size.width,
              padding: EdgeInsets.all(10),

              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20)
              ),

              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    height: 60,
                    padding: EdgeInsets.symmetric(
                      vertical: 10,
                      horizontal: 5 
                    ),
                    width: double.infinity,
                    margin: EdgeInsets.only(bottom: 5),


                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Text(
                          'Demande de rendez-vous',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 1,
                            color: const Color.fromARGB(158, 0, 0, 0)
                          ),
                        ),
                        GestureDetector(
                          onTap:(){
                            Navigator.of(context).push(MaterialPageRoute(builder: (context) => RendezvousSection(user: _infoUser)));         
                          },

                          child:  Stack(
                            clipBehavior: Clip.none,//ceci enleve le hidden overflow
                            children: [
                              const Icon(Icons.app_registration_rounded, size: 30,),
                              FutureBuilder<List<dynamic>>(
                                  future: _listDemd,
                                  builder: (context, snapshot) {
                                    if (snapshot.connectionState == ConnectionState.waiting) {
                                      return Positioned(
                                        top: -10,
                                        right: -5,
                                        child: Container(), // Affiche rien pendant le chargement
                                      );
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
                                      return Positioned(
                                        top: -10,
                                        right: -5,
                                        child: Container(), // Affiche rien en cas d’erreur
                                      );
                                    }
                                    final list = snapshot.data?? [];
                                    
                                    
                                    return   Positioned(
                                      top: -10,
                                      right: -5,

                                      child: Container(
                                        height: 20.w,
                                        width: 20.w,
                                        decoration: BoxDecoration(
                                          borderRadius: BorderRadius.all(Radius.circular(10.w)),

                                          color: list.isNotEmpty? const Color.fromARGB(255, 232, 99, 99) : Color.fromARGB(0, 232, 99, 99) 
                                        ),
                                      
                                        child: Center(
                                          child: list.isNotEmpty
                                          ? Text(
                                              '${list.length}',  
                                              style: TextStyle(
                                                color: list.isNotEmpty? Colors.white : const Color.fromARGB(0, 255, 255, 255),
                                                fontSize: 12,
                                                fontWeight: FontWeight.bold
                                              ),
                                            )
                                          : Text(
                                              '..',  
                                              style: TextStyle(
                                                color: list.isNotEmpty? Colors.white : const Color.fromARGB(0, 255, 255, 255),
                                                fontSize: 12,
                                                fontWeight: FontWeight.bold
                                              ),
                                            )
                                        )
                                      )
                                    );
                            
                                  },
                                ),
                            ],
                          )
                        )
                      ],
                    ),
                  ),
                ],
              ),
            )
          ],
      ),
    ) 
    ;
  }
}