import 'package:flutter/material.dart';
import '../app_theme.dart';

class TourDetailScreen extends StatefulWidget {
  const TourDetailScreen({
    super.key,
    required this.title,
    required this.imageAsset,
    required this.price,
  });

  final String title;
  final String imageAsset;
  final String price;

  @override
  State<TourDetailScreen> createState() => _TourDetailScreenState();
}

class _TourDetailScreenState extends State<TourDetailScreen> {
  int _day = 0;

  void _openShare() {
    showModalBottomSheet<void>(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: false,
      builder: (_) => const _ShareSheet(),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Stack(
          children: [
            Positioned.fill(
              child: SingleChildScrollView(
                padding: const EdgeInsets.only(bottom: 86),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildHeader(),
                    _buildInfo(),
                    const SizedBox(height: 12),
                    _buildSummary(),
                    const SizedBox(height: 14),
                    _buildSchedule(),
                    const SizedBox(height: 14),
                    _buildPrice(),
                  ],
                ),
              ),
            ),
            Positioned(
              left: 0,
              right: 0,
              bottom: 0,
              child: SafeArea(
                top: false,
                child: Container(
                  padding: const EdgeInsets.fromLTRB(16, 12, 16, 14),
                  color: Colors.white,
                  child: SizedBox(
                    height: 52,
                    child: ElevatedButton(
                      onPressed: () {},
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppTheme.authHeaderTeal,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                        elevation: 0,
                      ),
                      child: const Text('BOOK THIS TOUR', style: TextStyle(fontWeight: FontWeight.w700)),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Stack(
      children: [
        SizedBox(
          height: 220,
          width: double.infinity,
          child: Image.asset(widget.imageAsset, fit: BoxFit.cover),
        ),
        Positioned.fill(
          child: DecoratedBox(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Colors.black.withOpacity(0.30),
                  Colors.transparent,
                  Colors.black.withOpacity(0.10),
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
          child: Row(
            children: [
              _circleIcon(Icons.share, _openShare),
              const SizedBox(width: 8),
              _circleIcon(Icons.favorite_border, () {}),
              const SizedBox(width: 8),
              _circleIcon(Icons.bookmark_border, () {}),
            ],
          ),
        ),
      ],
    );
  }

  Widget _circleIcon(IconData icon, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(18),
      child: Container(
        width: 34,
        height: 34,
        decoration: BoxDecoration(
          color: Colors.black.withOpacity(0.25),
          shape: BoxShape.circle,
        ),
        child: Icon(icon, color: Colors.white, size: 18),
      ),
    );
  }

  Widget _buildInfo() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 14, 16, 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(widget.title, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF333333))),
                const SizedBox(height: 6),
                Row(
                  children: [
                    ...List.generate(5, (_) => Icon(Icons.star, size: 14, color: Colors.amber[700])),
                    const SizedBox(width: 8),
                    Text('145 Reviews', style: TextStyle(fontSize: 12, color: AppTheme.textLightGray)),
                  ],
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Text('Provider ', style: TextStyle(fontSize: 12, color: AppTheme.textLightGray)),
                    Text('dulichviet', style: TextStyle(fontSize: 12, color: AppTheme.authHeaderTeal, fontWeight: FontWeight.w600)),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(width: 10),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(widget.price, style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppTheme.authHeaderTeal)),
              const SizedBox(height: 4),
              Text('\$460.00', style: TextStyle(fontSize: 12, color: AppTheme.textLightGray, decoration: TextDecoration.lineThrough)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSummary() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.06), blurRadius: 10, offset: const Offset(0, 2))],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Summary', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF333333))),
            const SizedBox(height: 12),
            _summaryRow('Itinerary', widget.title),
            const SizedBox(height: 10),
            _summaryRow('Duration', '2 days, 2 nights'),
            const SizedBox(height: 10),
            _summaryRow('Departure Date', 'Feb 12'),
            const SizedBox(height: 10),
            _summaryRow('Departure Place', 'Ho Chi Minh'),
          ],
        ),
      ),
    );
  }

  Widget _summaryRow(String label, String value) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 120,
          child: Text(label, style: TextStyle(fontSize: 12, color: AppTheme.textLightGray)),
        ),
        Expanded(child: Text(value, style: const TextStyle(fontSize: 13, color: Color(0xFF333333), fontWeight: FontWeight.w500))),
      ],
    );
  }

  Widget _buildSchedule() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.list_alt, size: 18, color: AppTheme.textGray),
              const SizedBox(width: 6),
              const Text('Schedule', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xFF333333))),
            ],
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              _dayChip('Day 1', selected: _day == 0, onTap: () => setState(() => _day = 0)),
              const SizedBox(width: 10),
              _dayChip('Day 2', selected: _day == 1, onTap: () => setState(() => _day = 1)),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            _day == 0 ? 'Ho Chi Minh - Da Nang' : 'Da Nang - Hoi An',
            style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: Color(0xFF333333)),
          ),
          const SizedBox(height: 10),
          _timelineItem('6:00AM'),
          _timelineItem('10:00AM'),
          _timelineItem('1:00PM'),
          _timelineItem('8:00PM', isLast: true),
        ],
      ),
    );
  }

  Widget _dayChip(String text, {required bool selected, required VoidCallback onTap}) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(10),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 8),
        decoration: BoxDecoration(
          color: selected ? AppTheme.authHeaderTeal : const Color(0xFFEFEFEF),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Text(
          text,
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w700,
            color: selected ? Colors.white : AppTheme.textGray,
          ),
        ),
      ),
    );
  }

  Widget _timelineItem(String time, {bool isLast = false}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Column(
            children: [
              Container(
                width: 10,
                height: 10,
                decoration: BoxDecoration(color: AppTheme.authHeaderTeal, shape: BoxShape.circle),
              ),
              if (!isLast)
                Container(
                  width: 2,
                  height: 56,
                  color: AppTheme.authHeaderTeal.withOpacity(0.25),
                ),
            ],
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(time, style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: AppTheme.authHeaderTeal)),
                const SizedBox(height: 6),
                Text(
                  'Lorem ipsum is simply dummy text of the printing and typesetting industry. Lorem ipsum has been the industry\'s standard dummy text ever since.',
                  style: TextStyle(fontSize: 12, color: AppTheme.textGray, height: 1.35),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPrice() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.06), blurRadius: 10, offset: const Offset(0, 2))],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.attach_money, size: 18, color: AppTheme.textGray),
                const SizedBox(width: 6),
                const Text('Price', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xFF333333))),
              ],
            ),
            const SizedBox(height: 10),
            _priceRow('Adult (>10 years old)', '\$400.00'),
            Divider(height: 18, color: AppTheme.dividerGray),
            _priceRow('Child (5 - 10 years old)', '\$320.00'),
            Divider(height: 18, color: AppTheme.dividerGray),
            _priceRow('Child (<5 years old)', 'Free'),
          ],
        ),
      ),
    );
  }

  Widget _priceRow(String left, String right) {
    return Row(
      children: [
        Expanded(child: Text(left, style: const TextStyle(fontSize: 13, color: Color(0xFF333333)))),
        Text(right, style: TextStyle(fontSize: 13, color: AppTheme.textGray, fontWeight: FontWeight.w600)),
      ],
    );
  }
}

