import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/notification_model.dart';

class NotificationProvider with ChangeNotifier {
  final SupabaseClient _supabase = Supabase.instance.client;
  List<NotificationModel> _notifications = [];
  bool _isLoading = false;

  List<NotificationModel> get notifications => [..._notifications];
  int get unreadCount => _notifications.where((n) => !n.isRead).length;
  bool get isLoading => _isLoading;

  NotificationProvider() {
    _supabase.auth.onAuthStateChange.listen((data) {
      if (data.event == AuthChangeEvent.signedIn) {
        fetchNotifications();
        _subscribeToNotifications();
      } else if (data.event == AuthChangeEvent.signedOut) {
        _notifications = [];
        notifyListeners();
      }
    });
  }

  Future<void> fetchNotifications() async {
    final user = _supabase.auth.currentUser;
    if (user == null) return;

    _isLoading = true;
    notifyListeners();

    try {
      final data = await _supabase
          .from('notifications')
          .select()
          .eq('user_id', user.id)
          .order('created_at', ascending: false);

      _notifications = (data as List).map((json) => NotificationModel.fromMap(json)).toList();
    } catch (e) {
      debugPrint('Error fetching notifications: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> markAsRead(String id) async {
    try {
      await _supabase.from('notifications').update({'is_read': true}).eq('id', id);
      final index = _notifications.indexWhere((n) => n.id == id);
      if (index != -1) {
        final old = _notifications[index];
        _notifications[index] = NotificationModel(
          id: old.id,
          title: old.title,
          body: old.body,
          type: old.type,
          isRead: true,
          relatedOrderId: old.relatedOrderId,
          createdAt: old.createdAt,
        );
        notifyListeners();
      }
    } catch (e) {
      debugPrint('Error marking notification as read: $e');
    }
  }

  void _subscribeToNotifications() {
    final user = _supabase.auth.currentUser;
    if (user == null) return;

    _supabase
        .channel('public:notifications')
        .onPostgresChanges(
          event: PostgresChangeEvent.insert,
          schema: 'public',
          table: 'notifications',
          filter: PostgresChangeFilter(
            type: PostgresChangeFilterType.eq,
            column: 'user_id',
            value: user.id,
          ),
          callback: (payload) {
            final newNotification = NotificationModel.fromMap(payload.newRecord);
            _notifications.insert(0, newNotification);
            notifyListeners();
          },
        )
        .subscribe();
  }
}
