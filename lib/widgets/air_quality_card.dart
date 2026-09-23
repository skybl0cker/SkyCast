import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../state/app_state.dart';
import '../utils/aqi.dart';
import 'glass_card.dart';

class AirQualityCard extends StatelessWidget {
  const AirQualityCard({super.key});

  @override
  Widget build(BuildContext context) {
    final air = context.watch<AppState>().data?.air;
    if (air == null) return const SizedBox.shrink();

    final lvl = aqiLevel(air.usAqi);
    final frac = (air.usAqi / 300).clamp(0.0, 1.0).toDouble();

    return GlassCard(
      title: 'Air quality',
      icon: Icons.air,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text('${air.usAqi}',
                  style: const TextStyle(
                      fontSize: 44,
                      color: Colors.white,
                      fontWeight: FontWeight.w300,
                      height: 1)),
              const SizedBox(width: 12),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.only(bottom: 4),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(children: [
                        Container(
                          width: 10,
                          height: 10,
                          decoration: BoxDecoration(
                              color: lvl.color, shape: BoxShape.circle),
                        ),
                        const SizedBox(width: 6),
                        Flexible(
                          child: Text(lvl.label,
                              style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600)),
                        ),
                      ]),
                      const Text('US AQI',
                          style: TextStyle(color: Colors.white70, fontSize: 12)),
                    ],
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          LayoutBuilder(builder: (_, box) {
            final w = box.maxWidth;
            return SizedBox(
              height: 14,
              child: Stack(
                clipBehavior: Clip.none,
                children: [
                  Positioned(
                    left: 0,
                    right: 0,
                    top: 4,
                    height: 6,
                    child: DecoratedBox(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(3),
                        // Stops line up with the EPA category boundaries
                        // (50/100/150/200/300 on a 0-300 scale).
                        gradient: const LinearGradient(
                          colors: [
                            Color(0xFF00E400),
                            Color(0xFFFFFF00),
                            Color(0xFFFF7E00),
                            Color(0xFFFF4D4D),
                            Color(0xFFB36BD1),
                            Color(0xFFB0223F),
                          ],
                          stops: [0, 0.167, 0.333, 0.5, 0.667, 1],
                        ),
                      ),
                    ),
                  ),
                  Positioned(
                    left: (frac * w - 7).clamp(0.0, w - 14).toDouble(),
                    top: 0,
                    child: Container(
                      width: 14,
                      height: 14,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        shape: BoxShape.circle,
                        border: Border.all(color: lvl.color, width: 3),
                      ),
                    ),
                  ),
                ],
              ),
            );
          }),
          const SizedBox(height: 12),
          Text(lvl.advice,
              style: const TextStyle(color: Colors.white70, fontSize: 13)),
          const SizedBox(height: 14),
          Row(children: [
            _stat('PM2.5', air.pm25),
            _stat('PM10', air.pm10),
            _stat('Ozone', air.ozone),
          ]),
        ],
      ),
    );
  }

  Widget _stat(String label, double v) => Expanded(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(label,
                style: const TextStyle(color: Colors.white70, fontSize: 11)),
            Text('${v.round()} µg/m³',
                style: const TextStyle(
                    color: Colors.white,
                    fontSize: 14,
                    fontWeight: FontWeight.w600)),
          ],
        ),
      );
}
