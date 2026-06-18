import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:heathfirst_mobile/page/home/homePage.dart';
import 'package:heathfirst_mobile/page/profile/InfoUser.dart';
import 'package:heathfirst_mobile/page/widget/emptyWidget.dart';
import 'package:heathfirst_mobile/provider/app_provider.dart';
import 'package:heathfirst_mobile/provider/doc_provider.dart';
import 'package:heathfirst_mobile/service/data.dart';

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
  // Map<String, dynamic> get _infoUser => widget.user;
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
    final resultChearch = ref.watch(filteredDoctorsProvider);
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

          const SizedBox(width: 15),
        ],
      ),
      backgroundColor: Color.fromARGB(255, 229, 229, 229),
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
          
                  if(resultChearch.isNotEmpty)
                  ListView.builder(
                    itemCount: resultChearch.length,
                    shrinkWrap: true,
                    itemBuilder: (context, index){
                      var doc = resultChearch[index];
          
                      return GestureDetector(
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
                            children: [
                              SizedBox(
                                width: 65,
                                height: 65,
                                child: ClipRRect(
                                  borderRadius: BorderRadius.circular(50),
                                  child: Image.network(
                                    "${ref.watch(baseUrl)}/images/photos/${doc['photo_doc']}",
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
                                  SizedBox(height: 0),
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
                      );
                    }
                  ),
                ]
                
              ],
            ),
          ),
        )
    );
  }
}
