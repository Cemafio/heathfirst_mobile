import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:heathfirst_mobile/page/widget/loading_fusion.dart';
import 'package:heathfirst_mobile/provider/app_provider.dart';
import 'package:heathfirst_mobile/provider/demande_rdv_provider.dart';
import 'package:heathfirst_mobile/provider/userProvider.dart';
import 'package:heathfirst_mobile/utils/string_extension.dart';
import 'package:hugeicons/hugeicons.dart';

class CardUserWidget extends ConsumerStatefulWidget {
  final String firstName;
  final String lastName;
  final String symptome;
  final String dateTime;
  final String photo;
  final String heurRdv;
  final List<bool> isLoad;
  final void Function(Map<String, dynamic> dmd, String status) responseRdv;  
  final Map<String, dynamic> dmdData;

  const CardUserWidget({super.key, required this.isLoad,required this.dmdData,required this.responseRdv,required this.photo, required this.firstName, required this.lastName, required this.symptome, required this.dateTime, required this.heurRdv});

  @override
  ConsumerState<CardUserWidget> createState() => _CardUserWidgetState();
}

class _CardUserWidgetState extends ConsumerState<CardUserWidget> {
  bool isTextShow = false;
  bool isLoadingAccept = false;
  bool isLoadingRefuse = false;

  // List<bool> get isLoad => widget.isLoad;
  String get symptomText => widget.symptome;
  String get first_name => widget.firstName;
  String get last_name => widget.lastName;
  String get date_time => widget.dateTime;

  String _hideSommeText(String text){

    List<String> splitText = text.split(' ');

    if(splitText.length < 8) return text;

    String textCuted = '';

    for (var i = 0; i < 8; i++) {
      textCuted += '${splitText[i]} ';
    }
    return '$textCuted ...';
  }

  @override
  Widget build(BuildContext context) {
    final _userDataStatic = ref.watch(userDataStatic);

    return AnimatedContainer(
      duration: Duration(milliseconds: 300),
      curve: Curves.easeInOut,
      
      width: double.infinity,
      padding: EdgeInsets.symmetric(vertical: 15, horizontal: 15),
      margin: EdgeInsets.symmetric(vertical: 10),
      decoration: BoxDecoration(
        color: const Color.fromARGB(255, 255, 255, 255),
        borderRadius: BorderRadius.circular(30)
      ),

      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
        // (widget.photo != '')
        //   ? Container(
        //       width: 80,
        //       height: 80,
        //       margin: const EdgeInsets.only(bottom: 5),

        //       decoration: BoxDecoration(
        //         borderRadius: BorderRadius.circular(100),
        //         border: Border.all(
        //           width: sqrt1_2,
        //           color: const Color(0xFF81C784),
        //         ),
        //         image: DecorationImage(
        //           image: NetworkImage('${ref.watch(baseUrl)}/images/photos/${widget.photo}'),
        //           fit: BoxFit.cover,
        //         ),
        //       ),
        //     )
        //   : 
          Container(
            width: 80,
            height: 80,
            margin: const EdgeInsets.only(bottom: 5),

            decoration: BoxDecoration(
              color: const Color(0xFF81C784),
              borderRadius: BorderRadius.circular(100),
              border: Border.all(
                width: sqrt1_2,
                color: const Color(0xFF81C784),
              ),
            ),

            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  _userDataStatic.lastname.toString().uperFirstChart(),
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold
                  ),
                )
              ],
            ),
          ),

          const SizedBox(width: 15,),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Text(
                    '$last_name $first_name',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                       fontSize: 18
                    ),
                  ),
                  
                  const SizedBox(width: 10,),
                  Container(
                    width: 40,
                    height: 19,
                    alignment: Alignment.center,

                    decoration: BoxDecoration(
                      color: Color.fromARGB(125, 91, 217, 101),
                      borderRadius: BorderRadius.circular(30)
                    ),
                    child: Center(
                      child: Text(
                        widget.heurRdv, 
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                          color: Colors.white
                        )
                      ),
                    ),
                  )
                ],
              ),

              Row(
                children: [
                  const SizedBox(width: 10,),
                  AnimatedSize(
                    duration: Duration(milliseconds: 200),
                    child: SizedBox(
                      width: 175,
                      child: Text(
                        symptomText,
                        maxLines: isTextShow ? 6 : null,  
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ),
                  if(symptomText.split(' ').length > 8)...[
                    IconButton(
                      tooltip: isTextShow ? 'Réduire' : 'Voir plus',
                      onPressed: (){
                        setState(() {
                          isTextShow = !isTextShow;
                        });
                      }, 
                      icon: HugeIcon(
                        icon: (isTextShow == false)
                          ? HugeIcons.strokeRoundedArrowDown01
                          : HugeIcons.strokeRoundedArrowUp01,
                        strokeWidth: 3,
                      )
                    )
                  ]
                ],
              ),

              Container(
                margin: EdgeInsets.only( top: 5),
                child: Row(
                  children: [
                    TextButton(
                      onPressed: () async {
                        widget.responseRdv(widget.dmdData, 'refused');
                      }, 

                      child: LoadingFusBtn(
                        isLoaded: isLoadingRefuse, 
                        wid: Text('refuser', style: TextStyle(
                          color: Colors.red
                        ),
                        )
                      )
                    ),

                    TextButton(
                      onPressed: () async {
                        widget.responseRdv(widget.dmdData, 'accepted');

                      }, 
                      child:LoadingFusBtn(
                        isLoaded: ref.watch(responseLoadingProvider)[widget.dmdData['id']] ?? false, 
                        wid: Text(
                          'accepter',
                        )
                      ),
                    ),
                  ],
                ),
              )
            ],
          )
        ],
      ),
    );
  }
}