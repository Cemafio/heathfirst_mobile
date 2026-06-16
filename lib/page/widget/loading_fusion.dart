import 'package:flutter/material.dart';

class LoadingFusBtn extends StatefulWidget {
  final bool isLoaded;
  final Widget wid;
  const LoadingFusBtn({super.key, required this.isLoaded, required this.wid});

  @override
  State<LoadingFusBtn> createState() => _LoadingFusBtnState();
}

class _LoadingFusBtnState extends State<LoadingFusBtn> {
  bool get isLoaded => widget.isLoaded;

  @override
  Widget build(BuildContext context) {
    return (isLoaded == true)
      ? const SizedBox(
            height: 12,
            width: 12,
            child: CircularProgressIndicator(
              strokeWidth: 2.0,
            ),
        )
      : widget.wid;
  }
}