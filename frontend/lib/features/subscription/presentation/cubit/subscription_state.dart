import 'package:equatable/equatable.dart';

class SubscriptionState extends Equatable {
  final bool isPro;
  final int remainingRequests;
  final bool isLoading;

  const SubscriptionState({
    this.isPro = false,
    this.remainingRequests = 20,
    this.isLoading = false,
  });

  SubscriptionState copyWith({
    bool? isPro,
    int? remainingRequests,
    bool? isLoading,
  }) {
    return SubscriptionState(
      isPro: isPro ?? this.isPro,
      remainingRequests: remainingRequests ?? this.remainingRequests,
      isLoading: isLoading ?? this.isLoading,
    );
  }

  @override
  List<Object> get props => [isPro, remainingRequests, isLoading];
}
