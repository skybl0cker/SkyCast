import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import '../models/weather.dart';
import '../services/radar_service.dart';
import '../utils/radar_legend.dart';

// Change this to match your applicationId when you rename the app.
const _userAgent = 'com.example.skycast';
const _startZoom = 7.0;
const _radarMaxZoom = 8; // above this the tile server returns blank images

/// Darkens the light OpenStreetMap basemap so radar colors stand out.
const _darkTiles = ColorFilter.matrix(<double>[
  -0.15, -0.295, -0.055, 0, 149.5,
  -0.15, -0.295, -0.055, 0, 154.5,
  -0.15, -0.295, -0.055, 0, 165.5,
  0, 0, 0, 1, 0,
]);
const _noFilter = ColorFilter.mode(Colors.transparent, BlendMode.dst);

class RadarScreen extends StatefulWidget {
  final Place place;
  const RadarScreen({super.key, required this.place});

  @override
  State<RadarScreen> createState() => _RadarScreenState();
}

class _RadarScreenState extends State<RadarScreen> {
  final _map = MapController();
  final _frames = RadarService.frames;

  late int _index = _frames.length - 1;
  bool _playing = false;
  bool _dark = true;
  double _opacity = 0.8;
  int _hold = 0;
  Timer? _timer;
  final Set<int> _visited = {};

  @override
  void initState() {
    super.initState();
    _visited.add(_index);
    // Mount the rest one at a time so the free tile server isn't hit with a
    // burst of concurrent requests, then unlock playback.
    Timer.periodic(const Duration(milliseconds: 300), (t) {
      final next = _frames.length - 2 - (_visited.length - 1);
      if (next < 0) {
        t.cancel();
        return;
      }
      if (!mounted) {
        t.cancel();
        return;
      }
      setState(() => _visited.add(next));
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  void _show(int i) => setState(() {
        _index = i;
        _visited.add(i);
      });

  void _step(int d) => _show((_index + d) % _frames.length);

  void _tick() {
    if (_index == _frames.length - 1 && _hold < 2) {
      _hold++;
      return;
    }
    _hold = 0;
    _step(1);
  }

  void _togglePlay() {
    if (_playing) {
      _timer?.cancel();
      setState(() => _playing = false);
      return;
    }
    setState(() => _playing = true);
    _timer = Timer.periodic(const Duration(milliseconds: 600), (_) => _tick());
  }

  bool get _ready => _visited.length == _frames.length;

  @override
  Widget build(BuildContext context) {
    final p = widget.place;
    final center = LatLng(p.lat, p.lon);

    if (!RadarService.inCoverage(p.lat, p.lon)) {
      return Scaffold(
        appBar: AppBar(title: Text('Radar · ${p.name}')),
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(32),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.public_off, size: 56),
                const SizedBox(height: 16),
                Text(
                  '${p.name} is outside the radar coverage area.',
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                const SizedBox(height: 8),
                const Text(
                  'This radar only covers the continental United States.',
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Text('Radar · ${p.name}'),
        actions: [
          IconButton(
            tooltip: _dark ? 'Light map' : 'Dark map',
            icon: Icon(_dark ? Icons.light_mode_outlined : Icons.dark_mode_outlined),
            onPressed: () => setState(() => _dark = !_dark),
          ),
        ],
      ),
      body: Stack(
        children: [
          FlutterMap(
            mapController: _map,
            options: MapOptions(
              initialCenter: center,
              initialZoom: _startZoom,
              minZoom: 3,
              maxZoom: 9,
              interactionOptions: const InteractionOptions(
                flags: InteractiveFlag.all & ~InteractiveFlag.rotate,
              ),
            ),
            children: [
              ColorFiltered(
                colorFilter: _dark ? _darkTiles : _noFilter,
                child: TileLayer(
                  urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                  userAgentPackageName: _userAgent,
                ),
              ),
              for (final i in _visited)
                AnimatedOpacity(
                  opacity: i == _index ? _opacity : 0,
                  duration: const Duration(milliseconds: 200),
                  child: TileLayer(
                    key: ValueKey(_frames[i].tileUrl),
                    urlTemplate: _frames[i].tileUrl,
                    maxNativeZoom: _radarMaxZoom,
                    userAgentPackageName: _userAgent,
                  ),
                ),
              MarkerLayer(markers: [
                Marker(
                  point: center,
                  width: 22,
                  height: 22,
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.orangeAccent,
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.white, width: 3),
                      boxShadow: const [BoxShadow(color: Colors.black38, blurRadius: 6)],
                    ),
                  ),
                ),
              ]),
              const SimpleAttributionWidget(
                source: Text('© OpenStreetMap · Radar: Iowa Environmental Mesonet / NOAA'),
              ),
            ],
          ),
          if (!_ready)
            Positioned(
              top: 0,
              left: 0,
              right: 0,
              child: LinearProgressIndicator(
                minHeight: 3,
                value: _visited.length / _frames.length,
              ),
            ),
          Positioned(
            left: 12,
            top: 12,
            child: _Legend(),
          ),
          Positioned(
            right: 12,
            bottom: 200,
            child: FloatingActionButton.small(
              heroTag: 'recenter',
              tooltip: 'Back to my place',
              onPressed: () => _map.move(center, _startZoom),
              child: const Icon(Icons.my_location),
            ),
          ),
          Align(
            alignment: Alignment.bottomCenter,
            child: SafeArea(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(12, 0, 12, 20),
                child: Card(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(16, 12, 16, 6),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(_frames[_index].label,
                                style: Theme.of(context)
                                    .textTheme
                                    .titleMedium
                                    ?.copyWith(fontWeight: FontWeight.w700)),
                            Row(
                              children: [
                                const Icon(Icons.opacity, size: 16),
                                SizedBox(
                                  width: 90,
                                  child: Slider(
                                    value: _opacity,
                                    min: 0.2,
                                    max: 1,
                                    onChanged: (v) => setState(() => _opacity = v),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                        Row(
                          children: [
                            IconButton(
                              icon: const Icon(Icons.skip_previous),
                              onPressed: () => _step(-1),
                            ),
                            IconButton.filled(
                              icon: Icon(_playing ? Icons.pause : Icons.play_arrow),
                              onPressed: _ready ? _togglePlay : null,
                            ),
                            IconButton(
                              icon: const Icon(Icons.skip_next),
                              onPressed: () => _step(1),
                            ),
                            Expanded(
                              child: Slider(
                                min: 0,
                                max: (_frames.length - 1).toDouble(),
                                divisions: _frames.length - 1,
                                value: _index.toDouble(),
                                onChanged: (v) => _show(v.round()),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _Legend extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Card(
      color: Theme.of(context).cardColor.withAlpha(230),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('dBZ', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600)),
            const SizedBox(width: 6),
            for (final s in radarLegendStops)
              Padding(
                padding: const EdgeInsets.only(right: 6),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(width: 10, height: 10, color: s.color),
                    const SizedBox(width: 2),
                    Text(s.label, style: const TextStyle(fontSize: 10)),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }
}
