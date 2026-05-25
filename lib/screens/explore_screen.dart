import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../app_theme.dart';
import '../core/network/api_result.dart';
import '../features/explore/presentation/controllers/explore_api_controller.dart';
import 'guide_page_screen.dart';
import 'guides_more_screen.dart';
import 'notifications_screen.dart';
import 'profile_screen.dart';
import 'search_screen.dart';
import 'trips_screen.dart';
import 'chat_screen.dart';
import 'tour_detail_screen.dart';
import 'tours_more_screen.dart';
import 'travel_news_more_screen.dart';

class ExploreScreen extends StatefulWidget {
  const ExploreScreen({super.key});

  @override
  State<ExploreScreen> createState() => _ExploreScreenState();
}

class _ExploreScreenState extends State<ExploreScreen> {
  final ExploreApiController _controller = ExploreApiController();

  int _currentIndex = 0;
  bool _loading = true;
  String? _error;
  List<JourneyApiItem> _journeys = const <JourneyApiItem>[];
  List<GuideApiItem> _guides = const <GuideApiItem>[];
  List<ExperienceApiItem> _experiences = const <ExperienceApiItem>[];

  static const List<({String title, String date, String imageAsset})> _news = [
    (
      title: 'New Destination in Danang City',
      date: 'Feb 15, 2020',
      imageAsset: 'assets/images/news_danang.png',
    ),
    (
      title: '\$1 Flight Ticket',
      date: 'Feb 8, 2020',
      imageAsset: 'assets/images/news_flight.png',
    ),
    (
      title: 'Visit Hoian In this Tet Holiday',
      date: 'Jan 26, 2020',
      imageAsset: 'assets/images/news_tet_korea.png',
    ),
  ];

