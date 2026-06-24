import 'package:flutter/material.dart';

class SimpelBtn extends StatefulWidget {
  final double? w;
  final double? h;
  final String? t;
  final Color? c;
  final Color? txc;
  final Color? st;
  final void Function() action;
  final double? r;
  final double? sizetx;
  final bool? bold;
  final Icon? iconBtn;
  final bool? isLoaded;

  const SimpelBtn({super.key, this.w, this.h, this.t, this.c, this.txc, this.st,this.r, this.bold, this.sizetx, required this.action, this.isLoaded, this.iconBtn});

  @override
  State<SimpelBtn> createState() => _SimpelBtnState();
}

class _SimpelBtnState extends State<SimpelBtn> {
  bool? get _load => widget.isLoaded;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      borderRadius: BorderRadius.circular(widget.r ?? 10),

      child: Ink(
        decoration: BoxDecoration(
          color: widget.c ?? const Color.fromARGB(255, 255, 255, 255),

          border: Border.all(
            color: widget.st ?? Colors.transparent,
            width: 1,
          ),

          borderRadius: BorderRadius.circular(widget.r ?? 10),
        ),

        child: InkWell(
          borderRadius: BorderRadius.circular(widget.r ?? 10),

          onTap: widget.action,

          child: Container(
            alignment: Alignment.center,
            width: widget.w ?? 150,
            height: widget.h ?? 35,

            padding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 7,
            ),

            child: 
            (_load == false || _load == null)
              ?Text(
                widget.t ?? "Simple Button $_load",

                style: TextStyle(
                  color: widget.txc ?? Color(0xFF363636),

                  fontWeight:
                      (widget.bold ?? false)
                          ? FontWeight.bold
                          : FontWeight.normal,

                  fontSize: widget.sizetx ?? 13,
                ),
              )
              : SizedBox(
                height: 20,
                width: 20,
                child: Center(
                  child: CircularProgressIndicator(
                    color: Color(0xFF548856),
                    strokeWidth: 2,
                  ),
                ),
              )
          ),
        ),
      ),
    );
  }
}