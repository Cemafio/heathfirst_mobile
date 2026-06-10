  import 'package:flutter/material.dart';
  import 'package:flutter_screenutil/flutter_screenutil.dart';
  import 'package:heathfirst_mobile/page/login/login.dart';
  import 'package:flutter_riverpod/flutter_riverpod.dart';

  void main() {
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
        designSize: const Size(375, 812), // Taille de design (taille de référence)
        minTextAdapt: true, // Adapter la taille du texte
        builder: (BuildContext context, Widget? child) => MaterialApp(
          title: 'Health First',
          debugShowCheckedModeBanner: false,
          theme: ThemeData(
            colorScheme: ColorScheme.fromSeed(seedColor: Colors.white),
            useMaterial3: true,
          ),
          home: const LoginMobile(),
        ),
      );
    }
  }