  @override
  void initState() {
    super.initState();
    SystemChrome.setSystemUIOverlayStyle(
      const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.dark,
      ),
    );
    _loadData();
  }

  Future<void> _loadData() async {
    if (mounted) {
      setState(() {
        _loading = true;
        _error = null;
      });
    }

    try {
      final results = await Future.wait([
        _controller.getTopJourneys(),
        _controller.getBestGuides(),
        _controller.getTopExperiences(),
      ]);

      if (!mounted) return;

      final journeys = results[0] as ApiResult<List<JourneyApiItem>>;
      final guides = results[1] as ApiResult<List<GuideApiItem>>;
      final experiences = results[2] as ApiResult<List<ExperienceApiItem>>;

      setState(() {
        _journeys = journeys.data ?? const <JourneyApiItem>[];
        _guides = guides.data ?? const <GuideApiItem>[];
        _experiences = experiences.data ?? const <ExperienceApiItem>[];
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
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: _loadData,
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.only(bottom: 88),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildHeaderWithSearch(),
                if (_loading) const LinearProgressIndicator(minHeight: 2),
                if (_error != null) _buildErrorCard(),
                const SizedBox(height: 20),
                _buildSectionHeader(
                  'Top Journeys',
                  seeMore: true,
                  onSeeMore: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (_) => ToursMoreScreen(initialTours: _journeys),
                      ),
                    );
                  },
                ),
                const SizedBox(height: 12),
                _buildTopJourneys(),
                const SizedBox(height: 24),
                _buildSectionHeader(
                  'Best Guides',
                  seeMore: true,
                  onSeeMore: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (_) =>
                            GuidesMoreScreen(initialGuides: _guides),
                      ),
                    );
                  },
                ),
                const SizedBox(height: 12),
                _buildBestGuides(),
                const SizedBox(height: 24),
                _buildSectionHeader('Top Experiences'),
                const SizedBox(height: 12),
                _buildTopExperiences(),
                const SizedBox(height: 24),
                _buildSectionHeader(
                  'Featured Tours',
                  seeMore: true,
                  onSeeMore: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (_) => ToursMoreScreen(initialTours: _journeys),
                      ),
                    );
                  },
                ),
                const SizedBox(height: 12),
                _buildFeaturedTours(),
                const SizedBox(height: 24),
                _buildSectionHeader(
                  'Travel News',
                  seeMore: true,
                  onSeeMore: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (_) => const TravelNewsMoreScreen(),
                      ),
                    );
                  },
                ),
                const SizedBox(height: 12),
                _buildTravelNews(),
              ],
            ),
          ),
        ),
      ),
      bottomNavigationBar: _buildBottomNav(),
    );
  }

  Widget _buildHeaderWithSearch() {
    return Stack(
      children: [
        SizedBox(
          height: 224,
          width: double.infinity,
          child: Image.asset(
            'assets/images/explore_header_danang.png',
            fit: BoxFit.cover,
          ),
        ),
        Container(
          height: 224,
          width: double.infinity,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                Colors.black.withValues(alpha: 0.22),
                Colors.black.withValues(alpha: 0.10),
                Colors.black.withValues(alpha: 0.03),
              ],
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Row(
                children: [
                  Text(
                    'Explore',
                    style: TextStyle(
                      fontSize: 32,
                      fontWeight: FontWeight.w800,
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  _headerChip(Icons.location_on_outlined, 'Da Nang'),
                  _headerChip(Icons.wb_sunny_outlined, '26°C'),
                  _headerChip(Icons.trending_up_rounded, 'Best season'),
                ],
              ),
              const SizedBox(height: 16),
              GestureDetector(
                onTap: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(builder: (_) => const SearchScreen()),
                  );
                },
                child: Container(
                  height: 50,
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.96),
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.06),
                        blurRadius: 10,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  alignment: Alignment.centerLeft,
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Row(
                    children: [
                      Icon(
                        Icons.search,
                        color: AppTheme.textLightGray,
                        size: 22,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        'Hi, where do you want to explore?',
                        style: TextStyle(
                          fontSize: 14,
                          color: const Color(0xFF8B9A95),
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 12),
              SizedBox(
                height: 30,
                child: ListView(
                  scrollDirection: Axis.horizontal,
                  children: const [
                    _QuickTag(label: 'Nearby'),
                    SizedBox(width: 8),
                    _QuickTag(label: 'Food'),
                    SizedBox(width: 8),
                    _QuickTag(label: 'Culture'),
                    SizedBox(width: 8),
                    _QuickTag(label: 'Family'),
                  ],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildErrorCard() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 0),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: const Color(0xFFFFF5F5),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: const Color(0xFFFFC9C9)),
        ),
        child: Row(
          children: [
            const Icon(Icons.wifi_off_rounded, color: Color(0xFFC74646)),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                'Could not load API data. Pull to refresh or reopen the local API server.',
                style: TextStyle(
                  color: AppTheme.textDark,
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
            TextButton(
              onPressed: _loadData,
              child: const Text('Retry'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionHeader(
    String title, {
    bool seeMore = false,
    VoidCallback? onSeeMore,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Color(0xFF333333),
            ),
          ),
          if (seeMore)
            GestureDetector(
              onTap: onSeeMore,
              behavior: HitTestBehavior.opaque,
              child: Text(
                'SEE MORE',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: AppTheme.authHeaderTeal,
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildTopJourneys() {
    if (_journeys.isEmpty) {
      return _buildEmptySection('No journeys loaded yet.');
    }

    return SizedBox(
      height: 240,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 20),
        itemCount: _journeys.length,
        separatorBuilder: (_, _) => const SizedBox(width: 12),
        itemBuilder: (context, index) => _journeyCard(_journeys[index]),
      ),
    );
  }

  Widget _journeyCard(JourneyApiItem item) {
    return InkWell(
      onTap: () {
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (_) => TourDetailScreen(
              title: item.title,
              imageAsset: item.imageAsset,
              price: item.price,
            ),
          ),
        );
      },
      child: Container(
        width: 200,
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
            SizedBox(
              height: 130,
              child: Stack(
                clipBehavior: Clip.hardEdge,
                children: [
                  Positioned.fill(
                    child: ClipRRect(
                      borderRadius: const BorderRadius.vertical(
                        top: Radius.circular(12),
                      ),
                      child: Image.asset(item.imageAsset, fit: BoxFit.cover),
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
                            item.stars,
                            (_) => const Icon(
                              Icons.star,
                              size: 14,
                              color: Colors.amber,
                            ),
                          ),
                          if (item.km != null) ...[
                            const SizedBox(width: 4),
                            Text(
                              item.km!,
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
                  if (item.bookmark)
                    const Positioned(
                      top: 8,
                      right: 8,
                      child: Icon(
                        Icons.bookmark_border,
                        color: Colors.white,
                        size: 24,
                      ),
                    ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    item.title,
                    style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF333333),
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Icon(
                        Icons.calendar_today,
                        size: 12,
                        color: AppTheme.textLightGray,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        item.date,
                        style: TextStyle(
                          fontSize: 11,
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
                        item.days,
                        style: TextStyle(
                          fontSize: 11,
                          color: AppTheme.textLightGray,
                        ),
                      ),
                      const Spacer(),
                      Text(
                        item.price,
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: AppTheme.authHeaderTeal,
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

  Widget _buildBestGuides() {
    if (_guides.isEmpty) {
      return _buildEmptySection('No guides loaded yet.');
    }

    return SizedBox(
      height: 155,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 20),
        itemCount: _guides.length,
        separatorBuilder: (_, _) => const SizedBox(width: 16),
        itemBuilder: (context, index) => _guideCard(_guides[index]),
      ),
    );
  }

  Widget _guideCard(GuideApiItem item) {
    const double size = 88;

    return InkWell(
      onTap: () {
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (_) => GuidePageScreen(
              name: item.name,
              location: item.location,
              stars: item.stars,
              reviews: item.reviews,
              avatarAsset: item.avatarAsset,
              headerAsset: item.headerAsset,
            ),
          ),
        );
      },
      child: SizedBox(
        width: size,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Stack(
              alignment: Alignment.bottomCenter,
              children: [
                ClipOval(
                  child: SizedBox(
                    width: size,
                    height: size,
                    child: Image.asset(item.avatarAsset, fit: BoxFit.cover),
                  ),
                ),
                Positioned(
                  bottom: 4,
                  left: 4,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 5,
                      vertical: 3,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.black.withValues(alpha: 0.55),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisSize: MainAxisSize.min,
                          children: List.generate(
                            item.stars,
                            (_) => const Icon(
                              Icons.star,
                              size: 10,
                              color: Colors.amber,
                            ),
                          ),
                        ),
                        const SizedBox(height: 1),
                        Text(
                          item.reviews,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 9,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            SizedBox(
              width: size,
              child: Text(
                item.name,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF333333),
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            const SizedBox(height: 2),
            SizedBox(
              width: size,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.location_on,
                    size: 12,
                    color: AppTheme.authHeaderTeal,
                  ),
                  const SizedBox(width: 2),
                  Flexible(
                    child: Text(
                      item.location,
                      style: TextStyle(
                        fontSize: 11,
                        color: AppTheme.authHeaderTeal,
                        fontWeight: FontWeight.w500,
                      ),
                      overflow: TextOverflow.ellipsis,
                      textAlign: TextAlign.center,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTopExperiences() {
    if (_experiences.isEmpty) {
      return _buildEmptySection('No experiences loaded yet.');
    }

    return SizedBox(
      height: 200,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 20),
        itemCount: _experiences.length,
        separatorBuilder: (_, _) => const SizedBox(width: 12),
        itemBuilder: (context, index) => _experienceCard(_experiences[index]),
      ),
    );
  }

  Widget _experienceCard(ExperienceApiItem item) {
    return Container(
      width: 200,
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
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(12),
                ),
                child: SizedBox(
                  height: 120,
                  width: double.infinity,
                  child: Image.asset(item.imageAsset, fit: BoxFit.cover),
                ),
              ),
              Positioned(
                bottom: 8,
                right: 8,
                child: CircleAvatar(
                  radius: 16,
                  backgroundColor: Colors.white,
                  child: Text(
                    item.guideName.isNotEmpty
                        ? item.guideName[0].toUpperCase()
                        : '?',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: AppTheme.authHeaderTeal,
                    ),
                  ),
                ),
              ),
            ],
          ),
          Padding(
            padding: const EdgeInsets.all(10),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item.title,
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF333333),
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    Icon(
                      Icons.location_on,
                      size: 12,
                      color: AppTheme.textLightGray,
                    ),
                    const SizedBox(width: 4),
                    Expanded(
                      child: Text(
                        item.location,
                        style: TextStyle(
                          fontSize: 11,
                          color: AppTheme.textLightGray,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFeaturedTours() {
    if (_journeys.isEmpty) {
      return _buildEmptySection('No featured tours yet.');
    }

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        children: [
          for (final journey in _journeys.take(3))
            Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: _featuredTourCard(journey),
            ),
        ],
      ),
    );
  }

  Widget _featuredTourCard(JourneyApiItem item) {
    return InkWell(
      onTap: () {
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (_) => TourDetailScreen(
              title: item.title,
              imageAsset: item.imageAsset,
              price: item.price,
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
                  borderRadius: const BorderRadius.vertical(
                    top: Radius.circular(12),
                  ),
                  child: SizedBox(
                    height: 140,
                    width: double.infinity,
                    child: Image.asset(item.imageAsset, fit: BoxFit.cover),
                  ),
                ),
                if (item.km != null)
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
                            item.stars,
                            (_) => const Icon(
                              Icons.star,
                              size: 14,
                              color: Colors.amber,
                            ),
                          ),
                          const SizedBox(width: 4),
                          Text(
                            item.km!,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 11,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                const Positioned(
                  top: 8,
                  right: 8,
                  child: Icon(
                    Icons.bookmark_border,
                    color: Colors.white,
                    size: 24,
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
                          item.title,
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: Color(0xFF333333),
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      Icon(
                        Icons.favorite,
                        size: 20,
                        color: AppTheme.authHeaderTeal,
                      ),
                      const SizedBox(width: 6),
                      Text(
                        item.price,
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
                        item.date,
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
                        item.days,
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

  Widget _buildTravelNews() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        children: [
          for (final item in _news)
            Padding(
              padding: const EdgeInsets.only(bottom: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    item.title,
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF333333),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    item.date,
                    style: TextStyle(
                      fontSize: 12,
                      color: AppTheme.textLightGray,
                    ),
                  ),
                  const SizedBox(height: 8),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: SizedBox(
                      width: double.infinity,
                      height: 140,
                      child: Image.asset(item.imageAsset, fit: BoxFit.cover),
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildEmptySection(String message) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 20),
      child: Center(
        child: Text(
          message,
          style: TextStyle(fontSize: 14, color: AppTheme.textLightGray),
        ),
      ),
    );
  }

  Widget _buildBottomNav() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.06),
            blurRadius: 10,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 6),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _navItem(0, Icons.explore, 'Explore'),
              _navItem(1, Icons.location_on, 'Trips'),
              _navItem(2, Icons.chat_bubble_outline, 'Chat'),
              _navItem(3, Icons.notifications_none, 'Notifications'),
              _navItem(4, Icons.person_outline, 'Profile'),
            ],
          ),
        ),
      ),
    );
  }

  Widget _navItem(int index, IconData icon, String label) {
    final isSelected = _currentIndex == index;

    return GestureDetector(
      onTap: () {
        if (index == 3) {
          Navigator.of(context).push(
            MaterialPageRoute(builder: (_) => const NotificationsScreen()),
          );
          return;
        }
        if (index == 4) {
          Navigator.of(context).push(
            MaterialPageRoute(builder: (_) => const ProfileScreen()),
          );
          return;
        }
        if (index == 1 || index == 2) {
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (_) =>
                  index == 1 ? const TripsScreen() : const ChatScreen(),
            ),
          );
          return;
        }
        setState(() => _currentIndex = index);
      },
      behavior: HitTestBehavior.opaque,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 30,
            height: 30,
            decoration: BoxDecoration(
              color: isSelected
                  ? AppTheme.authHeaderTeal.withValues(alpha: 0.14)
                  : Colors.transparent,
              borderRadius: BorderRadius.circular(10),
            ),
            alignment: Alignment.center,
            child: Icon(
              icon,
              size: 20,
              color: isSelected
                  ? AppTheme.authHeaderTeal
                  : AppTheme.textLightGray,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: TextStyle(
              fontSize: 11,
              color: isSelected
                  ? AppTheme.authHeaderTeal
                  : AppTheme.textLightGray,
              fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
            ),
          ),
        ],
      ),
    );
  }

  Widget _headerChip(IconData icon, String text) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.17),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: Colors.white.withValues(alpha: 0.32)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: Colors.white),
          const SizedBox(width: 5),
          Text(
            text,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 12,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}

class _QuickTag extends StatelessWidget {
  const _QuickTag({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 11, vertical: 5),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.2),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: Colors.white.withValues(alpha: 0.33)),
      ),
      child: Text(
        label,
        style: const TextStyle(
          color: Colors.white,
          fontSize: 11.5,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}
