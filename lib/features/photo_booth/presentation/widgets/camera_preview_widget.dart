import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../controllers/photo_booth_controller.dart';
import 'package:camera/camera.dart';

class CameraPreviewWidget extends ConsumerWidget {
  const CameraPreviewWidget({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final photoBoothState = ref.watch(photoBoothControllerProvider);

    return photoBoothState.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (error) => Center(child: Text('Camera Error: $error')),
      data: (data) => data.isCameraReady
          ? AspectRatio(
              aspectRatio: 3 / 4,
              child: CameraPreview(
                ref
                    .read(photoBoothControllerProvider.notifier)
                    .cameraController!,
              ),
            )
          : const Center(child: Text('Initializing camera...')),
    );
  }
}
