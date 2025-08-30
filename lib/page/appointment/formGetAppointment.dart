import 'package:flutter/material.dart';

class FormGetAppointment extends StatefulWidget {
  const FormGetAppointment({super.key});

  @override
  State<FormGetAppointment> createState() => _FormGetAppointmentState();
}

class _FormGetAppointmentState extends State<FormGetAppointment> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('rendez-vous', style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: Color.fromARGB(171, 0, 0, 0),)),
      ),

    );
  }
}