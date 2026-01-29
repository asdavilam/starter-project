import '../../domain/repositories/subscription_repository.dart';
import '../data_sources/local/subscription_local_data_source.dart';

class SubscriptionRepositoryImpl implements SubscriptionRepository {
  final SubscriptionLocalDataSource localDataSource;

  // Maximum free requests allowed per day
  static const int kDailyQuota = 20;

  SubscriptionRepositoryImpl({required this.localDataSource});

  @override
  bool get isProUser => localDataSource.isProUser;

  @override
  int get remainingFreeRequests => localDataSource.remainingFreeRequests;

  @override
  Future<void> setProStatus(bool isPro) async {
    await localDataSource.setProStatus(isPro);
  }

  @override
  Future<void> decrementFreeRequest() async {
    if (isProUser) return; // Pro users don't consume quota

    final current = remainingFreeRequests;
    if (current > 0) {
      await localDataSource.setRemainingFreeRequests(current - 1);
      // Update usage date to today if it wasn't already
      await _updateDateIfNeeded();
    }
  }

  @override
  Future<void> checkAndResetDailyQuota() async {
    final lastDate = localDataSource.lastRequestDate;
    final today = DateTime.now().toIso8601String().split('T').first;

    if (lastDate != today) {
      // New day, reset quota
      await localDataSource.setRemainingFreeRequests(kDailyQuota);
      await localDataSource.setLastRequestDate(today);
    }
  }

  Future<void> _updateDateIfNeeded() async {
    final today = DateTime.now().toIso8601String().split('T').first;
    if (localDataSource.lastRequestDate != today) {
      await localDataSource.setLastRequestDate(today);
    }
  }
}
