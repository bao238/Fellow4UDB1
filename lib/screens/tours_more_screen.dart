import 'package:flutter/material.dart';

import '../app_theme.dart';
import '../features/explore/presentation/controllers/explore_api_controller.dart';
import 'tour_detail_screen.dart';

class ToursMoreScreen extends StatefulWidget {
  const ToursMoreScreen({super.key, this.initialTours = const []});

  final List<JourneyApiItem> initialTours;

  @override
  State<ToursMoreScreen> createState() => _ToursMoreScreenState();
}

class _ToursMoreScreenState extends State<ToursMoreScreen> {
  final ExploreApiController _controller = ExploreApiController();
  final TextEditingController _searchController = TextEditingController();

  bool _loading = false;
  String? _error;
  List<JourneyApiItem> _tours = const <JourneyApiItem>[];

  @override
  void initState() {
    super.initState();
    _tours = widget.initialTours;
    if (_tours.isEmpty) {
      _loadTours();
    }
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadTours() async {
    setState(() {
      _loading = true;
      _error = null;
    });

    try {
      final result = await _controller.getTopJourneys();
      if (!mounted) return;
      setState(() {
        _tours = result.data ?? const <JourneyApiItem>[];
        _loading = false;
      });
    } catch (error) {
      if (!mounted) return;
      setState(() {
        _error = error.toString();
        _loading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final query = _searchController.text.trim().toLowerCase();
    final filteredTours = _tours
        .where((tour) => query.isEmpty || tour.title.toLowerCase().contains(query))
        .toList();

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: _loadTours,
          child: CustomScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            slivers: [
              SliverAppBar(
                expandedHeight: 272,
                pinned: true,
                stretch: true,
                automaticallyImplyLeading: false,
                backgroundColor: AppTheme.authHeaderTeal,
                flexibleSpace: FlexibleSpaceBar(
                  collapseMode: CollapseMode.parallax,
                  background: _MoreHeader(
                    title: 'Plenty of amazing tours\nare waiting for you',
                    controller: _searchController,
                    onChanged: (_) => setState(() {}),
                    onRefreshTap: _loadTours,
                  ),
                ),
              ),
              if (_loading)
                const SliverToBoxAdapter(
                  child: Padding(
                    padding: EdgeInsets.only(top: 16),
                    child: Center(child: CircularProgressIndicator()),
                  ),
                )
              else if (_error != null)
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
                    child: _StateCard(
                      message: 'Could not load tours. Pull to refresh.',
                      icon: Icons.wifi_off_rounded,
                    ),
                  ),
                )
              else if (filteredTours.isEmpty)
                const SliverToBoxAdapter(
                  child: Padding(
                    padding: EdgeInsets.fromLTRB(16, 16, 16, 0),
                    child: _StateCard(
                      message: 'No tours match your search.',
                      icon: Icons.travel_explore_rounded,
                    ),
                  ),
                )
              else
                SliverPadding(
                  padding: const EdgeInsets.fromLTRB(16, 16, 16, 16),
                  sliver: SliverList(
                    delegate: SliverChildBuilderDelegate(
                      (context, index) {
                        final tour = filteredTours[index];
                        return Padding(
                          padding: const EdgeInsets.only(bottom: 12),
                          child: _TourMoreCard(tour: tour),
                        );
                      },
                      childCount: filteredTours.length,
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

class _MoreHeader extends StatelessWidget {
  const _MoreHeader({
    required this.title,
    required this.controller,
    required this.onChanged,
    required this.onRefreshTap,
  });

  final String title;
  final TextEditingController controller;
  final ValueChanged<String> onChanged;
  final VoidCallback onRefreshTap;

  @override
  Widget build(BuildContext context) {
    return Stack(
      fit: StackFit.expand,
      children: [
        Image.asset(
          'assets/images/explore_header_danang.png',
          fit: BoxFit.cover,
        ),
        Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                Colors.black.withValues(alpha: 0.4),
                Colors.black.withValues(alpha: 0.0),
              ],
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: kToolbarHeight - 12),
              Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.arrow_back, color: Colors.white),
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                  const Spacer(),
                  IconButton(
                    icon: const Icon(Icons.refresh, color: Colors.white),
                    onPressed: onRefreshTap,
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                title,
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 16),
              Container(
                height: 44,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.06),
                      blurRadius: 10,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    const SizedBox(width: 12),
                    const Icon(Icons.search, size: 20, color: Color(0xFFB0B0B0)),
                    const SizedBox(width: 8),
                    Expanded(
                      child: TextField(
                        controller: controller,
                        onChanged: onChanged,
                        decoration: const InputDecoration(
                          hintText: 'Search tours',
                          border: InputBorder.none,
                        ),
                        style: const TextStyle(fontSize: 14),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _TourMoreCard extends StatelessWidget {
  const _TourMoreCard({required this.tour});

  final JourneyApiItem tour;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () {
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (_) => TourDetailScreen(
              title: tour.title,
              imageAsset: tour.imageAsset,
              price: tour.price,
            ),
          ),
        );
      },
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.08),
              blurRadius: 10,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Stack(
              children: [
                ClipRRect(
                  borderRadius:
                      const BorderRadius.vertical(top: Radius.circular(12)),
                  child: SizedBox(
                    height: 150,
                    width: double.infinity,
                    child: Image.asset(tour.imageAsset, fit: BoxFit.cover),
                  ),
                ),
                Positioned(
                  bottom: 8,
                  left: 8,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 6,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.black.withValues(alpha: 0.5),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        ...List.generate(
                          tour.stars,
                          (_) => const Icon(
                            Icons.star,
                            size: 14,
                            color: Colors.amber,
                          ),
                        ),
                        if (tour.km != null) ...[
                          const SizedBox(width: 4),
                          Text(
                            tour.km!,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 11,
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                ),
                Positioned(
                  top: 8,
                  right: 8,
                  child: Container(
                    width: 26,
                    height: 26,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(13),
                    ),
                    child: Icon(
                      Icons.favorite_border,
                      size: 18,
                      color: AppTheme.authHeaderTeal,
                    ),
                  ),
                ),
              ],
            ),
            Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          tour.title,
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: Color(0xFF333333),
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        tour.price,
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.bold,
                          color: AppTheme.authHeaderTeal,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Row(
                    children: [
                      Icon(
                        Icons.calendar_today,
                        size: 12,
                        color: AppTheme.textLightGray,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        tour.date,
                        style: TextStyle(
                          fontSize: 12,
                          color: AppTheme.textLightGray,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 2),
                  Row(
                    children: [
                      Icon(
                        Icons.schedule,
                        size: 12,
                        color: AppTheme.textLightGray,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        tour.days,
                        style: TextStyle(
                          fontSize: 12,
                          color: AppTheme.textLightGray,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _StateCard extends StatelessWidget {
  const _StateCard({required this.message, required this.icon});

  final String message;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE0ECE7)),
      ),
      child: Row(
        children: [
          Icon(icon, color: AppTheme.authHeaderTeal),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              message,
              style: TextStyle(color: AppTheme.textGray),
            ),
          ),
        ],
      ),
    );
  }
}
