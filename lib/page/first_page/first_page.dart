import 'package:flutter/material.dart';
import 'package:heathfirst_mobile/page/login/login.dart';
import 'package:heathfirst_mobile/page/singIn/incription_doc.dart';
import 'package:heathfirst_mobile/page/widget/logo.dart';
import 'package:heathfirst_mobile/page/widget/simple_btn.dart';

class FirstPage extends StatefulWidget {
  const FirstPage({super.key});

  @override
  State<FirstPage> createState() => _FirstPageState();
}

class _FirstPageState extends State<FirstPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFF46904D),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          SizedBox(
            width: MediaQuery.of(context).size.width,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                LogoSalma(),
                
                const SizedBox(height: 15,),
                ConstrainedBox(
                  constraints: BoxConstraints(
                    maxWidth: 200
                  ),
                  child: const Text(
                    textAlign: TextAlign.center,
                    'Ou que vous soyez on est la pour vous aider, Salma', 
                    style: TextStyle(
                      color: Color.fromARGB(255, 255, 255, 255),
                      fontWeight: FontWeight.normal,
                      fontSize: 16,
                      letterSpacing: 1.9
                    )
                  ),
                ),


                const SizedBox(height: 60,),
                SimpelBtn(
                  st: Colors.white,
                  w: 270,
                  h: 50,
                  t: 'Se connecté',
                  txc: Colors.white,
                  c: Color(0xFF46904D),
                  r: 20,
                  circlColor: Colors.white,
                  action: (){
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => LoginMobile()),
                    );
                  }
                ),

                const SizedBox(height: 15,),
                SimpelBtn(
                  w: 270,
                  h: 50,
                  t: "S' inscrire",
                  txc: Colors.white,
                  c: Color.fromARGB(255, 0, 0, 0),
                  r: 20,
                  circlColor: Colors.white,
                  action: (){
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => DocInscription()),
                    );
                  }
                ),

              ],
            ),
          ),


          const SizedBox(height: 90),
        ],
      ),
    );
  }
}