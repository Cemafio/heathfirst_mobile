import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';

class EmptyStateWidget extends StatefulWidget {
  final String? txt;
  final String? lottiName;
  const EmptyStateWidget({super.key, this.txt, this.lottiName});

  @override
  State<EmptyStateWidget> createState() => _EmptyStateWidgetState();
}

class _EmptyStateWidgetState extends State<EmptyStateWidget> with TickerProviderStateMixin {
  late final AnimationController _controller;
  
  @override
    void initState() {
    super.initState();
    // 2. Initialiser le contrôleur (sans durée fixe au départ)
    _controller = AnimationController(vsync: this);
  }

  @override
  Widget build(BuildContext context) {

    return Column(
      children: [
        SizedBox(height: 70,),
        Center(
          child: Lottie.asset(
            width: 200,
            height: 200,
            "assets/animations/${widget.lottiName ?? 'empty_doc'}.json",
            controller: _controller,
            onLoaded: (composition) {
              _controller
                ..duration = composition.duration
                ..value = 0.5; // 50% de l'animation
            },          
          ),
        ),

        SizedBox(height: 10,),
        ConstrainedBox(
          constraints: BoxConstraints(
            maxWidth: 200
          ),
          child: Text(
            textAlign: TextAlign.center,
            widget.txt ?? "Aucune donnée disponible pour le moment. Réessayez dans quelques instants.",
            style: TextStyle(
              fontSize: 13,
              letterSpacing: 1,
              color: Color.fromARGB(171, 0, 0, 0),
            ),         
          ),
        ),
        
      ],
    );
  }
}