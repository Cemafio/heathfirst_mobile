import 'dart:async';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:heathfirst_mobile/page/login/login.dart';
import 'package:heathfirst_mobile/page/map/googlemap.dart';
import 'package:heathfirst_mobile/service/data.dart';
import 'package:intl/intl.dart';
import 'package:table_calendar/table_calendar.dart';


class InfoUser extends StatefulWidget {
  final List<dynamic> data;

  const InfoUser({super.key, required this.data});

  @override
  State<InfoUser> createState() => _InfoUserState();
}

class _InfoUserState extends State<InfoUser> {

  final _formKey = GlobalKey<FormState>();
  Map<String, dynamic> get _apropos => widget.data[0];
  Map<String, dynamic> get _infoUser => widget.data[1]; 
  Future<List<dynamic>> get _listDoc => widget.data[2];

  DateTime dayNow = DateTime.now();
  int justDay = DateTime.now().day;
  int justMonth = DateTime.now().month;
  final Future<List<dynamic>> _listDemd = rdvUserData();
  DateTime? _selectedDate;
  String _time = '';
  String _symptome = '';
  bool isWaiting = false;
  late Future<Map<String,dynamic>> _etatRdv ;
  
  @override
  void initState(){
    super.initState();
    _etatRdv = verrifAppointment(_apropos['id'], _infoUser['id']);
  }
  
  Future<void> _resetAppointmentVerrif() async {
      setState(() {
        _etatRdv = verrifAppointment(_apropos['id'], _infoUser['id']);
      });
  }
  void sendRdv() async{
    await takeAppointment(_apropos['id'], _symptome, _selectedDate!, _time, _apropos['id'], _infoUser['id']);
    Navigator.pop(context);
  }

