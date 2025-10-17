import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:animate_do/animate_do.dart';
import 'package:file_picker/file_picker.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/widgets/bottom_nav_bar.dart';
import '../../../../core/widgets/custom_app_bar.dart';
import '../../../../core/widgets/custom_card.dart';
import '../../../../core/widgets/loading_indicator.dart';
import '../../../../core/widgets/error_widget.dart';
import '../../../../providers/document_provider.dart';
import '../../../../providers/auth_provider.dart';
import '../../../../models/document_model.dart';
import '../../../../core/localization/app_localizations.dart';

class DocumentsScreen extends ConsumerWidget {
  const DocumentsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final documentState = ref.watch(documentProvider);
    final l10n = AppLocalizations.of(context);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: CustomAppBar(title: l10n.documents),
      body: documentState.when(
        data: (documents) {
          if (documents.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(
                    Icons.folder_open,
                    size: 80,
                    color: AppColors.textHint,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    l10n.noDocumentsAvailable,
                    style: const TextStyle(
                      fontSize: 18,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
            );
          }

          return RefreshIndicator(
            onRefresh: () => ref.read(documentProvider.notifier).refresh(),
            child: ListView.builder(
              padding: const EdgeInsets.only(top: 8, bottom: 16),
              itemCount: documents.length,
              itemBuilder: (context, index) {
                return FadeInUp(
                  delay: Duration(milliseconds: 100 * index),
                  child: _buildDocumentItem(context, documents[index]),
                );
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
      bottomNavigationBar: const BottomNavBar(currentIndex: 1),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showUploadDialog(context, ref),
        backgroundColor: AppColors.primary,
        icon: const Icon(Icons.upload_file),
        label: Text(l10n.uploadDocument),
      ),
    );
  }

  Widget _buildDocumentItem(BuildContext context, DocumentModel document) {
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
      case 'word':
      case 'doc':
      case 'docx':
        icon = Icons.description;
        iconColor = AppColors.primary;
        break;
      default:
        icon = Icons.insert_drive_file;
        iconColor = AppColors.textSecondary;
    }

    return CustomCard(
      onTap: () => _showDocumentViewer(context, document),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: iconColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: iconColor, size: 32),
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
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
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
          const Icon(Icons.arrow_forward_ios, size: 16),
        ],
      ),
    );
  }

  void _showDocumentViewer(BuildContext context, DocumentModel document) {
    final l10n = AppLocalizations.of(context);
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder:
          (context) => Container(
            height: MediaQuery.of(context).size.height * 0.8,
            decoration: const BoxDecoration(
              color: AppColors.background,
              borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
            ),
            child: Column(
              children: [
                Container(
                  margin: const EdgeInsets.only(top: 12),
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: AppColors.divider,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    children: [
                      Expanded(
                        child: Text(
                          document.title,
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.close),
                        onPressed: () => Navigator.pop(context),
                      ),
                    ],
                  ),
                ),
                const Divider(height: 1),
                Expanded(
                  child: Container(
                    color: AppColors.surface,
                    child: Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(
                            Icons.remove_red_eye,
                            size: 64,
                            color: AppColors.primary,
                          ),
                          const SizedBox(height: 16),
                          Text(
                            l10n.documentViewer,
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            l10n.mockViewerForPrototype,
                            style: const TextStyle(
                              fontSize: 14,
                              color: AppColors.textSecondary,
                            ),
                          ),
                          const SizedBox(height: 24),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              _buildViewerButton(Icons.zoom_in, l10n.zoom),
                              const SizedBox(width: 16),
                              _buildViewerButton(
                                Icons.highlight,
                                l10n.highlight,
                              ),
                              const SizedBox(width: 16),
                              _buildViewerButton(Icons.note_add, l10n.note),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                Container(
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    children: [
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed: () {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text(l10n.downloadFeatureComingSoon),
                              ),
                            );
                          },
                          icon: const Icon(Icons.download),
                          label: Text(l10n.download),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: ElevatedButton.icon(
                          onPressed: () {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text(l10n.shareFeatureComingSoon),
                              ),
                            );
                          },
                          icon: const Icon(Icons.share),
                          label: Text(l10n.share),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
    );
  }

  Widget _buildViewerButton(IconData icon, String label) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: AppColors.primary.withOpacity(0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(icon, color: AppColors.primary),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: const TextStyle(fontSize: 12, color: AppColors.textSecondary),
        ),
      ],
    );
  }

  void _showUploadDialog(BuildContext context, WidgetRef ref) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => _UploadDocumentSheet(ref: ref),
    );
  }
}

