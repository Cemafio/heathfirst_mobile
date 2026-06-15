import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:heathfirst_mobile/provider/app_provider.dart';
import 'package:heathfirst_mobile/provider/days_no_work_provider.dart';
import 'package:heathfirst_mobile/provider/rdvProvider.dart';
import 'package:heathfirst_mobile/provider/userProvider.dart';
import 'package:heathfirst_mobile/service/data.dart';

class Callendarbottomform extends ConsumerStatefulWidget {
  final VoidCallback reload;
  final DateTime dayNow;
  final TextEditingController reasonControl;
  final bool isdaySelectedMarked ;

  const Callendarbottomform({super.key, required this.reload, required this.dayNow, required this.reasonControl, required this.isdaySelectedMarked});

  @override
  ConsumerState<Callendarbottomform> createState() => _CallendarbottomformState();
}

class _CallendarbottomformState extends ConsumerState<Callendarbottomform> {
  final _formKey = GlobalKey<FormState>();
  DateTime get dayNow => widget.dayNow;
  TextEditingController get _reasonController => widget.reasonControl;
  bool isLoaded = false;
  bool isLoadedDel = false;
  bool get isdaySelectedMarked => widget.isdaySelectedMarked;
  List<String> weekDays = ['Jan','Fév','Mar','Avr','Mai','Juin','Jul','Août','Sep','Oct','Nov','Déc'];
  String? _reason;

  @override
  Widget build(BuildContext context) {
    return Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: EdgeInsets.all(25),
              margin: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
              decoration: BoxDecoration(
                color: Color.fromARGB(255, 241, 241, 241),
                borderRadius: BorderRadius.circular(15),
                border: Border.all(color: Colors.black26)
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Container(
                    width: 40,
                    height: 6,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(6),
                      color: Colors.grey
                    ),
                  ),
                  const SizedBox(height: 30,),
                  Text("Ajout jour d'indisponibilité", style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, letterSpacing: 2, color: Colors.black45),),
                  const SizedBox(height: 10,),
                  Form(
                    key: _formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text("Le", style: TextStyle(fontSize: 15, color: Colors.black, ),),
                            const SizedBox(width: 6,),
                            Text("${dayNow.year} ${weekDays[dayNow.month - 1]} ${dayNow.day}", style: TextStyle(fontSize: 18, color: Colors.black54,fontWeight: FontWeight.bold),),
                          ]

                        ),
                        const SizedBox(height: 20,),
                        TextFormField(
                          controller: _reasonController,
                          decoration: const InputDecoration(
                            hintText: 'Raison',
                          ),
                          readOnly: (isdaySelectedMarked || isLoaded || isLoadedDel),
                          validator: (value){
                            if( value == null || value.trim().isEmpty){
                              return 'Veuillez entrer la raison';
                            }
                            return null;
                          },
                          onChanged: (val) {
                            setState(() => _reason = val);
                          },
                        ),
                      
                      ],
                    ),
                  ),
                  const SizedBox(height: 20,),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      TextButton(
                        onPressed: (_reason != null && _reason!.trim().isNotEmpty)
                          ? () async {
                              if (_formKey.currentState!.validate()) {
                                final startTime = DateTime.now();
                                setState(() {
                                  isLoaded = true; // arrêter le loading
                                });
                                try {
                                  await addDayNoWork(dayNow, _reason!.trim(), baseUrl: ref.read(baseUrl), token: ref.read(accessTokenProvider));
                                  print('Try to pop this showBox');
                                  ref.refresh(daysNoWorkAsync);
                                  ref.refresh(rdvAsyncProvider);
                                  Navigator.pop(context);
                                  // Calcul du temps écoulé
                                  final elapsed = DateTime.now().difference(startTime).inMilliseconds;
                                  if (elapsed < 2000) {
                                    await Future.delayed(Duration(milliseconds: 2000 - elapsed));
                                  }

                                  widget.reload();

                                } catch (e) {
                                  print("Erreur : $e");
                                }finally{
                                  setState(() {
                                    isLoaded = false; // arrêter le loading
                                  });
                                }
                              }
                            }
                          : null,

                        child: (isLoaded == true)
                        ? const SizedBox(
                              height: 12,
                              width: 12,
                              child: CircularProgressIndicator(
                                strokeWidth: 2.0,
                              ),
                          )
                        : const Text(
                          'Ajouter',
                          style: TextStyle(
                            fontSize: 12,
                          ),
                        )
                      ),

                      const SizedBox(width: 5,),
                      TextButton(
                        onPressed: isdaySelectedMarked
                        ? () async {
                            final startTime = DateTime.now();

                            setState(() {
                              isLoadedDel = true;
                            });
                            if (_formKey.currentState!.validate()) {
                              try {
                                await deleteDaysNoWork(ref.watch(userDataStatic).id!, dayNow, ref.watch(baseUrl), ref.watch(accessTokenProvider));
                                Navigator.pop(context);
                                
                                // Calcul du temps écoulé
                                final elapsed = DateTime.now().difference(startTime).inMilliseconds;
                                // Si moins de 2000ms écoulées → attendre le reste
                                if (elapsed < 2000){ 
                                  await Future.delayed(Duration(milliseconds: 2000 - elapsed));
                                }
                                print('--------- Supprimer ------');
                                
                                // _reloadDataCallendar();
                                widget.reload();


                              } catch (e) {
                                  print("Erreur : $e");
                              }finally{
                                setState(() {
                                  isLoadedDel = false;
                                });
                              }
                            }
                          }
                        : null,

                        child: 
                        (isLoadedDel == true)
                        ? const SizedBox(
                              height: 12,
                              width: 12,
                              child: CircularProgressIndicator(
                                strokeWidth: 2.0,
                              ),
                          )
                        :  Text(
                            'Suprimer',
                            style: TextStyle(
                              fontSize: 12,
                              color: isdaySelectedMarked? Colors.red : Color.fromARGB(255, 253, 190, 186)
                            ),
                          ),
                      ),
                        
                    ]
                  ),
                ],
              ),
            ),
          ],
        );
  }
}