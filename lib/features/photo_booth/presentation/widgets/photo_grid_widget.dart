import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../controllers/photo_booth_controller.dart';
import 'dart:io';

class PhotoGridWidget extends ConsumerWidget {
  const PhotoGridWidget({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final photoBoothState = ref.watch(photoBoothControllerProvider);

    return photoBoothState.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (error) => Center(child: Text('Error: $error')),
      data: (photosPaths, isPhotoGridComplete, isCameraReady) =>
          GridView.builder(
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          childAspectRatio: 3 / 4,
        ),
        itemCount: photosPaths.length,
        itemBuilder: (context, index) => Image.file(
          File(photosPaths[index]),
          fit: BoxFit.cover,
        ),
      ),
    );
  }
}
