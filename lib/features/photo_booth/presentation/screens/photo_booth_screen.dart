import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../controllers/photo_booth_controller.dart';
import '../widgets/camera_preview_widget.dart';
import '../widgets/photo_booth_overlay.dart';
import '../screens/layout_selection_screen.dart';
import '../screens/filter_selection_screen.dart';

class PhotoBoothScreen extends ConsumerStatefulWidget {
  final bool isFromFilterSelection;

  const PhotoBoothScreen({
    super.key,
    this.isFromFilterSelection = false,
  });

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
    if (!widget.isFromFilterSelection) {
      // Only navigate to filter selection if this is the initial launch
      WidgetsBinding.instance.addPostFrameCallback((_) {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(
            builder: (context) => const FilterSelectionScreen(),
          ),
        );
      });
    } else {
      // Start countdown automatically if coming from filter selection
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _startCountdown();
      });
    }
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  void _startCountdown() {
    setState(() {
      _secondsRemaining = 2;
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
            // Check if the grid is complete (4 photos taken)
            if (isPhotoGridComplete) {
              // Navigate to layout selection screen
              Future.delayed(const Duration(milliseconds: 700), () {
                if (mounted) {
                  Navigator.of(context).pushReplacement(
                    MaterialPageRoute(
                      builder: (context) => LayoutSelectionScreen(
                        photosPaths: photosPaths,
                      ),
                    ),
                  );
                }
              });
            } else if (!isPhotoGridComplete &&
                photosPaths.length < 4 &&
                isCameraReady) {
              // Only start the next countdown if the grid is NOT complete
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
    final selectedFilter = ref.watch(selectedFilterProvider);

    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        child: Stack(
          children: [
            // Full screen dark background
            Container(
              color: Colors.black.withOpacity(0.5),
            ),

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
                      widthFactor: 0.9,
                      heightFactor: 0.9,
                      child: ColorFiltered(
                        colorFilter: _getColorFilter(selectedFilter),
                        child: const CameraPreviewWidget(),
                      ),
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
                                    color: photoBoothState.whenOrNull(
                                          data: (photosPaths, _, __) => i <
                                                  photosPaths.length
                                              ? Colors.green
                                              : Colors.white.withOpacity(0.5),
                                        ) ??
                                        Colors.white.withOpacity(0.5),
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
            ),

            // Flash overlay
            if (_showFlash)
              Positioned.fill(
                child: Container(
                  color: Colors.white,
                ),
              ),
          ],
        ),
      ),
    );
  }

  ColorFilter _getColorFilter(PhotoFilter filter) {
    switch (filter) {
      case PhotoFilter.none:
        return const ColorFilter.matrix([
          1,
          0,
          0,
          0,
          0,
          0,
          1,
          0,
          0,
          0,
          0,
          0,
          1,
          0,
          0,
          0,
          0,
          0,
          1,
          0,
        ]);
      case PhotoFilter.grayscale:
        return const ColorFilter.matrix([
          0.2126,
          0.7152,
          0.0722,
          0,
          0,
          0.2126,
          0.7152,
          0.0722,
          0,
          0,
          0.2126,
          0.7152,
          0.0722,
          0,
          0,
          0,
          0,
          0,
          1,
          0,
        ]);
      case PhotoFilter.sepia:
        return const ColorFilter.matrix([
          0.393,
          0.769,
          0.189,
          0,
          0,
          0.349,
          0.686,
          0.168,
          0,
          0,
          0.272,
          0.534,
          0.131,
          0,
          0,
          0,
          0,
          0,
          1,
          0,
        ]);
      case PhotoFilter.vintage:
        return const ColorFilter.matrix([
          0.9,
          0.5,
          0.1,
          0,
          0,
          0.3,
          0.8,
          0.1,
          0,
          0,
          0.2,
          0.3,
          0.5,
          0,
          0,
          0,
          0,
          0,
          1,
          0,
        ]);
      case PhotoFilter.purple:
        return const ColorFilter.matrix([
          1,
          0,
          0,
          0,
          0,
          -0.2,
          1,
          0,
          0,
          0,
          0.2,
          0,
          1,
          0,
          0,
          0,
          0,
          0,
          1,
          0,
        ]);
      case PhotoFilter.coldlife:
        return const ColorFilter.matrix([
          0.8,
          0,
          0,
          0,
          0,
          0,
          0.9,
          0,
          0,
          0,
          0,
          0,
          1.2,
          0,
          0,
          0,
          0,
          0,
          1,
          0,
        ]);
    }
  }
}
