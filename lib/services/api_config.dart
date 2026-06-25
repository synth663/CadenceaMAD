class ApiConfig {
  static const String _configuredBaseUrl = String.fromEnvironment(
    'API_BASE_URL',
    defaultValue: 'http://127.0.0.1:8000',
  );

  static String get baseUrl {
    if (_configuredBaseUrl.endsWith('/')) {
      return _configuredBaseUrl.substring(0, _configuredBaseUrl.length - 1);
    }
    return _configuredBaseUrl;
  }

  static Uri uri(
    String path, {
    Map<String, String?> queryParameters = const {},
  }) {
    final normalizedPath = path.startsWith('/') ? path : '/$path';
    final filteredQuery = <String, String>{};

    for (final entry in queryParameters.entries) {
      final value = entry.value;
      if (value != null && value.isNotEmpty) {
        filteredQuery[entry.key] = value;
      }
    }

    return Uri.parse(
      '$baseUrl$normalizedPath',
    ).replace(queryParameters: filteredQuery.isEmpty ? null : filteredQuery);
  }
}
