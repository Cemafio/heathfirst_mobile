import 'package:flutter/material.dart';

class PremiumBadge extends StatefulWidget {
  const PremiumBadge({super.key});

  @override
  State<PremiumBadge> createState() => _PremiumBadgeState();
}

class _PremiumBadgeState extends State<PremiumBadge> {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 12,
        vertical: 6,
      ),

      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Color(0xFF548856),
            Color(0xFF81C784),
          ],
        ),

        borderRadius: BorderRadius.circular(30),

        boxShadow: [
          BoxShadow(
            color: Color(0x33548856),
            blurRadius: 8,
            offset: Offset(0, 3),
          )
        ],
      ),

      child: const Row(
        mainAxisSize: MainAxisSize.min,
        children: [

          Icon(
            Icons.verified_rounded,
            size: 16,
            color: Colors.white,
          ),

          SizedBox(width: 6),

          Text(
            "Spécialiste vérifié",
            style: TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }
}