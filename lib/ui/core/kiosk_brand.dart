import 'dart:math' as math;

import 'package:flutter/material.dart';

abstract final class KioskColors {
  static const ink = Color(0xFF202337);
  static const mutedInk = Color(0xFF737586);
  static const orange = Color(0xFFFF5A09);
  static const orangeBright = Color(0xFFFF7A16);
  static const orangeSoft = Color(0xFFFFEEE3);
  static const peach = Color(0xFFFFE2CD);
  static const canvas = Color(0xFFFFFDFC);
  static const line = Color(0xFFF0E5DE);
  static const green = Color(0xFF42BC7B);
}

/// Layout measurements derived from Flutter's logical viewport.
///
/// Flutter maps each device's physical pixels through its display density, so
/// basing the layout on these constraints keeps controls readable and tappable
/// on both a phone and a high-resolution kiosk screen.
class KioskLayout {
  const KioskLayout._({required this.width, required this.height});

  factory KioskLayout.of(BuildContext context) {
    final size = MediaQuery.sizeOf(context);
    return KioskLayout._(width: size.width, height: size.height);
  }

  final double width;
  final double height;

  bool get isKioskViewport => width >= 600;

  double get pagePadding => isKioskViewport ? 30 : 18;

  double get headerHeight => isKioskViewport ? 58 : 38;
}

abstract final class KioskTheme {
  static ThemeData get theme {
    final colorScheme = ColorScheme.fromSeed(
      seedColor: KioskColors.orange,
      brightness: Brightness.light,
      surface: KioskColors.canvas,
    );
    return ThemeData(
      colorScheme: colorScheme.copyWith(
        primary: KioskColors.orange,
        onPrimary: Colors.white,
        surface: KioskColors.canvas,
        onSurface: KioskColors.ink,
      ),
      scaffoldBackgroundColor: KioskColors.canvas,
      useMaterial3: true,
      textTheme: const TextTheme(
        headlineLarge: TextStyle(
          color: KioskColors.ink,
          fontWeight: FontWeight.w800,
          letterSpacing: -1.2,
        ),
        headlineMedium: TextStyle(
          color: KioskColors.ink,
          fontWeight: FontWeight.w800,
          letterSpacing: -0.8,
        ),
        headlineSmall: TextStyle(
          color: KioskColors.ink,
          fontWeight: FontWeight.w800,
          letterSpacing: -0.5,
        ),
        titleLarge: TextStyle(
          color: KioskColors.ink,
          fontWeight: FontWeight.w800,
        ),
        titleMedium: TextStyle(
          color: KioskColors.ink,
          fontWeight: FontWeight.w700,
        ),
        bodyMedium: TextStyle(color: KioskColors.mutedInk),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: Colors.white,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 14,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: KioskColors.line),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: KioskColors.line),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: KioskColors.orange, width: 1.5),
        ),
      ),
    );
  }
}

class MysztechLogo extends StatelessWidget {
  const MysztechLogo({super.key, this.compact = false, this.height = 28});

  final bool compact;
  final double height;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        MysztechMark(size: height),
        if (!compact) ...[
          SizedBox(width: height * 0.32),
          Text(
            'MYSZTECH',
            style: TextStyle(
              color: const Color(0xFF008FD4),
              fontSize: height * 0.56,
              fontWeight: FontWeight.w900,
              letterSpacing: height * 0.08,
            ),
          ),
        ],
      ],
    );
  }
}

class MysztechMark extends StatelessWidget {
  const MysztechMark({super.key, this.size = 28});

  final double size;

  @override
  Widget build(BuildContext context) {
    return SizedBox.square(
      dimension: size,
      child: CustomPaint(painter: _MysztechMarkPainter()),
    );
  }
}

class _MysztechMarkPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = KioskColors.orange
      ..style = PaintingStyle.stroke
      ..strokeWidth = size.width * .13
      ..strokeCap = StrokeCap.round;
    final rect = Rect.fromLTWH(
      size.width * .1,
      size.height * .1,
      size.width * .8,
      size.height * .8,
    );
    canvas.drawArc(rect, math.pi * .1, math.pi * 1.15, false, paint);
    canvas.drawArc(rect, math.pi * 1.1, math.pi * 1.15, false, paint);
    final path = Path()
      ..moveTo(size.width * .22, size.height * .39)
      ..lineTo(size.width * .72, size.height * .39)
      ..lineTo(size.width * .55, size.height * .56)
      ..lineTo(size.width * .78, size.height * .56);
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class LanguagePill extends StatelessWidget {
  const LanguagePill({super.key, required this.onTap, this.large = false});

  final VoidCallback onTap;
  final bool large;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(999),
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.symmetric(
          horizontal: large ? 14 : 10,
          vertical: large ? 9 : 6,
        ),
        decoration: BoxDecoration(
          color: Colors.white,
          border: Border.all(color: KioskColors.line),
          borderRadius: BorderRadius.circular(999),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.language, size: large ? 17 : 12),
            SizedBox(width: large ? 6 : 4),
            Text(
              'EN',
              style: TextStyle(
                fontSize: large ? 14 : 11,
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class KioskPrimaryButton extends StatelessWidget {
  const KioskPrimaryButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.icon,
    this.large = false,
  });

  final String label;
  final VoidCallback? onPressed;
  final Widget? icon;
  final bool large;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: large ? 66 : 52,
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: KioskColors.orange,
          foregroundColor: Colors.white,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          textStyle: TextStyle(
            fontSize: large ? 18 : 15,
            fontWeight: FontWeight.w800,
          ),
        ),
        onPressed: onPressed,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(label),
            if (icon != null) ...[const SizedBox(width: 8), icon!],
          ],
        ),
      ),
    );
  }
}

