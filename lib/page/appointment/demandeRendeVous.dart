import 'dart:async';
// import 'dart:nativewrappers/_internal/vm/lib/core_patch.dart';
import 'package:flutter/material.dart';
import 'package:heathfirst_mobile/service/data.dart';

class RendezvousSection extends StatefulWidget {
  // Future<List<dynamic>> listDemd ;
  final Map<String, dynamic> user;
  RendezvousSection({super.key, required this.user});

  @override
  State<RendezvousSection> createState() => _RendezvousSectionState();
}

class _RendezvousSectionState extends State<RendezvousSection> {
  Future<List<dynamic>>? _list_demd;
  Map<String, dynamic> get _infoUser => widget.user;
  Map<int, Map<String, dynamic>> _usersProfil = {};
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _list_demd = _loadData();
  }

  void reloadRdv() {
    setState(() {
      _list_demd = _loadData();
    });
    print('reload rdv list');
  }

  Future<List<dynamic>> _loadData() async {
    try {
      final rdvList = await rdvUserData();
      final Map<int, Map<String, dynamic>> profils = {};

      for (var item in rdvList) {
        // ----------------------[Debug moi ca plus tard]--------------------------
        // Erreur lors du chargement des données : FormatException: Unexpected character (at character 80)
        // I/flutter (14908): ...c178a0f-6825b5fc67609280435486.jpg"}{"@id":"\/api\/errors","@type":"hydr...
        
        final patientId = item['patient']['id'] as int;
        final profil = await getProfilUser(patientId);
        profils[patientId] = profil;
      }

      setState(() {
        _usersProfil = profils;
        _loading = false;
      });
      return rdvList;
    } catch (e) {
      setState(() {
        _loading = false;
      });
      throw("Erreur lors du chargement des données : $e");
    }
  }


  Widget build(BuildContext context) {
    if (_loading) {
      return Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.white,
          title: const Text("Demande rendez-vous", style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: Color.fromARGB(171, 0, 0, 0),),),
        ),
        backgroundColor: Colors.white,
        body: 
          const Center(child: CircularProgressIndicator())
      ); 
    }
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        title: const Text("Appointment", style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: Color.fromARGB(171, 0, 0, 0),),),
      ),
      backgroundColor: Colors.white,
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  height: 90,
                  width: 90,

                  margin: const EdgeInsets.all(10),

                  decoration: BoxDecoration(
                    border: Border.all(
                      color: Colors.grey
                    ),
                    borderRadius: BorderRadius.circular(100),
                    image: DecorationImage(
                      image: NetworkImage('http://10.37.128.28:8000/images/photos/${_infoUser['photo_profil']}'),
                      fit: BoxFit.cover,
                    ),
                  ),
                ),

              ],
            ),
            Container(
              // width: 70,
              margin: const EdgeInsets.all(10),

              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                // mainAxisAlignment: MainAxisAlignment.center,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 250,
                    child: Text(
                      "Bonjour ${_infoUser['LastName']} ${_infoUser['FirstName']}", 
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: Color.fromARGB(171, 0, 0, 0),
                        fontWeight: FontWeight.bold,
                        fontSize: 20,
                        letterSpacing: 3
                      ),
                    ),
                  ),

                  const SizedBox(height: 30,),

                  Text(textAlign: TextAlign.center,"Tous vos demande de rendez-vous sont listé ci-dessous, veuilliez répondre.", 
                    style: TextStyle(
                      color: Color.fromARGB(171, 0, 0, 0),
                      fontSize: 15,
                      letterSpacing: 3
                    ),
                  ),
                ],) 
            ),

              const SizedBox(height: 30,),

              Container(
                height: MediaQuery.of(context).size.height - 280,
                margin: EdgeInsets.only(bottom: 10), // Définissez une hauteur appropriée
                child: FutureBuilder(
                  future: _list_demd,
                  builder: (context, snapshot) {

                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Center(child: CircularProgressIndicator());
                    }

                    if (snapshot.hasError) {
                      return Center(child: Text('Erreur : ${snapshot.error}'));
                    }

                    final demande = snapshot.data!;

                    if (demande.isEmpty) {
                      return const Center(
                        child: Column(
                          children: [
                            SizedBox(height: 200),
                            Icon(Icons.assignment_late, size: 70, color: Colors.grey),
                            SizedBox(width: 8),
                            Text('Aucun rendez-vous trouvé')
                          ],
                        ),
                      );
                    }

                    return ListView.builder(
                      itemCount: demande.length,
                      itemBuilder: (context, index) {
                        final demandeItem = demande[index]['patient'];
                        final userProfil = _usersProfil[demandeItem['id']];

                        return Stack(
                          children: [
                            Container(
                              height: 150,
                              margin: const EdgeInsets.all(10),
                              padding: const EdgeInsets.all(10),
                              decoration: BoxDecoration(
                                color: Color.fromARGB(255, 241, 241, 241),
                                borderRadius: BorderRadius.circular(15),
                                border: Border.all(color: Colors.black26)
                              ),
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Container(
                                    height: 60,
                                    width: 60,
                                    margin: const EdgeInsets.only(right: 10),
                                    decoration: BoxDecoration(
                                      border: Border.all(color: Colors.grey),
                                      borderRadius: BorderRadius.circular(100),
                                      image: DecorationImage(
                                        image: NetworkImage("http://10.37.128.28:8000/images/photos/${userProfil?['profil']}"),
                                        fit: BoxFit.cover,
                                      ),
                                    ),
                                  ),
                                  Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        "${demandeItem['lastname']} ${demandeItem['firstname']}",
                                        style: const TextStyle(
                                          color: Color.fromARGB(171, 0, 0, 0),
                                          fontWeight: FontWeight.bold,
                                          fontSize: 15,
                                          letterSpacing: 3,
                                        ),
                                      ),
                                      const SizedBox(height: 10),
                                      const Text("22 ans",
                                          style: TextStyle(
                                            color: Color.fromARGB(171, 0, 0, 0),
                                            fontSize: 15,
                                            letterSpacing: 3,
                                          )),
                                      const SizedBox(height: 10),
                                      if (demande[index]['information']['symptome'] != null)
                                        Text(
                                          "- ${demande[index]['information']['symptome']}",
                                          style: const TextStyle(
                                            color: Color.fromARGB(171, 0, 0, 0),
                                            fontSize: 15,
                                            letterSpacing: 1,
                                          ),
                                        ),
                                    ],
                                  )
                                ],
                              ),
                            ),
                            Positioned(
                              bottom: 10,
                              right: 20,
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.spaceAround,
                                children: [
                                  if(demande[index]['reponse'] == 'en attente')
                                    TextButton(
                                      onPressed: () async {
                                        final docId = demande[index]['doctor']['id'];
                                        final patientId = demande[index]['patient']['id'];
                                        final date = demande[index]['date']; 
                                        // print("${demande[index]['patient']['id']} et idDoc: ${demande[index]['doctor']['id']} et date: ${demande[index]['date']}");
                                        await responseAppointment(docId, patientId, 'refuser', date);
                                        reloadRdv();
                                      },
                                      child: const Text('refuser', style: TextStyle(color: Colors.red)),
                                    ),
                                  // if(demande[index]['reponse'] == 'en attente')
                                    // const SizedBox(width: 6),
                                  if(demande[index]['reponse'] == 'en attente')
                                    TextButton(
                                      onPressed: () async {
                                        final docId = demande[index]['doctor']['id'];
                                        final patientId = demande[index]['patient']['id'];
                                        final date = demande[index]['date']; 
                                        // print("${demande[index]['patient']['id']} et idDoc: ${demande[index]['doctor']['id']} et date: ${demande[index]['date']}");
                                        await responseAppointment(docId, patientId, 'accepter', date);
                                        reloadRdv();
                                      },
                                      child: const Text('accepter'),
                                    ),
                                  if(demande[index]['reponse'] != 'en attente')
                                    if(demande[index]['reponse'] == 'accepter')
                                      TextButton(
                                        onPressed: null,
                                        child: Text('accepté', style: const TextStyle(color: Color.fromARGB(255, 170, 211, 172)),),
                                      ),
                                    if(demande[index]['reponse'] == 'refuser')
                                      TextButton(
                                        onPressed: null,
                                        child: Text('refusé', style: const TextStyle(color:  Color.fromARGB(255, 216, 178, 176)),),
                                      ),
                                ],
                              ),
                            )
                          ],
                        );
                      },
                    );
                  },
                ),
                
              ),

            // if(_infoUser == null)
              
          ],
        ),
      ),
    );
  }

}