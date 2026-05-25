import '../../../../core/config/api_config.dart';
import '../../../../core/network/api_client.dart';
import '../../../../core/network/api_endpoints.dart';
import '../../../../core/network/api_result.dart';

class JourneyApiItem {
  const JourneyApiItem({
    required this.id,
    required this.title,
    required this.description,
    required this.imageAsset,
    required this.price,
    required this.date,
    required this.days,
    required this.stars,
    this.km,
    this.bookmark = false,
  });

  final int id;
  final String title;
  final String description;
  final String imageAsset;
  final String price;
  final String date;
  final String days;
  final int stars;
  final String? km;
  final bool bookmark;
}

class GuideApiItem {
  const GuideApiItem({
    required this.id,
    required this.name,
    required this.email,
    required this.city,
    required this.phone,
    required this.avatarAsset,
    required this.headerAsset,
    required this.stars,
    required this.reviews,
  });

  final int id;
  final String name;
  final String email;
  final String city;
  final String phone;
  final String avatarAsset;
  final String headerAsset;
  final int stars;
  final String reviews;

  String get location => city.contains(',') ? city : '$city, Vietnam';
}

class ExperienceApiItem {
  const ExperienceApiItem({
    required this.id,
    required this.title,
    required this.userId,
    required this.imageAsset,
    required this.location,
    required this.guideName,
  });

  final int id;
  final String title;
  final int userId;
  final String imageAsset;
  final String location;
  final String guideName;
}

class ExploreApiController {
  ExploreApiController()
    : _apiClient = ApiClient(
        baseUrl: ApiConfig.baseUrl,
        timeout: const Duration(milliseconds: ApiConfig.timeoutMs),
        enableLogging: true,
      );

  static final bool usesCustomApiUrl = ApiConfig.hasCustomApiUrl;

  final ApiClient _apiClient;

  Future<ApiResult<List<JourneyApiItem>>> getTopJourneys() async {
    final response = await _apiClient.get<dynamic>(
      ApiEndpoints.topJourneys,
      queryParameters: {'_limit': 8},
    );

    final data = response.data;
    final items = (data as List<dynamic>)
        .whereType<Map<String, dynamic>>()
        .map(_mapJourney)
        .toList();

    return ApiResult<List<JourneyApiItem>>(
      statusCode: response.statusCode ?? 0,
      message: 'Fetched ${items.length} journeys from API.',
      data: items,
    );
  }

  Future<ApiResult<List<GuideApiItem>>> getBestGuides() async {
    final response = await _apiClient.get<dynamic>(
      ApiEndpoints.bestGuides,
      queryParameters: {'_limit': 12},
    );

    final data = response.data;
    final items = (data as List<dynamic>)
        .whereType<Map<String, dynamic>>()
        .map(_mapGuide)
        .toList();

    return ApiResult<List<GuideApiItem>>(
      statusCode: response.statusCode ?? 0,
      message: 'Fetched ${items.length} guides from API.',
      data: items,
    );
  }

  Future<ApiResult<List<ExperienceApiItem>>> getTopExperiences() async {
    final response = await _apiClient.get<dynamic>(
      ApiEndpoints.topExperiences,
      queryParameters: {'_limit': 8},
    );

    final data = response.data;
    final items = (data as List<dynamic>)
        .whereType<Map<String, dynamic>>()
        .map(_mapExperience)
        .toList();

    return ApiResult<List<ExperienceApiItem>>(
      statusCode: response.statusCode ?? 0,
      message: 'Fetched ${items.length} experiences from API.',
      data: items,
    );
  }