class _UploadDocumentSheet extends StatefulWidget {
  final WidgetRef ref;

  const _UploadDocumentSheet({required this.ref});

  @override
  State<_UploadDocumentSheet> createState() => _UploadDocumentSheetState();
}

class _UploadDocumentSheetState extends State<_UploadDocumentSheet> {
  PlatformFile? _selectedFile;
  String _visibility = 'all'; // 'all' or 'admin_only'
  bool _isUploading = false;

  Future<void> _pickFile() async {
    try {
      final result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['pdf', 'doc', 'docx', 'png', 'jpg', 'jpeg'],
      );

      if (result != null && result.files.isNotEmpty) {
        setState(() {
          _selectedFile = result.files.first;
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error picking file: $e'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    }
  }

  Future<void> _uploadDocument() async {
    if (_selectedFile == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(AppLocalizations.of(context).pleaseSelectFile),
          backgroundColor: AppColors.warning,
        ),
      );
      return;
    }

    setState(() {
      _isUploading = true;
    });

    try {
      // Get current user name
      final authState = widget.ref.read(authStateProvider);
      final userName = authState.maybeWhen(
        data: (user) => user?.name ?? 'Member',
        orElse: () => 'Member',
      );

      // Create document model
      final document = DocumentModel(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        title: _selectedFile!.name,
        type: _selectedFile!.extension ?? 'file',
        url: 'mock://documents/${_selectedFile!.name}', // Mock URL
        uploadedAt: DateTime.now(),
        uploadedBy: userName,
        size: _selectedFile!.size,
        visibility: _visibility,
      );

      // Upload document
      await widget.ref.read(documentProvider.notifier).uploadDocument(document);

      if (mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(AppLocalizations.of(context).uploadSuccess),
            backgroundColor: AppColors.success,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(AppLocalizations.of(context).uploadFailed),
            backgroundColor: AppColors.error,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isUploading = false;
        });
      }
    }
  }

  String _getFileIcon(String? extension) {
    switch (extension?.toLowerCase()) {
      case 'pdf':
        return '📄';
      case 'doc':
      case 'docx':
        return '📝';
      case 'png':
      case 'jpg':
      case 'jpeg':
        return '🖼️';
      default:
        return '📎';
    }
  }

  String _formatFileSize(int bytes) {
    if (bytes < 1024) return '$bytes B';
    if (bytes < 1024 * 1024) return '${(bytes / 1024).toStringAsFixed(1)} KB';
    return '${(bytes / (1024 * 1024)).toStringAsFixed(1)} MB';
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return Container(
      height: MediaQuery.of(context).size.height * 0.75,
      decoration: const BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
        children: [
          // Handle
          Container(
            margin: const EdgeInsets.only(top: 12),
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: AppColors.divider,
              borderRadius: BorderRadius.circular(2),
            ),
          ),

          // Header
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    l10n.uploadDocument,
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.close),
                  onPressed: () => Navigator.pop(context),
                ),
              ],
            ),
          ),
          const Divider(height: 1),

          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // File Selection
                  Text(
                    l10n.selectFile,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 12),
                  GestureDetector(
                    onTap: _isUploading ? null : _pickFile,
                    child: Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: AppColors.surface,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color:
                              _selectedFile != null
                                  ? AppColors.primary
                                  : AppColors.divider,
                          width: 2,
                        ),
                      ),
                      child:
                          _selectedFile == null
                              ? Column(
                                children: [
                                  Icon(
                                    Icons.cloud_upload_outlined,
                                    size: 48,
                                    color: AppColors.primary,
                                  ),
                                  const SizedBox(height: 8),
                                  Text(
                                    l10n.chooseFile,
                                    style: const TextStyle(
                                      color: AppColors.primary,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  const Text(
                                    'PDF, DOC, DOCX, PNG, JPG',
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: AppColors.textHint,
                                    ),
                                  ),
                                ],
                              )
                              : Row(
                                children: [
                                  Text(
                                    _getFileIcon(_selectedFile!.extension),
                                    style: const TextStyle(fontSize: 32),
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          _selectedFile!.name,
                                          style: const TextStyle(
                                            fontWeight: FontWeight.w600,
                                          ),
                                          maxLines: 2,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                        const SizedBox(height: 4),
                                        Text(
                                          _formatFileSize(_selectedFile!.size),
                                          style: const TextStyle(
                                            fontSize: 12,
                                            color: AppColors.textSecondary,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  IconButton(
                                    icon: const Icon(Icons.close),
                                    onPressed: () {
                                      setState(() {
                                        _selectedFile = null;
                                      });
                                    },
                                  ),
                                ],
                              ),
                    ),
                  ),

                  const SizedBox(height: 24),

                  // Visibility Selection
                  Text(
                    l10n.documentVisibility,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 12),

                  // All Members Option
                  GestureDetector(
                    onTap:
                        _isUploading
                            ? null
                            : () {
                              setState(() {
                                _visibility = 'all';
                              });
                            },
                    child: Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color:
                            _visibility == 'all'
                                ? AppColors.primary.withOpacity(0.1)
                                : AppColors.surface,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color:
                              _visibility == 'all'
                                  ? AppColors.primary
                                  : AppColors.divider,
                          width: 2,
                        ),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            _visibility == 'all'
                                ? Icons.radio_button_checked
                                : Icons.radio_button_unchecked,
                            color:
                                _visibility == 'all'
                                    ? AppColors.primary
                                    : AppColors.textSecondary,
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  l10n.allMembers,
                                  style: TextStyle(
                                    fontWeight: FontWeight.w600,
                                    color:
                                        _visibility == 'all'
                                            ? AppColors.primary
                                            : AppColors.textPrimary,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  l10n.visibleToAll,
                                  style: const TextStyle(
                                    fontSize: 12,
                                    color: AppColors.textSecondary,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Icon(
                            Icons.people,
                            color:
                                _visibility == 'all'
                                    ? AppColors.primary
                                    : AppColors.textSecondary,
                          ),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(height: 12),

                  // Admin Only Option
                  GestureDetector(
                    onTap:
                        _isUploading
                            ? null
                            : () {
                              setState(() {
                                _visibility = 'admin_only';
                              });
                            },
                    child: Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color:
                            _visibility == 'admin_only'
                                ? AppColors.warning.withOpacity(0.1)
                                : AppColors.surface,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color:
                              _visibility == 'admin_only'
                                  ? AppColors.warning
                                  : AppColors.divider,
                          width: 2,
                        ),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            _visibility == 'admin_only'
                                ? Icons.radio_button_checked
                                : Icons.radio_button_unchecked,
                            color:
                                _visibility == 'admin_only'
                                    ? AppColors.warning
                                    : AppColors.textSecondary,
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  l10n.adminOnly,
                                  style: TextStyle(
                                    fontWeight: FontWeight.w600,
                                    color:
                                        _visibility == 'admin_only'
                                            ? AppColors.warning
                                            : AppColors.textPrimary,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  l10n.visibleToAdminOnly,
                                  style: const TextStyle(
                                    fontSize: 12,
                                    color: AppColors.textSecondary,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Icon(
                            Icons.admin_panel_settings,
                            color:
                                _visibility == 'admin_only'
                                    ? AppColors.warning
                                    : AppColors.textSecondary,
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Upload Button
          Container(
            padding: const EdgeInsets.all(16),
            child: SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _isUploading ? null : _uploadDocument,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child:
                    _isUploading
                        ? Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                valueColor: AlwaysStoppedAnimation<Color>(
                                  Colors.white,
                                ),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Text(l10n.uploading),
                          ],
                        )
                        : Text(
                          l10n.upload,
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
