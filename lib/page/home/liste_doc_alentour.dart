import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:heathfirst_mobile/page/login/login.dart';
import 'package:heathfirst_mobile/page/profile/InfoUser.dart';
import 'package:http/http.dart' as http;
import 'package:heathfirst_mobile/service/data.dart';

class ListDocSection extends StatefulWidget {
  final Future<List<dynamic>> listDoc;
  final Map<String, dynamic> user;

  ListDocSection({
    super.key,
    required this.listDoc,
    required this.user,
  });

  @override
  State<ListDocSection> createState() => _ListDocSectionState();
}

class _ListDocSectionState extends State<ListDocSection> {
  late Future<List<dynamic>> _listDoc;
  late Map<String, dynamic> _infoUser;

  List<Map<String, Object>> categorie = [];
  Set<String> specialitesUniques = {};

  @override
  void initState() {
    super.initState();
    _listDoc = widget.listDoc;
    _infoUser = widget.user;

    // Catégorie init
    categorie.add({"type": "Tous", "choice": true});
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        FutureBuilder(
          future: _listDoc,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return Container(
                margin: EdgeInsets.only(top: 100),
                child: Center(child: CircularProgressIndicator()),
              );
            }

            if (snapshot.hasError) {
              if (snapshot.error.toString().contains("unauthorized")) {
                Future.microtask(() {
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(builder: (_) => LoginMobile()),
                  );
                });
              }
              return Center(child: Text("Erreur : ${snapshot.error}"));
            }

            final docList = snapshot.data!;

            // Ajouter les spécialités sans dupliquer
            for (var doc in docList) {
              final spec = (doc['specialty'] ?? doc['Specialty'])?.toString() ?? "";
              if (spec.isNotEmpty && !specialitesUniques.contains(spec)) {
                specialitesUniques.add(spec);
                categorie.add({"type": spec, "choice": false});
              }
            }

            return Column(
              children: [
                // ------------------------ FILTRE HORIZONTAL ------------------------
                SizedBox(
                  height: 35, // <---- FIX du bug !
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
                              vertical: 2.0, horizontal: 5.0),
                          padding: const EdgeInsets.symmetric(
                              vertical: 5, horizontal: 7),
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
                    final specialty =
                        (doc['specialty'] ?? doc['Specialty']).toString();

                    if (activeFilter != "Tous" && specialty != activeFilter) {
                      return SizedBox.shrink();
                    }

                    return GestureDetector(
                      onTap: () {
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (context) =>
                                InfoUser(data:[doc, _infoUser, _listDoc]),
                          ),
                        );
                      },
                      child: Container(
                        height: 120,
                        margin: EdgeInsets.only(bottom: 10),
                        padding: EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(15),
                          color: Colors.white,
                        ),
                        child: Row(
                          children: [
                            Container(
                              width: 80,
                              height: 80,
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(50),
                                child: Image.network(
                                  "http://172.27.136.28:8000/images/photos/${doc['photoProfil']}",
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
                                  '${doc["LastName"]} ${doc["FirstName"]}',
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
                                      doc['specialty'],
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
                                      doc['AddressCabinet'],
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
