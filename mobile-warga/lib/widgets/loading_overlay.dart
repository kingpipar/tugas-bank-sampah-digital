import 'package:flutter/material.dart';

/// ============================================================
/// Widget: LoadingOverlay
/// ============================================================
/// Overlay semi-transparan dengan CircularProgressIndicator.
/// Digunakan saat proses submit/loading berlangsung agar user
/// tidak bisa berinteraksi dengan UI di bawahnya.
///
/// Cara pakai:
/// ```dart
/// Stack(
///   children: [
///     // ... konten utama ...
///     if (isLoading) const LoadingOverlay(),
///   ],
/// )
/// ```

class LoadingOverlay extends StatelessWidget {
  final String? message;

  const LoadingOverlay({super.key, this.message});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Container(
      color: Colors.black.withValues(alpha: 0.3),
      child: Center(
        child: Card(
          elevation: 8,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                CircularProgressIndicator(
                  color: colorScheme.primary,
                ),
                if (message != null) ...[
                  const SizedBox(height: 16),
                  Text(
                    message!,
                    style: Theme.of(context).textTheme.bodyMedium,
                    textAlign: TextAlign.center,
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}
