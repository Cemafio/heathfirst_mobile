import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:heathfirst_mobile/page/login/login.dart';
import 'package:heathfirst_mobile/provider/app_provider.dart';
import 'package:heathfirst_mobile/provider/days_no_work_provider.dart';
import 'package:heathfirst_mobile/provider/userProvider.dart';
import 'package:heathfirst_mobile/service/data.dart';
import 'package:hugeicons/hugeicons.dart';

import 'package:table_calendar/table_calendar.dart';

class Callendaronly extends ConsumerStatefulWidget {
  final Map<DateTime, List<String>> data;
  final int idUser;
  final double heigh;
  final String page;
  const Callendaronly({super.key,required this.data, required this.idUser, required this.heigh, required this.page});

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

  int get id_user => widget.idUser;
  double get height => widget.heigh;
  String get _page => widget.page;

  DateTime dayNow = DateTime.now();
  int justDay = DateTime.now().day;
  int justMonth = DateTime.now().month;

  // late Future<List<dynamic>> _daysNoWorks = getDayNoWork(id: ref.read(userDataStatic).id!, baseUrl: ref.read(baseUrl), token: ref.read(accessTokenProvider));

  @override
  void initState() {
    super.initState();
     print("INIT STATE CALENDAR");
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
    // print('daysNoworck => $daysNoWork');
    if(daysNoWork.isNotEmpty){
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
  
  List<String> _getEventsForDay  (DateTime day){
    return _data[DateTime(day.year, day.month, day.day)] ?? [];
  }

  void showBottomForm(){
    showModalBottomSheet(
      context: context, 
      builder: (context){
        return Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: EdgeInsets.all(25),
              margin: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
              decoration: BoxDecoration(
                color: Color.fromARGB(255, 241, 241, 241),
                borderRadius: BorderRadius.circular(15),
                border: Border.all(color: Colors.black26)
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Container(
                    width: 40,
                    height: 6,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(6),
                      color: Colors.grey
                    ),
                  ),
                  const SizedBox(height: 30,),
                  Text("Ajout jour d'indisponibilité", style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, letterSpacing: 2, color: Colors.black45),),
                  const SizedBox(height: 10,),
                  Form(
                    key: _formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text("Le", style: TextStyle(fontSize: 15, color: Colors.black, ),),
                            const SizedBox(width: 6,),
                            Text("${dayNow.year} ${weekDays[dayNow.month - 1]} ${dayNow.day}", style: TextStyle(fontSize: 18, color: Colors.black54,fontWeight: FontWeight.bold),),
                          ]

                        ),
                        const SizedBox(height: 20,),
                        TextFormField(
                          controller: _reasonController,
                          decoration: const InputDecoration(
                            hintText: 'Raison',
                          ),
                          readOnly: (isdaySelectedMarked || isLoaded || isLoadedDel),
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
                      
                      ],
                    ),
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
                                  await addDayNoWork(dayNow, _reason!.trim(), baseUrl: ref.read(baseUrl), token: ref.read(accessTokenProvider));

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
                                await deleteDaysNoWork(ref.watch(userDataStatic).id!, dayNow, ref.watch(baseUrl), ref.watch(accessTokenProvider));
                                
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
            ),
          ],
        );
      }
    );
  }

  Widget build(BuildContext context) {
    final _dayNoWorkAsync = ref.watch(daysNoWorkAsync);
    return _dayNoWorkAsync.when(
      loading: () => Container(
        width: double.infinity,
        padding: const EdgeInsets.all(70), child: const Center(child:CircularProgressIndicator(strokeWidth: 3.0,))
      ), 
      error: (error, stackTrace) => Text('Erreur de chargement, $error'),
      
      data: (dayNoWrk){

        return Column(
          children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              IconButton(
                onPressed: () => showBottomForm(), 
                icon: const Icon(Icons.add),
                style: ButtonStyle(
                  backgroundColor: WidgetStateProperty.all(const Color.fromARGB(255, 215, 215, 215))
                ), 
              ),
            ],
          ),
          const SizedBox(height: 10,),
            Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(10),
                color: const Color.fromARGB(0, 255, 255, 255)
              ),
            
              child:  
                Stack(
                  children: [
                    AbsorbPointer(
                      absorbing: (isLoaded || isLoadedDel), // true = interactions bloquées
                      child: TableCalendar(
                        locale: 'en_US',
                        rowHeight: height,
                        headerStyle: HeaderStyle(
                          formatButtonVisible: false,
                          titleCentered: true,
                        ),
                        focusedDay: dayNow,
                        firstDay: DateTime.utc(2000, 1, 1),
                        lastDay: DateTime.utc(2030, 1, 30),
                        selectedDayPredicate: (day) => isSameDay(day, dayNow),
                        calendarBuilders: CalendarBuilders(
                          defaultBuilder: (context, day, focusedDay) {
                            if (_markedDays.isNotEmpty) {
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
                            return null;
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
                        eventLoader: _getEventsForDay,
                      ),
                    ),
                ],
                )
              ),

              const SizedBox(height: 10,),
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
            const SizedBox(height: 10,),
            //Ajout nouveaux temp libre
            // if(ref.watch(userDataStatic).roles != 'ROLE_PATIENT' && _page != 'home')
              
          ],
        );
      }
    );
  }
} 