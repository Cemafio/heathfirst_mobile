import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:heathfirst_mobile/page/home/categorie.dart';
import 'package:heathfirst_mobile/page/widget/card_user.dart';
import 'package:heathfirst_mobile/page/widget/emptyWidget.dart';
import 'package:heathfirst_mobile/provider/app_provider.dart';
import 'package:heathfirst_mobile/provider/category_provider.dart';
import 'package:heathfirst_mobile/provider/demande_rdv_provider.dart';
import 'package:heathfirst_mobile/service/data.dart';
import 'package:intl/intl.dart';

class Acceuildoc extends ConsumerStatefulWidget {

 const Acceuildoc({super.key});

  @override
  ConsumerState<Acceuildoc> createState() => _AcceuildocState();
}

class _AcceuildocState extends ConsumerState<Acceuildoc> {
  bool isRefuLoad = false;
  bool isAcceptLoaded = false;

  String formatDate(String dateString) {
    final date = DateTime.parse(dateString);
    final now = DateTime.now();

    // Si ce n'est pas l'année actuelle
    if (date.year != now.year) {
      return date.year.toString();
    }

    const months = {
      1: 'Jan',
      2: 'Fév',
      3: 'Mar',
      4: 'Avr',
      5: 'Mai',
      6: 'Jun',
      7: 'Jul',
      8: 'Aoû',
      9: 'Sep',
      10: 'Oct',
      11: 'Nov',
      12: 'Déc',
    };

    return '${date.day} ${months[date.month]}';
  }

  void responseRdv (Map<String, dynamic> demande, String response) async {
    // print(demande);
    // print(response);

    final doc = demande['doctor'];
    final patient = demande['patient'];
    final id = demande['id'];

    ref.read(responseLoadingProvider.notifier).state = {
      ...ref.read(responseLoadingProvider),
      id: true,
    };
    
    try {
      await responseAppointment(id, response, patient['id'], doc['id'],ref.watch(baseUrl), ref.watch(accessTokenProvider));
      ref.refresh(dmdAsyncProvider);
    } catch (e) {
      print("error: $e");

    }finally{
      ref.read(responseLoadingProvider.notifier).state = {
        ...ref.read(responseLoadingProvider),
        id: false,
      };
    }
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
        final dates = dmd.where((d)=>d['status'] == 'pending').toList()
            .map((e) => DateTime.parse(e['date']))
            .toList()
          ..sort((a, b) => a.compareTo(b));

        final Set<String> uniqueDates = {};

        for (var date in dates) {
          uniqueDates.add(formatDate(date.toString()));
        }

        final listCategory = [
          'Tous',
          ...uniqueDates,
        ];

        String selectedCategory = ref.watch(selectedDocCategoryProvider);
        List filteredDmd = selectedCategory == 'Tous'
          ? dmd.where((d)=>d['status'] == 'pending').toList()
          : dmd.where((e) {
              return formatDate(e['date']) == selectedCategory  && e['status'] == 'pending';
            }).toList();

        if(filteredDmd.isEmpty){
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
                EmptyStateWidget(txtBold: "Aucune demande",)

              ],
            ),
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
                  itemCount: filteredDmd.length,
                  itemBuilder: (context, index){
                    final dmdPatient = filteredDmd[index]['patient'];

                    return CardUserWidget(firstName: dmdPatient['firstname'],lastName: dmdPatient['lastname'], symptome: filteredDmd[index]['information']['symptome'],dateTime: filteredDmd[index]['date'],photo: dmdPatient['photo'], heurRdv: filteredDmd[index]['information']['hour'], responseRdv: responseRdv,dmdData: filteredDmd[index],isLoad: [isRefuLoad, isAcceptLoaded],);
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