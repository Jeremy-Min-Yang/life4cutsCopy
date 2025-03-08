import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:photo_card_maker/features/photo_booth/presentation/controllers/photo_booth_controller.dart';

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
    expect(state, isA<_Loading>());
  });

  // Add more tests as needed
}