  JourneyApiItem _mapJourney(Map<String, dynamic> json) {
    final id = (json['id'] as num? ?? 0).toInt();
    final title = (json['title'] ?? '').toString();

    return switch (id) {
      1 => JourneyApiItem(
        id: id,
        title: title,
        description: (json['body'] ?? '').toString(),
        imageAsset: 'assets/images/journey_danang.png',
        price: '\$400.00',
        date: 'Jan 30, 2020',
        days: '3 days',
        stars: 5,
        km: '120 km',
        bookmark: true,
      ),
      2 => JourneyApiItem(
        id: id,
        title: title,
        description: (json['body'] ?? '').toString(),
        imageAsset: 'assets/images/journey_thailand.png',
        price: '\$1000.00',
        date: 'Jan 30, 2020',
        days: '3 days',
        stars: 5,
      ),
      _ => JourneyApiItem(
        id: id,
        title: title,
        description: (json['body'] ?? '').toString(),
        imageAsset: id.isEven
            ? 'assets/images/tour_halong.png'
            : 'assets/images/tour_sydney.png',
        price: id.isEven ? '\$300.00' : '\$600.00',
        date: 'Feb 02, 2020',
        days: id.isEven ? '5 days' : '7 days',
        stars: 4,
        km: id.isEven ? '1247 km' : '2817 km',
      ),
    };
  }

  GuideApiItem _mapGuide(Map<String, dynamic> json) {
    final id = (json['id'] as num? ?? 0).toInt();
    final name = (json['name'] ?? '').toString();
    final city =
        ((json['address'] as Map<String, dynamic>?)?['city'] ??
                json['city'] ??
                '')
            .toString();

    return switch (name) {
      'Tuan Tran' => GuideApiItem(
        id: id,
        name: name,
        email: (json['email'] ?? '').toString(),
        city: city,
        phone: (json['phone'] ?? '').toString(),
        avatarAsset: 'assets/images/guide_tuan_tran.png',
        headerAsset: 'assets/images/explore_header_danang.png',
        stars: 5,
        reviews: '127 Reviews',
      ),
      'Linh Hana' => GuideApiItem(
        id: id,
        name: name,
        email: (json['email'] ?? '').toString(),
        city: city,
        phone: (json['phone'] ?? '').toString(),
        avatarAsset: 'assets/images/guide_linh_hana.png',
        headerAsset: 'assets/images/tour_halong.png',
        stars: 4,
        reviews: '127 Reviews',
      ),
      _ => GuideApiItem(
        id: id,
        name: name,
        email: (json['email'] ?? '').toString(),
        city: city,
        phone: (json['phone'] ?? '').toString(),
        avatarAsset: id.isEven
            ? 'assets/images/guide_emmy.png'
            : 'assets/images/guide_khai_ho.png',
        headerAsset: id.isEven
            ? 'assets/images/journey_thailand.png'
            : 'assets/images/tour_sydney.png',
        stars: id.isEven ? 4 : 5,
        reviews: id.isEven ? '89 Reviews' : '127 Reviews',
      ),
    };
  }

  ExperienceApiItem _mapExperience(Map<String, dynamic> json) {
    final id = (json['id'] as num? ?? 0).toInt();
    final title = (json['title'] ?? '').toString();
    final userId = (json['userId'] as num? ?? 0).toInt();

    return switch (id) {
      1 => ExperienceApiItem(
        id: id,
        title: title,
        userId: userId,
        imageAsset: 'assets/images/exp_hoian_bicycle.png',
        location: 'Hoi An, Vietnam',
        guideName: 'Tuan Tran',
      ),
      2 => ExperienceApiItem(
        id: id,
        title: title,
        userId: userId,
        imageAsset: 'assets/images/exp_ba_na.png',
        location: 'Da Nang, Vietnam',
        guideName: 'Linh Hana',
      ),
      _ => ExperienceApiItem(
        id: id,
        title: title,
        userId: userId,
        imageAsset: id.isEven
            ? 'assets/images/exp_grid_4.png'
            : 'assets/images/exp_grid_6.png',
        location: id.isEven ? 'Da Nang, Vietnam' : 'Hoi An, Vietnam',
        guideName: id.isEven ? 'Guide Local' : 'Traveler Host',
      ),
    };
  }
}
