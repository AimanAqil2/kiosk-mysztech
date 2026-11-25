import 'package:flutter/material.dart';
import 'package:flutter/widget_previews.dart';

import 'kiosk_brand.dart';

@Preview(name: 'MYSZTECH kiosk controls', group: 'Brand', size: Size(412, 220))
Widget kioskControlsPreview() {
  return MaterialApp(
    theme: KioskTheme.theme,
    home: Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const MysztechLogo(),
            const SizedBox(height: 24),
            KioskPrimaryButton(label: 'View Cart', onPressed: () {}),
          ],
        ),
      ),
    ),
  );
}