  Future popUp () => showDialog(
    context: context,
    builder: (context) {
          
      final TextEditingController _dateController = TextEditingController();
      final TextEditingController _symptomeController = TextEditingController();
      String _timeSelected = '_ _ : _ _';
      bool isLoaded = false;

      void resetForm() {
        _formKey.currentState?.reset();
        _dateController.clear();
        _symptomeController.clear();
      }

      Future<void> _selectDate(BuildContext context) async{
        final DateTime? picked = await showDatePicker(
          context: context,
          initialDate: DateTime.now(),
          firstDate: DateTime.now(),
          lastDate: DateTime(2026),
        );
        if (picked != null) {
          setState(() {
            _selectedDate = picked;
            _dateController.text = DateFormat('yyyy-MM-dd').format(picked); // format ISO
            // _date_de_naissance =_dateController.text;
          });
        }
      }

      return StatefulBuilder(
        builder: (context, setState){
          return AlertDialog(
            title: const Center(child:  Text("Formulaire a remplir", style: TextStyle(fontSize: 16),)),
            content: Container(
              height: 260,
              width: 300,

              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    const SizedBox(height: 10,),
                    TextFormField(
                      controller: _dateController,
                      decoration:const InputDecoration(
                        labelText: 'Jours de rendez-vous',
                          prefixIcon: Icon(Icons.calendar_today),
                        border: OutlineInputBorder(),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Veuillez entrer votre date de naissance';
                        }
                        return null;
                      },
                        readOnly: true,
                        onTap: () => _selectDate(context),
                      ),  
                    const SizedBox(height: 10,),
                    TextFormField(
                      controller: _symptomeController,
                      decoration: const InputDecoration(
                        labelText: "Symptôme",
                        border: OutlineInputBorder(),
                      ),
                      keyboardType: TextInputType.multiline,
                      maxLines: 3,
                      minLines: 1,
                      textAlignVertical: TextAlignVertical.top,
                      validator: (value) {
                        if(value == null || value.isEmpty){
                          return 'Veulliez entrer le symptome que vous avez';
                        }
                        return null;
                      },
                      onChanged: (newValue) => _symptome = newValue,
                    ),
                    const SizedBox(height: 10,),
                    MaterialButton(
                      onPressed: () {
                        showTimePicker(
                          context: context, 
                          initialTime:TimeOfDay.now()
                        ).then((onValue) {
                          setState((){
                            _timeSelected = onValue!.format(context).toString();
                            _time = onValue.format(context).toString();
                          });
                        });
                      },
                      child: Container(
                        width: 100,
                        padding: const EdgeInsets.all(6),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(6),
                          border: Border.all()
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: [
                            const Icon(Icons.access_time_outlined),
                            const SizedBox(width: 6,),
                            Text(_timeSelected)
                          ],
                        ),
                      ), 
                    ),
                    const SizedBox(height: 15,),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        TextButton(
                          onPressed: () async{
                            setState(() {
                              isLoaded = true;
                            },);

                            print("📤 Donner envoyer ${_apropos['id']} ,$_symptome, $_selectedDate , $_time ");
                            try {
                              sendRdv();
                              _resetAppointmentVerrif();
                              setState(() {
                                _timeSelected = '_ _ : _ _';
                              });
                            } catch (e) {
                              
                              setState(() {
                                isLoaded = true;
                              },);
                              print("$e");

                            }finally{
                              setState(() {
                                isLoaded = false;
                              },);
                              resetForm();
                            }

                          }, 
                          child: Text('confirmé')
                        )
                      ],
                    ),

                  ]
                )
              ),
            ),
          );
        }
      );
      
    } 
  );

  Future<void> _navigation(Widget materialPage) async {
    final opened = await Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => materialPage),
    );

    if (opened == true) {
      setState(() {
        // _infoUser = userInfo();
      });
    }
  }
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color.fromARGB(255, 241, 241, 241),
      appBar: AppBar(
        backgroundColor: Colors.white,
        title: const Text("Apropos", style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: Color.fromARGB(171, 0, 0, 0),),),
      ),

      // 🔒 Bouton fixé en bas
      bottomNavigationBar: 
     
          FutureBuilder(
            future: _etatRdv, 
            builder: (context, snapshot){
              if (snapshot.connectionState == ConnectionState.waiting) {
                return Container(
                  width: double.infinity,
                  child: Center(child:const CircularProgressIndicator(strokeWidth: 3.0,)));
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
                return Center(child: Text('Erreur : ${snapshot.error}'));
              }
              
              final Map<String, dynamic> _etaRdv = snapshot.data!;
              
              return Padding(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
                child: InkWell(
                  onTap: () {
                    // Action lors du clic
                    if(!_etaRdv['existe']){
                      popUp();
                    }

                  },
                  child:
                    (_etaRdv['existe'] == false)
                    ? Container(
                        height: 60,
                        width: double.infinity,
                        decoration: BoxDecoration(
                          border: Border.all(color: Color(0xFF548856), width: 2),
                          borderRadius: BorderRadius.circular(20),
                          color: const Color.fromARGB(0, 224, 224, 224),
                        ),
                        child: const Center(
                          child: Text(
                            "Prendre rendez-vous",
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF548856),
                            ),
                          ),
                        ),
                      )
                    : (_etaRdv['response'] == 'accepted') 
                      ? Container(
                          height: 60,
                          width: double.infinity,
                          decoration: BoxDecoration(
                            border: Border.all(color: Color.fromARGB(0, 101, 109, 101), width: 2),
                            borderRadius: BorderRadius.circular(20),
                            color: const Color.fromARGB(0, 224, 224, 224),
                          ),
                          child: const Center(
                            child: Text(
                              "Appointment accepted",
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: Color.fromARGB(255, 124, 233, 128)
                              ),
                            ),
                          ),
                        )
                      : (_etaRdv['response'] == 'refused')
                        ? Container(
                            height: 60,
                            width: double.infinity,
                            decoration: BoxDecoration(
                              border: Border.all(color: Color.fromARGB(0, 101, 109, 101), width: 2),
                              borderRadius: BorderRadius.circular(20),
                              color: const Color.fromARGB(0, 224, 224, 224),
                            ),
                            child: const Center(
                              child: Text(
                                "Appointment refused",
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: Color.fromARGB(124, 212, 129, 129),
                                ),
                              ),
                            ),
                          )
                        : Container(
                            height: 60,
                            width: double.infinity,
                            decoration: BoxDecoration(
                              border: Border.all(color: Color.fromARGB(0, 101, 109, 101), width: 2),
                              borderRadius: BorderRadius.circular(20),
                              color: const Color.fromARGB(0, 224, 224, 224),
                            ),
                            child: const Center(
                              child: Text(
                                "Appointment pending",
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: Color.fromARGB(123, 106, 106, 106),
                                ),
                              ),
                            ),
                          )
                  ),
                );
            }
          ), 
          

      body: SingleChildScrollView(
        scrollDirection: Axis.vertical,

        child: Column(
          children: [
              Stack(
                clipBehavior: Clip.none,

                children: [
                  Container(
                    width: double.infinity,
                    height: 200,
                    decoration: const BoxDecoration(
                      borderRadius: BorderRadius.only(bottomLeft: Radius.circular(50), bottomRight: Radius.circular(50)),
                      color: Colors.white,
                    ),

                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                    
                      children: [
                        Container(
                          height: 50,
                          child: Column(
                            children: [
                              Text("1000+", style: TextStyle(fontWeight: FontWeight.bold, color: Colors.green)),
                              Text("patient"),
                            ],
                          ),
                        ),
                        Container(
                          height: 50,
                          child: Column(
                            children: [
                              Text("5ans", style: TextStyle(fontWeight: FontWeight.bold, color: Colors.green),),
                              Text("experience"),
                            ],
                          ),
                        ),
                        Container(
                          height: 50,
                          child: Column(
                            children: [
                              Text("9.000ar", style: TextStyle(fontWeight: FontWeight.bold, color: Colors.green),),
                              Text("Consultation"),
                            ],
                          ),
                        ),
                        
                      ],
                    ),
                  ),
                  Positioned(
                    bottom: -70,
                    left: 130,
                    child: Container(
                      width: 130,
                      height: 130,
                      margin: const EdgeInsets.only(bottom: 5),

                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(100),
                        border: Border.all(
                          width: sqrt1_2,
                          color: const Color(0xFF81C784),
                        ),
                          image: DecorationImage(
                            image: NetworkImage("http://172.27.136.28:8000/images/photos/${_apropos['photoProfil']}"),
                            fit: BoxFit.cover,
                          ),
                      ),
                    ),
                  ),

                ]
              ),
              const SizedBox(height: 80,),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    '${_apropos['lastName']} ${_apropos['firstName']}',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 2.0
                    ),
                  ),
              ],),
              Column(
                children: [
                  Container(
                    width: double.infinity,
                    margin: EdgeInsets.all(10),
                    padding: EdgeInsets.all(15),
                    // height: 300,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.all(Radius.circular(10))
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text("Information",
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.normal,
                            letterSpacing: 2.0
                          )
                        ),
                        const SizedBox(height: 20,),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                          Text("Specialisation"),
                          Text("${_apropos['specialty']}", style: TextStyle(fontWeight: FontWeight.bold),)
                        ],),
                        const SizedBox(height: 7,),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                          Text("Adress"),
                          Text("${_apropos['Address']}", style: TextStyle(fontWeight: FontWeight.bold),)
                        ],),
                        const SizedBox(height: 7,),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                          Text("Adess cabinet"),
                          Text("${_apropos['AddressCabinet']}", style: TextStyle(fontWeight: FontWeight.bold),)
                        ],),
                        const SizedBox(height: 7,),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                          Text("Numero de téléphone"),
                          Text("${_apropos['phone']}", style: TextStyle(fontWeight: FontWeight.bold),)
                        ],),
                        const SizedBox(height: 7,),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                          Text("email"),
                          Text("${_apropos['email']}", style: TextStyle(fontWeight: FontWeight.bold),)
                        ],),
                    ],),
                  ),

                   Container(
                    width: double.infinity,
                    margin: EdgeInsets.all(10),
                    padding: EdgeInsets.all(10),
                    // height: 300,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.all(Radius.circular(10)),
                      // border: Border.all()
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Container(
                          height: 100.w,
                          width: 100.w,

                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.all(Radius.circular(10)),
                            image: DecorationImage(
                              image: AssetImage("assets/images/map_img.jpg"),
                              fit: BoxFit.cover,
                            ),
                          ),
                        ),
                        const SizedBox(width: 10,),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Text('Localisation du cabinet'),
                            Text('Analakely - ${_apropos['AddressCabinet']}'),
                          ],
                        ),
                        const SizedBox(width: 10,),
                        GestureDetector(
                          onTap: (){
                            _navigation(GoogleMapPage(allDoc: [_listDoc, _apropos['lastName']]));
                          },
                          child: Container(
                            width: 40,
                            height: 40,
                            decoration: BoxDecoration(
                              // color: const Color.fromARGB(255, 241, 241, 241),
                              borderRadius: BorderRadius.circular(25),
                              border: Border.all(color: Colors.black26)
                            ),

                            child: Center(child: Icon(Icons.location_searching_sharp),),
                          ),
                        ),
                    ])
                  )
                ],

              )
            ]) 
        ),
    ); 
      
  }
}