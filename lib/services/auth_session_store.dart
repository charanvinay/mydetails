import 'package:shared_preferences/shared_preferences.dart';

abstract class AuthSessionStore {
  const AuthSessionStore();

  Future<bool> hasValidSession();

  Future<void> saveSuccessfulAuth();

  Future<void> clear();
}

class SharedPrefsAuthSessionStore extends AuthSessionStore {
  const SharedPrefsAuthSessionStore();

  static const _authTimestampKey = 'last_successful_auth_ms';
  static const Duration _validFor = Duration(minutes: 10);

  @override
  Future<bool> hasValidSession() async {
    final prefs = await SharedPreferences.getInstance();
    final timestamp = prefs.getInt(_authTimestampKey);
    if (timestamp == null) {
      return false;
    }

    final lastAuth = DateTime.fromMillisecondsSinceEpoch(timestamp);
    final now = DateTime.now();
    return now.difference(lastAuth) < _validFor;
  }

  @override
  Future<void> saveSuccessfulAuth() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(
      _authTimestampKey,
      DateTime.now().millisecondsSinceEpoch,
    );
  }

  @override
  Future<void> clear() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_authTimestampKey);
  }
}
