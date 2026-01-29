import 'package:shared_preferences/shared_preferences.dart';

abstract class SubscriptionLocalDataSource {
  bool get isProUser;
  int get remainingFreeRequests;
  String? get lastRequestDate;

  Future<void> setProStatus(bool isPro);
  Future<void> setRemainingFreeRequests(int count);
  Future<void> setLastRequestDate(String date);
}

class SubscriptionLocalDataSourceImpl implements SubscriptionLocalDataSource {
  final SharedPreferences sharedPreferences;

  static const String _keyIsPro = 'is_pro_user';
  static const String _keyRemainingRequests = 'remaining_requests_count';
  static const String _keyLastRequestDate = 'last_request_date';

  static const int kDailyFreeRequests = 20;

  SubscriptionLocalDataSourceImpl({required this.sharedPreferences});

  @override
  bool get isProUser => sharedPreferences.getBool(_keyIsPro) ?? false;

  @override
  int get remainingFreeRequests =>
      sharedPreferences.getInt(_keyRemainingRequests) ?? kDailyFreeRequests;

  @override
  String? get lastRequestDate =>
      sharedPreferences.getString(_keyLastRequestDate);

  @override
  Future<void> setProStatus(bool isPro) async {
    await sharedPreferences.setBool(_keyIsPro, isPro);
  }

  @override
  Future<void> setRemainingFreeRequests(int count) async {
    await sharedPreferences.setInt(_keyRemainingRequests, count);
  }

  @override
  Future<void> setLastRequestDate(String date) async {
    await sharedPreferences.setString(_keyLastRequestDate, date);
  }
}
