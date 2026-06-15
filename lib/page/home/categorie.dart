import 'package:flutter/material.dart';
class CategorieSection extends StatefulWidget {
  final List<Map<String,Object>> category;
  CategorieSection({super.key, required this.category });

  @override
  State<CategorieSection> createState() => _CategorieSectionState();
}

class _CategorieSectionState extends State<CategorieSection> {
  bool choice = true;

  List<Map<String,Object>> get categorie  => widget.category;
  

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: categorie.length, // Le nombre d'éléments dans la liste
            itemBuilder: (context, index) {
              return GestureDetector(
                  onTap: () {
                    setState(() {

                      for (var i = 0; i < categorie.length; i++) {
                        categorie[i]['choice'] = i==index;
                      }
                    });
                  },
              child: AnimatedContainer(
                duration: Duration(milliseconds: 300),
                curve: Curves.easeInOut,
                
                margin: const EdgeInsets.symmetric(
                  vertical: 2.0,
                  horizontal: 5.0
                ),
                padding: const EdgeInsets.symmetric(
                  vertical: 5,
                  horizontal: 7
                ),
                
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(15),
                  border: Border.all(
                    color: (categorie[index]['choice']) != true? Colors.white : Color(0xFF548856),

                  ),


                ), 

                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    if(categorie[index]['type'].toString() != 'Tous')...[
                      Text(
                        categorie[index]['type'].toString().split(' ')[1],
                        style: TextStyle(
                          fontWeight:  FontWeight.bold,
                          letterSpacing: 2.0,
                          fontSize: 11,

                          color: (
                            (categorie[index]['choice'])!= true)
                            ?Color.fromARGB(242, 37, 37, 37)
                            :Color(0xFF548856)
                          ),
                      ),
                    ],
                    const SizedBox(height: 5,),
                    Text(
                      (categorie[index]['type'].toString() == 'Tous')
                        ?categorie[index]['type'].toString() 
                        :categorie[index]['type'].toString().split(' ')[0],
                      style: TextStyle(
                        fontWeight:  FontWeight.bold,
                        letterSpacing: 2.0,
                        fontSize: 11,
                        color: (
                          (categorie[index]['choice'])!= true)
                          ?Color.fromARGB(242, 37, 37, 37)
                          :Color(0xFF548856)
                        ),
                    ),

                  ],
                ),
              ));
            }
          );

  }
}

