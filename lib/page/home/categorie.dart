import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:heathfirst_mobile/provider/category_provider.dart';
class CategorieSection extends ConsumerStatefulWidget {
  final List<String> category;
  CategorieSection({super.key, required this.category });

  @override
  ConsumerState<CategorieSection> createState() => _CategorieSectionState();
}

class _CategorieSectionState extends ConsumerState<CategorieSection> {
  bool choice = true;

  List<String> get categorie  => widget.category;
  

  @override
  Widget build(BuildContext context) {
    final categorySelected = ref.watch(selectedDocCategoryProvider);
    
    return ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: categorie.length, // Le nombre d'éléments dans la liste
            itemBuilder: (context, index) {
              return GestureDetector(
                  onTap: () {
                    setState(() {
                      ref.watch(selectedDocCategoryProvider.notifier).state = categorie[index].toString();
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
                    color: categorie[index].toString() != categorySelected? Colors.white : Color(0xFF548856),

                  ),


                ), 

                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [

                    if(categorie[index].toString() != 'Tous' && categorie[index].toString().split(' ').length > 1)...[
                      Text(
                        categorie[index].toString().split(' ')[1],
                        style: TextStyle(
                          fontWeight:  FontWeight.bold,
                          letterSpacing: 2.0,
                          fontSize: 11,

                          color: (
                            (categorie[index].toString() != categorySelected)
                            ?Color.fromARGB(242, 37, 37, 37)
                            :Color(0xFF548856)
                          ),
                        )
                      ),
                    ],
                    const SizedBox(height: 5,),
                    Text(
                      (categorie[index].toString() == 'Tous' && categorie[index].toString().split(' ').length <= 1)
                        ?categorie[index].toString() 
                        :categorie[index].toString().split(' ')[0],
                      style: TextStyle(
                        fontWeight:  FontWeight.bold,
                        letterSpacing: 2.0,
                        fontSize: 11,
                        color: (
                          (categorie[index].toString() != categorySelected)
                          ?Color.fromARGB(242, 37, 37, 37)
                          :Color(0xFF548856)
                        ),
                      )
                    ),

                  ],
                ),
              ));
            }
          );

  }
}