class _ShareSheet extends StatelessWidget {
  const _ShareSheet();

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Container(
        margin: const EdgeInsets.fromLTRB(12, 0, 12, 12),
        padding: const EdgeInsets.fromLTRB(16, 14, 16, 12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
          boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.16), blurRadius: 24, offset: const Offset(0, 10))],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('Share on', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700)),
            const SizedBox(height: 14),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: const [
                _ShareIcon(label: 'Facebook', bg: Color(0xFF1877F2), text: 'f'),
                _ShareIcon(label: 'Google', bg: Color(0xFFEA4335), text: 'G+'),
                _ShareIcon(label: 'Kakao Talk', bg: Color(0xFFFFE812), text: 'TALK', textColor: Colors.black87),
                _ShareIcon(label: 'Whatsapp', bg: Color(0xFF25D366), text: 'W'),
                _ShareIcon(label: 'Twitter', bg: Color(0xFF1DA1F2), text: 't'),
              ],
            ),
            const SizedBox(height: 14),
            Divider(color: AppTheme.dividerGray),
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text('Cancel', style: TextStyle(color: AppTheme.authHeaderTeal, fontSize: 16, fontWeight: FontWeight.w700)),
            ),
          ],
        ),
      ),
    );
  }
}

class _ShareIcon extends StatelessWidget {
  const _ShareIcon({
    required this.label,
    required this.bg,
    required this.text,
    this.textColor = Colors.white,
  });

  final String label;
  final Color bg;
  final String text;
  final Color textColor;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          width: 52,
          height: 52,
          decoration: BoxDecoration(color: bg, borderRadius: BorderRadius.circular(14)),
          alignment: Alignment.center,
          child: Text(text, style: TextStyle(color: textColor, fontWeight: FontWeight.w800)),
        ),
        const SizedBox(height: 6),
        SizedBox(
          width: 56,
          child: Text(
            label,
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 10, color: AppTheme.textGray),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }
}

