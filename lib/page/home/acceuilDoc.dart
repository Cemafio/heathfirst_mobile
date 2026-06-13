import 'dart:ffi';

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:heathfirst_mobile/page/agenda/callendarOnly.dart';
import 'package:heathfirst_mobile/page/appointment/demandeRendeVous.dart';
import 'package:heathfirst_mobile/page/login/login.dart';
import 'package:table_calendar/table_calendar.dart';


class Acceuildoc extends StatefulWidget {
  Future<List<dynamic>> listDemd ;
  // Map<String, dynamic> infoUser;

  Acceuildoc({super.key, required this.listDemd});

  @override
  State<Acceuildoc> createState() => _AcceuildocState();
}

class _AcceuildocState extends State<Acceuildoc> {
  // Map<String, dynamic> get _infoUser => widget.infoUser;
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
                            Navigator.of(context).push(MaterialPageRoute(builder: (context) => RendezvousSection()));         
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