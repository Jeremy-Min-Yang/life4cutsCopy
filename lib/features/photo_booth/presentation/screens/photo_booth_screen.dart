import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../controllers/photo_booth_controller.dart';
import '../widgets/camera_preview_widget.dart';
import '../widgets/photo_grid_widget.dart';

class PhotoBoothScreen extends ConsumerStatefulWidget {
  const PhotoBoothScreen({super.key});

  @override
  ConsumerState<PhotoBoothScreen> createState() => _PhotoBoothScreenState();
}

class _PhotoBoothScreenState extends ConsumerState<PhotoBoothScreen> {
  @override
  Widget build(BuildContext context) {
    final photoBoothState = ref.watch(photoBoothControllerProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Photo Booth'),
      ),
      body: SafeArea(
        child: photoBoothState.when(
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (error) => Center(child: Text('Error: $error')),
          data: (data) => _buildContent(data),
        ),
      ),
    );
  }

  Widget _buildContent(PhotoBoothData data) {
    return Column(
      children: [
        if (!data.isPhotoGridComplete)
          const Expanded(child: CameraPreviewWidget())
        else
          const Expanded(child: PhotoGridWidget()),
        _buildActionButton(data),
      ],
    );
  }

  Widget _buildActionButton(PhotoBoothData data) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: ElevatedButton(
        onPressed: () =>
            ref.read(photoBoothControllerProvider.notifier).takePhoto(),
        child:
            Text(data.isPhotoGridComplete ? 'Customize Photos' : 'Take Photo'),
      ),
    );
  }
}
