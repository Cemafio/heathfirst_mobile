import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:heathfirst_mobile/page/home/categorie.dart';
import 'package:heathfirst_mobile/page/widget/card_user.dart';
import 'package:heathfirst_mobile/provider/category_provider.dart';
import 'package:heathfirst_mobile/provider/demande_rdv_provider.dart';
import 'package:intl/intl.dart';

class Acceuildoc extends ConsumerStatefulWidget {

 const Acceuildoc({super.key});

  @override
  ConsumerState<Acceuildoc> createState() => _AcceuildocState();
}

class _AcceuildocState extends ConsumerState<Acceuildoc> {
  String formatDate(String dateString) {
    final date = DateTime.parse(dateString);
    String result = DateFormat('d MMMM', 'fr_FR').format(date);

    return result[0].toUpperCase() + result.substring(1);
  }

  @override
  void initState(){
    super.initState();
  }

  
 
  Widget build(BuildContext context) {
    final demandeAsync = ref.watch(dmdAsyncProvider);
    
    return demandeAsync.when(
      loading: () => Center(
        child: CircularProgressIndicator(),
      ),
      error: (err, state){
        return Text('Erreur de chargement');
      },

      data: (dmd){
        // print(dmd);
        final Set<String> dates = {'Tous'};

        for (var d in dmd) {
          dates.add(formatDate(d['date']));
        }

        final listCategory = dates.map((e) => {
          'type': e,
          'choice': e == 'Tous',
        }).toList();


        String selectedCategory = ref.watch(selectedDocCategoryProvider);
        List filteredDmd = selectedCategory == 'Tous'
          ? dmd
          : dmd.where((e) {
              print('$selectedCategory == ${formatDate(e['date'])}');
              return formatDate(e['date']) == selectedCategory;
            }).toList();

        return SizedBox(
          width: double.infinity,
          height: double.infinity,
          child: Column(
            children: [
              if(listCategory.isNotEmpty)...[
                SizedBox(
                  width: double.infinity,
                  height: 60,
                  child: CategorieSection(category: listCategory),
                ),
                
              ],

              const SizedBox(height: 15,),
              Expanded(
                child: ListView.builder(
                  itemCount: filteredDmd.length,
                  itemBuilder: (context, index){
                    final dmdPatient = filteredDmd[index]['patient'];
                    return CardUserWidget(firstName: dmdPatient['firstname'],lastName: dmdPatient['lastname'], symptome: dmd[index]['information']['symptome'],dateTime: dmd[index]['date'],photo: dmdPatient['photo'], heurRdv: dmd[index]['information']['hour'],);
                  }
                ),
              ),
            ],
          ),
        );
      }
    );
  }
}