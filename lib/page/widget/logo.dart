import 'package:flutter/material.dart';

class LogoSalma extends StatefulWidget {
  final String? logo;
  const LogoSalma({super.key, this.logo});

  @override
  State<LogoSalma> createState() => _LogoSalmaState();
}

class _LogoSalmaState extends State<LogoSalma> {
  @override
  Widget build(BuildContext context) {
    return Container(
      width: 40,
      height: 40,
      decoration: BoxDecoration(
        image: DecorationImage(
          fit: BoxFit.cover,
          image: AssetImage('assets/images/${widget.logo ?? 'Logo.png'}'),
        )
      ),
    );
  }
}