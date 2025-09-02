import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:heathfirst_mobile/page/home/homePage.dart';

class SearchPage extends StatefulWidget {
  final Map<String, dynamic> user;
  const SearchPage({super.key, required this.user});
  @override
  State<SearchPage> createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage> {
  Map<String, dynamic> get _infoUser => widget.user;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      
      appBar: AppBar(
        actions: [
          
          GestureDetector(
            onTap:(){
              print("click page search");
              Navigator.of(context).push(MaterialPageRoute(builder: (context) =>  HomePage(user: _infoUser,)));
            },

            child: Container(
              width: 300,
              height: 35,
              padding: EdgeInsets.all(5),

              decoration: BoxDecoration(
                borderRadius: BorderRadius.all(Radius.circular(20)),
                border: Border.all( color: Colors.black38),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  const Icon(Icons.search),
                  // const SizedBox(width: 10,),
                  Container(
                    width: 250,
                    height: 100.w,
                    child: TextFormField(
                      decoration: InputDecoration(
                        border: InputBorder.none,
                        enabledBorder: InputBorder.none,
                        focusedBorder: InputBorder.none,
                        hint: Text('Chercher')
                      ),
                    ),
                  ),
                  
                ],
              ),
              
            ), 
          ),
          const SizedBox(width: 15),
        ],
      ),
      backgroundColor: Color.fromARGB(255, 229, 229, 229),
    );
  }
}
