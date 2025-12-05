import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:heathfirst_mobile/page/home/homePage.dart';
import 'package:heathfirst_mobile/page/profile/InfoUser.dart';
import 'package:heathfirst_mobile/service/data.dart';

class SearchPage extends StatefulWidget {
  final Map<String, dynamic> user;
  final Future<List<dynamic>> listDoc;

  const SearchPage({
    super.key, 
    required this.user,
    required this.listDoc,
  });
  @override
  State<SearchPage> createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage> {
  Map<String, dynamic> get _infoUser => widget.user;
  Future<List<dynamic>> get _listDoc=> widget.listDoc;
  List<dynamic> doc_cheched = [];
  bool isLoaded = false;
  Timer? _debounce;


  Future<void> _chercheFunction (String value) async{
    print('✅ valeur entrer:'+ value);

    Map<String, dynamic> buildDoctor(Map<String, dynamic> list) {
      return {
        'id': list['id'],
        'name' : "${list['LastName']} ${list['FirstName']}",
        'lastName' : list['LastName'],
        'firstName' : list['FirstName'],
        'specialty' : list['Specialty'],
        'Address' : list['Address'],
        'AddressCabinet' : list['AddressCabinet'],
        'photoProfil' : list['photoProfil'],
        'phone' : list['phome'],
        'email' : list['email'],
      };
    }

    // if (value == "") {
    setState(() {
      isLoaded = true;
    });
    // }
    List<dynamic> newList = [];
    List<dynamic> listCherche = await recherche(value,'','',1);
    List<dynamic> listChercheAddress = await recherche('','',value,1);
    List<dynamic> listChercheSpeciality = await recherche('',value,'',1);


    if (listCherche.isEmpty) {

      if(listChercheSpeciality.isNotEmpty){
        for (var list in listChercheSpeciality) {
          print("✅ (>_<) Profil rechercher : ${list['LastName']} ${list['FirstName']}");
          newList.add(buildDoctor(list));
        }
      }else if(listChercheAddress.isNotEmpty){

        for (var list in listChercheAddress) {
          print("✅ (>_<) Profil rechercher : ${list['LastName']} ${list['FirstName']}");
          newList.add(buildDoctor(list));
        }
      }
    }else{

      for (var list in listCherche) {
        print("✅ (>_<) Profil rechercher : ${list['LastName']} ${list['FirstName']}");
        newList.add(buildDoctor(list));
      }
    }

    setState(() {
      doc_cheched = newList;
      isLoaded = false;
    });
    // else{
    //   print('Auccun donner correspond a notre recherche');
    // }

  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      
      appBar: AppBar(
        actions: [
          
          Container(
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
                  SizedBox(
                    width: 250,
                    height: 100.w,
                    child: TextFormField(

                      onChanged: (value) {
                        if (_debounce?.isActive ?? false) _debounce!.cancel();

                        _debounce = Timer(const Duration(milliseconds: 400), () {
                          _chercheFunction(value);
                        });
                      },

                      decoration: InputDecoration(
                        border: InputBorder.none,
                        enabledBorder: InputBorder.none,
                        focusedBorder: InputBorder.none,
                        hint: Text('Chercher')
                      ),
                    ),
                  ),
                  GestureDetector(
                    onTap:(){
                      // Navigator.of(context).push(MaterialPageRoute(builder: (context) =>  HomePage(user: _infoUser,)));
                    },

                    child: 
                      const Icon(Icons.search),
                  ),
                ],
              ),
              
            ), 

          const SizedBox(width: 15),
        ],
      ),
      backgroundColor: Color.fromARGB(255, 229, 229, 229),
      body: 
        SingleChildScrollView(
          scrollDirection: Axis.vertical,
          child: Column(
            children: [
              if (isLoaded == true) 
                Container(
                  // height: 20,
                  margin: EdgeInsets.only(top: 100),
                  child: Center(child: CircularProgressIndicator()),
                ),
              if(isLoaded == false)    
              ListView.builder(
                itemCount: doc_cheched.length,
                shrinkWrap: true,
                itemBuilder: (context, index){
                  var doc = doc_cheched[index];

                  if (doc_cheched.isEmpty) {
                    print('vide');
                  }

                
                  return GestureDetector(
                    onTap: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (context) =>
                              InfoUser(data: [doc,_infoUser, _listDoc]),
                        ),
                      );
                    },
                    child: Container(
                      height: 100,
                      margin: EdgeInsets.only(bottom: 0),
                      padding: EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(15),
                      ),
                      child: Row(
                        children: [
                          SizedBox(
                            width: 65,
                            height: 65,
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(50),
                              child: Image.network(
                                "http://172.27.136.28:8000/images/photos/${doc_cheched[index]['photoProfil']}",
                                fit: BoxFit.cover,
                              ),
                            ),
                          ),
                          const SizedBox(width: 20),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                doc_cheched[index]['name'],
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: Colors.black87,
                                  letterSpacing: 1.2
                                ),
                              ),
                              
                              Row(
                                children: [
                                  Icon(Icons.add_chart_rounded,
                                      color: Color(0xFF548856),
                                      size: 15),
                                      const SizedBox(width: 3),
                                  Text(
                                    doc_cheched[index]['specialty'],
                                    style: TextStyle(
                                      fontSize: 13,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.black87,
                                    ),
                                  )
                                ],
                              ),
                              SizedBox(height: 0),
                              Row(
                                children: [
                                  Icon(Icons.location_city_rounded,
                                      color: Color(0xFF548856),
                                      size: 15),
                                      const SizedBox(width: 3),
                                  Text(
                                    doc_cheched[index]['AddressCabinet'],
                                    style: TextStyle(
                                      fontSize: 10,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.black87,
                                    ),
                                  )
                                ],
                              )
                            ],
                          )
                        ],
                      ),
                    ),
                  );
                }),
            ],
          ),
        )
    );
  }
}
