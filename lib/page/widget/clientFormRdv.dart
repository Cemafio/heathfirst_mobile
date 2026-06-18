import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:heathfirst_mobile/page/widget/MyTextFieldWidget.dart';
import 'package:heathfirst_mobile/page/widget/simple_btn.dart';
import 'package:heathfirst_mobile/provider/app_provider.dart';
import 'package:heathfirst_mobile/provider/rdvProvider.dart';
import 'package:heathfirst_mobile/provider/userProvider.dart';
import 'package:heathfirst_mobile/service/data.dart';
import 'package:intl/intl.dart';
import 'package:table_calendar/table_calendar.dart';

class ClientFormRdv extends ConsumerStatefulWidget {
  // final List<DateTime> dates;
  // final DateTime selectedDay;
  final Map<String, dynamic> docInfo;
  const ClientFormRdv({super.key, required this.docInfo});

  @override
  ConsumerState<ClientFormRdv> createState() => _ClientFormRdvState();
}

class _ClientFormRdvState extends ConsumerState<ClientFormRdv> {
  List<DateTime> dates = List.generate(
    30,
    (index) => DateTime.now().add(Duration(days: index)),
  );
  DateTime selectedDay = DateTime.now();
  String selectedTime = '';
  String errorTime = '';
  String symptome = '';
  bool isLoaded = false;
  
  final _formKey = GlobalKey<FormState>();

  void changeValueFunction (String value, String type) {
    setState(() {
      symptome = value;
    });
    print(symptome);
  }

  @override
  Widget build(BuildContext context) {
    final rdvAsync = ref.watch(rdvAsyncProvider);
    final userDataStat = ref.watch(userDataStatic);

    return Container(
      padding: EdgeInsets.all(20),
      width: MediaQuery.of(context).size.width,
      height: MediaQuery.of(context).size.height * 0.57,

      margin: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),

      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          Container(
            width: 40,
            height: 6,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(6),
              color: Colors.grey
            ),
          ),          
          const SizedBox(height: 20,),
          Row(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              Text(
                "${DateFormat('MMM', 'fr_FR').format((selectedDay))}, ${selectedDay.year}",
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),

          const SizedBox(height: 20,),
          SizedBox(
            width: double.infinity,
            height: 55,

            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: dates.length,
              itemBuilder: (context, index) {
            
                final date = dates[index];
                bool selected = isSameDay(date, selectedDay);

            
                return GestureDetector(
                  onTap: (){
                    setState(() {
                      selectedDay = date;
                    });
                  },
                  child: AnimatedContainer(
                    duration: Duration(milliseconds: 300),
                    curve: Curves.easeInOut,
                    alignment: Alignment.center,
                    width: 43,
                    margin: const EdgeInsets.symmetric(horizontal: 5),

                    decoration: BoxDecoration(
                      border: selected
                        ? Border.all(
                          color: Color(0xFF548856),
                          width: 2,
                        )
                        : null,
                      borderRadius: BorderRadius.circular(15)
                    ),
                                      
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                                      
                        Text(
                          DateFormat('EEE', 'fr_FR').format(date).split('.')[0].toUpperCase(),
                          style: TextStyle(
                            color: selected ? Color(0xFF548856): null,
                          ),
                        ),
                                      
                        Text(
                          '${date.day}',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: selected ? Color(0xFF548856): null
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
          
          const SizedBox(height: 30,),
          Row(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              Text(
                "heurs",
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),

              if(errorTime != '')...[
                const SizedBox(width: 10,),
                Text(
                  "($errorTime)",
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.red
                  ),
                ),
              ]
            ],
          ),

          const SizedBox(height: 20,),
          SizedBox(
            height: 30,
            child: rdvAsync.when(
              data: (rdv) {
                  final allHours = [
                    '08:00',
                    '08:30',
                    '09:00',
                    '09:30',
                    '10:00',
                    '10:30',
                    '11:00',
                    '11:30',
                    '14:00',
                    '14:30',
                    '15:00',
                    '15:30',
                    '16:00',
                  ];

                final bookedHours = rdv.map<String>((e) {
                  DateTime date = DateTime.parse(e['date']);
                  return '${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}';
                }).toList();

                final availableHours = allHours.where(
                  (hour) => !bookedHours.contains(hour),
                ).toList();

                return ListView.builder(
                  scrollDirection: Axis.horizontal,
                  itemCount: availableHours.length,

                  itemBuilder: (context, index) {
                    bool _selected = selectedTime == availableHours[index];

                    return GestureDetector(
                      onTap: (){
                        setState(() {
                          selectedTime = availableHours[index];
                        });
                        print(selectedTime);
                      },
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 300),
                        curve: Curves.easeInOut,
                      
                        alignment: Alignment.center,
                        width: 65,
                        margin: const EdgeInsets.symmetric(horizontal: 5),
                      
                        decoration: BoxDecoration(
                          border: _selected ? Border.all(
                            color: const Color(0xFF548856),
                            width: 1,
                          ):null,
                          borderRadius: BorderRadius.circular(15),
                        ),
                      
                        child: Text(
                          availableHours[index],
                          style: TextStyle(
                            fontSize: 18,
                            color: _selected ? Color(0xFF548856): null
                          ),
                        ),
                      ),
                    );
                  },
                );
              },

              error: (err, st) {
                return Text(err.toString());
              },

              loading: () => const Center(
                child: CircularProgressIndicator(),
              ),
            ),
          ),

          const SizedBox(height: 30,),
          Row(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              Text(
                "Symptome",
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),

          const SizedBox(height: 20,),
          Form(
            key: _formKey,
            child: Mytextfieldwidget(
              label: 'Symptome', 
              actionSaved: changeValueFunction
            )
          ),
          
          const SizedBox(height: 20,),
          SimpelBtn(
            isLoaded: isLoaded,
            
            action: () async {
              if(selectedTime == ''){
                setState(() {
                  errorTime = "Veuillier choisir l'heur s'il vous plais";
                });
              }else{
                setState(() {
                  errorTime = "";
                });
              }

              final isValide = _formKey.currentState!.validate();
              _formKey.currentState!.save();

              String date = "${selectedDay.year}-${selectedDay.month.toString().padLeft(2,'0')}-${selectedDay.day.toString().padLeft(2,'0')}";

              if(isValide){
                try {
                  setState(() {
                    isLoaded = true;
                  });

                  // print( " ${userDataStat.phone}");
                  await takeAppointmentSimple(nom: ref.read(userDataStatic).firstname!,prenom: ref.read(userDataStatic).lastname!,birthday:  ref.read(userDataStatic).date_naissance!,sexe:  ref.read(userDataStatic).sexe!,tel:  userDataStat.phone!,email:  ref.read(userDataStatic).email!,address:  userDataStat.adress!,city:  userDataStat.adress!,hour:  selectedTime,date:  date, symptome:  symptome,idDoctor: widget.docInfo['id'], baseUrl: ref.watch(baseUrl), token: ref.read(accessTokenProvider));

                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Rendez-vous envoyée')),
                  );

                  Navigator.pop(context, true);
                  setState(() {
                    symptome = '';
                    selectedTime = '';
                  });
                } catch (e) {
                  print(e);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Erreur : ${e.toString()}')),
                  );
                }finally{
                  setState(() {
                    isLoaded = false;
                  });
                }
              }

            }
          )
        ],
      ),
    );
  }
}