import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:camera/camera.dart';
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

  CameraController? get cameraController => _cameraController;

  PhotoBoothController(this._photoRepository)
      : super(const PhotoBoothState.loading()) {
    _initializeCamera();
  }

  Future<void> _initializeCamera() async {
    try {
      final cameras = await availableCameras();
      if (cameras.isEmpty) {
        state = const PhotoBoothState.error('No cameras available');
        return;
      }

      _cameraController = CameraController(
        cameras.first,
        ResolutionPreset.medium,
      );

      await _cameraController!.initialize();
      state = const PhotoBoothState.data(
        PhotoBoothData(
          isCameraReady: true,
        ),
      );
    } catch (e) {
      state = PhotoBoothState.error(e.toString());
    }
  }

  Future<void> takePhoto() async {
    final currentState = state;
    if (currentState is! _Data) return;
    if (_cameraController == null) return;

    try {
      final xFile = await _cameraController!.takePicture();
      final updatedPhotos = [...currentState.data.photosPaths, xFile.path];

      state = PhotoBoothState.data(
        currentState.data.copyWith(
          photosPaths: updatedPhotos,
          isPhotoGridComplete: updatedPhotos.length >= 4,
        ),
      );
    } catch (e) {
      state = PhotoBoothState.error(e.toString());
    }
  }

  @override
  void dispose() {
    _cameraController?.dispose();
    super.dispose();
  }
}
