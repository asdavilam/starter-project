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
  const PublishArticlePage({super.key});

  @override
  State<PublishArticlePage> createState() => _PublishArticlePageState();
}

class _PublishArticlePageState extends State<PublishArticlePage> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _authorController = TextEditingController();
  final _contentController = TextEditingController();
  final _imagePicker = ImagePicker();

  File? _selectedImage;
  bool _isPublished = true;
  bool _isVisibleToPublic = true;

  @override
  void dispose() {
    _titleController.dispose();
    _authorController.dispose();
    _contentController.dispose();
    super.dispose();
  }

  /// Selecciona una imagen de la galería
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
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  /// Valida y envía el formulario
  void _submitForm() {
    if (_formKey.currentState!.validate()) {
      // Validar que se haya seleccionado una imagen
      if (_selectedImage == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('⚠️ Debes seleccionar una imagen'),
            backgroundColor: Colors.orange,
          ),
        );
        return;
      }

      // Cachear valores trimmed para evitar recalcular
      final trimmedContent = _contentController.text.trim();
      final trimmedTitle = _titleController.text.trim();
      final trimmedAuthor = _authorController.text.trim();

      // Crear descripción de forma segura (máximo 100 caracteres)
      final description = trimmedContent.length <= 100
          ? trimmedContent
          : trimmedContent.substring(0, 100);

      // Crea la entidad del artículo (sin thumbnailUrl aún)
      final article = ArticleEntity(
        author: trimmedAuthor,
        title: trimmedTitle,
        description: description,
        content: trimmedContent,
        thumbnailUrl: '', // Se llenará después del upload
        publishedAt: DateTime.now(),
        isPublished: _isPublished,
      );

      // Dispara el evento de publicación con el artículo Y la imagen
      context.read<PublishArticleBloc>().add(
            SubmitArticle(
              article: article,
              image: _selectedImage!,
            ),
          );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Publicar Artículo'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: BlocConsumer<PublishArticleBloc, PublishArticleState>(
        listener: (context, state) {
          if (state is PublishArticleSuccess) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('✅ Artículo publicado exitosamente'),
                backgroundColor: Colors.green,
                duration: Duration(seconds: 2),
              ),
            );
            // Navega de regreso a la Home
            Navigator.of(context).pop();
          } else if (state is PublishArticleFailure) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('❌ Error: ${state.error}'),
                backgroundColor: Colors.red,
                duration: const Duration(seconds: 3),
              ),
            );
          }
        },
        builder: (context, state) {
          final isSubmitting = state is PublishArticleSubmitting;

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16.0),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Campo de Título
                  TextFormField(
                    controller: _titleController,
                    decoration: const InputDecoration(
                      labelText: 'Título *',
                      hintText: 'Escribe el título del artículo',
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.title),
                    ),
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return 'El título es obligatorio';
                      }
                      if (value.trim().length < 5) {
                        return 'El título debe tener al menos 5 caracteres';
                      }
                      return null;
                    },
                    enabled: !isSubmitting,
                  ),
                  const SizedBox(height: 16),

                  // Campo de Autor
                  TextFormField(
                    controller: _authorController,
                    decoration: const InputDecoration(
                      labelText: 'Autor *',
                      hintText: 'Nombre del autor',
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.person),
                    ),
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return 'El autor es obligatorio';
                      }
                      return null;
                    },
                    enabled: !isSubmitting,
                  ),
                  const SizedBox(height: 16),

                  // Campo de Contenido (multilínea)
                  TextFormField(
                    controller: _contentController,
                    decoration: const InputDecoration(
                      labelText: 'Contenido *',
                      hintText: 'Escribe el contenido del artículo',
                      border: OutlineInputBorder(),
                      alignLabelWithHint: true,
                    ),
                    maxLines: 8,
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return 'El contenido es obligatorio';
                      }
                      if (value.trim().length < 20) {
                        return 'El contenido debe tener al menos 20 caracteres';
                      }
                      return null;
                    },
                    enabled: !isSubmitting,
                  ),
                  const SizedBox(height: 24),

                  // Selector de Imagen
                  _buildImagePicker(isSubmitting),
                  const SizedBox(height: 24),

                  // Switches de configuración
                  SwitchListTile(
                    title: const Text('Publicar inmediatamente'),
                    subtitle: const Text('El artículo estará publicado'),
                    value: _isPublished,
                    onChanged: isSubmitting
                        ? null
                        : (value) {
                            setState(() {
                              _isPublished = value;
                            });
                          },
                  ),
                  SwitchListTile(
                    title: const Text('Visible al público'),
                    subtitle: const Text('El artículo será visible para todos'),
                    value: _isVisibleToPublic,
                    onChanged: isSubmitting
                        ? null
                        : (value) {
                            setState(() {
                              _isVisibleToPublic = value;
                            });
                          },
                  ),
                  const SizedBox(height: 32),

                  // Botón de Publicar
                  ElevatedButton(
                    onPressed: isSubmitting ? null : _submitForm,
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: isSubmitting
                        ? const SizedBox(
                            height: 20,
                            width: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              valueColor:
                                  AlwaysStoppedAnimation<Color>(Colors.white),
                            ),
                          )
                        : const Text(
                            'Publicar Artículo',
                            style: TextStyle(
                                fontSize: 16, fontWeight: FontWeight.bold),
                          ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  /// Construye el widget selector de imagen
  Widget _buildImagePicker(bool isSubmitting) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Imagen del artículo',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w500,
            color: Color(0XFF8B8B8B),
          ),
        ),
        const SizedBox(height: 8),
        InkWell(
          onTap: isSubmitting ? null : _pickImage,
          borderRadius: BorderRadius.circular(8),
          child: Container(
            height: 200,
            decoration: BoxDecoration(
              border: Border.all(color: Colors.grey),
              borderRadius: BorderRadius.circular(8),
              color: Colors.grey[100],
            ),
            child: _selectedImage != null
                ? ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: Image.file(
                      _selectedImage!,
                      fit: BoxFit.cover,
                      width: double.infinity,
                    ),
                  )
                : Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.add_photo_alternate,
                        size: 64,
                        color: Colors.grey[400],
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Toca para seleccionar imagen',
                        style: TextStyle(
                          color: Colors.grey[600],
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
          ),
        ),
        if (_selectedImage != null)
          Padding(
            padding: const EdgeInsets.only(top: 8),
            child: TextButton.icon(
              onPressed: isSubmitting
                  ? null
                  : () {
                      setState(() {
                        _selectedImage = null;
                      });
                    },
              icon: const Icon(Icons.delete, size: 18),
              label: const Text('Eliminar imagen'),
              style: TextButton.styleFrom(
                foregroundColor: Colors.red,
              ),
            ),
          ),
      ],
    );
  }
}
