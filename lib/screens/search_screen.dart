import 'package:flutter/material.dart';
import '../app_theme.dart';
import 'guide_page_screen.dart';
import 'tour_detail_screen.dart';

class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final TextEditingController _controller = TextEditingController(text: 'Danang, Vietnam');
  bool _showResults = true;
  String? _selectedLanguage;

  // Local copies of guides & tours used for search UI
  static const allGuides = [
    (
      name: 'Tuan Tran',
      location: 'Danang, Vietnam',
      stars: 5,
      reviews: '127 Reviews',
      imageAsset: 'assets/images/guide_tuan_tran.png',
      language: 'Vietnamese',
    ),
    (
      name: 'Emmy',
      location: 'Hanoi, Vietnam',
      stars: 4,
      reviews: '89 Reviews',
      imageAsset: 'assets/images/guide_emmy.png',
      language: 'English',
    ),
    (
      name: 'Linh Hana',
      location: 'Danang, Vietnam',
      stars: 4,
      reviews: '127 Reviews',
      imageAsset: 'assets/images/guide_linh_hana.png',
      language: 'Korean',
    ),
    (
      name: 'Khai Ho',
      location: 'Ho Chi Minh, Vietnam',
      stars: 5,
      reviews: '127 Reviews',
      imageAsset: 'assets/images/guide_khai_ho.png',
      language: 'Spanish',
    ),
  ];

  static const allTours = [
    (
      title: 'Da Nang - Ba Na - Hoi An',
      date: 'Jan 30, 2020',
      days: '3 days',
      price: '\$400.00',
      imageAsset: 'assets/images/journey_danang.png',
    ),
    (
      title: 'Melbourne - Sydney',
      date: 'Jan 30, 2020',
      days: '7 days',
      price: '\$600.00',
      imageAsset: 'assets/images/tour_sydney.png',
    ),
    (
      title: 'Hanoi - Ha Long Bay',
      date: 'Jan 30, 2020',
      days: '5 days',
      price: '\$300.00',
      imageAsset: 'assets/images/tour_halong.png',
    ),
  ];

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _openFilters() async {
    final res = await showModalBottomSheet<String?>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => _SearchFilterSheet(initialLanguage: _selectedLanguage),
    );
    if (res != null) {
      setState(() {
        _selectedLanguage = res;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(8, 8, 8, 8),
              child: Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                  Expanded(
                    child: Container(
                      height: 44,
                      decoration: BoxDecoration(
                        color: const Color(0xFFF5F5F5),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        children: [
                          const SizedBox(width: 12),
                          Expanded(
                            child: TextField(
                              controller: _controller,
                              onChanged: (v) => setState(() => _showResults = v.trim().isNotEmpty),
                              decoration: const InputDecoration(
                                hintText: 'Where you want to explore',
                                border: InputBorder.none,
                              ),
                            ),
                          ),
                          if (_showResults)
                            IconButton(
                              icon: const Icon(Icons.close, size: 18),
                              onPressed: () {
                                _controller.clear();
                                setState(() => _showResults = false);
                              },
                            ),
                          if (_showResults)
                            IconButton(
                              icon: const Icon(Icons.tune, size: 20),
                              onPressed: _openFilters,
                            ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: _showResults ? _buildResults(theme) : _buildInitial(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInitial() {
    final popular = ['Danang, Vietnam', 'Ho Chi Minh, Vietnam', 'Venice, Italy'];
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Popular destinations', style: TextStyle(fontSize: 14, color: AppTheme.textGray)),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: popular
                .map(
                  (p) => ChoiceChip(
                    label: Text(p),
                    selected: _controller.text.trim() == p,
                    onSelected: (_) {
                      setState(() {
                        _controller.text = p;
                        _showResults = true;
                      });
                    },
                    backgroundColor: const Color(0xFFF5F5F5),
                    selectedColor: Colors.white,
                    labelStyle: TextStyle(fontSize: 13, color: AppTheme.textGray),
                  ),
                )
                .toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildResults(ThemeData theme) {
    final raw = _controller.text.trim();
    final query = raw.toLowerCase();
    final cityToken = (raw.isEmpty ? 'Danang' : raw.split(',').first).toLowerCase();

    bool _matchGuide(({
      String name,
      String location,
      int stars,
      String reviews,
      String imageAsset,
      String language,
    }) g) {
      if (_selectedLanguage != null && g.language != _selectedLanguage) {
        return false;
      }
      if (query.isEmpty) return g.location.toLowerCase().contains(cityToken);
      return g.name.toLowerCase().contains(query) || g.location.toLowerCase().contains(query);
    }

    bool _matchTour(({
      String title,
      String date,
      String days,
      String price,
      String imageAsset,
    }) t) {
      if (query.isEmpty) return t.title.toLowerCase().contains(cityToken);
      return t.title.toLowerCase().contains(query);
    }

    final filteredGuides = allGuides.where(_matchGuide).toList();
    final filteredTours = allTours.where(_matchTour).toList();

    final cityLabel = raw.isEmpty ? 'Danang' : raw;
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Guides in $cityLabel', style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xFF333333))),
          const SizedBox(height: 10),
          GridView.count(
            crossAxisCount: 2,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            mainAxisSpacing: 10,
            crossAxisSpacing: 10,
            childAspectRatio: 0.8,
            children: filteredGuides
                .map(
                  (g) => _GuideResultCard(
                    name: g.name,
                    location: g.location,
                    stars: g.stars,
                    reviews: g.reviews,
                    imageAsset: g.imageAsset,
                  ),
                )
                .toList(),
          ),
          const SizedBox(height: 20),
          Text('Tours in $cityLabel', style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xFF333333))),
          const SizedBox(height: 10),
          Column(
            children: filteredTours
                .map(
                  (t) => Padding(
                    padding: const EdgeInsets.only(bottom: 10),
                    child: _SearchTourCard(
                      title: t.title,
                      date: t.date,
                      days: t.days,
                      price: t.price,
                      imageAsset: t.imageAsset,
                    ),
                  ),
                )
                .toList(),
          ),
        ],
      ),
    );
  }
}

class _GuideResultCard extends StatelessWidget {
  const _GuideResultCard({
    required this.name,
    required this.location,
    required this.stars,
    required this.reviews,
    required this.imageAsset,
  });

  final String name;
  final String location;
  final int stars;
  final String reviews;
  final String imageAsset;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () {
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (_) => GuidePageScreen(
              name: name,
              location: location,
              stars: stars,
              reviews: reviews,
              avatarAsset: imageAsset,
              headerAsset: 'assets/images/explore_header_danang.png',
            ),
          ),
        );
      },
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.06), blurRadius: 10, offset: const Offset(0, 2))],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ClipRRect(
              borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
              child: SizedBox(
                height: 110,
                width: double.infinity,
                child: Image.asset(imageAsset, fit: BoxFit.cover),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(8),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(name, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: Color(0xFF333333))),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      ...List.generate(stars, (_) => Icon(Icons.star, size: 12, color: Colors.amber[700])),
                      const SizedBox(width: 4),
                      Text(reviews, style: TextStyle(fontSize: 11, color: AppTheme.textLightGray)),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Icon(Icons.location_on, size: 12, color: AppTheme.authHeaderTeal),
                      const SizedBox(width: 3),
                      Expanded(
                        child: Text(
                          location,
                          style: TextStyle(fontSize: 11, color: AppTheme.authHeaderTeal),
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
      ),
    );
  }
}

