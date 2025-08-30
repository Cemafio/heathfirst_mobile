import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:heathfirst_mobile/page/profile/editProfil.dart';
import 'package:heathfirst_mobile/page/login/login.dart';
import 'package:heathfirst_mobile/page/profile/editProfilDoc.dart';
import 'package:heathfirst_mobile/page/profile/profil.dart';

import 'package:shared_preferences/shared_preferences.dart';

class Settingpage extends StatefulWidget {
  final Map<String, dynamic> user;
  Settingpage({super.key, required this.user});

  @override
  State<Settingpage> createState() => _SettingpageState();
}

class _SettingpageState extends State<Settingpage> {
  Map<String,dynamic> get _user => widget.user;

  @override

  Future<void> _navigation(Widget materialPage) async {
    final opened = await Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => materialPage),
    );

    if (opened == true) {
      setState(() {
        // _infoUser = userInfo();
      });
    }
  }
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 229, 229, 229),
      body: SafeArea(
        child: SingleChildScrollView(
          scrollDirection: Axis.vertical,
          child: Column(
            children: [
              Container(
                height: 100,
                width: double.infinity,
                padding: const EdgeInsets.all(5),
                margin: const EdgeInsets.only(top: 30),

                // decoration: BoxDecoration(
                  // border: Border.all(color :Colors.black38)
                // ),

                child: Stack(
                  children:[
                    Container(
                      width: double.infinity,
                      height: double.maxFinite,
                      decoration: BoxDecoration(
                        color: Color.fromARGB(0, 214, 154, 154),
                      ),

                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Text(
                            "Paramètre",
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              letterSpacing: 2,
                              color: Colors.black87,
                            ),
                          )
                      ],),
                    ),
                    GestureDetector(
                      onTap: (){
                        Navigator.pop(context, true);
                      },
                      child: 
                        Positioned(
                          left: 10.w,
                          top: 20.w,
                          child: Container(
                            padding: const EdgeInsets.all(10),
                            margin: const EdgeInsets.only(bottom: 5),

                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(7),
                              color: const Color.fromARGB(57, 255, 255, 255),
                            ),

                            child: const Icon(Icons.arrow_back_ios_new_rounded, color: Color.fromARGB(255, 77, 76, 76)),
                          ), 
                        ),
                    ),
                  ]
                ),
              ),
              GestureDetector(
                onTap: (){
                  // _navigation(ProfilSection());
                  // Navigator.of(context).push(MaterialPageRoute(builder: (context)=>ProfilSection()));
                },
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    vertical: 10,
                    horizontal: 5 
                  ),
                  width: double.infinity,
                  margin: const EdgeInsets.all(20),

                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: Colors.black26)
                  ),

                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Container(
                        width: 250,
                        child: Row(children: [
                          Container(
                            width: 60,
                            height: 60,
                            margin: const EdgeInsets.only(bottom: 5),

                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(100),
                              border: Border.all(
                                width: 2,
                                color: Colors.black26,
                              ),
                              image: DecorationImage(
                                image: NetworkImage("http://10.37.128.28:8000/images/photos/${_user['photo_profil']}"),
                                fit: BoxFit.cover,
                              ),
                            ),
                          ),
                          const SizedBox(width: 10,),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                // '${infoUser['LastName']} ${infoUser['FirstName']}',
                                '${_user['LastName']} ${_user['FirstName']}',
                                style: const TextStyle(
                                  fontSize: 17,
                                  fontWeight: FontWeight.bold,
                                  letterSpacing: 2.0
                                ),
                              ),
                              Text(
                                "${_user['email']}",
                                style: const TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.normal,
                                  letterSpacing: 2.0
                                ),
                              ),

                            ],
                          ),
                        ],),  
                      ),
                      
                      // const SizedBox(width: 25,),
                      // Container(
                      //   padding: const EdgeInsets.all(10),
                      //   margin: const EdgeInsets.only(bottom: 5),

                      //   decoration: BoxDecoration(
                      //     borderRadius: BorderRadius.circular(20),
                      //     color: Color.fromARGB(0, 255, 255, 255),
                      //   ),

                      //   child: const Icon(Icons.arrow_forward_ios_rounded, color: Colors.black45,),
                      // ), 
                    ]
                  ),
                ),
              ),
              

              Container(
                margin: const EdgeInsets.all(20),
                padding: EdgeInsets.only(left: 10),

                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: Colors.black26)
                ),

                child: Column(
                  children: [
                    GestureDetector(
                      onTap: (){
                        // Navigator.of(context).push(MaterialPageRoute(builder: (context)=>()?Editprofil(infoUser: _user,)));
                        Widget route = (_user['roles'][0] == 'ROLE_PATIENT') ? Editprofil(infoUser: _user) : EditprofilDoc(infoUser: _user);
                        _navigation(route);
                      },
                      child: Container(
                        width: double.infinity,
                        height: 50,

                        decoration: const BoxDecoration(
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [ 
                            Container(
                              width: 200,
                              decoration:const BoxDecoration(
                                // border: Border.all()
                              ),
                              child: const Row(children: [
                                Icon(Icons.person),
                                SizedBox(width: 25,),
                                Text("Modifier information")
                              ],),
                            ),
                            const SizedBox(width: 25,),
                            Container(
                              padding: const EdgeInsets.all(10),
                              // margin: const EdgeInsets.only(bottom: 5),

                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(20),
                                color: Color.fromARGB(0, 255, 255, 255),
                              ),

                              child: const Icon(Icons.arrow_forward_ios_rounded, color: Colors.black45,),
                            ), 
                        ]),
                      ), 
                      
                    ),
                    GestureDetector(
                      onTap: (){
                        // _navigation(route);
                      },
                      child: Container(
                        width: double.infinity,
                        height: 50,

                        decoration: const BoxDecoration(
                          // border: Border.all()
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [ 
                            Container(
                              width: 200,
                              decoration:const BoxDecoration(
                                // border: Border.all()
                              ),
                              child: const Row(children: [
                                Icon(Icons.security),
                                SizedBox(width: 25,),
                                Text("Securiter")
                              ],),
                            ),
                            const SizedBox(width: 25,),
                            Container(
                              padding: const EdgeInsets.all(10),
                              // margin: const EdgeInsets.only(bottom: 5),

                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(20),
                                color: Color.fromARGB(0, 255, 255, 255),
                              ),

                              child: const Icon(Icons.arrow_forward_ios_rounded, color: Colors.black45,),
                            ), 
                        ]),
                      ), 
                      
                    ),
                    GestureDetector(
                      onTap: (){
                        // _navigation(route);
                      },
                      child: Container(
                        width: double.infinity,
                        height: 50,

                        decoration: const BoxDecoration(
                          // border: Border.all()
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [ 
                            Container(
                              width: 200,
                              child: Row(children: [
                                const Icon(Icons.nights_stay),
                                
                                const SizedBox(width: 25,),
                                
                                Text("Mode nuit")
                              ],),
                            ),
                            const SizedBox(width: 25,),
                            Container(
                              // padding: const EdgeInsets.all(10),
                              margin: const EdgeInsets.only(right: 8),
                              width: 35,
                              height: 17,
                              decoration: BoxDecoration(
                                border: Border.all(color: Colors.black54),
                                borderRadius: BorderRadius.circular(20),
                                color: Color.fromARGB(0, 255, 255, 255),
                              ),

                              child: Row(
                                // mainAxisAlignment: (modeNight == true)? MainAxisAlignment.start:MainAxisAlignment.end,
                                mainAxisAlignment: MainAxisAlignment.start,
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  Icon(Icons.circle, color: Colors.black54,size: 15,),
                              ]),
                            ), 
                        ]),
                      ), 
                    ),
                  ]
                ),
              ),
              Container(
                margin: const EdgeInsets.all(20),
                padding: EdgeInsets.only(left: 10),

                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: Colors.black26)
                ),

                child: Column(
                  children: [
                    GestureDetector(
                      onTap: (){
                        // _navigation(route);
                      },
                      child: Container(
                        width: double.infinity,
                        height: 50,

                        decoration: const BoxDecoration(
                          // border: Border.all()
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [ 
                            Container(
                              width: 200,
                              child: Row(children: [
                                const Icon(Icons.help_center),
                                
                                const SizedBox(width: 25,),
                                
                                Text("Demander de l'aide")
                              ],),
                            ),
                            const SizedBox(width: 25,),
                            Container(
                              padding: const EdgeInsets.all(10),
                              // margin: const EdgeInsets.only(bottom: 5),

                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(20),
                                color: Color.fromARGB(0, 255, 255, 255),
                              ),

                              child: const Icon(Icons.arrow_forward_ios_rounded, color: Colors.black45,),
                            ), 
                        ]),
                      ), 
                    ),
                    GestureDetector(
                      onTap: (){
                        // _navigation(route);
                      },
                      child: Container(
                        width: double.infinity,
                        height: 50,

                        decoration: const BoxDecoration(
                          // border: Border.all()
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [ 
                           Container(
                          // width: 250,
                            child: Row(children: [
                              const Icon(Icons.info),
                              
                              const SizedBox(width: 25,),
                              
                              Text("Apropos de l'application")
                            ],),
                          ),
                          const SizedBox(width: 25,),
                          Container(
                            padding: const EdgeInsets.all(10),
                            // margin: const EdgeInsets.only(bottom: 5),

                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(20),
                              color: Color.fromARGB(0, 255, 255, 255),
                            ),

                            child: const Icon(Icons.arrow_forward_ios_rounded, color: Colors.black45,),
                          ),  
                        ]),
                      ), 
                    ),
                    GestureDetector(
                      onTap: (){
                        // _navigation(route);
                      },
                      child: Container(
                        width: double.infinity,
                        height: 50,

                        decoration: const BoxDecoration(
                          // border: Border.all()
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [ 
                          Container(
                            width: 200,
                            child: Row(children: [
                              const Icon(Icons.delete, color: Colors.red),
                              
                              const SizedBox(width: 25,),
                              
                              Text("Suprimer votre compte", style: TextStyle(color: Colors.red),)
                            ],),
                          ),
                          const SizedBox(width: 25,),
                          Container(
                            padding: const EdgeInsets.all(10),
                            // margin: const EdgeInsets.only(bottom: 5),

                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(20),
                              color: Color.fromARGB(0, 255, 255, 255),
                            ),

                            child: const Icon(Icons.arrow_forward_ios_rounded, color: Colors.black45,),
                          ),  
                        ]),
                      ), 
                    ),
                  ]
                ),
              ),
              GestureDetector(
                onTap: () async{
                  final perfs = await SharedPreferences.getInstance();
                    await perfs.clear();
                    Navigator.of(context).push(MaterialPageRoute(builder: (context) => const LoginMobile()));
                },
                child: Container(
                  margin: const EdgeInsets.all(20),
                  padding: EdgeInsets.only(left: 10),

                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: Colors.black26)
                  ),

                  child: Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [ 
                          Container(
                            width: 200,
                            child: const Row(
                              children: [
                                Icon(Icons.logout_outlined),
                                SizedBox(width: 25,),
                                Text("Se déconecter")
                              ],
                            ),
                          ),
                          const SizedBox(width: 25,),
                          Container(
                            padding: const EdgeInsets.all(10),
                            // margin: const EdgeInsets.only(bottom: 5),

                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(20),
                              color: const Color.fromARGB(0, 255, 255, 255),
                            ),

                            child: const Icon(Icons.arrow_forward_ios_rounded, color: Colors.black45,),
                          ), 
                      ]),
                    ]
                  ),
                ),
              ),
            ],
          )
          
        ),
      )
      
    );
  }
}