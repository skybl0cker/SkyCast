class WeatherAlert {
  final String id;
  final String event;
  final String severity;
  final String headline;
  final String description;
  final String instruction;
  final DateTime? expires;
  final String areas;

  const WeatherAlert({
    required this.id,
    required this.event,
    required this.severity,
    required this.headline,
    required this.description,
    required this.instruction,
    required this.expires,
    required this.areas,
  });

  factory WeatherAlert.fromJson(Map<String, dynamic> j) {
    final p = j['properties'] as Map<String, dynamic>;
    String s(String key) => (p[key] as String?)?.trim() ?? '';
    return WeatherAlert(
      id: (j['id'] as String?) ?? s('id'),
      event: s('event'),
      severity: s('severity'),
      headline: s('headline'),
      description: s('description'),
      instruction: s('instruction'),
      expires: DateTime.tryParse(p['expires'] as String? ?? ''),
      areas: s('areaDesc'),
    );
  }

  bool get isSevere => severity == 'Severe' || severity == 'Extreme';
}
