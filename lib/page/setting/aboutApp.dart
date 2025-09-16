import 'package:flutter/material.dart';

class AboutAppPage extends StatefulWidget {
  const AboutAppPage({super.key});

  @override
  State<AboutAppPage> createState() => _AboutAppPageState();
}

class _AboutAppPageState extends State<AboutAppPage> {
  @override
   Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('About Us', style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold, letterSpacing: 2.0),),
        backgroundColor: Colors.white,
      ),
    );
  }
}