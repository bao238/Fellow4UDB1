import 'package:flutter/material.dart';

import '../app_theme.dart';
import 'guide_reviews_screen.dart';
import 'trip_information_screen.dart';

class GuidePageScreen extends StatelessWidget {
  const GuidePageScreen({
    super.key,
    required this.name,
    required this.location,
    required this.stars,
    required this.reviews,
    required this.avatarAsset,
    required this.headerAsset,
  });

  final String name;
  final String location;
  final int stars;
  final String reviews;
  final String avatarAsset;
  final String headerAsset;

  @override
  Widget build(BuildContext context) {
    final profile = _guideProfileFor(name, location);

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Stack(
                children: [
                  SizedBox(
                    height: 250,
                    width: double.infinity,
                    child: Image.asset(headerAsset, fit: BoxFit.cover),
                  ),
                  Positioned.fill(
                    child: DecoratedBox(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [
                            Colors.black.withValues(alpha: 0.18),
                            Colors.black.withValues(alpha: 0.1),
                            Colors.black.withValues(alpha: 0.42),
                          ],
                        ),
                      ),
                    ),
                  ),
                  Positioned(
                    top: 8,
                    left: 8,
                    child: IconButton(
                      icon: const Icon(Icons.arrow_back, color: Colors.white),
                      onPressed: () => Navigator.of(context).pop(),
                    ),
                  ),
                  Positioned(
                    top: 8,
                    right: 8,
                    child: IconButton(
                      icon: const Icon(
                        Icons.bookmark_border,
                        color: Colors.white,
                      ),
                      onPressed: () {},
                    ),
                  ),
                  Positioned(
                    bottom: 18,
                    left: 16,
                    right: 16,
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        CircleAvatar(
                          radius: 34,
                          backgroundColor: Colors.white,
                          child: ClipOval(
                            child: Image.asset(
                              avatarAsset,
                              width: 64,
                              height: 64,
                              fit: BoxFit.cover,
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                name,
                                style: const TextStyle(
                                  fontSize: 22,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                  shadows: [
                                    Shadow(
                                      color: Colors.black45,
                                      blurRadius: 8,
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(height: 4),
                              Row(
                                children: [
                                  ...List.generate(
                                    stars,
                                    (_) => Icon(
                                      Icons.star,
                                      size: 15,
                                      color: Colors.amber[700],
                                    ),
                                  ),
                                  const SizedBox(width: 6),
                                  Text(
                                    reviews,
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 12,
                                      fontWeight: FontWeight.w600,
                                      shadows: [
                                        Shadow(
                                          color: Colors.black45,
                                          blurRadius: 6,
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 5),
                              Row(
                                children: [
                                  const Icon(
                                    Icons.location_on,
                                    size: 14,
                                    color: Colors.white,
                                  ),
                                  const SizedBox(width: 4),
                                  Expanded(
                                    child: Text(
                                      location,
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontSize: 12,
                                        fontWeight: FontWeight.w500,
                                        shadows: [
                                          Shadow(
                                            color: Colors.black45,
                                            blurRadius: 6,
                                          ),
                                        ],
                                      ),
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 8),
                        SizedBox(
                          height: 38,
                          child: ElevatedButton(
                            onPressed: () {
                              Navigator.of(context).push(
                                MaterialPageRoute(
                                  builder: (_) => TripInformationScreen(
                                    guideName: name,
                                    guideLocation: location,
                                  ),
                                ),
                              );
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.white.withValues(
                                alpha: 0.94,
                              ),
                              foregroundColor: AppTheme.authHeaderTeal,
                              elevation: 0,
                              padding: const EdgeInsets.symmetric(
                                horizontal: 12,
                              ),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                            child: const Text(
                              'BOOK',
                              style: TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 18, 16, 22),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      profile.shortIntro,
                      style: TextStyle(
                        fontSize: 13,
                        color: AppTheme.textGray,
                        height: 1.55,
                      ),
                    ),
                    const SizedBox(height: 10),
                    Text(
                      profile.fullIntro,
                      style: TextStyle(
                        fontSize: 13,
                        color: AppTheme.textGray,
                        height: 1.55,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: [
                        _InfoChip(
                          icon: Icons.language_rounded,
                          label: profile.languages,
                        ),
                        _InfoChip(
                          icon: Icons.schedule_rounded,
                          label: profile.responseTime,
                        ),
                        _InfoChip(
                          icon: Icons.route_rounded,
                          label: profile.specialty,
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(16),
                      child: Stack(
                        children: [
                          SizedBox(
                            height: 180,
                            width: double.infinity,
                            child: Image.asset(headerAsset, fit: BoxFit.cover),
                          ),
                          Positioned.fill(
                            child: DecoratedBox(
                              decoration: BoxDecoration(
                                color: Colors.black.withValues(alpha: 0.16),
                              ),
                            ),
                          ),
                          Positioned.fill(
                            child: Center(
                              child: Container(
                                width: 52,
                                height: 52,
                                decoration: BoxDecoration(
                                  color: Colors.white.withValues(alpha: 0.88),
                                  shape: BoxShape.circle,
                                ),
                                child: Icon(
                                  Icons.play_arrow,
                                  color: AppTheme.authHeaderTeal,
                                  size: 30,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 14),
                    Container(
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: const Color(0xFFF7FBF9),
                        borderRadius: BorderRadius.circular(18),
                        border: Border.all(color: const Color(0xFFDCEEE7)),
                      ),
                      child: Column(
                        children: [
                          _priceRow('1 - 3 Travelers', '\$10 / hour'),
                          Divider(height: 18, color: AppTheme.dividerGray),
                          _priceRow('4 - 6 Travelers', '\$14 / hour'),
                          Divider(height: 18, color: AppTheme.dividerGray),
                          _priceRow('7 - 9 Travelers', '\$17 / hour'),
                        ],
                      ),
                    ),
                    const SizedBox(height: 22),
                    Row(
                      children: [
                        const Text(
                          'My Experiences',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF333333),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: const Color(0xFFEAF7F1),
                            borderRadius: BorderRadius.circular(999),
                          ),
                          child: Text(
                            'Featured',
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w700,
                              color: AppTheme.authHeaderTeal,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    ..._buildMyExperiences(),
                    const SizedBox(height: 20),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'Reviews',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF333333),
                          ),
                        ),
                        InkWell(
                          onTap: () {
                            Navigator.of(context).push(
                              MaterialPageRoute(
                                builder: (_) => GuideReviewsScreen(
                                  guideName: name,
                                  reviews: profile.reviews,
                                  rating: stars,
                                ),
                              ),
                            );
                          },
                          child: Padding(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 4,
                              vertical: 4,
                            ),
                            child: Text(
                              'SEE MORE',
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w700,
                                color: AppTheme.authHeaderTeal,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    for (final review in profile.reviews.take(2)) ...[
                      _reviewTile(review),
                      const SizedBox(height: 12),
                    ],
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _priceRow(String left, String right) {
    return Row(
      children: [
        Expanded(
          child: Text(
            left,
            style: const TextStyle(fontSize: 13, color: Color(0xFF333333)),
          ),
        ),
        Text(
          right,
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w700,
            color: AppTheme.textGray,
          ),
        ),
      ],
    );
  }

  Widget _reviewTile(GuideReviewItem review) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CircleAvatar(
            radius: 18,
            backgroundColor: const Color(0xFFEAF7F1),
            child: Text(
              review.name.isNotEmpty ? review.name[0] : '?',
              style: TextStyle(
                color: AppTheme.authHeaderTeal,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        review.name,
                        style: const TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w700,
                          color: Color(0xFF333333),
                        ),
                      ),
                    ),
                    Text(
                      review.date,
                      style: TextStyle(
                        fontSize: 11,
                        color: AppTheme.textLightGray,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                Text(
                  review.comment,
                  style: TextStyle(
                    fontSize: 12.5,
                    color: AppTheme.textGray,
                    height: 1.4,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  List<Widget> _buildMyExperiences() {
    final cards = switch (name) {
      'Emmy' => const [
          _ExperienceMosaicCard(
            leftImage: 'assets/images/exp_grid_2.png',
            rightTopImage: 'assets/images/exp_grid_3.png',
            rightBottomImage: 'assets/images/exp_grid_4.png',
            title: 'Street food in Hanoi',
            location: 'Hanoi, Vietnam',
            date: 'Feb 10, 2020',
            likes: '98 Likes',
          ),
          SizedBox(height: 14),
          _ExperienceMosaicCard(
            leftImage: 'assets/images/exp_grid_1.png',
            rightTopImage: 'assets/images/exp_grid_5.png',
            rightBottomImage: 'assets/images/exp_grid_6.png',
            title: 'Coffee hopping',
            location: 'Hanoi, Vietnam',
            date: 'Jan 28, 2020',
            likes: '312 Likes',
          ),
        ],
      'Linh Hana' => const [
          _ExperienceMosaicCard(
            leftImage: 'assets/images/exp_grid_6.png',
            rightTopImage: 'assets/images/exp_grid_1.png',
            rightBottomImage: 'assets/images/exp_grid_5.png',
            title: 'Local market tour',
            location: 'Da Nang, Vietnam',
            date: 'Feb 2, 2020',
            likes: '451 Likes',
          ),
          SizedBox(height: 14),
          _ExperienceMosaicCard(
            leftImage: 'assets/images/exp_grid_3.png',
            rightTopImage: 'assets/images/exp_grid_2.png',
            rightBottomImage: 'assets/images/exp_grid_4.png',
            title: 'Family food class',
            location: 'Da Nang, Vietnam',
            date: 'Jan 18, 2020',
            likes: '210 Likes',
          ),
        ],
      'Khai Ho' => const [
          _ExperienceMosaicCard(
            leftImage: 'assets/images/exp_grid_5.png',
            rightTopImage: 'assets/images/exp_grid_6.png',
            rightBottomImage: 'assets/images/exp_grid_2.png',
            title: 'Saigon food tour',
            location: 'Ho Chi Minh City, Vietnam',
            date: 'Feb 14, 2020',
            likes: '530 Likes',
          ),
          SizedBox(height: 14),
          _ExperienceMosaicCard(
            leftImage: 'assets/images/exp_grid_4.png',
            rightTopImage: 'assets/images/exp_grid_1.png',
            rightBottomImage: 'assets/images/exp_grid_3.png',
            title: 'Riverside walk',
            location: 'Ho Chi Minh City, Vietnam',
            date: 'Jan 12, 2020',
            likes: '144 Likes',
          ),
        ],
      _ => const [
          _ExperienceMosaicCard(
            leftImage: 'assets/images/exp_grid_6.png',
            rightTopImage: 'assets/images/exp_grid_5.png',
            rightBottomImage: 'assets/images/exp_grid_1.png',
            title: '2 Hour Bicycle Tour exploring Hoian',
            location: 'Hoi An, Vietnam',
            date: 'Jan 25, 2020',
            likes: '1234 Likes',
          ),
          SizedBox(height: 14),
          _ExperienceMosaicCard(
            leftImage: 'assets/images/exp_grid_4.png',
            rightTopImage: 'assets/images/exp_grid_2.png',
            rightBottomImage: 'assets/images/exp_grid_3.png',
            title: 'Food tour in Danang',
            location: 'Da Nang, Vietnam',
            date: 'Jan 20, 2020',
            likes: '234 Likes',
          ),
        ],
    };

    return [...cards];
  }

  _GuideProfileContent _guideProfileFor(String guideName, String guideLocation) {
    return switch (guideName) {
      'Tuan Tran' => const _GuideProfileContent(
          shortIntro:
              'Friendly local guide focused on food alleys, beach routes, and quick half-day city plans.',
          fullIntro:
              'Tuan usually builds flexible itineraries for solo travelers and couples who want a local pace instead of a crowded group schedule.',
          languages: 'Vietnamese | English',
          responseTime: 'Replies in 15 mins',
          specialty: 'Food and city rides',
          reviews: <GuideReviewItem>[
            GuideReviewItem(
              name: 'Pena Valdez',
              date: 'Aug 21, 2020',
              comment:
                  'Tuan kept the tour efficient and still relaxed. The food stops felt local instead of touristy.',
            ),
            GuideReviewItem(
              name: 'Daehyun',
              date: 'Jun 22, 2020',
              comment:
                  'Clear communication, strong English, and good timing. I would book him again for Da Nang.',
            ),
            GuideReviewItem(
              name: 'Anna Lee',
              date: 'May 03, 2020',
              comment:
                  'He adjusted the route around the weather and still covered the best viewpoints before sunset.',
            ),
          ],
        ),
      'Linh Hana' => const _GuideProfileContent(
          shortIntro:
              'Warm, calm guide for family trips, market walks, and easy introductions to local culture.',
          fullIntro:
              'Linh is strongest when the trip needs a gentle pace, clear planning, and extra attention for kids or first-time visitors.',
          languages: 'Vietnamese | English | Korean',
          responseTime: 'Replies in 30 mins',
          specialty: 'Family and culture',
          reviews: <GuideReviewItem>[
            GuideReviewItem(
              name: 'Min Ji',
              date: 'Jul 11, 2020',
              comment:
                  'Linh was patient with our family and gave good context at every stop. Very comfortable day.',
            ),
            GuideReviewItem(
              name: 'Tobias Hart',
              date: 'May 27, 2020',
              comment:
                  'Strong organization and good recommendations for quieter places to eat after the tour.',
            ),
            GuideReviewItem(
              name: 'Nhan Tran',
              date: 'Apr 09, 2020',
              comment:
                  'Easy to talk to and very thoughtful with small details, especially for our parents.',
            ),
          ],
        ),
      'Khai Ho' => const _GuideProfileContent(
          shortIntro:
              'Fast-moving city guide who mixes landmark routes with coffee, nightlife, and modern neighborhoods.',
          fullIntro:
              'Khai works well for travelers who want a sharper pace, strong city energy, and a practical route through busy districts.',
          languages: 'Vietnamese | English',
          responseTime: 'Replies in 20 mins',
          specialty: 'Urban and nightlife',
          reviews: <GuideReviewItem>[
            GuideReviewItem(
              name: 'Marcus Reed',
              date: 'Aug 08, 2020',
              comment:
                  'Khai packed a lot into one afternoon without making it feel rushed. Great city knowledge.',
            ),
            GuideReviewItem(
              name: 'Hoang Pham',
              date: 'Jun 16, 2020',
              comment:
                  'He knew exactly where to go to avoid traffic and still show the best spots for photos.',
            ),
            GuideReviewItem(
              name: 'Eri Sato',
              date: 'May 14, 2020',
              comment:
                  'Perfect guide for people who want a more energetic local experience and clear recommendations.',
            ),
          ],
        ),
      _ => _GuideProfileContent(
          shortIntro:
              '$guideName shares local routes, practical tips, and short custom plans built around the area.',
          fullIntro:
              'This guide profile is connected to the current API data and can be expanded further as you add more content to SQL.',
          languages: 'Vietnamese | English',
          responseTime: 'Replies in under 1 hour',
          specialty: guideLocation,
          reviews: const <GuideReviewItem>[
            GuideReviewItem(
              name: 'Pena Valdez',
              date: 'Aug 21, 2020',
              comment:
                  'Very smooth communication and a good sense of what first-time visitors actually need.',
            ),
            GuideReviewItem(
              name: 'Daehyun',
              date: 'Jun 22, 2020',
              comment:
                  'The guide adapted the route well and kept the experience practical instead of scripted.',
            ),
            GuideReviewItem(
              name: 'Maria Costa',
              date: 'May 03, 2020',
              comment:
                  'Good balance between sightseeing and local recommendations that we could reuse later.',
            ),
          ],
        ),
    };
  }
}

class _GuideProfileContent {
  const _GuideProfileContent({
    required this.shortIntro,
    required this.fullIntro,
    required this.languages,
    required this.responseTime,
    required this.specialty,
    required this.reviews,
  });

  final String shortIntro;
  final String fullIntro;
  final String languages;
  final String responseTime;
  final String specialty;
  final List<GuideReviewItem> reviews;
}

class _InfoChip extends StatelessWidget {
  const _InfoChip({required this.icon, required this.label});

  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: const Color(0xFFF7FBF9),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFDCEEE7)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: AppTheme.authHeaderTeal),
          const SizedBox(width: 8),
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              color: AppTheme.textGray,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}

class _ExperienceMosaicCard extends StatelessWidget {
  const _ExperienceMosaicCard({
    required this.leftImage,
    required this.rightTopImage,
    required this.rightBottomImage,
    required this.title,
    required this.location,
    required this.date,
    required this.likes,
  });

  final String leftImage;
  final String rightTopImage;
  final String rightBottomImage;
  final String title;
  final String location;
  final String date;
  final String likes;

  @override
  Widget build(BuildContext context) {
    return Container(
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
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ClipRRect(
            borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
            child: AspectRatio(
              aspectRatio: 1.9,
              child: Row(
                children: [
                  Expanded(
                    flex: 3,
                    child: Image.asset(leftImage, fit: BoxFit.cover),
                  ),
                  Expanded(
                    flex: 2,
                    child: Column(
                      children: [
                        Expanded(
                          child: Image.asset(rightTopImage, fit: BoxFit.cover),
                        ),
                        Expanded(
                          child: Image.asset(
                            rightBottomImage,
                            fit: BoxFit.cover,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(12, 12, 12, 12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF333333),
                  ),
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Icon(
                      Icons.location_on,
                      size: 14,
                      color: AppTheme.authHeaderTeal,
                    ),
                    const SizedBox(width: 4),
                    Expanded(
                      child: Text(
                        location,
                        style: TextStyle(
                          fontSize: 12,
                          color: AppTheme.authHeaderTeal,
                          fontWeight: FontWeight.w500,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                Row(
                  children: [
                    Text(
                      date,
                      style: TextStyle(
                        fontSize: 12,
                        color: AppTheme.textLightGray,
                      ),
                    ),
                    const Spacer(),
                    Icon(
                      Icons.favorite_border,
                      size: 18,
                      color: AppTheme.textLightGray,
                    ),
                    const SizedBox(width: 6),
                    Text(
                      likes,
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
    );
  }
}
