import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:camera/camera.dart';
import 'package:image/image.dart' as img;
import '../screens/filter_selection_screen.dart';
import 'dart:io';
import '../../domain/models/photo_booth_state.dart';
import '../../domain/repositories/photo_repository.dart';

final photoBoothControllerProvider =
    StateNotifierProvider<PhotoBoothController, PhotoBoothState>((ref) {
  final photoRepository = ref.watch(photoRepositoryProvider);
  return PhotoBoothController(photoRepository);
});

class PhotoBoothController extends StateNotifier<PhotoBoothState> {
  final PhotoRepository _photoRepository;
  CameraController? _cameraController;
  List<CameraDescription> _cameras = [];
  int _currentCameraIndex = 0;

  CameraController? get cameraController => _cameraController;

  PhotoBoothController(this._photoRepository)
      : super(const PhotoBoothState.loading()) {
    _initializeCamera();
  }

  Future<void> _initializeCamera() async {
    try {
      _cameras = await availableCameras();
      if (_cameras.isEmpty) {
        state = const PhotoBoothState.error('No cameras available');
        return;
      }

      // Find front camera
      _currentCameraIndex = _cameras.indexWhere(
        (camera) => camera.lensDirection == CameraLensDirection.front,
      );
      // If no front camera found, use the first available camera
      if (_currentCameraIndex == -1) _currentCameraIndex = 0;

      await _setupCamera();
    } catch (e) {
      state = PhotoBoothState.error(e.toString());
    }
  }

  Future<void> _setupCamera() async {
    if (_cameras.isEmpty) return;

    // Dispose of previous controller if it exists
    await _cameraController?.dispose();

    _cameraController = CameraController(
      _cameras[_currentCameraIndex],
      ResolutionPreset.max,
      enableAudio: false,
      imageFormatGroup: ImageFormatGroup.jpeg,
    );

    try {
      await _cameraController!.initialize();
      await _cameraController!.lockCaptureOrientation();

      // Preserve existing photos when switching cameras
      List<String> existingPhotos = [];
      bool isComplete = false;

      state.whenOrNull(
        data: (photosPaths, isPhotoGridComplete, _) {
          existingPhotos = photosPaths;
          isComplete = isPhotoGridComplete;
        },
      );

      state = PhotoBoothState.data(
        photosPaths: existingPhotos,
        isPhotoGridComplete: isComplete,
        isCameraReady: true,
      );
    } catch (e) {
      state = PhotoBoothState.error(e.toString());
    }
  }

  Future<void> switchCamera() async {
    if (_cameras.length < 2) return;

    _currentCameraIndex = (_currentCameraIndex + 1) % _cameras.length;
    await _setupCamera();
  }

  void _applyFilter(img.Image image, PhotoFilter filter) {
    switch (filter) {
      case PhotoFilter.none:
        return;
      case PhotoFilter.grayscale:
        img.grayscale(image);
        break;
      case PhotoFilter.sepia:
        img.sepia(image);
        break;
      case PhotoFilter.vintage:
        // Vintage effect
        img.adjustColor(image, contrast: 1.1);
        img.sepia(image, amount: 0.5);
        img.vignette(image, start: 0.9, end: 1.3);
        break;
      case PhotoFilter.purple:
        // Purple tint
        for (var y = 0; y < image.height; y++) {
          for (var x = 0; x < image.width; x++) {
            final pixel = image.getPixel(x, y);
            final r = pixel.r;
            final g = pixel.g;
            final b = pixel.b;

            final newR = (r * 1.0).round().clamp(0, 255);
            final newG = (g * 0.8).round().clamp(0, 255);
            final newB = (b * 1.2).round().clamp(0, 255);

            image.setPixelRgba(x, y, newR, newG, newB, 255);
          }
        }
        break;
      case PhotoFilter.coldlife:
        // Cold life effect
        for (var y = 0; y < image.height; y++) {
          for (var x = 0; x < image.width; x++) {
            final pixel = image.getPixel(x, y);
            final r = pixel.r;
            final g = pixel.g;
            final b = pixel.b;

            final newR = (r * 0.8).round().clamp(0, 255);
            final newG = (g * 0.9).round().clamp(0, 255);
            final newB = (b * 1.2).round().clamp(0, 255);

            image.setPixelRgba(x, y, newR, newG, newB, 255);
          }
        }
        break;
    }
  }

  Future<void> takePhoto() async {
    state.whenOrNull(
      data: (photosPaths, isPhotoGridComplete, isCameraReady) async {
        if (!isCameraReady || _cameraController == null) return;

        try {
          final selectedFilter =
              ProviderContainer().read(selectedFilterProvider);
          final XFile photo = await _cameraController!.takePicture();

          // Read the image file
          final bytes = await File(photo.path).readAsBytes();
          var image = img.decodeImage(bytes);

          if (image != null) {
            // Apply the selected filter
            _applyFilter(image, selectedFilter);

            // Save the filtered image
            final filteredBytes = img.encodeJpg(image);
            final filteredPath = photo.path.replaceAll('.jpg', '_filtered.jpg');
            await File(filteredPath).writeAsBytes(filteredBytes);

            // Update state with the filtered image path
            final updatedPhotos = [...photosPaths, filteredPath];
            state = PhotoBoothState.data(
              photosPaths: updatedPhotos,
              isPhotoGridComplete: updatedPhotos.length >= 4,
              isCameraReady: true,
            );
          }
        } catch (e) {
          print('Error taking photo: $e');
        }
      },
    );
  }

  @override
  void dispose() {
    _cameraController?.dispose();
    super.dispose();
  }
}