class _SearchTourCard extends StatelessWidget {
  const _SearchTourCard({
    required this.title,
    required this.date,
    required this.days,
    required this.price,
    required this.imageAsset,
  });

  final String title;
  final String date;
  final String days;
  final String price;
  final String imageAsset;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () {
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (_) => TourDetailScreen(title: title, imageAsset: imageAsset, price: price),
          ),
        );
      },
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.06), blurRadius: 10, offset: const Offset(0, 2))],
        ),
        child: Row(
          children: [
            ClipRRect(
              borderRadius: const BorderRadius.horizontal(left: Radius.circular(12)),
              child: SizedBox(
                width: 110,
                height: 80,
                child: Image.asset(imageAsset, fit: BoxFit.cover),
              ),
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(10),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: Color(0xFF333333)),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Icon(Icons.calendar_today, size: 12, color: AppTheme.textLightGray),
                        const SizedBox(width: 4),
                        Text(date, style: TextStyle(fontSize: 11, color: AppTheme.textLightGray)),
                      ],
                    ),
                    const SizedBox(height: 2),
                    Row(
                      children: [
                        Icon(Icons.schedule, size: 12, color: AppTheme.textLightGray),
                        const SizedBox(width: 4),
                        Text(days, style: TextStyle(fontSize: 11, color: AppTheme.textLightGray)),
                        const Spacer(),
                        Text(
                          price,
                          style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: AppTheme.authHeaderTeal),
                        ),
                      ],
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

class _SearchFilterSheet extends StatefulWidget {
  const _SearchFilterSheet({this.initialLanguage});

  final String? initialLanguage;

  @override
  State<_SearchFilterSheet> createState() => _SearchFilterSheetState();
}

