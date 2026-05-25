import 'package:flutter/material.dart';

import '../app_theme.dart';
import '../features/explore/presentation/controllers/explore_api_controller.dart';
import 'tour_detail_screen.dart';

class TripsScreen extends StatefulWidget {
  const TripsScreen({super.key});

  @override
  State<TripsScreen> createState() => _TripsScreenState();
}

class _TripsScreenState extends State<TripsScreen> {
  final ExploreApiController _controller = ExploreApiController();
  bool _loading = true;
  String? _error;
  List<JourneyApiItem> _journeys = const <JourneyApiItem>[];

  @override
  void initState() {
    super.initState();
    _loadTrips();
  }

  Future<void> _loadTrips() async {
    if (mounted) {
      setState(() {
        _loading = true;
        _error = null;
      });
    }

    try {
      final result = await _controller.getTopJourneys();
      if (!mounted) return;
      setState(() {
        _journeys = result.data ?? const <JourneyApiItem>[];
        _loading = false;
      });
    } catch (error) {
      if (!mounted) return;
      setState(() {
        _loading = false;
        _error = error.toString();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF4FAF7),
      appBar: AppBar(
        backgroundColor: const Color(0xFFF4FAF7),
        elevation: 0,
        title: const Text('Trips'),
      ),
      body: RefreshIndicator(
        onRefresh: _loadTrips,
        child: ListView(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 20),
          children: [
            _summaryCard(),
            if (_loading) ...[
              const SizedBox(height: 12),
              const LinearProgressIndicator(minHeight: 2),
            ],
            if (_error != null) ...[
              const SizedBox(height: 12),
              _errorCard(),
            ],
            const SizedBox(height: 14),
            if (!_loading && _journeys.isEmpty) _emptyCard(),
            for (final journey in _journeys)
              Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: _tripCard(journey),
              ),
          ],
        ),
      ),
    );
  }

  Widget _summaryCard() {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        gradient: const LinearGradient(
          colors: [Color(0xFF11735C), Color(0xFF27A680)],
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 42,
            height: 42,
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.20),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(Icons.map_outlined, color: Colors.white),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              'Your current trips are synced from SQL API.',
              style: TextStyle(
                color: Colors.white.withValues(alpha: 0.96),
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _errorCard() {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFFFFF1F1),
        border: Border.all(color: const Color(0xFFFFC8C8)),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          const Icon(Icons.wifi_off_rounded, color: Color(0xFFC73737)),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              'Cannot load trips from API. Pull down to retry.',
              style: TextStyle(
                color: AppTheme.textDark,
                fontSize: 12.5,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _emptyCard() {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: const Color(0xFFDDE8E3)),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Text(
        'No trips found yet.',
        style: TextStyle(color: AppTheme.textGray, fontWeight: FontWeight.w600),
      ),
    );
  }

  Widget _tripCard(JourneyApiItem journey) {
    return InkWell(
      borderRadius: BorderRadius.circular(14),
      onTap: () {
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (_) => TourDetailScreen(
              title: journey.title,
              imageAsset: journey.imageAsset,
              price: journey.price,
            ),
          ),
        );
      },
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: const Color(0xFFDDE8E3)),
        ),
        child: Row(
          children: [
            ClipRRect(
              borderRadius: const BorderRadius.horizontal(left: Radius.circular(14)),
              child: SizedBox(
                width: 94,
                height: 94,
                child: Image.asset(journey.imageAsset, fit: BoxFit.cover),
              ),
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(12, 10, 12, 10),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      journey.title,
                      style: const TextStyle(
                        fontWeight: FontWeight.w700,
                        color: Color(0xFF23312C),
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 5),
                    Text(
                      journey.date,
                      style: TextStyle(
                        fontSize: 12,
                        color: AppTheme.textLightGray,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      journey.days,
                      style: TextStyle(
                        fontSize: 12,
                        color: AppTheme.textLightGray,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      journey.price,
                      style: TextStyle(
                        color: AppTheme.authHeaderTeal,
                        fontWeight: FontWeight.w700,
                        fontSize: 15,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
