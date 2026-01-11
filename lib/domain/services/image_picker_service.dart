import 'dart:typed_data';

import 'package:flutter/foundation.dart';
import 'package:image_picker/image_picker.dart';

/// Resultado de selección de imagen.
class PickedImage {
  PickedImage({required this.file, required this.bytes});

  final XFile file;
  final Uint8List bytes;
}

/// Servicio para selección de imágenes con manejo graceful de errores.
///
/// Envuelve [ImagePicker] para capturar excepciones de permisos
/// y devolver null en lugar de fallar.
class ImagePickerService {
  ImagePickerService({ImagePicker? picker}) : _picker = picker ?? ImagePicker();

  final ImagePicker _picker;

  /// Abre la galería para seleccionar una imagen.
  ///
  /// Retorna null si el usuario cancela o deniega permisos.
  Future<PickedImage?> pickFromGallery() async {
    return _pickImage(ImageSource.gallery);
  }

  /// Abre la cámara para tomar una foto.
  ///
  /// Retorna null si el usuario cancela o deniega permisos.
  Future<PickedImage?> pickFromCamera() async {
    return _pickImage(ImageSource.camera);
  }

  Future<PickedImage?> _pickImage(ImageSource source) async {
    try {
      final file = await _picker.pickImage(source: source);
      if (file == null) return null;

      final bytes = await file.readAsBytes();
      return PickedImage(file: file, bytes: bytes);
    } catch (e) {
      // Log but don't throw - permission denied or other platform errors
      debugPrint('ImagePickerService error: $e');
      return null;
    }
  }
}
