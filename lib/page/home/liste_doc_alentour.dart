import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:heathfirst_mobile/page/login/login.dart';
import 'package:heathfirst_mobile/page/profile/InfoUser.dart';
import 'package:heathfirst_mobile/page/widget/emptyWidget.dart';
import 'package:heathfirst_mobile/provider/app_provider.dart';
import 'package:heathfirst_mobile/provider/doc_provider.dart';
import 'package:http/http.dart' as http;
import 'package:heathfirst_mobile/service/data.dart';

class ListDocSection extends ConsumerStatefulWidget {
  final Future<List<dynamic>> listDoc;
  // final Map<String, dynamic> user;

  ListDocSection({
    super.key,
    required this.listDoc,
  });

  @override
  ConsumerState<ListDocSection> createState() => _ListDocSectionState();
}

class _ListDocSectionState extends ConsumerState<ListDocSection> {
  late Future<List<dynamic>> _listDoc;

  List<Map<String, Object>> categorie = [];
  Set<String> specialitesUniques = {};

  @override
  void initState() {
    super.initState();
    _listDoc = widget.listDoc;

    // Catégorie init
    categorie.add({"type": "Tous", "choice": true});
  }

  @override
  Widget build(BuildContext context) {
    final listDocAsync = ref.watch(docAsyncProvider); 

    return Column(
      children: [
        listDocAsync.when(
          loading: () {
            print('Loading doc list ...');
            return Container(
              margin: EdgeInsets.only(top: 100),
              child: Center(
                child: CircularProgressIndicator()
              ),
            );
          },

          error: (err, state){
              if (err.toString().contains("unauthorized")) {
                Future.microtask(() {
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(builder: (_) => LoginMobile()),
                  );
                });
              }

              if(err.toString().contains("Null")){
                return Center(
                  child: EmptyStateWidget()
                );
              }

            return Text('Erreur de chargement');
          },

          data: (list_D) {

            final docList = list_D;
            print(docList[0]);
            // Ajouter les spécialités sans dupliquer
            for (var doc in docList) {
              final spec = (doc['speciality'] ?? doc['Speciality'])?.toString() ?? "";
              if (spec.isNotEmpty && !specialitesUniques.contains(spec)) {
                specialitesUniques.add(spec);
                categorie.add({"type": spec, "choice": false});
              }
            }

            return Column(
              children: [
                // ------------------------ FILTRE HORIZONTAL ------------------------
                SizedBox(
                  height: 35,
                  child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    itemCount: categorie.length,
                    itemBuilder: (context, index) {
                      return GestureDetector(
                        onTap: () {
                          setState(() {
                            for (int i = 0; i < categorie.length; i++) {
                              categorie[i]['choice'] = (i == index);
                            }
                          });
                        },
                        child: AnimatedContainer(
                          duration: Duration(milliseconds: 300),
                          margin: const EdgeInsets.symmetric(
                            vertical: 2.0, horizontal: 5.0
                          ),
                          padding: const EdgeInsets.symmetric(
                            vertical: 5, horizontal: 7
                          ),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(10),
                            color: categorie[index]['choice'] as bool
                                ? Color(0xFF548856)
                                : Colors.white,
                          ),
                          child: Center(
                            child: Text(
                              categorie[index]['type'].toString(),
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                letterSpacing: 2.0,
                                color: categorie[index]['choice'] as bool
                                    ? Colors.white
                                    : Colors.black87,
                              ),
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),
                const SizedBox(height: 15,),
                // ------------------------ LISTE DES DOCTEURS ------------------------
                ListView.builder(
                  itemCount: docList.length,
                  shrinkWrap: true,
                  physics: NeverScrollableScrollPhysics(),
                  itemBuilder: (contex, index) {
                    var doc = docList[index];

                    // Filtre actif
                    final activeFilter = categorie
                        .firstWhere((c) => c['choice'] == true)['type']
                        .toString();

                    // Filtrage
                    final specialty = (doc['speciality'] ?? doc['Speciality']).toString();

                    if (activeFilter != "Tous" && specialty != activeFilter) {
                      return SizedBox.shrink();
                    }

                    return GestureDetector(
                      onTap: () {
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (context) =>
                                InfoUser(data:[doc, _listDoc]),
                          ),
                        );
                      },
                      child: Container(
                        height: 120,
                        padding: EdgeInsets.symmetric(vertical: 15, horizontal: 15),
                        margin: EdgeInsets.symmetric(vertical: 10),
                        decoration: BoxDecoration(
                          color: const Color.fromARGB(255, 255, 255, 255),
                          borderRadius: BorderRadius.circular(30)
                        ),

                        child: Row(
                          children: [
                            SizedBox(
                              width: 80,
                              height: 80,
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
                                  '${doc["last_name"]} ${doc["first_name"]}',
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color: Colors.black87,
                                  ),
                                ),
                                SizedBox(height: 5),
                                Row(
                                  children: [
                                    Icon(Icons.add_chart_rounded,
                                        color: Color(0xFF548856),
                                        size: 15),
                                        const SizedBox(width: 3),
                                    Text(
                                      doc['speciality']??'',
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
                                    Icon(
                                      Icons.location_city_rounded,
                                      color: Color(0xFF548856),
                                      size: 15
                                    ),
                                    const SizedBox(width: 3),
                                    Text(
                                      doc['addressCabinet']??'',
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
                  },
                ),
              ],
            );
          },
        ),
      ],
    );
  }
}
