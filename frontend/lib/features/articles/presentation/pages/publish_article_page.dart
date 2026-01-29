import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';

import '../../domain/entities/article_entity.dart';
import '../bloc/publish_article_bloc.dart';
import '../bloc/publish_article_event.dart';
import '../bloc/publish_article_state.dart';

/// Página para crear y publicar nuevos artículos

class PublishArticlePage extends StatefulWidget {
  final VoidCallback? onCancel;
  final ArticleEntity? draft; // Optional draft to edit
  final ArticleEntity? articleToEdit; // Published article to edit

  const PublishArticlePage({
    super.key,
    this.onCancel,
    this.draft,
    this.articleToEdit,
  });

  @override
  State<PublishArticlePage> createState() => PublishArticlePageState();
}

class PublishArticlePageState extends State<PublishArticlePage> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _authorController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _contentController = TextEditingController();
  final _imagePicker = ImagePicker();

  File? _selectedImage;
  String? _currentDraftId;
  ArticleEntity? _lastSavedDraft;
  bool _isEditingPublished = false;

  @override
  void initState() {
    super.initState();
    // Priority: articleToEdit (Published) > draft (Local)
    if (widget.articleToEdit != null) {
      _isEditingPublished = true;
      _lastSavedDraft = widget.articleToEdit; // Treat as baseline
      _currentDraftId = widget.articleToEdit!.id;
      _titleController.text = widget.articleToEdit!.title;
      _authorController.text = widget.articleToEdit!.author;
      _descriptionController.text = widget.articleToEdit!.description;
      _contentController.text = widget.articleToEdit!.content;
      // Note: _selectedImage needs a File, but we have a URL.
      // We can't pre-fill File from URL easily without downloading.
      // We'll trust the logic: if _selectedImage is null, check for URL in Bloc?
      // But SubmitArticle event demands File image or we use logic in Bloc to reuse image?
      // Re-reading Bloc logic: "Si estamos editando, tendríamos que manejar el caso de 'mantener imagen existente'."
      // I need to handle this. For now, if user doesn't pick new image, we might fail validation in UI.
      // Modifying UI validation to allow empty image if updating.
    } else if (widget.draft != null) {
      _lastSavedDraft = widget.draft;
      _currentDraftId = widget.draft!.id;
      _titleController.text = widget.draft!.title;
      _authorController.text = widget.draft!.author;
      _descriptionController.text = widget.draft!.description;
      _contentController.text = widget.draft!.content;
      if (widget.draft!.thumbnailUrl.isNotEmpty) {
        _selectedImage = File(widget.draft!.thumbnailUrl);
      }
    }
  }

  /// Public method to check if we can exit (unsaved changes)
  Future<bool> canExit() async {
    return await _onWillPop();
  }

  /// Public method to reset the form (called by parent or self)
  void resetForm() {
    _titleController.clear();
    _authorController.clear();
    _descriptionController.clear();
    _contentController.clear();
    setState(() {
      _selectedImage = null;
      _currentDraftId = null;
      _lastSavedDraft = null;
    });
  }

  @override
  void dispose() {
    _titleController.dispose();
    _authorController.dispose();
    _descriptionController.dispose();
    _contentController.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    try {
      final XFile? pickedFile = await _imagePicker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 1920,
        maxHeight: 1080,
        imageQuality: 85,
      );

      if (pickedFile != null) {
        setState(() {
          _selectedImage = File(pickedFile.path);
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content: Text('Error al seleccionar imagen: $e'),
              backgroundColor: Colors.red),
        );
      }
    }
  }

  void _saveDraft() {
    context.read<PublishArticleBloc>().add(
          SaveDraft(
            id: _currentDraftId,
            author: _authorController.text.trim(),
            title: _titleController.text.trim(),
            description: _descriptionController.text.trim(),
            content: _contentController.text.trim(),
            imagePath: _selectedImage?.path,
          ),
        );
  }

  void _submitForm() {
    if (_formKey.currentState!.validate()) {
      // Validate image: Required only if NOT updating or if we want to enforce it.
      // If updating, and no new image selected, we assume keeping old one.
      // BUT Bloc expects File.
      // Hack/Workaround: If updating and no image selected, we need to pass SOMETHING or change Bloc.
      // Best fix: Change Bloc to accept optional File.
      // For now, to unblock user: require re-selecting image OR download it.
      // Downloading is cleaner. Or create a placeholder File object? No.
      // Let's just ask user to select image for now if it's null,
      // OR if I already have a local path in draft.

      // If articleToEdit (published) has URL, we can't easily make a File.
      // Let's modify validation:
      if (_selectedImage == null && !_isEditingPublished) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
              content: Text('⚠️ Debes seleccionar una imagen de portada'),
              backgroundColor: Colors.orange),
        );
        return;
      }
      // Removed blocking check for _isEditingPublished because we now support optional updates.

      context.read<PublishArticleBloc>().add(
            SubmitArticle(
              id: _currentDraftId,
              author: _authorController.text.trim(),
              title: _titleController.text.trim(),
              description: _descriptionController.text.trim(),
              content: _contentController.text.trim(),
              image: _selectedImage, // Can be null
              currentImageUrl:
                  _lastSavedDraft?.thumbnailUrl, // Pass existing URL
              isUpdate: _isEditingPublished,
            ),
          );
    }
  }

  Future<bool> _onWillPop() async {
    if (!_hasChanges()) return true;

    final shouldDiscard = await _showExitConfirmationDialog();
    return shouldDiscard ?? false;
  }

  /// Check if there are significant changes
  bool _hasChanges() {
    // If we have a saved version (initial or updated), compare against it.
    if (_lastSavedDraft != null) {
      if (_titleController.text.trim() != _lastSavedDraft!.title) {
        return true;
      }
      if (_contentController.text.trim() != _lastSavedDraft!.content) {
        return true;
      }
      if (_descriptionController.text.trim() != _lastSavedDraft!.description) {
        return true;
      }
      if (_authorController.text.trim() != _lastSavedDraft!.author) {
        return true;
      }

      // Compare images (path string)
      final currentImagePath = _selectedImage?.path ?? '';
      if (currentImagePath != _lastSavedDraft!.thumbnailUrl) {
        return true;
      }

      return false;
    }

    // If no saved version (new article never saved), check if fields are empty
    return _titleController.text.isNotEmpty ||
        _contentController.text.isNotEmpty ||
        _descriptionController.text.isNotEmpty ||
        _selectedImage != null;
  }

  Future<bool?> _showExitConfirmationDialog() {
    return showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('¿Guardar Borrador?',
            style:
                TextStyle(fontFamily: 'Butler', fontWeight: FontWeight.bold)),
        content: const Text(
            'Tienes cambios sin guardar. ¿Quieres guardarlos en borradores antes de salir?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false), // Cancel -> Stay
            child: const Text('Cancelar', style: TextStyle(color: Colors.grey)),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(context).pop(true); // Confirm Discard -> Exit
            },
            child: const Text('Descartar', style: TextStyle(color: Colors.red)),
          ),
          ElevatedButton(
            onPressed: () {
              _saveDraft(); // Save
              Navigator.of(context).pop(true); // Exit after save
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.black,
              foregroundColor: Colors.white,
            ),
            child: const Text('Guardar'),
          ),
        ],
      ),
    );
  }

  void _handleCancel() async {
    if (await _onWillPop()) {
      if (widget.onCancel != null) {
        widget.onCancel!();
      } else {
        if (mounted) Navigator.of(context).pop();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    // Use PopScope for Android Back Button / System Back
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) async {
        if (didPop) return;
        final shouldPop = await _onWillPop();
        if (shouldPop) {
          if (widget.onCancel != null) {
            // Custom handling (tab switch)
            widget.onCancel!();
          } else {
            if (mounted) Navigator.of(context).pop();
          }
        }
      },
      child: Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          title: const Text(
            'Crear Historia',
            style: TextStyle(
                color: Colors.black,
                fontFamily: 'Butler',
                fontWeight: FontWeight.bold),
          ),
          backgroundColor: Colors.white,
          elevation: 0,
          leading: IconButton(
            icon: const Icon(Icons.close, color: Colors.black),
            onPressed: _handleCancel,
          ),
        ),
        body: BlocConsumer<PublishArticleBloc, PublishArticleState>(
          listener: (context, state) {
            if (state is PublishArticleSuccess) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                    content: Text('✨ Historia publicada correctamente'),
                    backgroundColor: Colors.green),
              );
              // Reset form for next use
              resetForm();

              if (widget.onCancel != null) {
                widget.onCancel!();
              } else {
                Navigator.of(context).pop();
              }
            } else if (state is SaveDraftSuccess) {
              // Only update ID if the form matches the saved draft context
              // i.e., we haven't reset the form in the meantime.
              if (_titleController.text.isNotEmpty) {
                setState(() {
                  _currentDraftId = state.article.id;
                  _lastSavedDraft =
                      state.article; // Update baseline for change detection
                });
              }

              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                    content: Text('💾 Borrador guardado localmente'),
                    backgroundColor: Colors.blueGrey),
              );
            } else if (state is PublishArticleFailure) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                    content: Text('Error: ${state.error}'),
                    backgroundColor: Colors.red),
              );
            }
          },
          builder: (context, state) {
            final isSubmitting = state is PublishArticleSubmitting;

            return SingleChildScrollView(
              padding: const EdgeInsets.all(20.0),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // 1. Image Picker (Hero Style)
                    _buildImagePicker(isSubmitting),
                    const SizedBox(height: 32),

                    // 2. Main Details
                    const Text('Detalles Principales',
                        style: TextStyle(
                            fontFamily: 'Butler',
                            fontSize: 20,
                            fontWeight: FontWeight.bold)),
                    const SizedBox(height: 16),

                    _buildInput(
                      controller: _titleController,
                      label: 'Título',
                      hint: 'Un titular llamativo...',
                      icon: Icons.title,
                      maxLength: 100,
                      isSubmitting: isSubmitting,
                      validator: (v) =>
                          v!.trim().length < 5 ? 'Mínimo 5 caracteres' : null,
                    ),
                    const SizedBox(height: 16),

                    _buildInput(
                      controller: _authorController,
                      label: 'Autor',
                      hint: 'Tu nombre o el del autor',
                      icon: Icons.person_outline,
                      isSubmitting: isSubmitting,
                      validator: (v) =>
                          v!.trim().isEmpty ? 'Obligatorio' : null,
                    ),
                    const SizedBox(height: 32),

                    // 3. Content
                    const Text('Contenido',
                        style: TextStyle(
                            fontFamily: 'Butler',
                            fontSize: 20,
                            fontWeight: FontWeight.bold)),
                    const SizedBox(height: 16),

                    _buildInput(
                      controller: _descriptionController,
                      label: 'Resumen',
                      hint: 'Breve introducción (tipo tweet)...',
                      icon: Icons.short_text,
                      maxLength: 140,
                      maxLines: 3,
                      isSubmitting: isSubmitting,
                      validator: (v) =>
                          v!.trim().length < 10 ? 'Mínimo 10 caracteres' : null,
                    ),
                    const SizedBox(height: 16),

                    _buildInput(
                      controller: _contentController,
                      label: 'Cuerpo de la historia',
                      hint: 'Desarrolla tu idea aquí...',
                      icon: Icons.article_outlined,
                      maxLength: 3000,
                      maxLines: 15,
                      isSubmitting: isSubmitting,
                      validator: (v) =>
                          v!.trim().length < 20 ? 'Mínimo 20 caracteres' : null,
                    ),
                    const SizedBox(height: 32),

                    // 5. Submit Button (Row)
                    Row(
                      children: [
                        if (!_isEditingPublished) ...[
                          Expanded(
                            child: SizedBox(
                              height: 56,
                              child: OutlinedButton.icon(
                                onPressed: isSubmitting ? null : _saveDraft,
                                icon: const Icon(Icons.save_outlined),
                                label: const Text('Guardar Borrador',
                                    style: TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold)),
                                style: OutlinedButton.styleFrom(
                                  foregroundColor: Colors.black,
                                  side: const BorderSide(color: Colors.black),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(16),
                                  ),
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 16),
                        ],
                        Expanded(
                          child: SizedBox(
                            height: 56,
                            child: ElevatedButton(
                              onPressed: isSubmitting ? null : _submitForm,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.black,
                                foregroundColor: Colors.white,
                                elevation: 5,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(16),
                                ),
                                disabledBackgroundColor: Colors.grey[300],
                              ),
                              child: isSubmitting
                                  ? const CircularProgressIndicator(
                                      color: Colors.white)
                                  : Text(
                                      _isEditingPublished
                                          ? 'Guardar Cambios'
                                          : 'Publicar',
                                      style: const TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.bold)),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 40),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildInput({
    required TextEditingController controller,
    required String label,
    required String hint,
    required IconData icon,
    bool isSubmitting = false,
    int? maxLength,
    int maxLines = 1,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      maxLength: maxLength,
      maxLines: maxLines,
      buildCounter: _buildCharacterCount,
      validator: validator,
      enabled: !isSubmitting,
      style: const TextStyle(fontSize: 16),
      decoration: InputDecoration(
        filled: true,
        fillColor: Colors.grey[50],
        labelText: label,
        hintText: hint,
        alignLabelWithHint: maxLines > 1,
        prefixIcon: Padding(
          padding: const EdgeInsets.only(bottom: 0),
          child: Icon(icon, color: Colors.grey[600], size: 22),
        ),
        labelStyle: TextStyle(color: Colors.grey[600]),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none, // Clean look
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.grey.shade200),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Colors.black, width: 1.5),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Colors.redAccent),
        ),
      ),
    );
  }

  Widget _buildImagePicker(bool isSubmitting) {
    // Determine existing image URL from draft/edit
    final existingImageUrl = _lastSavedDraft?.thumbnailUrl;
    final hasExistingImage =
        existingImageUrl != null && existingImageUrl.isNotEmpty;
    final hasSelectedImage = _selectedImage != null;

    ImageProvider? bgImage;
    if (hasSelectedImage) {
      bgImage = FileImage(_selectedImage!);
    } else if (hasExistingImage) {
      bgImage = NetworkImage(existingImageUrl);
    }

    return GestureDetector(
      onTap: isSubmitting ? null : _pickImage,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        height: 220,
        width: double.infinity,
        decoration: BoxDecoration(
          color: bgImage != null ? Colors.transparent : Colors.grey[50],
          borderRadius: BorderRadius.circular(20),
          border: bgImage != null
              ? null
              : Border.all(
                  color: Colors.grey.shade300, style: BorderStyle.solid),
          image: bgImage != null
              ? DecorationImage(
                  image: bgImage,
                  fit: BoxFit.cover,
                )
              : null,
        ),
        child: bgImage != null
            ? Stack(
                children: [
                  Positioned(
                    top: 12,
                    right: 12,
                    child: GestureDetector(
                      onTap: () => setState(() {
                        _selectedImage = null;
                        // To remove existing image, we might need more logic
                        // For now just clearing selected allows re-picking.
                        // Clearing existing URL from UI requires clearing draft variable
                        // but we probably want to keep it until replaced.
                      }),
                      child: Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: Colors.black.withValues(alpha: 0.6),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                            Icons
                                .edit, // Changed to edit icon to imply replacing
                            color: Colors.white,
                            size: 20),
                      ),
                    ),
                  ),
                ],
              )
            : Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.add_photo_alternate_outlined,
                      size: 48, color: Colors.grey[400]),
                  const SizedBox(height: 12),
                  Text(
                    'Añadir Portada',
                    style: TextStyle(
                        fontFamily: 'Butler',
                        fontSize: 18,
                        color: Colors.grey[500],
                        fontWeight: FontWeight.w500),
                  ),
                ],
              ),
      ),
    );
  }

  Widget? _buildCharacterCount(
    BuildContext context, {
    required int currentLength,
    required bool isFocused,
    required int? maxLength,
  }) {
    if (maxLength == null) return null;
    final remaining = maxLength - currentLength;
    final isNearLimit = remaining <= 20;

    if (!isNearLimit) return null;

    return Text(
      '$remaining caracteres restantes',
      style: TextStyle(
        color: isNearLimit ? Colors.red : Colors.grey,
        fontWeight: isNearLimit ? FontWeight.bold : FontWeight.normal,
        fontSize: 12,
      ),
    );
  }
}
