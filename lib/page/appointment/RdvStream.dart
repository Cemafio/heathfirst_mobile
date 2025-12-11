import 'package:flutter/material.dart';
import 'package:heathfirst_mobile/service/RdvStreamService.dart';
import 'package:heathfirst_mobile/service/data.dart';

class RendezvousStream extends StatefulWidget {
  // Future<List<dynamic>> listDemd ;
  // final Map<String, dynamic> user;
  RendezvousStream({super.key});

  @override
  State<RendezvousStream> createState() => _RdvPageState();
}

class _RdvPageState extends State<RendezvousStream> {
  late RdvStreamService _service;
  int? _loadingRdvId;
  bool _isLoaded = false;

  @override
  void initState() {
    super.initState();
    _service = RdvStreamService();
    _service.start();
  }

  @override
  void dispose() {
    _service.stop();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        title: const Text("Demande de consultation", style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: Color.fromARGB(171, 0, 0, 0),),),
      ),
      backgroundColor: Colors.white,
      body: SingleChildScrollView(
        child: SizedBox(
          height: MediaQuery.of(context).size.height - 280,
          child: StreamBuilder<List<dynamic>>(
            stream: _service.stream,
            builder: (context, snapshot) {
              if (!snapshot.hasData) {
                return Center(child: CircularProgressIndicator());
              }

              final rdvList = snapshot.data!;

              return ListView.builder(
                itemCount: rdvList.length,
                itemBuilder: (context, index) {
                  final rdv = rdvList[index];
                  final bool isLoading = _loadingRdvId == rdv['id'];

                  // print(rdv);

                  return Stack(
                          children: [
                            Container(
                              height: 190,
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
                                        image: NetworkImage("http://172.27.136.28:8000/images/photos/${rdv['patient']['photo']}"),
                                        fit: BoxFit.cover,
                                      ),
                                    ),
                                  ),
                                  Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      SizedBox(
                                        width: 200,
                                        child: Text(
                                          "${rdv['patient']['lastname']} ${rdv['patient']['firstname']}",
                                          style: const TextStyle(
                                            color: Color.fromARGB(171, 0, 0, 0),
                                            fontWeight: FontWeight.bold,
                                            fontSize: 15,
                                            letterSpacing: 3,
                                          ),
                                        ),
                                      ),

                                      const SizedBox(height: 10),
                                      Text("À - ${rdv['information']['hour']}H",
                                          style: TextStyle(
                                            color: Color.fromARGB(171, 63, 137, 72),
                                            fontSize: 15,
                                            fontWeight: FontWeight.bold,
                                            letterSpacing: 3,
                                          )),
                                      const SizedBox(height: 10),
                                      if (rdv['information']['symptome'] != null)
                                        SizedBox(
                                          width: 200,
                                          child: Text(
                                            "Symptome: - ${rdv['information']['symptome']}",
                                            style: const TextStyle(
                                              color: Color.fromARGB(171, 0, 0, 0),
                                              fontSize: 15,
                                              letterSpacing: 1,
                                            ),
                                          ),
                                        ),
                                        
                                    ],
                                  )
                                ]
                              )
                            ),
                            Positioned(
                              bottom: 15,
                              right: 20,
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.spaceAround,
                                children: [
                                  if (isLoading)
                                    Container(
                                      margin: const EdgeInsets.only(bottom: 10),
                                      height: 18,
                                      width: 18,
                                      child: const CircularProgressIndicator(strokeWidth: 3),
                                    ),


                                  if (rdv['status'] == 'pending' && !isLoading)
                                    TextButton(
                                      onPressed: () async {
                                        final doc = rdv['doctor'];
                                        final patient = rdv['patient'];

                                        setState(() {
                                          _loadingRdvId = rdv['id'];
                                        });

                                        await responseAppointment(rdv['id'], 'refused', patient['id'], doc['id']);
                                        await Future.delayed(const Duration(seconds: 6));

                                        setState(() {
                                          _loadingRdvId = null;
                                        });
                                      },
                                      child: const Text('refuser', style: TextStyle(color: Colors.red)),
                                    ),

                                  if (rdv['status'] == 'pending' && !isLoading)
                                    TextButton(
                                      onPressed: () async {
                                        final doc = rdv['doctor'];
                                        final patient = rdv['patient'];

                                        setState(() {
                                          _loadingRdvId = rdv['id'];
                                        });

                                        await responseAppointment(rdv['id'], 'accepted', patient['id'], doc['id']);
                                        await Future.delayed(const Duration(seconds: 5));

                                        setState(() {
                                          _loadingRdvId = null;
                                        });
                                      },
                                      child: const Text('accepter'),
                                    ),

                                  if (!isLoading && rdv['status'] != 'pending')
                                    Text(
                                      rdv['status'] == 'accepted' ? 'accepté' : 'refusé',
                                      style: TextStyle(
                                        color: rdv['status'] == 'accepted'
                                            ? Color.fromARGB(255, 170, 211, 172)
                                            : Color.fromARGB(255, 216, 178, 176),
                                      ),
                                    ),
                                  


                                  // if(rdv['status'] != 'pending' && _isLoaded == false)
 
                                  //   if(rdv['status'] == 'accepted')
                                  //     TextButton(
                                  //       onPressed: null,
                                  //       child: Text('accepté', style: const TextStyle(color: Color.fromARGB(255, 170, 211, 172)),),
                                  //     ),
                                  //   if(rdv['status'] == 'refused')
                                  //     TextButton(
                                  //       onPressed: null,
                                  //       child: Text('refusé', style: const TextStyle(color:  Color.fromARGB(255, 216, 178, 176)),),
                                  //     ),
                                ],
                              ),
                            )
                          ]);
                  // ListTile(
                  //   title: Text("Rendez-vous n°$index"),
                  //   subtitle: Text(rdv.toString()),
                  // );
                },
              );
            },
          ),
        )
      ),
    );
  }
}