class KioskStepIndicator extends StatelessWidget {
  const KioskStepIndicator({
    super.key,
    required this.activeStep,
    this.steps = 4,
  });

  final int activeStep;
  final int steps;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        for (var index = 0; index < steps; index++) ...[
          Expanded(
            child: Container(
              height: 2,
              decoration: BoxDecoration(
                color: index < activeStep
                    ? KioskColors.orange
                    : KioskColors.line,
                borderRadius: BorderRadius.circular(20),
              ),
            ),
          ),
          if (index < steps - 1) const SizedBox(width: 7),
        ],
      ],
    );
  }
}

enum FoodArtKind { burger, fries, chicken, generic }

class FoodArtwork extends StatelessWidget {
  const FoodArtwork({super.key, required this.kind, this.size = 92});

  final FoodArtKind kind;
  final double size;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size,
      height: size,
      child: CustomPaint(painter: _FoodArtworkPainter(kind)),
    );
  }
}

class _FoodArtworkPainter extends CustomPainter {
  const _FoodArtworkPainter(this.kind);

  final FoodArtKind kind;

  @override
  void paint(Canvas canvas, Size size) {
    switch (kind) {
      case FoodArtKind.burger:
        _burger(canvas, size);
      case FoodArtKind.fries:
        _fries(canvas, size);
      case FoodArtKind.chicken:
        _chicken(canvas, size);
      case FoodArtKind.generic:
        _generic(canvas, size);
    }
  }

  void _burger(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;
    final rounded = RRect.fromRectAndRadius;
    final bun = Paint()..color = const Color(0xFFF3A639);
    final bunDark = Paint()..color = const Color(0xFFDA7C22);
    final green = Paint()..color = const Color(0xFF54A653);
    final patty = Paint()..color = const Color(0xFF783B23);
    final cheese = Paint()..color = const Color(0xFFFFD34D);
    canvas.drawRRect(
      rounded(
        Rect.fromLTWH(w * .14, h * .16, w * .72, h * .28),
        Radius.circular(h * .3),
      ),
      bun,
    );
    final seeds = Paint()..color = const Color(0xFFFFE4AA);
    for (final x in [.28, .43, .58, .7]) {
      canvas.drawOval(
        Rect.fromCenter(
          center: Offset(w * x, h * .25),
          width: w * .045,
          height: h * .025,
        ),
        seeds,
      );
    }
    canvas.drawRRect(
      rounded(
        Rect.fromLTWH(w * .12, h * .48, w * .76, h * .08),
        Radius.circular(h * .08),
      ),
      green,
    );
    canvas.drawRRect(
      rounded(
        Rect.fromLTWH(w * .15, h * .56, w * .7, h * .14),
        Radius.circular(h * .08),
      ),
      patty,
    );
    canvas.drawPath(
      Path()
        ..moveTo(w * .2, h * .52)
        ..lineTo(w * .8, h * .52)
        ..lineTo(w * .7, h * .64)
        ..lineTo(w * .52, h * .57)
        ..lineTo(w * .34, h * .65)
        ..close(),
      cheese,
    );
    canvas.drawRRect(
      rounded(
        Rect.fromLTWH(w * .13, h * .72, w * .74, h * .14),
        Radius.circular(h * .08),
      ),
      bunDark,
    );
  }

  void _fries(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;
    final fry = Paint()..color = const Color(0xFFFFC843);
    for (final spec in [
      (.25, .2, .1),
      (.39, .12, .1),
      (.53, .17, .1),
      (.67, .09, .1),
    ]) {
      final (x, y, width) = spec;
      canvas.drawRRect(
        RRect.fromRectAndRadius(
          Rect.fromLTWH(w * x, h * y, w * width, h * .55),
          Radius.circular(w * .03),
        ),
        fry,
      );
    }
    final pack = Path()
      ..moveTo(w * .17, h * .48)
      ..lineTo(w * .83, h * .48)
      ..lineTo(w * .72, h * .88)
      ..lineTo(w * .28, h * .88)
      ..close();
    canvas.drawPath(pack, Paint()..color = KioskColors.orange);
    canvas.drawCircle(
      Offset(w * .5, h * .67),
      w * .12,
      Paint()..color = Colors.white,
    );
  }

  void _chicken(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;
    final paint = Paint()..color = const Color(0xFFD68427);
    canvas.drawOval(Rect.fromLTWH(w * .13, h * .34, w * .5, h * .42), paint);
    canvas.drawOval(Rect.fromLTWH(w * .42, h * .22, w * .48, h * .45), paint);
    final bone = Paint()..color = const Color(0xFFFFE7C7);
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(w * .1, h * .63, w * .3, h * .11),
        Radius.circular(h),
      ),
      bone,
    );
    canvas.drawCircle(Offset(w * .09, h * .69), w * .08, bone);
  }

  void _generic(Canvas canvas, Size size) {
    canvas.drawCircle(
      Offset(size.width / 2, size.height / 2),
      size.width * .32,
      Paint()..color = KioskColors.peach,
    );
    canvas.drawCircle(
      Offset(size.width / 2, size.height / 2),
      size.width * .18,
      Paint()..color = KioskColors.orange,
    );
  }

  @override
  bool shouldRepaint(covariant _FoodArtworkPainter oldDelegate) =>
      oldDelegate.kind != kind;
}
