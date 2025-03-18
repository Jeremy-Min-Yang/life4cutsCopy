import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../controllers/photo_booth_controller.dart';
import 'package:camera/camera.dart';

class CameraPreviewWidget extends ConsumerWidget {
  const CameraPreviewWidget({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final photoBoothState = ref.watch(photoBoothControllerProvider);
    final controller =
        ref.read(photoBoothControllerProvider.notifier).cameraController;

    return photoBoothState.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (error) => Center(child: Text('Camera Error: $error')),
      data: (photosPaths, isPhotoGridComplete, isCameraReady) => isCameraReady
          ? Stack(
              children: [
                AspectRatio(
                  aspectRatio: 3 / 4,
                  child: Transform.scale(
                    scaleX: controller?.description.lensDirection ==
                            CameraLensDirection.front
                        ? -1.0
                        : 1.0,
                    child: CameraPreview(
                      controller!,
                    ),
                  ),
                ),
                Positioned(
                  top: 16,
                  right: 16,
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.black.withOpacity(0.5),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: TextButton(
                      onPressed: () {
                        ref
                            .read(photoBoothControllerProvider.notifier)
                            .switchCamera();
                      },
                      child: const Text(
                        'Switch',
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            )
          : const Center(child: Text('Initializing camera...')),
    );
  }
}
