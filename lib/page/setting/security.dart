import 'package:flutter/material.dart';

class SecurityPage extends StatefulWidget {
  const SecurityPage({super.key});

  @override
  State<SecurityPage> createState() => _SecurityPageState();
}

class _SecurityPageState extends State<SecurityPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Security',style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold, letterSpacing: 2.0),),
        backgroundColor: Colors.white,
      ),
      body: Column(
        children: [
          Container(
            margin: const EdgeInsets.only(left: 20,right: 20,top: 10,),
            padding: EdgeInsets.only(left: 10),
            height: 55,

            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: Colors.black26)
            ),

            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                GestureDetector(
                  onTap: (){
                    // Widget route = ;
                    // _navigation(route);
                  },
                  child: Container(
                    width: double.infinity,
                    height: 50,

                    decoration: const BoxDecoration(
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [ 
                        Container(
                          width: 200,
                          decoration:const BoxDecoration(
                            // border: Border.all()
                          ),
                          child: const Row(children: [
                            Icon(Icons.password),
                            SizedBox(width: 25,),
                            Text("Edit password")
                          ],),
                        ),
                        const SizedBox(width: 25,),
                        Container(
                          padding: const EdgeInsets.all(10),
                          // margin: const EdgeInsets.only(bottom: 5),

                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(20),
                            color: Color.fromARGB(0, 255, 255, 255),
                          ),

                          child: const Icon(Icons.arrow_forward_ios_rounded, color: Colors.black45,),
                        ), 
                    ]),
                  ), 
                  
                ),
              ]
            ),
          ),
          Container(
            margin: const EdgeInsets.only(left: 20,right: 20,top: 10,),
            padding: EdgeInsets.only(left: 10),
            height: 55,

            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: Colors.black26)
            ),

            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                GestureDetector(
                  onTap: (){
                    // Widget route = ;
                    // _navigation(route);
                  },
                  child: Container(
                    width: double.infinity,
                    height: 50,

                    decoration: const BoxDecoration(
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [ 
                        Container(
                          width: 200,
                          decoration:const BoxDecoration(
                            // border: Border.all()
                          ),
                          child: const Row(children: [
                            
                              const Icon(Icons.delete, color: Colors.red),
                              
                              const SizedBox(width: 25,),
                              
                              Text("Delete compte", style: TextStyle(color: Colors.red),)
                            
                          ],),
                        ),
                        const SizedBox(width: 25,),
                        Container(
                          padding: const EdgeInsets.all(10),
                          // margin: const EdgeInsets.only(bottom: 5),

                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(20),
                            color: Color.fromARGB(0, 255, 255, 255),
                          ),

                          child: const Icon(Icons.arrow_forward_ios_rounded, color: Colors.black45,),
                        ), 
                    ]),
                  ), 
                  
                ),
              ]
            ),
          )
        ],
      ), 
      
      
    );
  }
}