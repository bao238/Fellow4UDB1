import 'package:flutter/material.dart';

import '../app_theme.dart';
import '../features/explore/presentation/controllers/explore_api_controller.dart';
import 'guide_page_screen.dart';

class GuidesMoreScreen extends StatefulWidget {
  const GuidesMoreScreen({super.key, this.initialGuides = const []});

  final List<GuideApiItem> initialGuides;

  @override
  State<GuidesMoreScreen> createState() => _GuidesMoreScreenState();
}

class _GuidesMoreScreenState extends State<GuidesMoreScreen> {
  final ExploreApiController _controller = ExploreApiController();
  final TextEditingController _searchController = TextEditingController();

  bool _loading = false;
  String? _error;
  List<GuideApiItem> _guides = const <GuideApiItem>[];

  @override
  void initState() {
    super.initState();
    _guides = widget.initialGuides;
    if (_guides.isEmpty) {
      _loadGuides();
    }
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadGuides() async {
    setState(() {
      _loading = true;
      _error = null;
    });

    try {
      final result = await _controller.getBestGuides();
      if (!mounted) return;
      setState(() {
        _guides = result.data ?? const <GuideApiItem>[];
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
    final filteredGuides = _guides
        .where(
          (guide) =>
              query.isEmpty ||
              guide.name.toLowerCase().contains(query) ||
              guide.location.toLowerCase().contains(query),
        )
        .toList();

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: _loadGuides,
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
                    title: 'Book your own private local\nGuide and explore the city',
                    controller: _searchController,
                    onChanged: (_) => setState(() {}),
                    onRefreshTap: _loadGuides,
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
                      message: 'Could not load guides. Pull to refresh.',
                      icon: Icons.wifi_off_rounded,
                    ),
                  ),
                )
              else if (filteredGuides.isEmpty)
                const SliverToBoxAdapter(
                  child: Padding(
                    padding: EdgeInsets.fromLTRB(16, 16, 16, 0),
                    child: _StateCard(
                      message: 'No guides match your search.',
                      icon: Icons.person_search_rounded,
                    ),
                  ),
                )
              else
                SliverPadding(
                  padding: const EdgeInsets.fromLTRB(16, 16, 16, 16),
                  sliver: SliverGrid(
                    delegate: SliverChildBuilderDelegate(
                      (context, index) {
                        final guide = filteredGuides[index];
                        return _GuideGridCard(guide: guide);
                      },
                      childCount: filteredGuides.length,
                    ),
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      crossAxisSpacing: 12,
                      mainAxisSpacing: 12,
                      childAspectRatio: 0.78,
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
                          hintText: 'Search guides',
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

class _GuideGridCard extends StatelessWidget {
  const _GuideGridCard({required this.guide});

  final GuideApiItem guide;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () {
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (_) => GuidePageScreen(
              name: guide.name,
              location: guide.location,
              stars: guide.stars,
              reviews: guide.reviews,
              avatarAsset: guide.avatarAsset,
              headerAsset: guide.headerAsset,
            ),
          ),
        );
      },
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: Stack(
                children: [
                  Positioned.fill(
                    child: Image.asset(
                      guide.avatarAsset,
                      fit: BoxFit.cover,
                    ),
                  ),
                  Positioned(
                    left: 8,
                    bottom: 8,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 6,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.black.withValues(alpha: 0.6),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          ...List.generate(
                            guide.stars,
                            (_) => const Icon(
                              Icons.star,
                              size: 12,
                              color: Colors.amber,
                            ),
                          ),
                          const SizedBox(width: 4),
                          Text(
                            guide.reviews,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 10,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 6),
          Text(
            guide.name,
            style: const TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: Color(0xFF333333),
            ),
          ),
          const SizedBox(height: 2),
          Row(
            children: [
              Icon(Icons.location_on, size: 12, color: AppTheme.authHeaderTeal),
              const SizedBox(width: 4),
              Expanded(
                child: Text(
                  guide.location,
                  style: TextStyle(fontSize: 11, color: AppTheme.authHeaderTeal),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
        ],
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
