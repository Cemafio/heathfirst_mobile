import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:heathfirst_mobile/page/agenda/callendarBottomForm.dart';
import 'package:heathfirst_mobile/page/login/login.dart';
import 'package:heathfirst_mobile/page/widget/card_event_callendar.dart';
import 'package:heathfirst_mobile/page/widget/emptyWidget.dart';
import 'package:heathfirst_mobile/provider/app_provider.dart';
import 'package:heathfirst_mobile/provider/days_no_work_provider.dart';
import 'package:heathfirst_mobile/provider/rdvProvider.dart';
import 'package:heathfirst_mobile/provider/userProvider.dart';
import 'package:heathfirst_mobile/service/data.dart';
import 'package:hugeicons/hugeicons.dart';

import 'package:table_calendar/table_calendar.dart';

class Callendaronly extends ConsumerStatefulWidget {
  final Map<DateTime, List<String>> data;
  final int idUser;
  final double heigh;
  final String page;
  final List patienInfo;
  const Callendaronly({super.key,required this.data, required this.idUser, required this.heigh, required this.page, required this.patienInfo});

  @override
  ConsumerState<Callendaronly> createState() => _CallendaronlyState();
}

class _CallendaronlyState extends ConsumerState<Callendaronly> {
  Map<DateTime, List<String>> programmes = {};
  late final Map<DateTime, List<String>> _data = widget.data;
  List<DateTime> _markedDays = [];
  bool isMarkedRealyEmpty = false;
  String? _reason;
  final _formKey = GlobalKey<FormState>();
  Key keyForm = UniqueKey();
  final TextEditingController _dateController = TextEditingController();
  TextEditingController _reasonController = TextEditingController();
  bool isLoaded = false;
  bool isLoadedDel = false;
  bool isdaySelectedMarked = false;
  List<dynamic> _selectedAppointment = [];
  bool isCallendarExpanded = false;
  int get id_user => widget.idUser;
  double get height => widget.heigh;
  String get _page => widget.page;

  DateTime dayNow = DateTime.now();
  int justDay = DateTime.now().day;
  int justMonth = DateTime.now().month;
  final Map months = {
    1: 'Jan',
    2: 'Fév',
    3: 'Mar',
    4: 'Avr',
    5: 'Mai',
    6: 'Jun',
    7: 'Jul',
    8: 'Aoû',
    9: 'Sep',
    10: 'Oct',
    11: 'Nov',
    12: 'Déc',
  };

  @override
  void initState() {
    super.initState();
     _reloadDataCallendar();
  }

