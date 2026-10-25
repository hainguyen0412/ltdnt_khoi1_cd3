import 'package:flutter/material.dart';

/// Hiệu ứng chuyển động liên tục để quan sát UI có bị đơ hay không.
class AnimationMonitor extends StatelessWidget {
  const AnimationMonitor({super.key});

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 0,
      color: Theme.of(context).colorScheme.surfaceContainerHighest,
      child: const Padding(
        padding: EdgeInsets.all(20),
        child: Column(
          children: [
            Text(
              'Nếu vòng quay bị khựng lại, Main Thread đang bị nghẽn (UI Freeze).',
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 20),
            Row(
              children: [
                SizedBox(
                  width: 48,
                  height: 48,
                  child: CircularProgressIndicator(strokeWidth: 5),
                ),
                SizedBox(width: 24),
                Expanded(child: LinearProgressIndicator(minHeight: 8)),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
