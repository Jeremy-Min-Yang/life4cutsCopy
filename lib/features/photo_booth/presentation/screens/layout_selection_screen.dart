import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../controllers/photo_booth_controller.dart';
import 'photo_grid_screen.dart';

enum PhotoLayout {
  grid2x2,
  vertical1x4,
}

final selectedLayoutProvider = StateProvider<PhotoLayout>((ref) {
  return PhotoLayout.grid2x2; // Default layout
});

class LayoutSelectionScreen extends ConsumerWidget {
  final List<String> photosPaths;

  const LayoutSelectionScreen({
    super.key,
    required this.photosPaths,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        child: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                Color(0xFF2B1641), // Dark purple
                Colors.black,
              ],
            ),
          ),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                const SizedBox(height: 20),
                const Text(
                  'Choose Your Layout',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 30),
                Expanded(
                  child: Row(
                    children: [
                      // 2x2 Grid Option
                      Expanded(
                        child: _LayoutOption(
                          title: '2×2 Grid',
                          layout: PhotoLayout.grid2x2,
                          selected: ref.watch(selectedLayoutProvider) ==
                              PhotoLayout.grid2x2,
                          onTap: () {
                            ref.read(selectedLayoutProvider.notifier).state =
                                PhotoLayout.grid2x2;
                          },
                          photosPaths: photosPaths,
                        ),
                      ),
                      const SizedBox(width: 20),
                      // 1x4 Vertical Option
                      Expanded(
                        child: _LayoutOption(
                          title: '1×4 Vertical',
                          layout: PhotoLayout.vertical1x4,
                          selected: ref.watch(selectedLayoutProvider) ==
                              PhotoLayout.vertical1x4,
                          onTap: () {
                            ref.read(selectedLayoutProvider.notifier).state =
                                PhotoLayout.vertical1x4;
                          },
                          photosPaths: photosPaths,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF6A3093), // Purple
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(
                        horizontal: 48, vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  onPressed: () {
                    Navigator.of(context).pushReplacement(
                      MaterialPageRoute(
                        builder: (context) => PhotoGridScreen(
                          photosPaths: photosPaths,
                          layout: ref.read(selectedLayoutProvider),
                        ),
                      ),
                    );
                  },
                  child: const Text(
                    'Continue',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                ),
                const SizedBox(height: 40),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _LayoutOption extends StatelessWidget {
  final String title;
  final PhotoLayout layout;
  final bool selected;
  final VoidCallback onTap;
  final List<String> photosPaths;

  const _LayoutOption({
    required this.title,
    required this.layout,
    required this.selected,
    required this.onTap,
    required this.photosPaths,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: selected
              ? const Color(0xFF6A3093).withOpacity(0.3) // Highlighted purple
              : Colors.white.withOpacity(0.1),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: selected ? const Color(0xFF6A3093) : Colors.transparent,
            width: 3,
          ),
        ),
        padding: const EdgeInsets.all(12),
        child: Column(
          children: [
            Text(
              title,
              style: TextStyle(
                color: Colors.white,
                fontWeight: selected ? FontWeight.bold : FontWeight.normal,
                fontSize: 18,
              ),
            ),
            const SizedBox(height: 12),
            Expanded(
              child: layout == PhotoLayout.grid2x2
                  ? _buildGridPreview()
                  : _buildVerticalPreview(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildGridPreview() {
    return AspectRatio(
      aspectRatio: 1,
      child: Container(
        decoration: BoxDecoration(
          color: Colors.black,
          borderRadius: BorderRadius.circular(8),
        ),
        child: GridView.count(
          crossAxisCount: 2,
          padding: EdgeInsets.zero,
          physics: const NeverScrollableScrollPhysics(),
          children: List.generate(
            4,
            (index) => Container(
              margin: const EdgeInsets.all(4),
              decoration: BoxDecoration(
                color: Colors.grey.shade800,
                borderRadius: BorderRadius.circular(4),
                image:
                    photosPaths.length > index && photosPaths[index].isNotEmpty
                        ? DecorationImage(
                            image: FileImage(File(photosPaths[index])),
                            fit: BoxFit.cover,
                          )
                        : null,
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildVerticalPreview() {
    return AspectRatio(
      aspectRatio: 0.5,
      child: Container(
        decoration: BoxDecoration(
          color: Colors.black,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Column(
          children: List.generate(
            4,
            (index) => Expanded(
              child: Container(
                margin: const EdgeInsets.symmetric(vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.grey.shade800,
                  borderRadius: BorderRadius.circular(4),
                  image: photosPaths.length > index &&
                          photosPaths[index].isNotEmpty
                      ? DecorationImage(
                          image: FileImage(File(photosPaths[index])),
                          fit: BoxFit.cover,
                        )
                      : null,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
