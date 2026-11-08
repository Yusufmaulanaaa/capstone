import 'package:flutter/foundation.dart';

class ApiConfig {
  static const String _envBase = String.fromEnvironment('API_BASE_URL');
  static const String _envHost = String.fromEnvironment('API_HOST', defaultValue: '10.0.2.2');

  static String get baseUrl {
    if (_envBase.isNotEmpty) return _envBase;
    if (kIsWeb) return 'http://localhost:3000';
    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
        return 'http://$_envHost:3000';
      case TargetPlatform.iOS:
      case TargetPlatform.macOS:
      case TargetPlatform.windows:
      case TargetPlatform.linux:
      case TargetPlatform.fuchsia:
        return 'http://localhost:3000';
    }
  }

  static Uri uri(String path, [Map<String, dynamic>? query]) {
    final normalized = path.startsWith('/') ? path : '/$path';
    final qp = <String, String>{};
    query?.forEach((k, v) {
      if (v == null) return;
      if (v is Iterable) {
        qp[k] = v.join(',');
      } else {
        qp[k] = '$v';
      }
    });
    return Uri.parse('$baseUrl$normalized').replace(queryParameters: qp.isEmpty ? null : qp);
  }
}
