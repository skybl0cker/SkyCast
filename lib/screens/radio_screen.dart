import 'package:flutter/material.dart';
import 'package:just_audio/just_audio.dart';
import '../services/radio_stations.dart';

class RadioScreen extends StatefulWidget {
  const RadioScreen({super.key});

  @override
  State<RadioScreen> createState() => _RadioScreenState();
}

class _RadioScreenState extends State<RadioScreen> {
  final _player = AudioPlayer();
  final _searchCtrl = TextEditingController();
  RadioStation? _current;
  bool _loading = false;
  String? _error;

  @override
  void dispose() {
    _player.dispose();
    _searchCtrl.dispose();
    super.dispose();
  }

  Future<void> _play(RadioStation s) async {
    setState(() {
      _current = s;
      _loading = true;
      _error = null;
    });
    try {
      await _player.setUrl(s.url);
      await _player.play();
    } catch (_) {
      setState(() => _error =
          'Could not connect to ${s.label}. This is a volunteer-run stream — try another station.');
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _stop() async {
    await _player.stop();
    setState(() => _current = null);
  }

  @override
  Widget build(BuildContext context) {
    final q = _searchCtrl.text.trim().toLowerCase();
    final filtered = q.isEmpty
        ? radioStations
        : radioStations
            .where((s) =>
                s.city.toLowerCase().contains(q) ||
                s.state.toLowerCase().contains(q) ||
                s.callsign.toLowerCase().contains(q))
            .toList();

    return Scaffold(
      appBar: AppBar(title: const Text('Weather Radio')),
      body: Column(
        children: [
          Container(
            color: Theme.of(context).colorScheme.surfaceContainerHighest,
            padding: const EdgeInsets.all(12),
            child: Row(
              children: [
                const Icon(Icons.info_outline, size: 18),
                const SizedBox(width: 8),
                const Expanded(
                  child: Text(
                    'Volunteer-relayed feeds, not official NOAA streams. Can lag up to 2 min '
                    "— not a substitute for a real weather alert radio.",
                    style: TextStyle(fontSize: 12),
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(12, 12, 12, 4),
            child: TextField(
              controller: _searchCtrl,
              onChanged: (_) => setState(() {}),
              decoration: InputDecoration(
                hintText: 'Search state or city…',
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                isDense: true,
                suffixIcon: _searchCtrl.text.isEmpty
                    ? null
                    : IconButton(
                        icon: const Icon(Icons.clear),
                        onPressed: () => setState(_searchCtrl.clear),
                      ),
              ),
            ),
          ),
          if (_error != null)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
              child: Text(_error!, style: const TextStyle(color: Colors.red)),
            ),
          Expanded(
            child: ListView.builder(
              itemCount: filtered.length,
              itemBuilder: (_, i) {
                final s = filtered[i];
                final active = _current?.callsign == s.callsign;
                return ListTile(
                  leading: Icon(active ? Icons.graphic_eq : Icons.radio_outlined,
                      color: active ? Theme.of(context).colorScheme.primary : null),
                  title: Text(s.label),
                  subtitle: Text(s.callsign),
                  trailing: active && _loading
                      ? const SizedBox(
                          width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2))
                      : null,
                  selected: active,
                  onTap: () => active ? _stop() : _play(s),
                );
              },
            ),
          ),
          if (_current != null)
            SafeArea(
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                color: Theme.of(context).colorScheme.primaryContainer,
                child: Row(
                  children: [
                    const Icon(Icons.graphic_eq),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text('Playing ${_current!.label}',
                          style: const TextStyle(fontWeight: FontWeight.w600)),
                    ),
                    IconButton(icon: const Icon(Icons.stop_circle), onPressed: _stop),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }
}
