import 'package:flutter/material.dart';

import '../app_theme.dart';
import '../features/notifications/presentation/controllers/notifications_api_controller.dart';
import 'chat_screen.dart';
import 'explore_screen.dart';
import 'profile_screen.dart';
import 'search_screen.dart';
import 'trips_screen.dart';

class NotificationsScreen extends StatefulWidget {
  const NotificationsScreen({super.key});

  @override
  State<NotificationsScreen> createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends State<NotificationsScreen> {
  final NotificationsApiController _controller = NotificationsApiController();
  bool _loading = true;
  String? _error;
  List<_NotificationItem> _items = const <_NotificationItem>[];

  static const List<_NotificationItem> _fallbackItems = <_NotificationItem>[
    _NotificationItem(
      avatarAsset: 'assets/images/guide_tuan_tran.png',
      message:
          'Tuan Tran accepted your request for the trip in Danang, Vietnam on Jan 20, 2020',
      date: 'Jan 16',
      accentColor: Color(0xFF8BC34A),
      badgeIcon: Icons.check,
    ),
    _NotificationItem(
      avatarAsset: 'assets/images/guide_emmy.png',
      message:
          'Emmy sent you an offer for the trip in Ho Chi Minh, Vietnam on Feb 12, 2020',
      date: 'Jan 16',
      accentColor: Color(0xFFFFC107),
      badgeIcon: Icons.attach_money,
    ),
    _NotificationItem(
      avatarAsset: 'assets/images/app_icon.png',
      message:
          'Thanks! Your trip in Danang, Vietnam on Jan 20, 2020 has been finished. Please leave a review for the guide Tuan Tran.',
      date: 'Jan 24',
      accentColor: Color(0xFF3F8CFF),
      badgeIcon: Icons.rate_review,
      showReviewButton: true,
    ),
  ];

  @override
  void initState() {
    super.initState();
    _loadNotifications();
  }

  Future<void> _loadNotifications() async {
    if (mounted) {
      setState(() {
        _loading = true;
        _error = null;
      });
    }

    try {
      final result = await _controller.getNotifications();
      if (!mounted) return;

      final items = (result.data ?? const <NotificationApiItem>[])
          .map(
            (item) => _NotificationItem(
              avatarAsset: item.actorAvatar,
              message: item.message,
              date: item.date,
              accentColor: _parseColor(item.accentColor),
              badgeIcon: _parseBadgeIcon(item.badgeIcon),
              showReviewButton: item.showReviewButton,
            ),
          )
          .toList();

      setState(() {
        _items = items.isEmpty ? _fallbackItems : items;
        _loading = false;
      });
    } catch (error) {
      if (!mounted) return;
      setState(() {
        _loading = false;
        _error = error.toString();
        _items = _fallbackItems;
      });
    }
  }

  Color _parseColor(String hex) {
    final value = hex.replaceAll('#', '').trim();
    if (value.length == 6) {
      final raw = int.tryParse('FF$value', radix: 16);
      if (raw != null) return Color(raw);
    }
    return const Color(0xFF3F8CFF);
  }

  IconData _parseBadgeIcon(String iconName) {
    return switch (iconName) {
      'check' => Icons.check,
      'attach_money' => Icons.attach_money,
      'rate_review' => Icons.rate_review,
      'done_all' => Icons.done_all,
      'favorite' => Icons.favorite,
      _ => Icons.notifications,
    };
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF7F7F7),
      body: SafeArea(
        child: Column(
          children: [
            _NotificationsHeader(
              onSearchTap: () {
                Navigator.of(context).push(
                  MaterialPageRoute(builder: (_) => const SearchScreen()),
                );
              },
            ),
            if (_loading) const LinearProgressIndicator(minHeight: 2),
            if (_error != null) _buildErrorBanner(),
            Expanded(
              child: RefreshIndicator(
                onRefresh: _loadNotifications,
                child: ListView.separated(
                  padding: EdgeInsets.zero,
                  itemCount: _items.length,
                  separatorBuilder: (context, index) => Divider(
                    height: 1,
                    thickness: 1,
                    color: Colors.grey.withValues(alpha: 0.14),
                    indent: 16,
                    endIndent: 16,
                  ),
                  itemBuilder: (context, index) {
                    final item = _items[index];
                    return _NotificationTile(item: item);
                  },
                ),
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: _NotificationsBottomNav(
        onExploreTap: () {
          Navigator.of(context).pushReplacement(
            MaterialPageRoute(builder: (_) => const ExploreScreen()),
          );
        },
        onTripsTap: () {
          Navigator.of(context).push(
            MaterialPageRoute(builder: (_) => const TripsScreen()),
          );
        },
        onChatTap: () {
          Navigator.of(context).push(
            MaterialPageRoute(builder: (_) => const ChatScreen()),
          );
        },
        onProfileTap: () {
          Navigator.of(context).push(
            MaterialPageRoute(builder: (_) => const ProfileScreen()),
          );
        },
      ),
    );
  }

  Widget _buildErrorBanner() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(12, 8, 12, 8),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: const Color(0xFFFFF1F1),
          border: Border.all(color: const Color(0xFFFFC8C8)),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Row(
          children: [
            const Icon(Icons.wifi_off_rounded, color: Color(0xFFC73737)),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                'Notifications API unavailable. Showing fallback data.',
                style: TextStyle(
                  color: AppTheme.textDark,
                  fontSize: 12.5,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            TextButton(
              onPressed: _loadNotifications,
              child: const Text('Retry'),
            ),
          ],
        ),
      ),
    );
  }
}

class _NotificationsHeader extends StatelessWidget {
  const _NotificationsHeader({required this.onSearchTap});

  final VoidCallback onSearchTap;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 138,
      width: double.infinity,
      child: Stack(
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
                  Colors.black.withValues(alpha: 0.10),
                  Colors.black.withValues(alpha: 0.04),
                  Colors.transparent,
                ],
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(18, 18, 18, 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Align(
                  alignment: Alignment.topRight,
                  child: InkWell(
                    onTap: onSearchTap,
                    borderRadius: BorderRadius.circular(18),
                    child: Container(
                      width: 34,
                      height: 34,
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.22),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.search,
                        color: Colors.white,
                        size: 20,
                      ),
                    ),
                  ),
                ),
                const Spacer(),
                const Text(
                  'Notifications',
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _NotificationTile extends StatelessWidget {
  const _NotificationTile({required this.item});

  final _NotificationItem item;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 14, 16, 14),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _NotificationAvatar(item: item),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item.message,
                  style: const TextStyle(
                    fontSize: 13,
                    height: 1.35,
                    color: Color(0xFF333333),
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  item.date,
                  style: const TextStyle(
                    fontSize: 12,
                    color: Color(0xFF9E9E9E),
                  ),
                ),
                if (item.showReviewButton) ...[
                  const SizedBox(height: 10),
                  SizedBox(
                    height: 30,
                    child: ElevatedButton(
                      onPressed: () {},
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppTheme.authHeaderTeal,
                        foregroundColor: Colors.white,
                        elevation: 2,
                        shadowColor: AppTheme.authHeaderTeal.withValues(
                          alpha: 0.35,
                        ),
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      child: const Text(
                        'Leave Review',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _NotificationAvatar extends StatelessWidget {
  const _NotificationAvatar({required this.item});

  final _NotificationItem item;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 42,
      height: 42,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          ClipOval(
            child: Image.asset(
              item.avatarAsset,
              width: 42,
              height: 42,
              fit: BoxFit.cover,
            ),
          ),
          Positioned(
            right: -2,
            bottom: -2,
            child: Container(
              width: 18,
              height: 18,
              decoration: BoxDecoration(
                color: item.accentColor,
                shape: BoxShape.circle,
                border: Border.all(color: Colors.white, width: 1.5),
              ),
              child: Icon(
                item.badgeIcon,
                size: 10,
                color: Colors.white,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _NotificationsBottomNav extends StatelessWidget {
  const _NotificationsBottomNav({
    required this.onExploreTap,
    required this.onTripsTap,
    required this.onChatTap,
    required this.onProfileTap,
  });

  final VoidCallback onExploreTap;
  final VoidCallback onTripsTap;
  final VoidCallback onChatTap;
  final VoidCallback onProfileTap;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 18,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _BottomItem(
                icon: Icons.explore_outlined,
                label: 'Explore',
                onTap: onExploreTap,
              ),
              _BottomItem(
                icon: Icons.location_on_outlined,
                label: 'Trips',
                onTap: onTripsTap,
              ),
              _BottomItem(
                icon: Icons.chat_bubble_outline,
                label: 'Chat',
                onTap: onChatTap,
              ),
              const _BottomItem(
                icon: Icons.notifications,
                label: 'Notifications',
                active: true,
                badge: '2',
              ),
              _BottomItem(
                icon: Icons.person_outline,
                label: 'Profile',
                onTap: onProfileTap,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _BottomItem extends StatelessWidget {
  const _BottomItem({
    required this.icon,
    required this.label,
    this.active = false,
    this.badge,
    this.onTap,
  });

  final IconData icon;
  final String label;
  final bool active;
  final String? badge;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final color = active ? AppTheme.authHeaderTeal : const Color(0xFF9E9E9E);
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: SizedBox(
        width: 60,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Stack(
              clipBehavior: Clip.none,
              children: [
                Icon(icon, size: 24, color: color),
                if (badge != null)
                  Positioned(
                    top: -4,
                    right: -10,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 5,
                        vertical: 1,
                      ),
                      decoration: const BoxDecoration(
                        color: Color(0xFFFF4B4B),
                        shape: BoxShape.circle,
                      ),
                      child: Text(
                        badge!,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 10,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 4),
            Text(
              label,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontSize: 11,
                color: color,
                fontWeight: active ? FontWeight.w600 : FontWeight.w400,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _NotificationItem {
  const _NotificationItem({
    required this.avatarAsset,
    required this.message,
    required this.date,
    required this.accentColor,
    required this.badgeIcon,
    this.showReviewButton = false,
  });

  final String avatarAsset;
  final String message;
  final String date;
  final Color accentColor;
  final IconData badgeIcon;
  final bool showReviewButton;
}
