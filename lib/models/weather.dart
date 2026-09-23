class Place {
  final String name;
  final String? region;
  final String? country;
  final double lat;
  final double lon;
  final bool isCurrent;

  const Place({
    required this.name,
    this.region,
    this.country,
    required this.lat,
    required this.lon,
    this.isCurrent = false,
  });

  String get key => '${lat.toStringAsFixed(2)},${lon.toStringAsFixed(2)}';

  String get subtitle => [region, country]
      .where((s) => s != null && s.isNotEmpty)
      .join(', ');

  factory Place.fromGeocoding(Map<String, dynamic> j) => Place(
        name: j['name'] as String,
        region: j['admin1'] as String?,
        country: j['country'] as String?,
        lat: (j['latitude'] as num).toDouble(),
        lon: (j['longitude'] as num).toDouble(),
      );

  factory Place.fromJson(Map<String, dynamic> j) => Place(
        name: j['name'] as String,
        region: j['region'] as String?,
        country: j['country'] as String?,
        lat: (j['lat'] as num).toDouble(),
        lon: (j['lon'] as num).toDouble(),
        isCurrent: j['isCurrent'] as bool? ?? false,
      );

  Map<String, dynamic> toJson() => {
        'name': name,
        'region': region,
        'country': country,
        'lat': lat,
        'lon': lon,
        'isCurrent': isCurrent,
      };
}

class CurrentWeather {
  final DateTime time;
  final double tempC;
  final double feelsC;
  final double humidity;
  final double windKmh;
  final int windDir;
  final double pressure;
  final double precipMm;
  final int code;
  final bool isDay;

  const CurrentWeather({
    required this.time,
    required this.tempC,
    required this.feelsC,
    required this.humidity,
    required this.windKmh,
    required this.windDir,
    required this.pressure,
    required this.precipMm,
    required this.code,
    required this.isDay,
  });
}

class HourlyPoint {
  final DateTime time;
  final double tempC;
  final int precipProb;
  final int code;

  const HourlyPoint({
    required this.time,
    required this.tempC,
    required this.precipProb,
    required this.code,
  });
}

class DailyPoint {
  final DateTime date;
  final int code;
  final double maxC;
  final double minC;
  final DateTime sunrise;
  final DateTime sunset;
  final double uv;
  final int precipProb;

  const DailyPoint({
    required this.date,
    required this.code,
    required this.maxC,
    required this.minC,
    required this.sunrise,
    required this.sunset,
    required this.uv,
    required this.precipProb,
  });
}

class AirQuality {
  final int usAqi;
  final double pm25;
  final double pm10;
  final double ozone;
  final double no2;

  const AirQuality({
    required this.usAqi,
    required this.pm25,
    required this.pm10,
    required this.ozone,
    required this.no2,
  });

  static AirQuality? tryParse(Map<String, dynamic> j) {
    final c = j['current'] as Map<String, dynamic>?;
    final aqi = c?['us_aqi'] as num?;
    if (c == null || aqi == null) return null;
    double n(dynamic v) => (v as num?)?.toDouble() ?? 0;
    return AirQuality(
      usAqi: aqi.round(),
      pm25: n(c['pm2_5']),
      pm10: n(c['pm10']),
      ozone: n(c['ozone']),
      no2: n(c['nitrogen_dioxide']),
    );
  }
}

class WeatherData {
  final CurrentWeather current;
  final List<HourlyPoint> hourly;
  final List<DailyPoint> daily;
  final AirQuality? air;

  const WeatherData({
    required this.current,
    required this.hourly,
    required this.daily,
    this.air,
  });

  WeatherData withAir(AirQuality? a) => WeatherData(
        current: current,
        hourly: hourly,
        daily: daily,
        air: a,
      );

  factory WeatherData.fromJson(Map<String, dynamic> j) {
    double n(dynamic v) => (v as num?)?.toDouble() ?? 0;
    int i(dynamic v) => (v as num?)?.toInt() ?? 0;

    final c = j['current'] as Map<String, dynamic>;
    final h = j['hourly'] as Map<String, dynamic>;
    final d = j['daily'] as Map<String, dynamic>;

    final current = CurrentWeather(
      time: DateTime.parse(c['time'] as String),
      tempC: n(c['temperature_2m']),
      feelsC: n(c['apparent_temperature']),
      humidity: n(c['relative_humidity_2m']),
      windKmh: n(c['wind_speed_10m']),
      windDir: i(c['wind_direction_10m']),
      pressure: n(c['pressure_msl']),
      precipMm: n(c['precipitation']),
      code: i(c['weather_code']),
      isDay: i(c['is_day']) == 1,
    );

    final hTimes = (h['time'] as List).cast<String>();
    final hTemp = h['temperature_2m'] as List;
    final hProb = h['precipitation_probability'] as List;
    final hCode = h['weather_code'] as List;
    final startOfHour = DateTime(current.time.year, current.time.month,
        current.time.day, current.time.hour);

    final hourly = <HourlyPoint>[];
    for (var k = 0; k < hTimes.length && hourly.length < 24; k++) {
      final t = DateTime.parse(hTimes[k]);
      if (t.isBefore(startOfHour)) continue;
      hourly.add(HourlyPoint(
        time: t,
        tempC: n(hTemp[k]),
        precipProb: i(hProb[k]),
        code: i(hCode[k]),
      ));
    }

    final dTimes = (d['time'] as List).cast<String>();
    final daily = <DailyPoint>[
      for (var k = 0; k < dTimes.length; k++)
        DailyPoint(
          date: DateTime.parse(dTimes[k]),
          code: i((d['weather_code'] as List)[k]),
          maxC: n((d['temperature_2m_max'] as List)[k]),
          minC: n((d['temperature_2m_min'] as List)[k]),
          sunrise: DateTime.parse((d['sunrise'] as List)[k] as String),
          sunset: DateTime.parse((d['sunset'] as List)[k] as String),
          uv: n((d['uv_index_max'] as List)[k]),
          precipProb: i((d['precipitation_probability_max'] as List)[k]),
        ),
    ];

    return WeatherData(current: current, hourly: hourly, daily: daily);
  }
}