class _SearchFilterSheetState extends State<_SearchFilterSheet> {
  int _tab = 0; // 0 = guides, 1 = tours
  DateTime? _date;
  late Set<String> _languages;
  final TextEditingController _feeController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _languages = {
      widget.initialLanguage ?? 'Vietnamese',
    };
  }

  @override
  void dispose() {
    _feeController.dispose();
    super.dispose();
  }

  Future<void> _pickDate() async {
    final now = DateTime.now();
    final res = await showDatePicker(
      context: context,
      firstDate: DateTime(now.year - 1),
      lastDate: DateTime(now.year + 2),
      initialDate: _date ?? now,
    );
    if (res != null) setState(() => _date = res);
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Container(
        margin: const EdgeInsets.fromLTRB(0, 40, 0, 0),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(18)),
        ),
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                  const Expanded(
                    child: Text(
                      'Filters',
                      textAlign: TextAlign.center,
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                    ),
                  ),
                  const SizedBox(width: 48),
                ],
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  _filterTab('Guides', selected: _tab == 0, onTap: () => setState(() => _tab = 0)),
                  const SizedBox(width: 8),
                  _filterTab('Tours', selected: _tab == 1, onTap: () => setState(() => _tab = 1)),
                ],
              ),
              const SizedBox(height: 18),
              const Text('Date', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
              const SizedBox(height: 8),
              InkWell(
                onTap: _pickDate,
                child: Container(
                  padding: const EdgeInsets.only(bottom: 8),
                  decoration: BoxDecoration(border: Border(bottom: BorderSide(color: AppTheme.dividerGray))),
                  child: Row(
                    children: [
                      Icon(Icons.calendar_today, size: 18, color: AppTheme.textLightGray),
                      const SizedBox(width: 8),
                      Text(
                        _date == null ? 'mm/dd/yy' : '${_date!.month}/${_date!.day}/${_date!.year}',
                        style: TextStyle(fontSize: 13, color: _date == null ? AppTheme.textLightGray : const Color(0xFF333333)),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 18),
              const Text("Guide's Language", style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
              const SizedBox(height: 10),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: ['Vietnamese', 'English', 'Korean', 'Spanish', 'French']
                    .map(
                      (lang) {
                        final selected = _languages.contains(lang);
                        return ChoiceChip(
                          label: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              if (selected) ...[
                                const Icon(Icons.check, size: 16, color: Colors.white),
                                const SizedBox(width: 6),
                              ],
                              Text(lang),
                            ],
                          ),
                          selected: selected,
                          onSelected: (sel) {
                            setState(() {
                              if (sel) {
                                _languages
                                  ..clear()
                                  ..add(lang);
                              } else {
                                _languages.remove(lang);
                              }
                            });
                          },
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(22),
                            side: BorderSide(
                              color: selected ? Colors.transparent : AppTheme.dividerGray,
                            ),
                          ),
                          selectedColor: AppTheme.authHeaderTeal,
                          backgroundColor: Colors.white,
                          labelStyle: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                            color: selected ? Colors.white : AppTheme.textGray,
                          ),
                          materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                        );
                      },
                    )
                    .toList(),
              ),
              const SizedBox(height: 18),
              const Text('Fee', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
              const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.only(bottom: 8),
                decoration: BoxDecoration(border: Border(bottom: BorderSide(color: AppTheme.dividerGray))),
                child: Row(
                  children: [
                    const Icon(Icons.attach_money, size: 18, color: Colors.black54),
                    const SizedBox(width: 8),
                    Expanded(
                      child: TextField(
                        controller: _feeController,
                        keyboardType: TextInputType.number,
                        decoration: InputDecoration(
                          hintText: 'Fee',
                          hintStyle: TextStyle(fontSize: 13, color: AppTheme.textLightGray),
                          border: InputBorder.none,
                          isDense: true,
                        ),
                        style: const TextStyle(fontSize: 13, color: Color(0xFF333333)),
                      ),
                    ),
                    Text('(\$/hour)', style: TextStyle(fontSize: 13, color: AppTheme.textLightGray)),
                  ],
                ),
              ),
              const SizedBox(height: 22),
              SizedBox(
                width: double.infinity,
                height: 48,
                child: ElevatedButton(
                  onPressed: () => Navigator.of(context).pop(
                    _languages.isEmpty ? null : _languages.first,
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.authHeaderTeal,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                    elevation: 0,
                  ),
                  child: const Text('APPLY FILTERS', style: TextStyle(fontWeight: FontWeight.w700)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _filterTab(String label, {required bool selected, required VoidCallback onTap}) {
    return Expanded(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(8),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 8),
          decoration: BoxDecoration(
            color: selected ? AppTheme.authHeaderTeal : const Color(0xFFF5F5F5),
            borderRadius: BorderRadius.circular(8),
          ),
          alignment: Alignment.center,
          child: Text(
            label,
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w700,
              color: selected ? Colors.white : AppTheme.textGray,
            ),
          ),
        ),
      ),
    );
  }
}

