import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:heathfirst_mobile/service/data.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';


class EditprofilDoc extends StatefulWidget {
  Map<String, dynamic> infoUser;
  EditprofilDoc({super.key, required this.infoUser});

  @override 
  State<EditprofilDoc> createState() => _EditprofilDocState();
}

class _EditprofilDocState extends State<EditprofilDoc> {
  final _formKey = GlobalKey<FormState>();
  DateTime? _selectedDate;
  File? _selectedImage;
  String? _networkImageUrl;
  Map<String, dynamic> get _infoUser => widget.infoUser;

  final TextEditingController _dateController = TextEditingController();
  TextEditingController _nameController = TextEditingController();
  TextEditingController _firstNameController = TextEditingController();
  TextEditingController _emailController = TextEditingController();
  TextEditingController _numController = TextEditingController();
  TextEditingController _specialityController = TextEditingController();
  TextEditingController _adrCabinetController = TextEditingController();
  // TextEditingController _medocController = TextEditingController();
  // TextEditingController _passController = TextEditingController();
  TextEditingController _adrController = TextEditingController();

  String _nom = '';
  String _prenom = '';
  String _photo = '';
  String _roles = 'ROLE_DOCTOR';
  String _tel = '';
  String _sexe = 'Homme';
  String _identifiant = '';
  String _pass = '';
  String _adress = '';
  String _adress_cabinet = '';
  String _date_de_naissance = '';
  String _speciality = '';

  bool isLoaded = false;


  Future<void> _selectDate(BuildContext context) async{
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime(2000, 1),
      firstDate: DateTime(1900),
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

  Future<void> _pickImage() async {
    final ImagePicker picker = ImagePicker();
    final XFile? image = await picker.pickImage(source: ImageSource.gallery);

    if (image != null) {
      setState(() {
        _selectedImage = File(image.path);
        _photo = image.path;
      });
    }
  }
  @override
  void initState () {
    super.initState();
    _setInitialValue();
    print(_infoUser);

  }
  void _setInitialValue () {
    // {@context: /api/contexts/Patient, @id: /api/patients/18, @type: Patient, HistoryMedical: xjfu, allergy: fju, MedicationInProgress: cju, id: 18, email: itadori@gmail.com, roles: [ROLE_PATIENT], LastName: ITADORY , FirstName: Yuji , DateOfBird: 2000-01-31T00:00:00+00:00, photo_profil: 1001354998-682da7e4e561f536585918.jpg, Address: Jdu 135, phone: 1468634863}

    _nameController.text = _infoUser['LastName']; 
    _firstNameController.text = _infoUser['FirstName'];
    _emailController.text = _infoUser['email'];
    _adrController.text = _infoUser['Address'];
    _numController.text  = _infoUser['phone'];
    _dateController.text = _infoUser['DateOfBird'];
    _specialityController.text = _infoUser['Specialty'];
    _adrCabinetController.text = _infoUser['AddressCabinet'];
    _networkImageUrl = "http://10.37.128.28:8000/images/photos/${_infoUser['photo_profil']}";
    _photo = _infoUser['photo_profil'];
  }

  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
          backgroundColor: Colors.white,
          title: const Text("Modification", style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: Color.fromARGB(171, 0, 0, 0),),),
      ),
      body: SingleChildScrollView(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            
            const SizedBox(height: 80),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                GestureDetector(
                  onTap: _pickImage,
                  child: _selectedImage != null
                      ? ClipOval(child:Image.file(_selectedImage!, width: 100, height: 100, fit: BoxFit.cover))
                      : (_networkImageUrl != null)
                        ? ClipOval(child: Image.network(_networkImageUrl!,width: 100,height: 100,fit: BoxFit.cover))
                        
                        : Container(
                          width: 100,
                          height: 100,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.all(Radius.circular(50.w)),
                            color: Colors.grey[300],
                          ),
  
                          child: const Icon(Icons.camera_alt),
                        ),
                ),
                const SizedBox(height: 10),
                const Text('Photo de profil'),
              ],
            ),
            const SizedBox(height: 30,),
            Container(
              padding: EdgeInsets.symmetric(horizontal: 50.w),
              child: Form(
                key: _formKey,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: <Widget>[
                    TextFormField(
                      controller: _nameController,
                      decoration: const InputDecoration(
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
                      controller: _firstNameController,
                      decoration: const InputDecoration(
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
                      value: _sexe,
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
                      controller: _emailController,
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
                      controller: _numController,
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
                      controller: _adrController,
                      decoration: const InputDecoration(
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
                    TextFormField(
                      controller: _adrCabinetController,
                      decoration: InputDecoration(
                        labelText: 'Votre adresse de cabinet',
                        prefixIcon: Icon(Icons.location_on_outlined),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Veuillez entrer votre adresse de cabinet';
                        }
                        return null;
                      },
                      onSaved: (newValue) => _adress_cabinet = newValue!,
                    ),
                    const SizedBox(height: 30),
                    TextFormField(
                      controller: _specialityController,
                      decoration: const InputDecoration(
                        labelText: 'Votre Specialiter',
                        prefixIcon: Icon(Icons.folder_special_outlined),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Veuillez entrer votre specialité';
                        }
                        return null;
                      },
                      onSaved: (newValue) => _speciality = newValue!,
                    ),
                    const SizedBox(height: 30),
                    TextFormField(
                      controller: _dateController,
                      decoration: const InputDecoration(
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
                    const SizedBox(height: 80),
                    Material(
                      color: Colors.transparent,
                      child: InkWell(
                        onTap: () async {
                          final isValide = _formKey.currentState!.validate();
                          setState(() {
                            isLoaded = true;
                          });

                          if (isValide) {
                            _formKey.currentState!.save();
                            try {
                              // print("Donner envoyer: ${_infoUser['id']},$_nom,$_prenom, $_date_de_naissance, $_photo, $_sexe, $_tel, $_identifiant, $_adress,$_speciality, $_adress_cabinet");
                              await editProfilDoc( _infoUser['id'],_nom,_prenom, _date_de_naissance, _photo, _sexe, _tel,_identifiant, _adress,_speciality, _adress_cabinet,'doctor');
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(content: Text('Profil mis à jour !')),
                              );
                            } catch (e) {
                            //   ScaffoldMessenger.of(context).showSnackBar(
                            //     SnackBar(content: Text('Erreur : ${e.toString()}...... (O_o)')),
                            //   );
                            }finally{
                              setState(() {
                                isLoaded = false;
                              });
                              Navigator.pop(context, true);
                            }
                          }
                        },

                        child: Container(
                          padding: const EdgeInsets.symmetric(vertical: 15),
                          margin:const EdgeInsets.only(bottom: 30),
                          decoration: BoxDecoration(
                            border: Border.all(color: Color(0xFF548856), width: 2),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Center(
                            child:
                            (isLoaded != true) 
                            ?const Text(
                              "Enregistrer",
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
                            )
                          ),
                        ),
                      ),
                    ),
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