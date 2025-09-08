import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:heathfirst_mobile/page/profile/InfoUser.dart';
import 'package:http/http.dart' as http;
import 'package:heathfirst_mobile/service/data.dart';


class ListDocSection extends StatefulWidget {
  Future<List<dynamic>> listDoc;
  final Map<String, dynamic> user;
  ListDocSection({super.key, required this.listDoc, required this.user});

  @override
  State<ListDocSection> createState() => _ListDocSectionState();
}
class _ListDocSectionState extends State<ListDocSection> {
  Future <List<dynamic>> get _listDoc => widget.listDoc;
  Map<String, dynamic> get _infoUser => widget.user;

  @override
  void initState(){
    super.initState();
    // _listDoc =  fetchData(); 
  }
  Widget build(BuildContext context) {
    return Column(
      children: [
        FutureBuilder(
          future: _listDoc, 
          builder: (context, snapshot){
            if(snapshot.connectionState == ConnectionState.waiting)
              return Container(
                margin: EdgeInsets.only(top: 100),
                child: Center(
                    child: CircularProgressIndicator()
                  )
              );

            if (snapshot.hasError){
              return Center(child: Text('Erreur : ${snapshot}'));
            }
            final docList = snapshot.data!;
            return ListView.builder(
              itemCount: docList.length,
              shrinkWrap: true, // important si la liste est dans une Column
              physics: NeverScrollableScrollPhysics(), // évite le scroll imbriqué  
              itemBuilder: (contex, index){
                var listRdvItem = docList[index];
                
                return GestureDetector(
                  onTap: () {
                    Navigator.of(context).push(MaterialPageRoute(builder: (context) =>InfoUser(rdv: listRdvItem, user: _infoUser)));
                  },
                  child:   Container(
                    height: 120,
                    margin: EdgeInsets.only(
                      bottom: 10
                    ),
                    padding: EdgeInsets.all(12),
                  
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(15),
                      color: Colors.white,
                    ),
                    child: Row(children: [
                      Container(
                        width: 80,
                        height: 80,

                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(50),
                          child: Image.network("http://10.241.20.28:8000/images/photos/${listRdvItem['photoProfil']}", fit: BoxFit.cover,)
                        ),
                      ),
                      const SizedBox(width: 20,),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.center,

                        children: [
                          Text('${listRdvItem['LastName']} ${listRdvItem['FirstName']}',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Color.fromARGB(171, 0, 0, 0),
                          )),
              
                          const SizedBox(height: 5,),

                          Text('${listRdvItem['specialty']}', style: TextStyle(
                            fontSize: 13,
                            color: Color.fromARGB(171, 0, 0, 0),
                          ),),

                          const SizedBox(height: 10,),
                          Container(child: Row(children: [
                            Icon(Icons.timer_outlined, color: Color(0xFF548856)),
                            Text("08:00am et 18:30 pm",
                              style: TextStyle(
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                                color: Color.fromARGB(171, 0, 0, 0),
                              )
                            )
                          ]),),
                          ]),
                        ])
                      )
                    );
                  }
              );
            }

          )
      ]);
  }
}