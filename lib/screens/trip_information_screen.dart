import 'package:flutter/material.dart';
import '../app_theme.dart';
import 'new_attractions_screen.dart';

class TripInformationScreen extends StatefulWidget {
  const TripInformationScreen({
    super.key,
    required this.guideName,
    required this.guideLocation,
  });

  final String guideName;
  final String guideLocation;

  @override
  State<TripInformationScreen> createState() => _TripInformationScreenState();
}

class _TripInformationScreenState extends State<TripInformationScreen> {
  DateTime? _date;
  TimeOfDay? _from;
  TimeOfDay? _to;
  String _city = 'Danang';
  int _travelers = 1;

  final List<_Attraction> _attractions = [
    _Attraction(name: 'Cham Museum', image: 'assets/images/exp_hoian_bicycle.png', selected: false),
    _Attraction(name: 'Dragon Bridge', image: 'assets/images/journey_danang.png', selected: true),
    _Attraction(name: 'My Khe Beach', image: 'assets/images/exp_ba_na.png', selected: true),
  ];

  String _fmtDate(DateTime? d) {
    if (d == null) return 'mm/dd/yy';
    final mm = d.month.toString().padLeft(2, '0');
    final dd = d.day.toString().padLeft(2, '0');
    final yy = (d.year % 100).toString().padLeft(2, '0');
    return '$mm/$dd/$yy';
  }

  String _fmtTime(TimeOfDay? t) => t == null ? '' : t.format(context);

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

  Future<void> _pickTime({required bool isFrom}) async {
    final res = await showTimePicker(
      context: context,
      initialTime: (isFrom ? _from : _to) ?? TimeOfDay.now(),
    );
    if (res != null) {
      setState(() {
        if (isFrom) {
          _from = res;
        } else {
          _to = res;
        }
      });
    }
  }

