import 'package:flutter/material.dart';

class EmptyStateWidget extends StatefulWidget {
  final String? txt;
  const EmptyStateWidget({super.key, this.txt});

  @override
  State<EmptyStateWidget> createState() => _EmptyStateWidgetState();
}

class _EmptyStateWidgetState extends State<EmptyStateWidget> {
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        SizedBox(height: 70,),
        Icon(
          Icons.no_accounts_sharp,
          size: 40,
          color: Colors.grey,
        ),
        SizedBox(height: 10,),
        Text(widget.txt ?? "C'est encore vide")
      ],
    );
  }
}