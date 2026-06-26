import 'dart:async';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:heathfirst_mobile/page/home/homePage.dart';
import 'package:heathfirst_mobile/page/profile/InfoUser.dart';
import 'package:heathfirst_mobile/page/profile/carnet_patient.dart';
import 'package:heathfirst_mobile/page/profile/profil.dart';
import 'package:heathfirst_mobile/page/widget/emptyWidget.dart';
import 'package:heathfirst_mobile/provider/app_provider.dart';
import 'package:heathfirst_mobile/provider/doc_provider.dart';
import 'package:heathfirst_mobile/provider/userProvider.dart';
import 'package:heathfirst_mobile/service/data.dart';
import 'package:heathfirst_mobile/utils/string_extension.dart';
import 'package:hugeicons/hugeicons.dart';

class SearchPage extends ConsumerStatefulWidget {
  final Future<List<dynamic>> listDoc;

  const SearchPage({
    super.key, 
    required this.listDoc,
  });
  @override
  ConsumerState<SearchPage> createState() => _SearchPageState();
}

class _SearchPageState extends ConsumerState<SearchPage> {
  Future<List<dynamic>> get _listDoc=> widget.listDoc;
  List<dynamic> doc_cheched = [];
  bool isLoaded = false;
  Timer? _debounce;


  Future<void> _chercheFunction (String value) async{
    ref.read(searchProvider.notifier).state = value; 
    print('✅ valeur entrer:'+ value);

  }

  @override
  Widget build(BuildContext context) {
    final resultChearch = ref.watch(filteredUsersProvider);
    final userData = ref.watch(userDataStatic);

    print("result => ${resultChearch}");
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
                      Navigator.of(context).push(MaterialPageRoute(builder: (context) =>  HomePage()));
                    },

                    child: 
                      const Icon(Icons.search),
                  ),
                ],
              ),
              
            ), 
        ],
      ),
      body: 
        SizedBox(
          width: MediaQuery.of(context).size.width,

          child: SingleChildScrollView(
            scrollDirection: Axis.vertical,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                if (isLoaded == true) 
                  Container(
                    // height: 20,
                    margin: EdgeInsets.only(top: 100),
                    child: Center(child: CircularProgressIndicator()),
                  ),
          
                if(isLoaded == false)...[
                  if(resultChearch.isEmpty)
                  EmptyStateWidget(lottiName: 'empty_search',),
          
                  if(resultChearch.isNotEmpty)...[
                    const SizedBox(height: 20,),
                    Row(
                      children: [
                        const SizedBox(width: 20,),
                        Text(
                          userData.roles != 'ROLE_PATIENT' ? 'Patient' : 'Docteur',
                          style: TextStyle(
                            fontSize: 17,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 1
                          ),
                        ),
                      ],
                    ),
                    ListView.builder(
                      itemCount: resultChearch.length,
                      shrinkWrap: true,
                      itemBuilder: (context, index){
                        var doc = resultChearch[index];
            
                        return userData.roles == 'ROLE_PATIENT'
                        ? GestureDetector(
                          onTap: () {
                            Navigator.of(context).push(
                              MaterialPageRoute(
                                builder: (context) => InfoUser(data: [doc, _listDoc]),
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
                              mainAxisAlignment: MainAxisAlignment.start,
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                Container(
                                  width: 65,
                                  height: 65,

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
                                      HugeIcon(
                                        icon: HugeIcons.strokeRoundedDoctor01,
                                        size: 30,
                                      ),
                                    ],
                                  ),
                                ),

                                const SizedBox(width: 20),
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Text(
                                      resultChearch[index]['last_name'],
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
                                          resultChearch[index]['speciality'],
                                          style: TextStyle(
                                            fontSize: 13,
                                            fontWeight: FontWeight.bold,
                                            color: Colors.black87,
                                          ),
                                        )
                                      ],
                                    ),
                                    Row(
                                      children: [
                                        Icon(Icons.location_city_rounded,
                                            color: Color(0xFF548856),
                                            size: 15),
                                            const SizedBox(width: 3),
                                        Text(
                                          resultChearch[index]['addressCabinet'],
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
                        )
                        : GestureDetector(
                          onTap: () {
                            Navigator.of(context).push(
                              MaterialPageRoute(
                                builder: (context) => CarnetPatient(),
                              ),
                            );
                          },

                          child: Container(
                            height: 100,
                            padding: EdgeInsets.all(12),

                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(15),
                            ),

                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.start,
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                Container(
                                  width: 65,
                                  height: 65,
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
                                        resultChearch[index].last_name.toString().uperFirstChart(),
                                        style: TextStyle(
                                          fontSize: 20,
                                          fontWeight: FontWeight.bold
                                        ),
                                      )
                                    ],
                                  ),
                                ),
                                // Container(
                                //   width: 65,
                                //   height: 65,

                                //   decoration: BoxDecoration(
                                //     color: const Color(0xFF81C784),
                                //     borderRadius: BorderRadius.circular(100),
                                //     border: Border.all(
                                //       width: sqrt1_2,
                                //       color: const Color(0xFF81C784),
                                //     ),
                                //   ),

                                //   child: Column(
                                //     mainAxisAlignment: MainAxisAlignment.center,
                                //     children: [
                                //       HugeIcon(
                                //         icon: HugeIcons.strokeRoundedDoctor01,
                                //         size: 30,
                                //       ),
                                //     ],
                                //   ),
                                // ),

                                const SizedBox(width: 20),
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Text(
                                      resultChearch[index].last_name,
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
                                          resultChearch[index].email,
                                          style: TextStyle(
                                            fontSize: 13,
                                            fontWeight: FontWeight.bold,
                                            color: Colors.black87,
                                          ),
                                        )
                                      ],
                                    ),
                                    Row(
                                      children: [
                                        Icon(Icons.location_city_rounded,
                                            color: Color(0xFF548856),
                                            size: 15),
                                            const SizedBox(width: 3),
                                        Text(
                                          resultChearch[index].adress,
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
                          )
                        );
                        // Text('${resultChearch[index].last_name}');
                      }
                    ),
                  ],
                ]
                
              ],
            ),
          ),
        )
    );
  }
}
