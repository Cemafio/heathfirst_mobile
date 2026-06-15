import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:heathfirst_mobile/page/home/categorie.dart';
import 'package:heathfirst_mobile/page/widget/card_user.dart';
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
        print(dmd);
        List<Map<String,Object>> listCategory = [{
              'type': 'Tous',
              'choice': true
        }];
        for (var d in dmd) {
          listCategory.add(
            {
              'type': formatDate(d['date']),
              'choice': false
            }
          );
        }

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
                  itemCount: 1,
                  itemBuilder: (context, index){
                    final dmdPatient = dmd[index]['patient'];
                    // print('ici =>${dmdPatient['firstname']}, ${dmdPatient['lastname']}, ${dmd[index]['information']['symptome']}, ${dmd[index]['date']}, ${dmdPatient['photo']}');
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