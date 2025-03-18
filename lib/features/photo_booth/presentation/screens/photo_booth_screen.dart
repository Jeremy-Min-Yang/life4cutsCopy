import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../controllers/photo_booth_controller.dart';
import '../widgets/camera_preview_widget.dart';
import '../widgets/photo_grid_widget.dart';
import '../widgets/photo_booth_overlay.dart';

class PhotoBoothScreen extends ConsumerStatefulWidget {
  const PhotoBoothScreen({super.key});

  @override
  ConsumerState<PhotoBoothScreen> createState() => _PhotoBoothScreenState();
}

class _PhotoBoothScreenState extends ConsumerState<PhotoBoothScreen> {
  Timer? _timer;
  int _secondsRemaining = 0;
  bool _isCountingDown = false;

  @override
  void initState() {
    super.initState();
    // Start countdown automatically when screen loads
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _startCountdown();
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  void _startCountdown() {
    setState(() {
      _secondsRemaining = 10; // Changed to 10 seconds
      _isCountingDown = true;
    });

    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      setState(() {
        if (_secondsRemaining > 0) {
          _secondsRemaining--;
        } else {
          _isCountingDown = false;
          timer.cancel();
          ref.read(photoBoothControllerProvider.notifier).takePhoto();
        }
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    final photoBoothState = ref.watch(photoBoothControllerProvider);

    return Scaffold(
      body: SafeArea(
        child: photoBoothState.when(
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (error) => Center(child: Text('Error: $error')),
          data: (photosPaths, isPhotoGridComplete, isCameraReady) =>
              _buildContent(photosPaths, isPhotoGridComplete, isCameraReady),
        ),
      ),
    );
  }

  Widget _buildContent(
      List<String> photosPaths, bool isPhotoGridComplete, bool isCameraReady) {
    return Column(
      children: [
        if (!isPhotoGridComplete) ...[
          PhotoBoothOverlay(
            currentPhotoNumber: photosPaths.length + 1,
            secondsRemaining: _secondsRemaining,
            isCountingDown: _isCountingDown,
          ),
          const Expanded(child: CameraPreviewWidget()),
          Container(
            height: 80,
            color: Colors.black.withOpacity(0.5),
            child: const Center(
              child: Text(
                'Get Ready!',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        ] else
          const Expanded(child: PhotoGridWidget()),
      ],
    );
  }
}
