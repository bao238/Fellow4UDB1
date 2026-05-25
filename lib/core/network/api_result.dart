class ApiResult<T> {
  const ApiResult({required this.statusCode, required this.message, this.data});

  final int statusCode;
  final String message;
  final T? data;
}
