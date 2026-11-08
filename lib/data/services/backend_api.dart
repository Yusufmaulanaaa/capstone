import '../services/api_client.dart';
import '../services/session_store.dart';
import '../models/booking_model.dart';
import '../models/chat_model.dart';
import '../models/lawyer_model.dart';
import '../models/user_model.dart';

class AuthRepository {
  final ApiClient _api;
  final SessionStore _session;
  AuthRepository(this._api, this._session);

  Future<AppUser> register({required String name, required String email, required String password}) async {
    final data = await _api.post('/api/auth/register', auth: false, body: {'name': name, 'email': email, 'password': password});
    return _saveAuth(data);
  }

  Future<AppUser> login({required String email, required String password}) async {
    final data = await _api.post('/api/auth/login', auth: false, body: {'email': email, 'password': password});
    return _saveAuth(data);
  }

  Future<AppUser?> restore() async {
    final token = await _session.readToken();
    if (token == null || token.isEmpty) return null;
    try {
      final data = await _api.get('/api/auth/me');
      return AppUser.fromJson(Map<String, dynamic>.from(data as Map));
    } catch (_) {
      await _session.clear();
      return null;
    }
  }

  Future<void> logout() => _session.clear();

  Future<AppUser> _saveAuth(dynamic data) async {
    final map = Map<String, dynamic>.from(data as Map);
    final token = '${map['accessToken'] ?? ''}';
    if (token.isNotEmpty) await _session.saveToken(token);
    final user = map['user'] is Map ? Map<String, dynamic>.from(map['user']) : map;
    return AppUser.fromJson(user);
  }
}

class LawyersApi {
  final ApiClient _api;
  LawyersApi(this._api);

  Future<List<LawyerModel>> fetch({String? q, String? specialty, String? city, double? minRating, int? maxPrice, String? sort, int page = 1, int limit = 50}) async {
    final data = await _api.get('/api/lawyers', auth: false, query: {'q': q, 'specialty': specialty, 'city': city, 'minRating': minRating, 'maxPrice': maxPrice, 'sort': sort, 'page': page, 'limit': limit});
    final items = data is Map ? (data['items'] as List? ?? const []) : (data as List? ?? const []);
    return items.whereType<Map>().map((e) => LawyerModel.fromJson(Map<String, dynamic>.from(e))).toList();
  }

  Future<LawyerModel> detail(String id) async => LawyerModel.fromJson(Map<String, dynamic>.from((await _api.get('/api/lawyers/$id', auth: false)) as Map));

  Future<ReviewModel> addReview(String id, {required int rating, String? comment}) async => ReviewModel.fromJson(Map<String, dynamic>.from((await _api.post('/api/lawyers/$id/reviews', body: {'rating': rating, 'comment': comment})) as Map));
}

class ChatApi {
  final ApiClient _api;
  ChatApi(this._api);
  Future<Map<String, dynamic>> send({String? conversationId, required String message}) async =>
      Map<String, dynamic>.from((await _api.post('/api/chat/messages', body: {'conversationId': conversationId, 'message': message})) as Map);
  Future<Map<String, dynamic>> datasetStatus() async => Map<String, dynamic>.from((await _api.get('/api/chat/dataset')) as Map);
  Future<List<SavedChat>> conversations() async {
    final data = await _api.get('/api/chat/conversations');
    return (data as List? ?? const []).whereType<Map>().map((e) => SavedChat.fromJson(Map<String, dynamic>.from(e))).toList();
  }
  Future<Map<String, dynamic>> detail(String id) async => Map<String, dynamic>.from((await _api.get('/api/chat/conversations/$id')) as Map);
  Future<void> remove(String id) => _api.delete('/api/chat/conversations/$id');
}

class BookingsApi {
  final ApiClient _api;
  BookingsApi(this._api);
  Future<List<Map<String, dynamic>>> slots(String lawyerId, String date) async => ((await _api.get('/api/bookings/slots', query: {'lawyerId': lawyerId, 'date': date})) as List).whereType<Map>().map((e) => Map<String, dynamic>.from(e)).toList();
  Future<BookingModel> create({required String lawyerId, required String date, required String time, required String type, String? note}) async => BookingModel.fromJson(Map<String, dynamic>.from((await _api.post('/api/bookings', body: {'lawyerId': lawyerId, 'date': date, 'time': time, 'type': type, 'note': note})) as Map));
  Future<List<BookingModel>> list({String? status}) async => ((await _api.get('/api/bookings', query: {'status': status})) as List).whereType<Map>().map((e) => BookingModel.fromJson(Map<String, dynamic>.from(e))).toList();
  Future<BookingModel> cancel(String id) async => BookingModel.fromJson(Map<String, dynamic>.from((await _api.patch('/api/bookings/$id/cancel')) as Map));
  Future<BookingModel> reschedule(String id, {required String date, required String time}) async => BookingModel.fromJson(Map<String, dynamic>.from((await _api.patch('/api/bookings/$id/reschedule', body: {'date': date, 'time': time})) as Map));
}

class NotificationsApi {
  final ApiClient _api;
  NotificationsApi(this._api);
  Future<({int unreadCount, List<NotificationModel> items})> list() async {
    final map = Map<String, dynamic>.from((await _api.get('/api/notifications')) as Map);
    final items = (map['items'] as List? ?? const []).whereType<Map>().map((e) => NotificationModel.fromJson(Map<String, dynamic>.from(e))).toList();
    return (unreadCount: (map['unreadCount'] as num?)?.toInt() ?? items.where((n)=>!n.isRead).length, items: items);
  }
  Future<void> readAll() => _api.patch('/api/notifications/read-all');
}
