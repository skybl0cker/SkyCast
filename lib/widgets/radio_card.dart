import 'package:flutter/material.dart';
import '../screens/radio_screen.dart';
import 'glass_card.dart';

class RadioCard extends StatelessWidget {
  const RadioCard({super.key});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => const RadioScreen()),
      ),
      child: GlassCard(
        title: 'Weather radio',
        icon: Icons.radio,
        child: const Row(
          children: [
            Expanded(
              child: Text(
                'Listen to live NOAA weather radio relays',
                style: TextStyle(color: Colors.white, fontSize: 15),
              ),
            ),
            Icon(Icons.chevron_right, color: Colors.white70),
          ],
        ),
      ),
    );
  }
}
