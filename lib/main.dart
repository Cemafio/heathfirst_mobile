  import 'package:flutter/material.dart';
  import 'package:flutter_screenutil/flutter_screenutil.dart';
  import 'package:heathfirst_mobile/page/login/login.dart';
  import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/date_symbol_data_local.dart';

  void main() async {
    await initializeDateFormatting('fr_FR');
  runApp(
    const ProviderScope(
      child: MyApp(),
    )
  );
}


  class MyApp extends StatelessWidget {
    const MyApp({super.key});

    @override
    Widget build(BuildContext context) {
      return ScreenUtilInit(
        minTextAdapt: true, 
        builder: (BuildContext context, Widget? child) => MaterialApp(

          title: "Salma",
          debugShowCheckedModeBanner: false,

          theme: ThemeData(
            primaryColor: Color(0xFF548856),
            // scaffoldBackgroundColor: ,
            colorScheme: ColorScheme.fromSeed(seedColor: Colors.white),
            useMaterial3: true,
          ),

          home: const LoginMobile(),
        ),
      );
    }
  }