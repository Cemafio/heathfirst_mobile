import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:heathfirst_mobile/service/data.dart';
import 'package:intl/intl.dart';

class TakeAppointment extends StatefulWidget {
  final Map<String, dynamic> docInfo;
  const TakeAppointment({super.key, required this.docInfo});

  @override
  State<TakeAppointment> createState() => _TakeAppointmentState();
}

class _TakeAppointmentState extends State<TakeAppointment> {
  Map<String, dynamic> get _docInfo => widget.docInfo;
  bool isLoaded = false;
  final _formKey = GlobalKey<FormState>();
  DateTime? _selectedDate;
  DateTime? _selectedDateRdv;
  final TextEditingController _dateController = TextEditingController();
  final TextEditingController _dateControllerRdv = TextEditingController();

  String _nom = '';
  String _prenom = '';
  String _photo = '';
  String _roles = 'ROLE_DOCTOR';
  String _tel = '';
  String _sexe = '';
  String _identifiant = '';
  String _pass = '';
  String _adress = '';
  String _date_de_naissance = '';
  String _date_de_rdv = '';
  String _city = '';

  String _symptome = '';
  String _timeSelected = '_ _ : _ _';
  String _time = '';


  Future<void> _selectDate(BuildContext context) async{
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime(2001, 1),
      firstDate: DateTime(1990),
      lastDate: DateTime.now(),
    );
    if (picked != null) {
      setState(() {
        _selectedDate = picked;
        _dateController.text = DateFormat('yyyy-MM-dd').format(picked); // format ISO
        _date_de_naissance =_dateController.text;
      });
    }
  }
    Future<void> _selectDateRdv(BuildContext context) async{
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime(DateTime.now().year, DateTime.now().month),
      firstDate: DateTime(2024),
      lastDate: DateTime(DateTime.now().year + 1, 12),
    );
    if (picked != null) {
      setState(() {
        _selectedDateRdv = picked;
        _dateControllerRdv.text = DateFormat('yyyy-MM-dd').format(picked); // format ISO
        _date_de_rdv =_dateController.text;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      resizeToAvoidBottomInset: true,

      body: SingleChildScrollView(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            // const SizedBox(height: 60),
            
            const SizedBox(height: 80),
            Container(
              padding: EdgeInsets.symmetric(horizontal: 50.w),
              child: Form(
                key: _formKey,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: <Widget>[
                    TextFormField(
                      decoration: InputDecoration(
                        labelText: 'Nom',
                        prefixIcon: Icon(Icons.account_circle),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Veuillez entrer votre nom';
                        }
                        return null;
                      },
                      onSaved: (newValue) => _nom = newValue!,
                    ),
                    const SizedBox(height: 30),
                    TextFormField(
                      decoration: InputDecoration(
                        labelText: 'Prenom',
                        prefixIcon: Icon(Icons.account_box),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Veuillez entrer votre prenom';
                        }
                        return null;
                      },
                      onSaved: (newValue) => _prenom = newValue!,
                    ),
                    const SizedBox(height: 30),
                    DropdownButtonFormField(
                      decoration: const InputDecoration(
                        labelText: 'Sexe',
                        prefixIcon: Icon(Icons.wc),
                      ),
                      items: ['Homme', 'Femme']
                        .map((label) => DropdownMenuItem(
                          value: label,
                          child: Text(label),
                        ))
                        .toList(), 
                      
                      onChanged: (value){
                        setState(() {
                          _sexe = value!;
                        });
                      },
                      validator: (value) => value == null ? 'Veuillez sélectionner une option' : null,
                      onSaved: (newValue) {
                        _sexe = newValue!;
                      },
                    ),
                    const SizedBox(height: 30),
                    TextFormField(
                      decoration: const InputDecoration(
                        labelText: 'Mail',
                        prefixIcon: Icon(Icons.email),
                      ),
                      keyboardType: TextInputType.emailAddress,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Veuillez entrer votre email';
                        }
                        return null;
                      },
                      onSaved: (newValue) => _identifiant = newValue!,
                    ),
                    const SizedBox(height: 30),
                    TextFormField(
                      decoration: const InputDecoration(
                        labelText: 'Numero de télephone',
                        prefixIcon: Icon(Icons.phone_android_outlined),
                      ),
                      keyboardType: TextInputType.phone,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Veuillez entrer votre numero de télephone';
                        }
                        return null;
                      },
                      onSaved: (newValue) => _tel = newValue!,
                    ),


                    const SizedBox(height: 30),
                    TextFormField(
                      decoration: InputDecoration(
                        labelText: 'Votre adresse',
                        prefixIcon: Icon(Icons.location_on_outlined),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Veuillez entrer votre adresse';
                        }
                        return null;
                      },
                      onSaved: (newValue) => _adress = newValue!,
                    ),
                    const SizedBox(height: 30),
                    DropdownButtonFormField(
                      decoration: const InputDecoration(
                        labelText: 'Ville',
                        prefixIcon: Icon(Icons.wc),
                      ),
                      items: ['Madagascar', 'France']
                        .map((label) => DropdownMenuItem(
                          value: label,
                          child: Text(label),
                        ))
                        .toList(), 
                      
                      onChanged: (value){
                        setState(() {
                          _city = value!;
                        });
                      },
                      validator: (value) => value == null ? 'Veuillez sélectionner une option' : null,
                      onSaved: (newValue) {
                        _city = newValue!;
                      },
                    ),
                    const SizedBox(height: 30),
                    TextFormField(
                      controller: _dateController,
                      decoration: InputDecoration(
                        labelText: 'Date de naissance',
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
                    const SizedBox(height: 40),
                    Container(
                      width: double.infinity,
                      child: Row(
                        children: [
                          Icon(Icons.calendar_month_rounded, color: const Color.fromARGB(255, 62, 119, 85),),
                          const SizedBox(width: 15,),
                          Text('Information important', style: TextStyle(
                            fontSize: 16,

                          ),),
                        ],
                      ),
                    ),
                    const SizedBox(height: 20),

                    TextFormField(
                      decoration: InputDecoration(
                        labelText: 'Symptôme',
                        prefixIcon: Icon(Icons.healing),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Veuillez entrer votre Symptôme';
                        }
                        return null;
                      },
                      onSaved: (newValue) => _symptome = newValue!,
                    ),
                    const SizedBox(height: 20),
                    TextFormField(
                      controller: _dateControllerRdv,
                      decoration: InputDecoration(
                        labelText: 'Date de rendez-vous',
                        prefixIcon: Icon(Icons.calendar_today),
                        border: OutlineInputBorder(),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Veuillez entrer votre date de rendez-vous';
                        }
                        return null;
                      },
                      readOnly: true,
                      onTap: () => _selectDateRdv(context),
                    ),
                    const SizedBox(height: 20),
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
                    
                    const SizedBox(height: 80),
                    Material(
                      color: Colors.transparent,
                      child: InkWell(
                        onTap: () async {
                          // Action
                          final isValide = _formKey.currentState!.validate();
                          if (isValide) {
                            // Save data in texFormField
                            _formKey.currentState!.save();
                            
                            // Call function future
                            try {
                              setState(() {
                                isLoaded = true;
                              });

                              print( " $_nom,$_prenom, $_date_de_naissance,$_sexe, $_tel,$_identifiant, $_adress, $_symptome,$_date_de_rdv, $_time");
                              await takeAppointmentSimple(nom: _nom,prenom: _prenom,birthday:  _date_de_naissance,sexe:  _sexe,tel:  _tel,email:  _identifiant,address:  _adress,city:  _city,hour:  _time,date:  _date_de_rdv,symptome:  _symptome,idDoctor:  _docInfo['id']);

                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(content: Text('Rendez-vous envoyée')),
                              );
                              Navigator.pop(context, true);
                              // Redirection ou autre
                            } catch (e) {
                              setState(() {
                                isLoaded = false;
                              });

                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(content: Text('Erreur : ${e.toString()}')),
                              );
                            }finally{
                              setState(() {
                                isLoaded = false;
                              });

                            }
                          }
                        },

                        borderRadius: BorderRadius.circular(10),
                        child: Container(
                          padding: const EdgeInsets.symmetric(vertical: 15),
                          margin:const EdgeInsets.only(bottom: 30),
                          decoration: BoxDecoration(
                            border: Border.all(color: Color(0xFF548856), width: 2),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child:  Center(
                            child: 
                              (isLoaded != true) 
                              ?Text(
                                "Envoyé rendez-vous",
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: Color(0xFF548856),
                                ),
                              )
                              : const SizedBox(
                                  height: 20,
                                  width: 20,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 3.0,
                                  ),
                                ),
                            ),
                          ),
                        ),
                      )
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      );
  }
}