import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/document_model.dart';
import '../services/mock_data_service.dart';

final documentProvider =
    StateNotifierProvider<DocumentNotifier, AsyncValue<List<DocumentModel>>>((
      ref,
    ) {
      return DocumentNotifier();
    });

class DocumentNotifier extends StateNotifier<AsyncValue<List<DocumentModel>>> {
  DocumentNotifier() : super(const AsyncValue.loading()) {
    loadDocuments();
  }

  Future<void> loadDocuments() async {
    state = const AsyncValue.loading();
    try {
      await Future.delayed(const Duration(milliseconds: 500));
      final documents = MockDataService.getDocuments();
      state = AsyncValue.data(documents);
    } catch (e, stack) {
      state = AsyncValue.error(e, stack);
    }
  }

  Future<void> uploadDocument(DocumentModel document) async {
    state.whenData((documents) {
      final updatedDocuments = [...documents, document];
      state = AsyncValue.data(updatedDocuments);
    });
  }

  Future<void> deleteDocument(String documentId) async {
    state.whenData((documents) {
      final updatedDocuments =
          documents.where((doc) => doc.id != documentId).toList();
      state = AsyncValue.data(updatedDocuments);
    });
  }

  Future<void> refresh() async {
    await loadDocuments();
  }
}