  void _reloadDataCallendar() async {

    final newData = await _loadData();

    setState(() {
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
    List<dynamic> daysNoWork = await getDayNoWork(id: id_user, baseUrl: ref.read(baseUrl), token: ref.read(accessTokenProvider));
    if(daysNoWork.isNotEmpty){
        final marked = daysNoWork.map<DateTime>((e) {
          return DateTime.parse(e['date']);
        }).toList();

      return {
        "markedDays": marked,
      };
      // });
    }else{
      // print('Pas de jours feré');
      setState(() {
        isMarkedRealyEmpty = true;
      });
      return {
        "markedDays": [],
      };    
    }
  }

  void resetForm() {
    _formKey.currentState?.reset();
    _dateController.clear();
    _reasonController.clear();
  } 
  
  List<String> _getEventsForDay  (DateTime day){
    return _data[DateTime(day.year, day.month, day.day)] ?? [];
  }

  void showBottomForm(){
    showModalBottomSheet(
      context: context, 
      builder: (context){
        return Callendarbottomform(reload: _reloadDataCallendar,dayNow: dayNow,reasonControl: _reasonController, isdaySelectedMarked: isdaySelectedMarked,);
      }
    );
  }

  Widget build(BuildContext context) {
    final _dayNoWorkAsync = ref.watch(daysNoWorkAsync);
    return _dayNoWorkAsync.when(
      loading: () {
        // print();
        return Container(
          width: double.infinity,
          padding: const EdgeInsets.all(70), child: const Center(child:CircularProgressIndicator(strokeWidth: 3.0,))
        );
      }, 

      error: (error, stackTrace) => Text('Erreur de chargement, $error'),
      
      data: (dayNoWrk){
        return Column(
          children: [
          
            Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.only(bottomLeft: Radius.circular(35), bottomRight: Radius.circular(35)),
                color: const Color.fromARGB(255, 255, 255, 255)
              ),
            
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      IconButton(
                        onPressed: () => showBottomForm(), 
                        icon: Icon(
                          isdaySelectedMarked ? Icons.delete_outline_outlined : Icons.add,
                          color: isdaySelectedMarked ? Colors.red : null,
                        ),
                        style: ButtonStyle(
                          backgroundColor: WidgetStateProperty.all(const Color.fromARGB(255, 215, 215, 215))
                        ), 
                      ),
                      const SizedBox(width: 10,)
                    ],
                  ),
                  AbsorbPointer(
                    absorbing: (isLoaded || isLoadedDel), // true = interactions bloquées
                    child: TableCalendar(
                      locale: 'en_US',
                      rowHeight: height,
                      calendarFormat: isCallendarExpanded ? CalendarFormat.week : CalendarFormat.month,
                  
                  
                      headerStyle: HeaderStyle(
                        formatButtonVisible: false,
                        titleCentered: true,
                      ),
                  
                      focusedDay: dayNow,
                      firstDay: DateTime.utc(2000, 1, 1),
                      lastDay: DateTime.utc(2030, 1, 30),
                      selectedDayPredicate: (day) => isSameDay(day, dayNow),

                      calendarStyle: CalendarStyle(
                        selectedDecoration: BoxDecoration(
                          color: Color(0xFF548856), // couleur sélection
                          shape: BoxShape.circle,
                        ),

                        todayDecoration: BoxDecoration(
                          color: Color.fromARGB(139, 89, 138, 90), // couleur du jour actuel
                          shape: BoxShape.circle,
                        ),

                        selectedTextStyle: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),

                      calendarBuilders: CalendarBuilders(
                        defaultBuilder: (context, day, focusedDay) {
                  
                          if (_markedDays.isNotEmpty) {
                            final isMarked = _markedDays.any((d) => isSameDay(d, day));
                  
                            if (isMarked) {
                              return Container(
                                margin: const EdgeInsets.all(6),
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  border: Border.all(
                                    // style: BorderStyle
                                    color: const Color(0xFF479652),
                                  )
                                ),
                                child: Center(
                                  child: Text(
                                    '${day.day}',
                                    style: TextStyle(
                                      fontSize: 14, 
                                      fontWeight: FontWeight.bold, 
                                      letterSpacing: 2, 
                                      color: Color(0xFF479652)
                                    )                              
                                  ),
                                ),
                              );
                            }
                          }
                  
                          return null;
                        },
                      ),
                      onDaySelected: (selectedDay, focusedDay) {
                        if (isLoaded || isLoadedDel) return;
                        
                        setState(() {
                          dayNow = selectedDay;
                  
                          _selectedAppointment = widget.patienInfo.where((item) {
                            final date = DateTime.parse(item['date']);
                            return isSameDay(date, dayNow);
                          }).toList();
                  
                          print(_selectedAppointment);
                  
                          if (_markedDays.isNotEmpty) {
                            final isdayMarked = _markedDays.any((d) => isSameDay(d, selectedDay));
                            if (isdayMarked) {
                              isdaySelectedMarked = true;
                              _reasonController = TextEditingController(text: dayNoWrk
                                .where(
                                  (dnw)=>dnw['date'].split('T')[0]== selectedDay.toString().split(' ')[0]
                                ).toList()[0]['reason']
                                .toString());
                            } else {
                              isdaySelectedMarked = false;
                              _reasonController = TextEditingController();
                            }
                          }
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

            const SizedBox(height: 30,),
            if(_getEventsForDay(dayNow).isEmpty)
                EmptyStateWidget(txtBold: 'Aucun rendez-vous', txt: 'Vous pouvez prendre rendez-vous se jour ci !',),
          
            if(_selectedAppointment.isNotEmpty)
              ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: _selectedAppointment.length,

                itemBuilder: (context, index) {
                  final patient = _selectedAppointment[index]['patient'];
                  final info = _selectedAppointment[index]['information'];
                  return CardEventCallendar(
                    name: '${patient['lastname']} ${patient['firstname']}',
                    speciality: info['symptome'],
                    heurRdv: info['hour'],
                    w: 290,
                  );

                },
              )

              // ..._getEventsForDay(dayNow).map(
              //   (event) => CardEventCallendar(name: event, heurRdv: '08:00', w: 250)
              // ),
              
          ],
        );
      }
    );
  }
} 