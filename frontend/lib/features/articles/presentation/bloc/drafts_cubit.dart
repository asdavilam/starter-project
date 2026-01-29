import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import '../../../../core/resources/data_state.dart';
import '../../domain/entities/article_entity.dart';
import '../../domain/use_cases/get_drafts_use_case.dart';
import '../../domain/use_cases/delete_draft_use_case.dart';

// States
abstract class DraftsState extends Equatable {
  final List<ArticleEntity> drafts;
  const DraftsState({this.drafts = const []});

  @override
  List<Object> get props => [drafts];
}

class DraftsLoading extends DraftsState {
  const DraftsLoading();
}

class DraftsLoaded extends DraftsState {
  const DraftsLoaded(List<ArticleEntity> drafts) : super(drafts: drafts);
}

class DraftsEmpty extends DraftsState {
  const DraftsEmpty();
}

// Cubit
class DraftsCubit extends Cubit<DraftsState> {
  final GetDraftsUseCase _getDraftsUseCase;
  final DeleteDraftUseCase _deleteDraftUseCase;

  DraftsCubit(this._getDraftsUseCase, this._deleteDraftUseCase)
      : super(const DraftsLoading());

  Future<void> loadDrafts() async {
    final dataState = await _getDraftsUseCase.call();

    if (dataState is DataSuccess && dataState.data != null) {
      if (dataState.data!.isNotEmpty) {
        emit(DraftsLoaded(dataState.data!));
      } else {
        emit(const DraftsEmpty());
      }
    } else {
      // For now, treat errors as empty or handle appropriately
      // In a real app we might want a DraftsError state
      emit(const DraftsEmpty());
    }
  }

  Future<void> deleteDraft(String id) async {
    // 1. Optimistic Update: Remove from UI immediately
    if (state is DraftsLoaded) {
      final currentList = List<ArticleEntity>.from(state.drafts);
      currentList.removeWhere((element) => element.id == id);

      final initLength = currentList.length;
      currentList.removeWhere((element) => element.id == id);
      final finalLength = currentList.length;

      if (initLength == finalLength) {
        // Debug: Removal failed (ID mismatch?)
        // Consider forcing a reload if optimistic fails
      }

      if (currentList.isEmpty) {
        emit(const DraftsEmpty());
      } else {
        emit(DraftsLoaded(currentList));
      }
    }

    // 2. Perform actual deletion
    await _deleteDraftUseCase.call(params: id);

    // 3. Optional: Reload to sync (can be skipped if we trust optimistic)
    // loadDrafts();
  }
}
