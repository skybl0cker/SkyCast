import 'dart:async';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/weather.dart';
import '../state/app_state.dart';

class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final _ctrl = TextEditingController();
  Timer? _debounce;
  List<Place> _results = [];
  bool _busy = false;
  String? _err;

  @override
  void dispose() {
    _debounce?.cancel();
    _ctrl.dispose();
    super.dispose();
  }

  void _onChanged(String q) {
    _debounce?.cancel();
    final query = q.trim();
    if (query.length < 2) {
      setState(() {
        _results = [];
        _err = null;
        _busy = false;
      });
      return;
    }
    final state = context.read<AppState>();
    _debounce = Timer(const Duration(milliseconds: 400), () async {
      setState(() => _busy = true);
      try {
        final r = await state.search(query);
        if (!mounted) return;
        setState(() {
          _results = r;
          _err = null;
        });
      } catch (_) {
        if (!mounted) return;
        setState(() => _err = 'Search failed. Check your connection.');
      } finally {
        if (mounted) setState(() => _busy = false);
      }
    });
  }

  void _pick(Place p) {
    context.read<AppState>().selectPlace(p);
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final s = context.watch<AppState>();
    final searching = _ctrl.text.trim().length >= 2;

    return Scaffold(
      appBar: AppBar(
        title: TextField(
          controller: _ctrl,
          autofocus: true,
          onChanged: _onChanged,
          decoration: const InputDecoration(
            hintText: 'Search for a city…',
            border: InputBorder.none,
          ),
        ),
        actions: [
          if (_ctrl.text.isNotEmpty)
            IconButton(
              icon: const Icon(Icons.clear),
              onPressed: () {
                _ctrl.clear();
                _onChanged('');
              },
            ),
        ],
        bottom: _busy
            ? const PreferredSize(
                preferredSize: Size.fromHeight(2),
                child: LinearProgressIndicator(minHeight: 2),
              )
            : null,
      ),
      body: searching ? _resultsList() : _savedList(s),
    );
  }

  Widget _resultsList() {
    if (_err != null) return Center(child: Text(_err!));
    if (_results.isEmpty && !_busy) {
      return const Center(child: Text('No matching places'));
    }
    return ListView(
      children: [
        for (final p in _results)
          ListTile(
            leading: const Icon(Icons.place_outlined),
            title: Text(p.name),
            subtitle: p.subtitle.isEmpty ? null : Text(p.subtitle),
            onTap: () => _pick(p),
          ),
      ],
    );
  }

  Widget _savedList(AppState s) {
    return ListView(
      children: [
        ListTile(
          leading: const Icon(Icons.my_location),
          title: const Text('Use my location'),
          onTap: () {
            s.useMyLocation();
            Navigator.pop(context);
          },
        ),
        if (s.saved.isNotEmpty)
          const Padding(
            padding: EdgeInsets.fromLTRB(16, 16, 16, 4),
            child: Text('SAVED', style: TextStyle(fontSize: 12, letterSpacing: 1)),
          ),
        for (final p in s.saved)
          Dismissible(
            key: ValueKey(p.key),
            direction: DismissDirection.endToStart,
            background: Container(
              color: Colors.red,
              alignment: Alignment.centerRight,
              padding: const EdgeInsets.only(right: 20),
              child: const Icon(Icons.delete, color: Colors.white),
            ),
            onDismissed: (_) => s.removePlace(p),
            child: ListTile(
              leading: const Icon(Icons.star, color: Colors.amber),
              title: Text(p.name),
              subtitle: p.subtitle.isEmpty ? null : Text(p.subtitle),
              onTap: () => _pick(p),
            ),
          ),
        if (s.saved.isEmpty)
          const Padding(
            padding: EdgeInsets.all(24),
            child: Text(
              'Search for a city, open it, and tap the star to save it here.',
              textAlign: TextAlign.center,
            ),
          ),
      ],
    );
  }
}
