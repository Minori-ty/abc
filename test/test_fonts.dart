import 'dart:io';

import 'package:flutter/services.dart';

/// Loads the bundled Figma fonts into the test font collection so widget
/// tests and goldens use real metrics instead of the Ahem fallback.
Future<void> loadAppFonts() async {
  final families = <String, List<(String, int)>>{
    'Open Sans': [
      ('assets/fonts/OpenSans-Regular.ttf', 400),
      ('assets/fonts/OpenSans-SemiBold.ttf', 600),
    ],
    'Poppins': [
      ('assets/fonts/Poppins-SemiBold.ttf', 600),
      ('assets/fonts/Poppins-Bold.ttf', 700),
      // 首屏 Logo 里的 "MF" 是 ExtraBold。
      ('assets/fonts/Poppins-ExtraBold.ttf', 800),
    ],
  };
  for (final entry in families.entries) {
    final loader = FontLoader(entry.key);
    for (final (path, _) in entry.value) {
      final bytes = await File(path).readAsBytes();
      loader.addFont(Future.value(ByteData.view(bytes.buffer)));
    }
    await loader.load();
  }
}
