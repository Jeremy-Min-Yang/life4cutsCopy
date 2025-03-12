import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:four_cuts/features/photo_booth/presentation/controllers/photo_booth_controller.dart';
import 'package:four_cuts/features/photo_booth/domain/models/photo_booth_state.dart';

void main() {
  late ProviderContainer container;

  setUp(() {
    container = ProviderContainer();
  });

  tearDown(() {
    container.dispose();
  });

  test('Initial state should be loading', () {
    final state = container.read(photoBoothControllerProvider);
    expect(
      state.when(
        loading: () => true,
        error: (_) => false,
        data: (_, __, ___) => false,
      ),
      true,
    );
  });

  // Add more tests as needed
}
