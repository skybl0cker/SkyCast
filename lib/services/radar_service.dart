/// NEXRAD base reflectivity mosaic from the Iowa Environmental Mesonet
/// (Iowa State University) — free, no API key, sourced from NOAA/NWS radar.
/// Coverage is the continental US only. Confirmed working tile zooms are
/// 0-8; above that the server returns blank tiles.
/// Docs: https://mesonet.agron.iastate.edu/ogc/
class RadarFrame {
  final int minutesAgo;
  const RadarFrame(this.minutesAgo);

  String get label => minutesAgo == 0 ? 'Now' : '$minutesAgo min ago';

  String get tileUrl {
    final suffix = minutesAgo == 0 ? '' : '-m${minutesAgo.toString().padLeft(2, '0')}m';
    return 'https://mesonet.agron.iastate.edu/cache/tile.py/1.0.0/'
        'nexrad-n0q$suffix/{z}/{x}/{y}.png';
  }
}

class RadarService {

  static const frames = [
    RadarFrame(30),
    RadarFrame(25),
    RadarFrame(20),
    RadarFrame(15),
    RadarFrame(10),
    RadarFrame(5),
    RadarFrame(0),
  ];

  static bool inCoverage(double lat, double lon) =>
      lat >= 24 && lat <= 50 && lon >= -125 && lon <= -66;
}
