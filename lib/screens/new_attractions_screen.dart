import 'package:flutter/material.dart';
import '../app_theme.dart';

class NewAttractionsScreen extends StatefulWidget {
  const NewAttractionsScreen({
    super.key,
    required this.initialSelected,
  });

  final List<String> initialSelected;

  @override
  State<NewAttractionsScreen> createState() => _NewAttractionsScreenState();
}

class _NewAttractionsScreenState extends State<NewAttractionsScreen> {
  final TextEditingController _controller = TextEditingController();
  late List<String> _selected;
  String _q = '';

  static const Map<String, String> _placeImages = {
    'Cong Coffee': 'assets/images/exp_grid_6.png',
    'Cong Hoa Market': 'assets/images/exp_grid_5.png',
    'Cong Cho': 'assets/images/exp_grid_1.png',
    'Cong Church': 'assets/images/exp_grid_2.png',
    'Dragon Bridge': 'assets/images/explore_header_danang.png',
    'My Khe Beach': 'assets/images/exp_ba_na.png',
    'Cham Museum': 'assets/images/exp_hoian_bicycle.png',
    'Hoi An Ancient Town': 'assets/images/exp_hoian_bicycle.png',
  };

  final List<String> _suggestions = const [
    'Cong Coffee',
    'Cong Hoa Market',
    'Cong Cho',
    'Cong Church',
    'Dragon Bridge',
    'My Khe Beach',
    'Cham Museum',
    'Hoi An Ancient Town',
  ];

  @override
  void initState() {
    super.initState();
    _selected = [...widget.initialSelected];
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _toggle(String item) {
    setState(() {
      if (_selected.contains(item)) {
        _selected.remove(item);
      } else {
        _selected.add(item);
      }
    });
  }

  void _addCustom() {
    final text = _controller.text.trim();
    if (text.isEmpty) return;
    if (!_selected.contains(text)) {
      _toggle(text);
    }
    setState(() {
      _controller.clear();
      _q = '';
    });
  }

  @override
  Widget build(BuildContext context) {
    final filtered = _suggestions.where((s) => s.toLowerCase().contains(_q)).toList();
    final showSelectedCards = _q.isEmpty && _controller.text.trim().isEmpty;

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
              child: Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                  const Expanded(
                    child: Text(
                      'New Attractions',
                      textAlign: TextAlign.center,
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                    ),
                  ),
                  TextButton(
                    onPressed: () => Navigator.of(context).pop(_selected),
                    child: Text('DONE', style: TextStyle(color: AppTheme.authHeaderTeal, fontWeight: FontWeight.w700)),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 4, 16, 10),
              child: Container(
                height: 44,
                decoration: BoxDecoration(
                  color: const Color(0xFFF6F6F6),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Row(
                  children: [
                    const SizedBox(width: 12),
                    Expanded(
                      child: TextField(
                        controller: _controller,
                        onChanged: (v) => setState(() => _q = v.trim().toLowerCase()),
                        decoration: const InputDecoration(
                          hintText: 'Type a Place',
                          border: InputBorder.none,
                        ),
                      ),
                    ),
                    IconButton(
                      icon: Icon(Icons.add_circle, color: AppTheme.authHeaderTeal),
                      onPressed: _addCustom,
                    ),
                  ],
                ),
              ),
            ),
            Expanded(
              child: showSelectedCards ? _selectedCardsView() : _searchListView(filtered),
            ),
          ],
        ),
      ),
    );
  }

  Widget _searchListView(List<String> filtered) {
    return ListView(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      children: [
        if (_controller.text.trim().isNotEmpty && filtered.isEmpty)
          Padding(
            padding: const EdgeInsets.only(top: 8, bottom: 12),
            child: Text(
              'No matches. Tap + to add \"${_controller.text.trim()}\"',
              style: TextStyle(color: AppTheme.textLightGray),
            ),
          ),
        ...filtered.map(
          (s) => ListTile(
            contentPadding: const EdgeInsets.symmetric(horizontal: 8),
            title: Text(s),
            onTap: () => _toggle(s),
            trailing: _selected.contains(s)
                ? Icon(Icons.check_circle, color: AppTheme.authHeaderTeal)
                : Icon(Icons.radio_button_unchecked, color: AppTheme.textLightGray),
          ),
        ),
      ],
    );
  }

  Widget _selectedCardsView() {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Align(
        alignment: Alignment.topLeft,
        child: Wrap(
          spacing: 12,
          runSpacing: 12,
          children: _selected
              .map(
                (name) => _SelectedPlaceCard(
                  name: name,
                  imageAsset: _placeImages[name] ?? 'assets/images/news_danang.png',
                  selected: true,
                  onTap: () => _toggle(name),
                ),
              )
              .toList(),
        ),
      ),
    );
  }
}

class _SelectedPlaceCard extends StatelessWidget {
  const _SelectedPlaceCard({
    required this.name,
    required this.imageAsset,
    required this.selected,
    required this.onTap,
  });

  final String name;
  final String imageAsset;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(10),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(10),
        child: SizedBox(
          width: 170,
          height: 90,
          child: Stack(
            children: [
              Positioned.fill(
                child: Image.asset(imageAsset, fit: BoxFit.cover),
              ),
              Positioned.fill(
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.bottomCenter,
                      end: Alignment.topCenter,
                      colors: [Colors.black.withOpacity(0.55), Colors.transparent],
                    ),
                  ),
                ),
              ),
              Positioned(
                left: 10,
                bottom: 8,
                right: 36,
                child: Text(
                  name,
                  style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.w600),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              Positioned(
                top: 8,
                right: 8,
                child: Icon(
                  selected ? Icons.check_circle : Icons.radio_button_unchecked,
                  color: selected ? AppTheme.authHeaderTeal : Colors.white.withOpacity(0.85),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

