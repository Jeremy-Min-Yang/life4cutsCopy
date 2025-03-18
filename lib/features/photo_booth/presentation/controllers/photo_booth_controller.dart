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
      state = const PhotoBoothState.data(isCameraReady: true);
    } catch (e) {
      state = PhotoBoothState.error(e.toString());
    }
  }

  Future<void> switchCamera() async {
    if (_cameras.length < 2) return;

    _currentCameraIndex = (_currentCameraIndex + 1) % _cameras.length;
    await _setupCamera();
  }

  Future<void> takePhoto() async {
    if (_cameraController == null) return;

    state.whenOrNull(
      data: (photosPaths, isPhotoGridComplete, isCameraReady) async {
        try {
          final xFile = await _cameraController!.takePicture();
          final updatedPhotos = [...photosPaths, xFile.path];

          state = PhotoBoothState.data(
            photosPaths: updatedPhotos,
            isPhotoGridComplete: updatedPhotos.length >= 4,
            isCameraReady: true,
          );
        } catch (e) {
          state = PhotoBoothState.error(e.toString());
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
