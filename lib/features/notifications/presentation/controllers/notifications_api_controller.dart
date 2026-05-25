import '../../../../core/config/api_config.dart';
import '../../../../core/network/api_client.dart';
import '../../../../core/network/api_endpoints.dart';
import '../../../../core/network/api_result.dart';

class NotificationApiItem {
  const NotificationApiItem({
    required this.id,
    required this.actorName,
    required this.actorAvatar,
    required this.message,
    required this.date,
    required this.accentColor,
    required this.badgeIcon,
    required this.showReviewButton,
  });

  final int id;
  final String actorName;
  final String actorAvatar;
  final String message;
  final String date;
  final String accentColor;
  final String badgeIcon;
  final bool showReviewButton;
}

class NotificationsApiController {
  NotificationsApiController()
    : _apiClient = ApiClient(
        baseUrl: ApiConfig.baseUrl,
        timeout: const Duration(milliseconds: ApiConfig.timeoutMs),
        enableLogging: true,
      );

  final ApiClient _apiClient;

  Future<ApiResult<List<NotificationApiItem>>> getNotifications() async {
    final response = await _apiClient.get<dynamic>(
      ApiEndpoints.notifications,
      queryParameters: {'_limit': 30},
    );

    final data = response.data;
    final items = (data as List<dynamic>)
        .whereType<Map<String, dynamic>>()
        .map(_mapNotification)
        .toList();

    return ApiResult<List<NotificationApiItem>>(
      statusCode: response.statusCode ?? 0,
      message: 'Fetched ${items.length} notifications from API.',
      data: items,
    );
  }

  NotificationApiItem _mapNotification(Map<String, dynamic> json) {
    return NotificationApiItem(
      id: (json['id'] as num? ?? 0).toInt(),
      actorName: (json['actorName'] ?? '').toString(),
      actorAvatar: (json['actorAvatar'] ?? '').toString(),
      message: (json['message'] ?? '').toString(),
      date: (json['date'] ?? '').toString(),
      accentColor: (json['accentColor'] ?? '#3F8CFF').toString(),
      badgeIcon: (json['badgeIcon'] ?? 'notifications').toString(),
      showReviewButton: json['showReviewButton'] == true,
    );
  }
}
