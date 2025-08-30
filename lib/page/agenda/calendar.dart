// import 'dart:nativewrappers/_internal/vm/lib/core_patch.dart';

import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:heathfirst_mobile/page/agenda/callendarDocRdvVide.dart';
import 'package:heathfirst_mobile/page/agenda/callendarOnly.dart';
import 'package:heathfirst_mobile/service/data.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:table_calendar/table_calendar.dart';

class CalendarSection extends StatefulWidget {
  final Map<String, dynamic> user;
  CalendarSection({super.key, this.user = const {}});

  @override
  State<CalendarSection> createState() => _CalendarSectionState();
}

class _CalendarSectionState extends State<CalendarSection> {
  Map<String, dynamic> get _infoUser => widget.user;
  final Future<List<dynamic>> _listDemd = rdvUserData() ;
  DateTime dayNow = DateTime.now();



  @override
  void initState(){
    super.initState();
  }

  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 229, 229, 229),
      appBar: AppBar(
        title: const Text("Votre calendrier", style: TextStyle(
          fontSize: 20
        ),), 
        backgroundColor: const Color.fromARGB(255, 229, 229, 229),
      ),
      body: SingleChildScrollView(
        scrollDirection: Axis.vertical,
        child: Container(
          padding: EdgeInsets.all(20),
          width: MediaQuery.of(context).size.width,
          margin: EdgeInsets.only(top: 20),

          child: Column(
            mainAxisSize: MainAxisSize.min,

            children: [

              FutureBuilder<List<dynamic>>(
                future: _listDemd,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return  Container(padding: EdgeInsets.all(70), child: const CircularProgressIndicator(strokeWidth: 3.0,));
                  }

                  if (snapshot.hasError) {
                    return Center(child: Text('Erreur : ${snapshot.error}'));
                  }

                  final rdv = snapshot.data!;
                  if (rdv.isEmpty) {
                    print('rdv vide ....');
                    return CallendardocrdvVide(infoUser: _infoUser, idUser: _infoUser['id'], heigh: 60, page: 'agenda');
                  }

                  Map<DateTime, List<String>> data = {};

                  for (var item in rdv) {
                    final dateStr = item['date'].split(' ')[0];
                    final heure = item['date'].split(' ')[1];
                    final patient = item['patient']['firstname'];
                    final date = DateTime.parse(dateStr);
                    final text = "$heure - $patient";

                    if (data.containsKey(date)) {
                      data[date]!.add(text);
                    } else {
                      data[date] = [text];
                    }
                  }
                  return Column(
                    children: [
                        Callendaronly(data: data, infoUser: _infoUser, idUser: rdv[0]['doctor']['id'], heigh: 60,page: 'agenda')
                    ],
                  );
                },
              ),
            ],
          ),
        ),
      )
    ); 
  }
}