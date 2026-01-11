import 'dart:typed_data';

import 'package:flutter_test/flutter_test.dart';
import 'package:image_picker/image_picker.dart';
import 'package:mocktail/mocktail.dart';
import 'package:padel_punilla/domain/services/image_picker_service.dart';

// Mocks
class MockImagePicker extends Mock implements ImagePicker {}

class MockXFile extends Mock implements XFile {}

void main() {
  group('ImagePickerService', () {
    late MockImagePicker mockPicker;
    late ImagePickerService service;

    setUp(() {
      mockPicker = MockImagePicker();
      service = ImagePickerService(picker: mockPicker);
    });

    group('pickImage', () {
      test('should return image data when user picks an image', () async {
        // Arrange
        final mockFile = MockXFile();
        final testBytes = Uint8List.fromList([1, 2, 3, 4]);

        when(
          () => mockPicker.pickImage(source: ImageSource.gallery),
        ).thenAnswer((_) async => mockFile);
        when(mockFile.readAsBytes).thenAnswer((_) async => testBytes);

        // Act
        final result = await service.pickFromGallery();

        // Assert
        expect(result, isNotNull);
        expect(result!.bytes, testBytes);
      });

      test('should return null when user cancels', () async {
        // Arrange
        when(
          () => mockPicker.pickImage(source: ImageSource.gallery),
        ).thenAnswer((_) async => null);

        // Act
        final result = await service.pickFromGallery();

        // Assert
        expect(result, isNull);
      });

      test('should return null and not throw on permission denied', () async {
        // Arrange - image_picker throws PlatformException on permission denied
        when(
          () => mockPicker.pickImage(source: ImageSource.gallery),
        ).thenThrow(Exception('Permission denied'));

        // Act
        final result = await service.pickFromGallery();

        // Assert - should return null, not throw
        expect(result, isNull);
      });
    });

    group('pickFromCamera', () {
      test('should return image data from camera', () async {
        // Arrange
        final mockFile = MockXFile();
        final testBytes = Uint8List.fromList([5, 6, 7, 8]);

        when(
          () => mockPicker.pickImage(source: ImageSource.camera),
        ).thenAnswer((_) async => mockFile);
        when(mockFile.readAsBytes).thenAnswer((_) async => testBytes);

        // Act
        final result = await service.pickFromCamera();

        // Assert
        expect(result, isNotNull);
        expect(result!.bytes, testBytes);
      });

      test('should return null on camera permission denied', () async {
        // Arrange
        when(
          () => mockPicker.pickImage(source: ImageSource.camera),
        ).thenThrow(Exception('Camera permission denied'));

        // Act
        final result = await service.pickFromCamera();

        // Assert
        expect(result, isNull);
      });
    });
  });
}
