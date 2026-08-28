import 'package:flutter/material.dart';

import '../models/score.dart';
import '../services/download_store.dart';
import '../services/musescore_api.dart';
import 'detail_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({
    super.key,
    required this.api,
    required this.settings,
    required this.store,
  });

  final MuseScoreApi api;
  final AppSettings settings;
  final DownloadStore store;

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final _controller = TextEditingController();
  bool _loading = false;
  String? _error;
  List<SearchHit> _hits = const [];

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _runSearch() async {
    final q = _controller.text.trim();
    if (q.isEmpty) {
      setState(() => _error = 'Please enter a query or MuseScore URL');
      return;
    }
    setState(() {
      _loading = true;
      _error = null;
      _hits = const [];
    });
    try {
      final hits = await widget.api.search(q);
      if (!mounted) return;
      if (hits.isEmpty) {
        setState(() {
          _loading = false;
          _error = 'No results';
        });
        return;
      }
      if (hits.length == 1 && widget.api.isScoreUrl(q)) {
        setState(() => _loading = false);
        await _openHit(hits.first);
        return;
      }
      setState(() {
        _loading = false;
        _hits = hits;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _loading = false;
        _error = e.toString();
      });
    }
  }

  Future<void> _openHit(SearchHit hit) async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final score = await widget.api.fetchScore(hit.url);
      if (!mounted) return;
      setState(() => _loading = false);
      await Navigator.of(context).push(
        MaterialPageRoute(
          builder: (_) => DetailScreen(
            api: widget.api,
            settings: widget.settings,
            store: widget.store,
            score: score,
          ),
        ),
      );
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _loading = false;
        _error = e.toString();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
            child: TextField(
              controller: _controller,
              textInputAction: TextInputAction.search,
              onSubmitted: (_) => _runSearch(),
              decoration: InputDecoration(
                hintText: 'Search MuseScore or paste a score URL',
                border: const OutlineInputBorder(),
                suffixIcon: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if (_controller.text.isNotEmpty)
                      IconButton(
                        tooltip: 'Clear',
                        onPressed: () {
                          _controller.clear();
                          setState(() {
                            _hits = const [];
                            _error = null;
                          });
                        },
                        icon: const Icon(Icons.clear),
                      ),
                    IconButton(
                      tooltip: 'Search',
                      onPressed: _loading ? null : _runSearch,
                      icon: const Icon(Icons.search),
                    ),
                  ],
                ),
              ),
              onChanged: (_) => setState(() {}),
            ),
          ),
          if (_loading) const LinearProgressIndicator(),
          if (_error != null)
            Padding(
              padding: const EdgeInsets.all(16),
              child: Text(
                _error!,
                style: TextStyle(color: Theme.of(context).colorScheme.error),
              ),
            ),
          Expanded(
            child: _hits.isEmpty
                ? Center(
                    child: Padding(
                      padding: const EdgeInsets.all(24),
                      child: Text(
                        'Search sheet music on MuseScore, or paste a full score URL.\n\n'
                        'If MuseScore blocks requests, configure a proxy under Settings.',
                        textAlign: TextAlign.center,
                        style: Theme.of(context).textTheme.bodyLarge,
                      ),
                    ),
                  )
                : ListView.separated(
                    itemCount: _hits.length,
                    separatorBuilder: (_, _) => const Divider(height: 1),
                    itemBuilder: (context, i) {
                      final hit = _hits[i];
                      return ListTile(
                        title: Text(hit.title),
                        subtitle: Text(hit.url),
                        trailing: const Icon(Icons.chevron_right),
                        onTap: _loading ? null : () => _openHit(hit),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}
