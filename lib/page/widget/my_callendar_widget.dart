import 'package:table_calendar/table_calendar.dart';
import 'package:flutter/widgets.dart';

class MyCallendarWidget extends StatefulWidget {
  const MyCallendarWidget({super.key});

  @override
  State<MyCallendarWidget> createState() => _MyCallendarWidgetState();
}

class _MyCallendarWidgetState extends State<MyCallendarWidget> {
  @override
  Widget build(BuildContext context) {
    return TableCalendar(
      focusedDay: DateTime.now(), 
      firstDay: DateTime.utc(2000, 1, 1), 
      lastDay: DateTime.utc(2030, 1, 30),
    );
  }
}