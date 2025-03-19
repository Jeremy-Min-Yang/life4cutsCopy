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
  bool _showFlash = false;

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
      _secondsRemaining = 10; // 10 seconds countdown
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
          _takePictureWithFlash();
        }
      });
    });
  }

  void _takePictureWithFlash() {
    // Show flash effect
    setState(() {
      _showFlash = true;
    });

    // Take picture
    ref.read(photoBoothControllerProvider.notifier).takePhoto();

    // Hide flash after a short delay
    Future.delayed(const Duration(milliseconds: 300), () {
      if (mounted) {
        setState(() {
          _showFlash = false;
        });

        // Check if we need to start another countdown
        final photoBoothState = ref.read(photoBoothControllerProvider);
        photoBoothState.whenOrNull(
          data: (photosPaths, isPhotoGridComplete, isCameraReady) {
            // Only start the next countdown if the grid is NOT complete
            if (!isPhotoGridComplete &&
                photosPaths.length < 4 &&
                isCameraReady) {
              // Start next countdown
              Future.delayed(const Duration(milliseconds: 700), () {
                if (mounted) {
                  _startCountdown();
                }
              });
            }
          },
        );
      }
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
    return Stack(
      children: [
        // Full screen dark background
        Container(
          color: Colors.black.withOpacity(0.5),
        ),

        if (!isPhotoGridComplete)
          Column(
            children: [
              // Top timer bar - fixed height
              PhotoBoothOverlay(
                secondsRemaining: _secondsRemaining,
                isCountingDown: _isCountingDown,
              ),
              // Camera view - takes remaining space
              Expanded(
                child: Center(
                  child: FractionallySizedBox(
                    widthFactor: 0.9, // 90% of available width
                    heightFactor: 0.9, // 90% of available height
                    child: const CameraPreviewWidget(),
                  ),
                ),
              ),
              // Bottom indicator bar - adaptive height
              Container(
                height: 60,
                child: Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // Switch camera button
                      Container(
                        margin: const EdgeInsets.only(bottom: 8),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: TextButton(
                          style: TextButton.styleFrom(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 12, vertical: 6),
                          ),
                          onPressed: () {
                            ref
                                .read(photoBoothControllerProvider.notifier)
                                .switchCamera();
                          },
                          child: const Text(
                            'Switch Camera',
                            style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 14,
                            ),
                          ),
                        ),
                      ),
                      // Photo indicators
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            for (int i = 0; i < 4; i++)
                              Container(
                                margin:
                                    const EdgeInsets.symmetric(horizontal: 4),
                                width: 16,
                                height: 16,
                                decoration: BoxDecoration(
                                  color: i < photosPaths.length
                                      ? Colors.green
                                      : Colors.white.withOpacity(0.5),
                                  borderRadius: BorderRadius.circular(4),
                                ),
                              ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          )
        else
          const Expanded(child: PhotoGridWidget()),

        // Flash overlay
        if (_showFlash)
          Positioned.fill(
            child: Container(
              color: Colors.white,
            ),
          ),
      ],
    );
  }
}
