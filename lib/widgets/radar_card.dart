import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../screens/radar_screen.dart';
import '../state/app_state.dart';
import 'glass_card.dart';

class RadarCard extends StatelessWidget {
  const RadarCard({super.key});

  @override
  Widget build(BuildContext context) {
    final place = context.watch<AppState>().selected;
    if (place == null) return const SizedBox.shrink();

    return GestureDetector(
      onTap: () => Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => RadarScreen(place: place)),
      ),
      child: GlassCard(
        title: 'Radar',
        icon: Icons.radar,
        child: const Row(
          children: [
            Expanded(
              child: Text(
                'Live NEXRAD radar with a 30-minute animated loop',
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
