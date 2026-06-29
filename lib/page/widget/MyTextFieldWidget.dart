import 'package:flutter/material.dart';
import 'package:hugeicons/hugeicons.dart';

class Mytextfieldwidget extends StatefulWidget {
  final String label;
  final double? radius;
  final Function actionSaved;
  final Function? changeObscureText;
  final bool? obscuredText;
  const Mytextfieldwidget({super.key,this.radius ,required this.label, required this.actionSaved, this.obscuredText, this.changeObscureText});

  @override
  State<Mytextfieldwidget> createState() => _MytextfieldwidgetState();
}

class _MytextfieldwidgetState extends State<Mytextfieldwidget> {
  @override
  Widget build(BuildContext context) {
    return Container(
      width: 270,
      height: 70,
      margin: EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      child: Center(
        child: Stack(
          children: [
            TextFormField(
              keyboardType:(widget.label == 'Email') 
                ? TextInputType.emailAddress
                : TextInputType.text,
            
              obscureText: widget.label == 'Mot de passe' && widget.obscuredText == true,
              
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return "Entrer votre ${widget.label.toLowerCase()}";
                }
            
                return null;
              },
              onSaved: (newValue) => newValue != '' 
                ? widget.actionSaved(newValue, widget.label)
                : null,
            
              decoration: InputDecoration(
                labelText: widget.label,
                labelStyle: TextStyle(
                  color:  Color.fromARGB(171, 0, 0, 0),
                  fontSize: 11,
                  // fontFamily: 'Jersey15',
                ),
                filled: true,
                fillColor: Colors.white,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(widget.radius ?? 20),
                  borderSide: BorderSide(
                    color: Colors.white,
                    width: 1,
                  ),
                ),
              ),
              
            ),
            if(widget.label == 'Mot de passe')
            Positioned(
              top: 5,
              right: 0,
              child: GestureDetector(
                onTap: () => widget.changeObscureText!(),
                child: SizedBox(
                  width: 50,
                  height: 50,
                  child: Center(
                    child: HugeIcon(
                      icon: (widget.obscuredText == true)
                        ? HugeIcons.strokeRoundedViewOff
                        :HugeIcons.strokeRoundedView, 
                      color: Color(0xFF46904D)
                    )
                  ),
                ),
              )
            )
          ],
        ),
      ),
    );
  }
}