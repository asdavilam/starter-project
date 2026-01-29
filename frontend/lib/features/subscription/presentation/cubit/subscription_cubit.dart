import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/repositories/subscription_repository.dart';
import 'subscription_state.dart';

class SubscriptionCubit extends Cubit<SubscriptionState> {
  final SubscriptionRepository _repository;

  SubscriptionCubit(this._repository) : super(const SubscriptionState()) {
    checkSubscriptionStatus();
  }

  /// Initial check on app start
  Future<void> checkSubscriptionStatus() async {
    emit(state.copyWith(isLoading: true));

    // Check if day changed and reset quota if needed
    await _repository.checkAndResetDailyQuota();

    final isPro = _repository.isProUser;
    final requests = _repository.remainingFreeRequests;

    emit(state.copyWith(
      isPro: isPro,
      remainingRequests: requests,
      isLoading: false,
    ));
  }

  /// Called when user successfully consumes an AI feature
  Future<void> decrementQuota() async {
    if (state.isPro) return;

    await _repository.decrementFreeRequest();
    // Refresh state from repo to ensure sync
    final requests = _repository.remainingFreeRequests;
    emit(state.copyWith(remainingRequests: requests));
  }

  /// Simulate Pro Upgrade
  Future<void> upgradeToPro() async {
    await _repository.setProStatus(true);
    emit(state.copyWith(isPro: true));
  }

  /// For simulation/testing purposes: Revert to Free
  Future<void> downgradeToFree() async {
    await _repository.setProStatus(false);
    emit(state.copyWith(isPro: false));
    // Refresh quota when downgrading
    await _repository.checkAndResetDailyQuota();
    emit(state.copyWith(remainingRequests: _repository.remainingFreeRequests));
  }
}
