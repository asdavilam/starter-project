import 'package:equatable/equatable.dart';
import '../../../articles/domain/entities/article_entity.dart';
import 'package:dio/dio.dart';

abstract class AccountState extends Equatable {
  const AccountState();

  @override
  List<Object?> get props => [];
}

class AccountInitial extends AccountState {
  const AccountInitial();
}

class AccountLoading extends AccountState {
  const AccountLoading();
}

class AccountLoaded extends AccountState {
  final List<ArticleEntity> myArticles;

  const AccountLoaded({required this.myArticles});

  @override
  List<Object?> get props => [myArticles];
}

class AccountError extends AccountState {
  final DioException error;

  const AccountError(this.error);

  @override
  List<Object?> get props => [error];
}
