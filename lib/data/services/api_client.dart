import 'dart:async';
import 'dart:convert';
import 'package:http/http.dart' as http;
import '../../core/api_config.dart';
import 'session_store.dart';

class ApiException implements Exception {
  final String message;
  final int statusCode;
  final dynamic body;
  ApiException(this.message, {this.statusCode = 0, this.body});
  @override
  String toString() => message;
}

class ApiClient {
  final http.Client _client;
  final SessionStore _session;
  ApiClient(this._session, [http.Client? client]) : _client = client ?? http.Client();

  Future<Map<String, String>> _headers({bool auth = true}) async {
    final h = <String, String>{'Content-Type': 'application/json', 'Accept': 'application/json'};
    if (auth) {
      final token = await _session.readToken();
      if (token != null && token.isNotEmpty) h['Authorization'] = 'Bearer $token';
    }
    return h;
  }

  Future<dynamic> get(String path, {Map<String, dynamic>? query, bool auth = true}) async {
    final res = await _client.get(ApiConfig.uri(path, query), headers: await _headers(auth: auth)).timeout(const Duration(seconds: 20));
    return _handle(res);
  }

  Future<dynamic> post(String path, {Object? body, Map<String, dynamic>? query, bool auth = true}) async {
    final res = await _client.post(ApiConfig.uri(path, query), headers: await _headers(auth: auth), body: body == null ? null : jsonEncode(body)).timeout(const Duration(seconds: 25));
    return _handle(res);
  }

  Future<dynamic> patch(String path, {Object? body, bool auth = true}) async {
    final res = await _client.patch(ApiConfig.uri(path), headers: await _headers(auth: auth), body: body == null ? null : jsonEncode(body)).timeout(const Duration(seconds: 20));
    return _handle(res);
  }

  Future<dynamic> delete(String path, {bool auth = true}) async {
    final res = await _client.delete(ApiConfig.uri(path), headers: await _headers(auth: auth)).timeout(const Duration(seconds: 20));
    return _handle(res);
  }

  dynamic _handle(http.Response res) {
    if (res.statusCode == 204) return null;
    dynamic data;
    if (res.body.isNotEmpty) {
      try { data = jsonDecode(res.body); } catch (_) { data = res.body; }
    }
    if (res.statusCode >= 200 && res.statusCode < 300) return data;
    final msg = _message(data) ?? 'Permintaan gagal (${res.statusCode}).';
    throw ApiException(msg, statusCode: res.statusCode, body: data);
  }

  String? _message(dynamic data) {
    if (data is Map) {
      final m = data['message'];
      if (m is String && m.isNotEmpty) return m;
      if (m is List && m.isNotEmpty) return m.map((e) => '$e').join('\n');
      final e = data['error'];
      if (e is String && e.isNotEmpty) return e;
    }
    return null;
  }
}
