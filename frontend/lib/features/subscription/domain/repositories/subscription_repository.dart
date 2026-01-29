abstract class SubscriptionRepository {
  /// Checks if the current user has Pro status
  bool get isProUser;

  /// Returns the number of remaining free requests for the day
  int get remainingFreeRequests;

  /// Sets the Pro status (true for Pro, false for Free)
  Future<void> setProStatus(bool isPro);

  /// Decrements the remaining free requests count by 1
  /// Should only be called if not Pro and quota > 0
  Future<void> decrementFreeRequest();

  /// Resets the daily quota to the default maximum (e.g. 20)
  /// checks if a new day has started before resetting
  Future<void> checkAndResetDailyQuota();
}
