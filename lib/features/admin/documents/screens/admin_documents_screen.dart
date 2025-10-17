import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:file_picker/file_picker.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/widgets/admin_sidebar.dart';
import '../../../../core/widgets/loading_indicator.dart';
import '../../../../core/widgets/error_widget.dart';
import '../../../../providers/document_provider.dart';
import '../../../../models/document_model.dart';
import '../../../../core/localization/app_localizations.dart';

class AdminDocumentsScreen extends ConsumerWidget {
  const AdminDocumentsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final documentState = ref.watch(documentProvider);
    final l10n = AppLocalizations.of(context);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        foregroundColor: AppColors.textPrimary,
        elevation: 0,
        title: Text(l10n.documentsManagement),
        bottom: const PreferredSize(
          preferredSize: Size.fromHeight(1),
          child: Divider(height: 1, color: AppColors.border),
        ),
      ),
      drawer: const AdminSidebar(currentRoute: '/admin/documents'),
      body: documentState.when(
        data: (documents) {
          if (documents.isEmpty) {
            return Center(child: Text(l10n.noDocumentsUploaded));
          }

          return RefreshIndicator(
            onRefresh: () => ref.read(documentProvider.notifier).refresh(),
            child: ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: documents.length,
              itemBuilder: (context, index) {
                return _buildDocumentCard(context, ref, documents[index]);
              },
            ),
          );
        },
        loading: () => LoadingIndicator(message: l10n.loadingDocuments),
        error:
            (error, _) => CustomErrorWidget(
              message: error.toString(),
              onRetry: () => ref.read(documentProvider.notifier).refresh(),
            ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _pickAndUploadDocument(context, ref),
        icon: const Icon(Icons.upload_file),
        label: Text(l10n.uploadDocumentTitle),
      ),
    );
  }

  Future<void> _pickAndUploadDocument(
    BuildContext context,
    WidgetRef ref,
  ) async {
    final l10n = AppLocalizations.of(context);
    try {
      final result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['pdf', 'doc', 'docx', 'png', 'jpg', 'jpeg'],
      );

      if (result != null) {
        // Mock upload - in production, this would upload to backend
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              '${l10n.documentUploaded}: "${result.files.first.name}"',
            ),
            backgroundColor: AppColors.success,
          ),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('${l10n.errorPickingFile}: $e'),
          backgroundColor: AppColors.error,
        ),
      );
    }
  }

  Widget _buildDocumentCard(
    BuildContext context,
    WidgetRef ref,
    DocumentModel document,
  ) {
    IconData icon;
    Color iconColor;

    switch (document.type.toLowerCase()) {
      case 'pdf':
        icon = Icons.picture_as_pdf;
        iconColor = AppColors.error;
        break;
      case 'image':
      case 'png':
      case 'jpg':
      case 'jpeg':
        icon = Icons.image;
        iconColor = AppColors.info;
        break;
      default:
        icon = Icons.insert_drive_file;
        iconColor = AppColors.textSecondary;
    }

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: iconColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, color: iconColor, size: 28),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    document.title,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '${AppLocalizations.of(context).uploadedBy} ${document.uploadedBy}',
                    style: const TextStyle(
                      fontSize: 12,
                      color: AppColors.textSecondary,
                    ),
                  ),
                  Text(
                    '${document.sizeInMB} ${AppLocalizations.of(context).mb} • ${DateFormat('MMM d, yyyy').format(document.uploadedAt)}',
                    style: const TextStyle(
                      fontSize: 12,
                      color: AppColors.textHint,
                    ),
                  ),
                ],
              ),
            ),
            PopupMenuButton<String>(
              onSelected: (value) {
                final l10n = AppLocalizations.of(context);
                if (value == 'delete') {
                  showDialog(
                    context: context,
                    builder:
                        (context) => AlertDialog(
                          title: Text(l10n.deleteDocument),
                          content: Text(l10n.confirmDeleteDocument),
                          actions: [
                            TextButton(
                              onPressed: () => Navigator.pop(context),
                              child: Text(l10n.cancel),
                            ),
                            ElevatedButton(
                              onPressed: () {
                                ref
                                    .read(documentProvider.notifier)
                                    .deleteDocument(document.id);
                                Navigator.pop(context);
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text(l10n.documentDeleted),
                                    backgroundColor: AppColors.success,
                                  ),
                                );
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: AppColors.error,
                              ),
                              child: Text(l10n.delete),
                            ),
                          ],
                        ),
                  );
                }
              },
              itemBuilder: (context) {
                final l10n = AppLocalizations.of(context);
                return [
                  PopupMenuItem(
                    value: 'assign',
                    child: Row(
                      children: [
                        const Icon(Icons.person_add, size: 20),
                        const SizedBox(width: 8),
                        Text(l10n.assignToMembers),
                      ],
                    ),
                  ),
                  PopupMenuItem(
                    value: 'delete',
                    child: Row(
                      children: [
                        const Icon(
                          Icons.delete,
                          size: 20,
                          color: AppColors.error,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          l10n.delete,
                          style: const TextStyle(color: AppColors.error),
                        ),
                      ],
                    ),
                  ),
                ];
              },
            ),
          ],
        ),
      ),
    );
  }
}
