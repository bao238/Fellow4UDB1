class ApiEndpoints {
  ApiEndpoints._();

  static const String topJourneys = '/api/TopJourneys';
  static const String bestGuides = '/api/BestGuides';
  static const String topExperiences = '/api/TopExperiences';
  static const String notifications = '/api/notifications';
  static const String apiRoutes = '/api/meta/routes';
  static const String apiHealth = '/api/meta/health';
  static const String setupSql = '/api/setup/sql';
  static const String setupAuthSql = '/api/setup/sql/auth';
  static const String setupNotificationsSql = '/api/setup/sql/notifications';
  static const String login = '/api/auth/login';
  static const String register = '/api/auth/register';
  static const String users = '/api/users';
  static const String usersAdd = '/api/users/add';

  static String topJourneyDetail(int id) => '$topJourneys/$id';

  static String topJourneyUpdate(int id) => '$topJourneys/$id';

  static String topJourneyDelete(int id) => '$topJourneys/$id';
}
