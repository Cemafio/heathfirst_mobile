// import 'dart:nativewrappers/_internal/vm/lib/core_patch.dart';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:heathfirst_mobile/page/agenda/callendarDocRdvVide.dart';
import 'package:heathfirst_mobile/page/agenda/callendarOnly.dart';
import 'package:heathfirst_mobile/page/login/login.dart';
import 'package:heathfirst_mobile/provider/app_provider.dart';
import 'package:heathfirst_mobile/provider/rdvProvider.dart';
import 'package:heathfirst_mobile/service/data.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:table_calendar/table_calendar.dart';

class CalendarSection extends ConsumerStatefulWidget {
  // final Map<String, dynamic> user;
  CalendarSection({super.key});

  @override
  ConsumerState<CalendarSection> createState() => _CalendarSectionState();
}

class _CalendarSectionState extends ConsumerState<CalendarSection> {
  DateTime dayNow = DateTime.now();

  @override
  void initState(){
    super.initState();
  }

  Widget build(BuildContext context) {
    final rdvAsync = ref.watch(rdvAsyncProvider);
    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 229, 229, 229),
      appBar: AppBar(
        title: const Text("Votre calendrier", style: TextStyle(
            fontSize: 20
          ),
        ), 
        backgroundColor: const Color.fromARGB(255, 255, 255, 255),
      ),
      body: SingleChildScrollView(
        scrollDirection: Axis.vertical,
        child: Container(
          // padding: EdgeInsets.all(20),
          width: MediaQuery.of(context).size.width,
          // margin: EdgeInsets.only(top: 10),

          child: Column(
            mainAxisSize: MainAxisSize.min,

            children: [
              rdvAsync.when(
                loading: () => Container(
                  padding: EdgeInsets.all(70), 
                  child: const CircularProgressIndicator(strokeWidth: 3.0,)
                ),

                data: (rdv){
                  if (rdv.isEmpty) {
                    return CallendardocrdvVide( heigh: 60, page: 'agenda');
                  }
                  final List rdvAccepted = rdv
                    .where((r) => r['status'] =='accepted')
                    .toList();
                  print("Ici => ${rdvAccepted[0]['patient']}");
                  Map<DateTime, List<String>> data = {};

                  for (var item in rdvAccepted) {
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
                      Callendaronly(data: data, idUser: rdv[0]['doctor']['id'], heigh: 60,page: 'agenda', patienInfo: rdvAccepted,)
                    ],
                  );
                },

                error: (err, st){
                  return Text('Erreur de chargement');
                }
              ),
            ],
          ),
        ),
      )
    ); 
  }
}