import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';

import '../../domain/entities/article_entity.dart';
import '../bloc/publish_article_bloc.dart';
import '../bloc/publish_article_event.dart';
import '../bloc/publish_article_state.dart';

/// Página para crear y publicar nuevos artículos
///
/// Permite al usuario ingresar título, autor, contenido y seleccionar una imagen
/// Utiliza PublishArticleBloc para gestionar el estado de la publicación
class PublishArticlePage extends StatefulWidget {
  final VoidCallback? onCancel;

  const PublishArticlePage({super.key, this.onCancel});

  @override
  State<PublishArticlePage> createState() => _PublishArticlePageState();
}

class _PublishArticlePageState extends State<PublishArticlePage> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _authorController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _contentController = TextEditingController();
  final _imagePicker = ImagePicker();

  File? _selectedImage;
  bool _isPublished = true;
  bool _isVisibleToPublic = true;

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

  void _submitForm() {
    if (_formKey.currentState!.validate()) {
      if (_selectedImage == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
              content: Text('⚠️ Debes seleccionar una imagen de portada'),
              backgroundColor: Colors.orange),
        );
        return;
      }

      final article = ArticleEntity(
        author: _authorController.text.trim(),
        title: _titleController.text.trim(),
        description: _descriptionController.text.trim(),
        content: _contentController.text.trim(),
        thumbnailUrl: '',
        publishedAt: DateTime.now(),
        isPublished: _isPublished,
      );

      context.read<PublishArticleBloc>().add(
            SubmitArticle(article: article, image: _selectedImage!),
          );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
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
          onPressed: () {
            if (widget.onCancel != null) {
              widget.onCancel!();
            } else {
              if (widget.onCancel != null) {
                widget.onCancel!();
              } else {
                Navigator.of(context).pop();
              }
            }
          },
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
            if (widget.onCancel != null) {
              widget.onCancel!();
            } else {
              Navigator.of(context).pop();
            }
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
                    validator: (v) => v!.trim().isEmpty ? 'Obligatorio' : null,
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

                  // 4. Settings
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.grey[50], // Very subtle bg
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: Colors.grey.shade100),
                    ),
                    child: Column(
                      children: [
                        SwitchListTile(
                          title: const Text('Publicar Inmediatamente',
                              style: TextStyle(fontWeight: FontWeight.w600)),
                          value: _isPublished,
                          onChanged: isSubmitting
                              ? null
                              : (v) => setState(() => _isPublished = v),
                        ),
                        Divider(height: 1, color: Colors.grey.shade200),
                        SwitchListTile(
                          title: const Text('Visible al Público',
                              style: TextStyle(fontWeight: FontWeight.w600)),
                          value: _isVisibleToPublic,
                          onChanged: isSubmitting
                              ? null
                              : (v) => setState(() => _isVisibleToPublic = v),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 40),

                  // 5. Submit Button
                  SizedBox(
                    width: double.infinity,
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
                          ? const CircularProgressIndicator(color: Colors.white)
                          : const Text('Publicar Historia',
                              style: TextStyle(
                                  fontSize: 18, fontWeight: FontWeight.bold)),
                    ),
                  ),
                  const SizedBox(height: 40),
                ],
              ),
            ),
          );
        },
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
    return GestureDetector(
      onTap: isSubmitting ? null : _pickImage,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        height: 220,
        width: double.infinity,
        decoration: BoxDecoration(
          color: _selectedImage != null ? Colors.transparent : Colors.grey[50],
          borderRadius: BorderRadius.circular(20),
          border: _selectedImage != null
              ? null
              : Border.all(
                  color: Colors.grey.shade300, style: BorderStyle.solid),
          image: _selectedImage != null
              ? DecorationImage(
                  image: FileImage(_selectedImage!),
                  fit: BoxFit.cover,
                )
              : null,
        ),
        child: _selectedImage != null
            ? Stack(
                children: [
                  Positioned(
                    top: 12,
                    right: 12,
                    child: GestureDetector(
                      onTap: () => setState(() => _selectedImage = null),
                      child: Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: Colors.black.withValues(alpha: 0.6),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(Icons.close,
                            color: Colors.white, size: 20),
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
