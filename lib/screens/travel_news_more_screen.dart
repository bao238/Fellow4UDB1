import 'package:flutter/material.dart';

import '../app_theme.dart';

class TravelNewsMoreScreen extends StatelessWidget {
  const TravelNewsMoreScreen({super.key});

  static const List<_NewsItem> _items = <_NewsItem>[
    _NewsItem(
      title: 'New Destination in Danang City',
      date: 'Feb 15, 2020',
      category: 'Destination',
      imageAsset: 'assets/images/news_danang.png',
      excerpt:
          'Discover quiet beaches, seafood streets, and a cleaner riverfront route for sunrise walks.',
    ),
    _NewsItem(
      title: '\$1 Flight Ticket',
      date: 'Feb 8, 2020',
      category: 'Deals',
      imageAsset: 'assets/images/news_flight.png',
      excerpt:
          'Airlines are opening limited flash-sale seats for weekday routes from major Vietnam hubs.',
    ),
    _NewsItem(
      title: 'Visit Hoian In this Tet Holiday',
      date: 'Jan 26, 2020',
      category: 'Culture',
      imageAsset: 'assets/images/news_tet_korea.png',
      excerpt:
          'Lantern streets, old-town food tours, and family workshops are drawing heavier holiday traffic.',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF7FBF9),
      body: SafeArea(
        child: CustomScrollView(
          slivers: [
            SliverAppBar(
              backgroundColor: Colors.white,
              pinned: true,
              elevation: 0,
              surfaceTintColor: Colors.white,
              leading: IconButton(
                icon: const Icon(Icons.arrow_back, color: Color(0xFF1E2A26)),
                onPressed: () => Navigator.of(context).pop(),
              ),
              title: const Text(
                'Travel News',
                style: TextStyle(
                  color: Color(0xFF1E2A26),
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 12, 20, 8),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Fresh updates for your next trip',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.w700,
                        color: Color(0xFF1E2A26),
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      'News, deals, and destination ideas collected for Fellow4U travelers.',
                      style: TextStyle(
                        fontSize: 14,
                        color: AppTheme.textGray,
                        height: 1.4,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            SliverPadding(
              padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
              sliver: SliverList.builder(
                itemCount: _items.length,
                itemBuilder: (context, index) {
                  final item = _items[index];
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 16),
                    child: _NewsCard(item: item),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _NewsCard extends StatelessWidget {
  const _NewsCard({required this.item});

  final _NewsItem item;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 14,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ClipRRect(
            borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
            child: AspectRatio(
              aspectRatio: 1.8,
              child: Image.asset(item.imageAsset, fit: BoxFit.cover),
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 18),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 5,
                  ),
                  decoration: BoxDecoration(
                    color: const Color(0xFFEAF7F1),
                    borderRadius: BorderRadius.circular(999),
                  ),
                  child: Text(
                    item.category,
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                      color: AppTheme.authHeaderTeal,
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  item.title,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF1E2A26),
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  item.excerpt,
                  style: TextStyle(
                    fontSize: 14,
                    color: AppTheme.textGray,
                    height: 1.5,
                  ),
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Icon(
                      Icons.calendar_today_outlined,
                      size: 14,
                      color: AppTheme.textLightGray,
                    ),
                    const SizedBox(width: 6),
                    Text(
                      item.date,
                      style: TextStyle(
                        fontSize: 12,
                        color: AppTheme.textLightGray,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const Spacer(),
                    Text(
                      'Fellow4U News',
                      style: TextStyle(
                        fontSize: 12,
                        color: AppTheme.authHeaderTeal,
                        fontWeight: FontWeight.w700,
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
}

class _NewsItem {
  const _NewsItem({
    required this.title,
    required this.date,
    required this.category,
    required this.imageAsset,
    required this.excerpt,
  });

  final String title;
  final String date;
  final String category;
  final String imageAsset;
  final String excerpt;
}