  Future<void> _openNewAttractions() async {
    final current = _attractions.map((a) => a.name).toList();
    final res = await Navigator.of(context).push<List<String>>(
      MaterialPageRoute(
        builder: (_) => NewAttractionsScreen(initialSelected: current),
        fullscreenDialog: true,
      ),
    );
    if (res == null) return;

    setState(() {
      for (final n in res) {
        if (_attractions.every((a) => a.name != n)) {
          _attractions.add(_Attraction(name: n, image: 'assets/images/news_danang.png', selected: true));
        }
      }
      for (final a in _attractions) {
        a.selected = res.contains(a.name);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
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
                      'Trip Information',
                      textAlign: TextAlign.center,
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                    ),
                  ),
                  const SizedBox(width: 48),
                ],
              ),
            ),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(20, 8, 20, 20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Date', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
                    const SizedBox(height: 8),
                    _UnderlineField(
                      icon: Icons.calendar_today,
                      value: _fmtDate(_date),
                      onTap: _pickDate,
                    ),
                    const SizedBox(height: 18),
                    const Text('Time', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Expanded(
                          child: _UnderlineField(
                            icon: Icons.access_time,
                            value: _from == null ? 'From' : _fmtTime(_from),
                            onTap: () => _pickTime(isFrom: true),
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: _UnderlineField(
                            icon: Icons.access_time,
                            value: _to == null ? 'To' : _fmtTime(_to),
                            onTap: () => _pickTime(isFrom: false),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 18),
                    const Text('City', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
                    const SizedBox(height: 8),
                    Container(
                      padding: const EdgeInsets.only(bottom: 8),
                      decoration: BoxDecoration(
                        border: Border(bottom: BorderSide(color: AppTheme.dividerGray)),
                      ),
                      child: Row(
                        children: [
                          Icon(Icons.location_on, size: 18, color: AppTheme.textLightGray),
                          const SizedBox(width: 8),
                          DropdownButton<String>(
                            value: _city,
                            underline: const SizedBox.shrink(),
                            items: const [
                              DropdownMenuItem(value: 'Danang', child: Text('Danang')),
                              DropdownMenuItem(value: 'Hanoi', child: Text('Hanoi')),
                              DropdownMenuItem(value: 'Ho Chi Minh', child: Text('Ho Chi Minh')),
                            ],
                            onChanged: (v) => setState(() => _city = v ?? 'Danang'),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 18),
                    const Text('Number of travelers', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        _stepButton(Icons.keyboard_arrow_down, () => setState(() => _travelers = (_travelers - 1).clamp(1, 99))),
                        Container(
                          width: 64,
                          alignment: Alignment.center,
                          padding: const EdgeInsets.symmetric(vertical: 8),
                          decoration: BoxDecoration(
                            border: Border(bottom: BorderSide(color: AppTheme.dividerGray)),
                          ),
                          child: Text('$_travelers', style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600)),
                        ),
                        _stepButton(Icons.keyboard_arrow_up, () => setState(() => _travelers = (_travelers + 1).clamp(1, 99))),
                      ],
                    ),
                    const SizedBox(height: 18),
                    const Text('Attractions', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
                    const SizedBox(height: 12),
                    GridView.count(
                      crossAxisCount: 2,
                      crossAxisSpacing: 12,
                      mainAxisSpacing: 12,
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      childAspectRatio: 1.65,
                      children: [
                        InkWell(
                          onTap: _openNewAttractions,
                          borderRadius: BorderRadius.circular(12),
                          child: Container(
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(color: AppTheme.dividerGray),
                            ),
                            child: Center(
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(Icons.add, color: AppTheme.authHeaderTeal),
                                  const SizedBox(width: 6),
                                  Text('Add New', style: TextStyle(color: AppTheme.authHeaderTeal, fontWeight: FontWeight.w600)),
                                ],
                              ),
                            ),
                          ),
                        ),
                        ..._attractions.map(_attractionTile),
                      ],
                    ),
                    const SizedBox(height: 22),
                    SizedBox(
                      width: double.infinity,
                      height: 52,
                      child: ElevatedButton(
                        onPressed: () {
                          Navigator.of(context).pop({
                            'guideName': widget.guideName,
                            'guideLocation': widget.guideLocation,
                            'date': _date,
                            'from': _from,
                            'to': _to,
                            'city': _city,
                            'travelers': _travelers,
                            'attractions': _attractions.where((a) => a.selected).map((a) => a.name).toList(),
                          });
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppTheme.authHeaderTeal,
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                          elevation: 0,
                        ),
                        child: const Text('DONE', style: TextStyle(fontWeight: FontWeight.w700)),
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

  Widget _stepButton(IconData icon, VoidCallback onTap) {
    return Container(
      width: 36,
      height: 36,
      margin: const EdgeInsets.only(right: 10),
      decoration: BoxDecoration(
        color: const Color(0xFFF2F2F2),
        borderRadius: BorderRadius.circular(8),
      ),
      child: IconButton(
        icon: Icon(icon, size: 18, color: AppTheme.authHeaderTeal),
        onPressed: onTap,
      ),
    );
  }

  Widget _attractionTile(_Attraction a) {
    return InkWell(
      onTap: () => setState(() => a.selected = !a.selected),
      borderRadius: BorderRadius.circular(12),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: Stack(
          children: [
            Positioned.fill(
              child: Image.asset(a.image, fit: BoxFit.cover),
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
              bottom: 10,
              right: 42,
              child: Text(
                a.name,
                style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w600, fontSize: 12),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            Positioned(
              top: 8,
              right: 8,
              child: Icon(
                a.selected ? Icons.check_circle : Icons.radio_button_unchecked,
                color: a.selected ? AppTheme.authHeaderTeal : Colors.white.withOpacity(0.8),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _UnderlineField extends StatelessWidget {
  const _UnderlineField({
    required this.icon,
    required this.value,
    required this.onTap,
  });

  final IconData icon;
  final String value;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final isPlaceholder = value == 'mm/dd/yy' || value == 'From' || value == 'To' || value.isEmpty;
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.only(bottom: 8),
        decoration: BoxDecoration(
          border: Border(bottom: BorderSide(color: AppTheme.dividerGray)),
        ),
        child: Row(
          children: [
            Icon(icon, size: 18, color: AppTheme.textLightGray),
            const SizedBox(width: 8),
            Text(
              value,
              style: TextStyle(
                fontSize: 13,
                color: isPlaceholder ? AppTheme.textLightGray : const Color(0xFF333333),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _Attraction {
  _Attraction({required this.name, required this.image, required this.selected});

  final String name;
  final String image;
  bool selected;
}

