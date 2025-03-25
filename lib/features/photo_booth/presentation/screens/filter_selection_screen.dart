import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../widgets/camera_preview_widget.dart';
import 'photo_booth_screen.dart';

enum PhotoFilter {
  none,
  grayscale,
  sepia,
  vintage,
  purple,
  coldlife,
}

final selectedFilterProvider =
    StateProvider<PhotoFilter>((ref) => PhotoFilter.none);

class FilterSelectionScreen extends ConsumerWidget {
  const FilterSelectionScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selectedFilter = ref.watch(selectedFilterProvider);

    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              const Color(0xFF2B1641),
              Colors.black,
            ],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Text(
                  'Choose a Filter',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              Expanded(
                child: GridView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    childAspectRatio: 0.75,
                    crossAxisSpacing: 16,
                    mainAxisSpacing: 16,
                  ),
                  itemCount: PhotoFilter.values.length,
                  itemBuilder: (context, index) {
                    final filter = PhotoFilter.values[index];
                    final isSelected = filter == selectedFilter;
                    return _FilterOption(
                      filter: filter,
                      isSelected: isSelected,
                      onTap: () {
                        ref.read(selectedFilterProvider.notifier).state =
                            filter;
                      },
                    );
                  },
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF6A3093),
                    foregroundColor: Colors.white,
                    minimumSize: Size(double.infinity, 50),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  onPressed: () {
                    Navigator.of(context).pushReplacement(
                      MaterialPageRoute(
                        builder: (context) => const PhotoBoothScreen(
                          isFromFilterSelection: true,
                        ),
                      ),
                    );
                  },
                  child: const Text(
                    'Continue',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _FilterOption extends StatelessWidget {
  final PhotoFilter filter;
  final bool isSelected;
  final VoidCallback onTap;

  const _FilterOption({
    required this.filter,
    required this.isSelected,
    required this.onTap,
  });

  String _getFilterName() {
    switch (filter) {
      case PhotoFilter.none:
        return 'Normal';
      case PhotoFilter.grayscale:
        return 'Grayscale';
      case PhotoFilter.sepia:
        return 'Sepia';
      case PhotoFilter.vintage:
        return 'Vintage';
      case PhotoFilter.purple:
        return 'Purple';
      case PhotoFilter.coldlife:
        return 'Cold Life';
    }
  }

  ColorFilter _getColorFilter() {
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

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isSelected
                ? const Color(0xFF6A3093)
                : Colors.white.withOpacity(0.2),
            width: isSelected ? 3 : 1,
          ),
        ),
        child: Column(
          children: [
            Expanded(
              child: ClipRRect(
                borderRadius: BorderRadius.vertical(top: Radius.circular(15)),
                child: ColorFiltered(
                  colorFilter: _getColorFilter(),
                  child: const CameraPreviewWidget(),
                ),
              ),
            ),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 12),
              decoration: BoxDecoration(
                color: isSelected
                    ? const Color(0xFF6A3093).withOpacity(0.3)
                    : Colors.white.withOpacity(0.1),
                borderRadius:
                    BorderRadius.vertical(bottom: Radius.circular(15)),
              ),
              child: Text(
                _getFilterName(),
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
