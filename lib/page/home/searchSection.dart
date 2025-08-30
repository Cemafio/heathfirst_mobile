import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

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
              Navigator.of(context).push(MaterialPageRoute(builder: (context) =>  SearchPage(user: _infoUser,)));
            },

            child: Container(
              width: 300,
              height: 35,
              padding: EdgeInsets.all(5),

              decoration: BoxDecoration(
                borderRadius: BorderRadius.all(Radius.circular(20)),
                border: Border.all( color: Colors.black38)
              ),
              child: Row(
                children: [
                  const Icon(Icons.search),
                  const SizedBox(width: 10,),
                  TextFormField(
                    decoration: InputDecoration(
                      hint: Text('Chercher')
                    ),
                  )
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
