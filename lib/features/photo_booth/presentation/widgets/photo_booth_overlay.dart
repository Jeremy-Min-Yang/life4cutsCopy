import 'package:flutter/material.dart';

class PhotoBoothOverlay extends StatelessWidget {
  final int secondsRemaining;
  final bool isCountingDown;

  const PhotoBoothOverlay({
    super.key,
    required this.secondsRemaining,
    required this.isCountingDown,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 60,
      child: Center(
        child: isCountingDown
            ? Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(30),
                ),
                child: Text(
                  '$secondsRemaining',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              )
            : const SizedBox(),
      ),
    );
  }
}
