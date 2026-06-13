import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:heathfirst_mobile/provider/app_provider.dart';
import 'package:heathfirst_mobile/provider/userProvider.dart';
import 'package:heathfirst_mobile/service/data.dart';
import 'package:table_calendar/table_calendar.dart';

class RealCallendar extends ConsumerStatefulWidget {
  final Map<DateTime, List<String>> data;
  final double heigh;
  final String page;
  const RealCallendar({super.key,required this.data,  required this.heigh, required this.page});

  @override
  ConsumerState<RealCallendar> createState() => _CallendaronlyState();
}

class _CallendaronlyState extends ConsumerState<RealCallendar> {
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

  double get height => widget.heigh;
  String get _page => widget.page;

  DateTime dayNow = DateTime.now();
  int justDay = DateTime.now().day;
  int justMonth = DateTime.now().month;

  late Future<Map<String, dynamic>> _dataCallendar;

  @override
  void initState() {
    super.initState();
    _dataCallendar = _loadData();
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
    List<dynamic> daysNoWork = await getDayNoWork(id: ref.read(userDataStatic).id!, baseUrl: ref.read(baseUrl), token: ref.read(accessTokenProvider));
    print('daysNoworck => $daysNoWork');
    if(daysNoWork.isNotEmpty){
      // setState(() {
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

  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,

      children: [
        FutureBuilder(
          future: getDayNoWork(id: ref.watch(userDataStatic).id!, baseUrl: ref.read(baseUrl), token: ref.read(accessTokenProvider)), 
          builder: (context, index){
            return TableCalendar(
              focusedDay: dayNow, 
              firstDay: DateTime.utc(2000, 1, 1), 
              lastDay: DateTime.utc(2030, 1, 30),
            );
          }
        ),
    ],);
  }
} 