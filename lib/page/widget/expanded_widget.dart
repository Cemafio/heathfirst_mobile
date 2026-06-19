import 'package:flutter/material.dart';
import 'package:hugeicons/hugeicons.dart';

class MyExpandedWidget extends StatefulWidget {
  final String textShow;
  final Widget hide;
  const MyExpandedWidget({super.key, required this.hide, required this.textShow});

  @override
  State<MyExpandedWidget> createState() => _MyExpandedWidgetState();
}

class _MyExpandedWidgetState extends State<MyExpandedWidget> {
  final expensibleController = ExpansibleController();
  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      margin: EdgeInsets.all(10),
      padding: EdgeInsets.all(15),
      // height: 300,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.all(Radius.circular(10))
      ),
      child: Expansible(
        headerBuilder: (context, index){
          return GestureDetector(
            onTap: (){
              (expensibleController.isExpanded)
              ?expensibleController.collapse()
              :expensibleController.expand();
            },
            child: Container(
              margin: EdgeInsets.only(bottom: 15),
              width: double.infinity,
              height: 20,
      
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    widget.textShow,

                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 1.5
                    ),
                  ),
                  HugeIcon(
                    icon: (!expensibleController.isExpanded)
                      ? HugeIcons.strokeRoundedArrowDown01
                      : HugeIcons.strokeRoundedArrowUp01,
                    strokeWidth: 3,
                  )
                ],
              )
            ),
          );
        }, 
        bodyBuilder: (context, index){
          return widget.hide;
        }, 
        controller: expensibleController
      ),
    );
  }
}