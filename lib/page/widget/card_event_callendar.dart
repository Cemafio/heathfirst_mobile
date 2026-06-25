import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:heathfirst_mobile/provider/userProvider.dart';
import 'package:heathfirst_mobile/utils/string_extension.dart';
import 'package:hugeicons/hugeicons.dart';

class CardEventCallendar extends ConsumerStatefulWidget {
  final String name;
  final double? w;
  final String? speciality;
  final String? role;
  final String heurRdv;
  const CardEventCallendar({super.key, required this.name, this.w, required this.heurRdv, this.speciality, this.role});

  @override
  ConsumerState<CardEventCallendar> createState() => _CardEventCallendarState();
}

class _CardEventCallendarState extends ConsumerState<CardEventCallendar> {
  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,

      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                // Container(
                //   width: 20,
                //   height: 20,

                //   decoration: BoxDecoration(
                //     borderRadius: BorderRadius.circular(50),
                //     color: Colors.transparent,
                //     border: Border.all(
                //       color: Colors.black54
                //     )
                //   ),
                //   child: Center(
                //     child: Container(
                //       width: 10,
                //       height: 10,
                    
                //       decoration: BoxDecoration(
                //         borderRadius: BorderRadius.circular(50),
                //         color: Colors.black54
                //       ),
                //     ),
                //   )
                // ),
                Container(
                  width: 60,
                  height: 22,
                  alignment: Alignment.center,
                  margin: EdgeInsets.only(left: 15, right: 10),

                  decoration: BoxDecoration(
                    // color: Color.fromARGB(125, 91, 217, 101),
                    borderRadius: BorderRadius.circular(6),
                    // border: Border.all(
                    //   color: Colors.black54
                    // )
                  ),
                  child: Center(
                    child: Text(
                      widget.heurRdv, 
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                        color: Colors.black54
                      )
                    ),
                  ),
                ),

                const SizedBox(height: 5),
                Container(
                  width: 2,
                  height: 50,

                  decoration: BoxDecoration(
                    color: Colors.black54
                  ),
                )
              ],
            ),
          ),
          // const SizedBox(width: 30,),
          Container(
            padding: const EdgeInsets.all(15),
            width: widget.w??300,

            decoration: BoxDecoration(
              color: const Color.fromARGB(255, 255, 255, 255),
              borderRadius: BorderRadius.circular(20),
              // border: Border.all(color: Colors.black26)
            ),

            child: Row(
              children: [
                Container(
                  width: 40,
                  height: 40,
                
                  decoration: BoxDecoration(
                    color: const Color(0xFF81C784),
                    borderRadius: BorderRadius.circular(100),
                    border: Border.all(
                      width: sqrt1_2,
                      color: const Color(0xFF81C784),
                    ),
                  ),
                
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [

                      // if(widget.role == 'ROLE_PATIENT')
                        Text(
                          widget.name.toString().uperFirstChart(),
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold
                          ),
                        )
                    ],
                  ),
                ),

                const SizedBox(width: 10,),
                Row(
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Text(
                              widget.name,
                              style: TextStyle(
                                fontSize: 14, 
                                fontWeight: FontWeight.bold, 
                                letterSpacing: 2, 
                                color: Colors.black54
                              )
                            ),
                            
                            // const SizedBox(width: 10,),
                            // Container(
                            //   width: 40,
                            //   height: 19,
                            //   alignment: Alignment.center,

                            //   decoration: BoxDecoration(
                            //     color: Color.fromARGB(125, 91, 217, 101),
                            //     borderRadius: BorderRadius.circular(30)
                            //   ),
                            //   child: Center(
                            //     child: Text(
                            //       widget.heurRdv, 
                            //       style: TextStyle(
                            //         fontSize: 10,
                            //         fontWeight: FontWeight.bold,
                            //         color: Colors.white
                            //       )
                            //     ),
                            //   ),
                            // )
                          ],
                        ),
                        
                        Text(
                          widget.speciality??'Speciality',
                          style: TextStyle(
                            fontSize: 12, 
                            fontWeight: FontWeight.bold, 
                            letterSpacing: 2, 
                            color: Colors.green
                          )
                        )
                      ],
                    )
                  ],
                )
              ],
            ),
          )
        ],
      ),
    );
  }
}