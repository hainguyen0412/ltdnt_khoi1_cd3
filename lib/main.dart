import 'package:flutter/material.dart';

import 'ui/screens/isolate_demo_screen.dart';

void main() {
  runApp(const IsolateDemoApp());
}

class IsolateDemoApp extends StatelessWidget {
  const IsolateDemoApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Isolate Demo',
      debugShowCheckedModeBanner: false,
      // Đổi thành true để xem biểu đồ khung hình khi demo (tuỳ chọn).
      showPerformanceOverlay: false,
      theme: ThemeData(colorSchemeSeed: Colors.teal, useMaterial3: true),
      home: const IsolateDemoScreen(),
    );
  }
}
