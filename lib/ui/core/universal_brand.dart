import 'package:flutter/material.dart';

// Shared tokens from MYSZTECH_Kiosk_UI_Style_Guide.md.
abstract final class UniversalColors {
  static const canvas = Color(0xFFFAF8F5);
  static const surface = Colors.white;
  static const ink = Color(0xFF24201E);
  static const muted = Color(0xFF625C56);
  static const line = Color(0xFFE7E1DA);
  static const inputBorder = Color(0xFFD9D0C8);
  static const orange = Color(0xFFBC3D16);
  static const orangeHover = Color(0xFFA5300F);
  static const orangeDark = Color(0xFF9F2F0F);
  static const orangeSoft = Color(0xFFFFF0E9);
  static const focus = Color(0xFFB24018);
  static const selectedBorder = Color(0xFFD17756);
  static const success = Color(0xFF176344);
  static const greenSoft = Color(0xFFE8F5ED);
  static const validation = Color(0xFFA12710);
  static const counterSurface = Color(0xFFFFF9F5);
  static const counterBorder = Color(0xFFE1A68F);
  static const adminSelectedSurface = Color(0xFFFFF8F4);
  static const adminSelectedBorder = Color(0xFFDD9E87);
  static const foodSurface = Color(0xFFFFEDE3);
  static const foodIcon = Color(0xFFAA3B19);
  static const retailSurface = Color(0xFFF3EEE6);
  static const retailIcon = Color(0xFF725435);
  static const servicesSurface = Color(0xFFEAF1EC);
  static const servicesIcon = Color(0xFF315E4B);
  static const goldSoft = retailSurface;
  static const shadow = Color(0x0A2B1C10);
  static const dialogBarrier = Color(0x7A261D18);
}

abstract final class UniversalType {
  static const figures = [FontFeature.tabularFigures()];
  static const heading = TextStyle(
    fontWeight: FontWeight.w700,
    fontVariations: [FontVariation('wght', 740)],
    height: 1.09,
    letterSpacing: -1.1,
    color: UniversalColors.ink,
  );
  static const button = TextStyle(
    fontFamily: 'Inter',
    fontSize: 15.2,
    fontWeight: FontWeight.w700,
    fontVariations: [FontVariation('wght', 710)],
    height: 1.2,
    fontFeatures: figures,
  );
  static const price = TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.w800,
    fontVariations: [FontVariation('wght', 780)],
    fontFeatures: figures,
    color: UniversalColors.orangeDark,
  );
}

abstract final class UniversalTheme {
  static ThemeData get theme => ThemeData(
    useMaterial3: true,
    fontFamily: 'Inter',
    scaffoldBackgroundColor: UniversalColors.canvas,
    colorScheme: const ColorScheme.light(
      primary: UniversalColors.orange,
      onPrimary: Colors.white,
      secondary: UniversalColors.orangeDark,
      onSecondary: Colors.white,
      surface: UniversalColors.surface,
      onSurface: UniversalColors.ink,
      onSurfaceVariant: UniversalColors.muted,
      outline: UniversalColors.line,
      outlineVariant: UniversalColors.line,
      error: UniversalColors.validation,
      onError: Colors.white,
    ),
    textTheme: TextTheme(
      headlineLarge: UniversalType.heading.copyWith(fontSize: 48),
      headlineMedium: UniversalType.heading.copyWith(fontSize: 36),
      headlineSmall: UniversalType.heading.copyWith(fontSize: 32),
      titleLarge: UniversalType.heading.copyWith(
        fontSize: 19.6,
        height: 1.25,
        letterSpacing: -.3,
      ),
      titleMedium: const TextStyle(fontSize: 17, fontWeight: FontWeight.w700),
      bodyLarge: const TextStyle(
        fontSize: 16,
        height: 1.5,
        color: UniversalColors.ink,
      ),
      bodyMedium: const TextStyle(
        fontSize: 16,
        height: 1.45,
        color: UniversalColors.ink,
      ),
      bodySmall: const TextStyle(
        fontSize: 14,
        height: 1.4,
        color: UniversalColors.muted,
      ),
      labelLarge: UniversalType.button,
      labelMedium: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
      labelSmall: const TextStyle(fontSize: 12, color: UniversalColors.muted),
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: Colors.white,
      constraints: const BoxConstraints(minHeight: 46),
      contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 13),
      labelStyle: const TextStyle(
        fontSize: 15.2,
        fontWeight: FontWeight.w700,
        fontVariations: [FontVariation('wght', 690)],
      ),
      hintStyle: const TextStyle(fontSize: 16, color: UniversalColors.muted),
      border: _inputBorder(UniversalColors.inputBorder),
      enabledBorder: _inputBorder(UniversalColors.inputBorder),
      focusedBorder: _inputBorder(UniversalColors.focus, 3),
      errorBorder: _inputBorder(UniversalColors.validation),
      focusedErrorBorder: _inputBorder(UniversalColors.validation, 3),
    ),
    iconButtonTheme: IconButtonThemeData(
      style: ButtonStyle(
        minimumSize: const WidgetStatePropertyAll(Size(48, 48)),
        foregroundColor: WidgetStateProperty.resolveWith(
          (states) => states.contains(WidgetState.disabled)
              ? UniversalColors.ink.withValues(alpha: .44)
              : states.contains(WidgetState.hovered)
              ? UniversalColors.orangeDark
              : UniversalColors.ink,
        ),
        backgroundColor: WidgetStateProperty.resolveWith(
          (states) => states.contains(WidgetState.hovered)
              ? UniversalColors.orangeSoft
              : Colors.transparent,
        ),
        side: WidgetStateProperty.resolveWith(
          (states) => states.contains(WidgetState.focused)
              ? const BorderSide(color: UniversalColors.focus, width: 3)
              : states.contains(WidgetState.hovered)
              ? const BorderSide(color: Color(0xFFE3A38B))
              : BorderSide.none,
        ),
        shape: WidgetStatePropertyAll(
          RoundedRectangleBorder(borderRadius: BorderRadius.circular(9)),
        ),
      ),
    ),
    textButtonTheme: TextButtonThemeData(
      style: TextButton.styleFrom(
        minimumSize: const Size(48, 48),
        foregroundColor: UniversalColors.orangeDark,
        textStyle: UniversalType.button,
      ),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: buttonStyle(primary: true),
    ),
    outlinedButtonTheme: OutlinedButtonThemeData(
      style: buttonStyle(primary: false),
    ),
    chipTheme: ChipThemeData(
      backgroundColor: Colors.white,
      selectedColor: UniversalColors.orangeSoft,
      showCheckmark: false,
      labelStyle: TextStyle(
        fontFamily: 'Inter',
        fontSize: 15.2,
        color: WidgetStateColor.resolveWith(
          (states) => states.contains(WidgetState.selected)
              ? UniversalColors.orangeDark
              : UniversalColors.ink,
        ),
      ),
      labelPadding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
      padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 4),
      side: WidgetStateBorderSide.resolveWith(
        (states) => BorderSide(
          color: states.contains(WidgetState.focused)
              ? UniversalColors.focus
              : states.contains(WidgetState.selected)
              ? UniversalColors.selectedBorder
              : UniversalColors.line,
          width: states.contains(WidgetState.focused) ? 3 : 1,
        ),
      ),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(9)),
    ),
    dividerColor: UniversalColors.line,
    dividerTheme: const DividerThemeData(
      color: UniversalColors.line,
      thickness: 1,
    ),
    dialogTheme: DialogThemeData(
      backgroundColor: Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
    ),
    focusColor: UniversalColors.orangeSoft,
    hoverColor: UniversalColors.orangeSoft,
    materialTapTargetSize: MaterialTapTargetSize.padded,
  );

  static OutlineInputBorder _inputBorder(Color color, [double width = 1]) =>
      OutlineInputBorder(
        borderRadius: BorderRadius.circular(9),
        borderSide: BorderSide(color: color, width: width),
      );

  static ButtonStyle buttonStyle({required bool primary}) => ButtonStyle(
    minimumSize: const WidgetStatePropertyAll(Size(49, 49)),
    padding: const WidgetStatePropertyAll(
      EdgeInsets.symmetric(horizontal: 17, vertical: 10),
    ),
    textStyle: const WidgetStatePropertyAll(UniversalType.button),
    foregroundColor: WidgetStatePropertyAll(
      primary ? Colors.white : UniversalColors.ink,
    ),
    backgroundColor: WidgetStateProperty.resolveWith(
      (states) => primary
          ? states.contains(WidgetState.hovered)
                ? UniversalColors.orangeHover
                : UniversalColors.orange
          : states.contains(WidgetState.hovered)
          ? const Color(0xFFFDF9F5)
          : Colors.white,
    ),
    side: WidgetStateProperty.resolveWith(
      (states) => states.contains(WidgetState.focused)
          ? const BorderSide(color: UniversalColors.focus, width: 3)
          : primary
          ? BorderSide.none
          : BorderSide(
              color: states.contains(WidgetState.hovered)
                  ? const Color(0xFFCFC0B2)
                  : UniversalColors.line,
            ),
    ),
    elevation: const WidgetStatePropertyAll(0),
    shape: WidgetStatePropertyAll(
      RoundedRectangleBorder(borderRadius: BorderRadius.circular(11)),
    ),
  );
}

class UniversalLayout {
  const UniversalLayout._(this.width);
  factory UniversalLayout.of(BuildContext context) =>
      UniversalLayout._(MediaQuery.sizeOf(context).width);
  final double width;
  static const frameWidth = 1280.0;
  static const sidebarGap = 24.0;
  static const customerSidebarWidth = 204.0;
  static const adminSidebarWidth = 236.0;
  bool get isDesktop => width > 1160;
  bool get isTablet => width > 630;
  double get pageInset => isTablet ? (width * .025).clamp(20, 32) : 13;
  double get headerHeight => isTablet ? 72 : 65;
  double get contentMaxWidth => frameWidth;
  double get headingSize => (width * .035).clamp(32, 48);
  double get detailHeadingSize =>
      isTablet ? (width * .03).clamp(32, 42) : (width * .065).clamp(24.8, 36);
  double get panelInset => isTablet ? (width * .025).clamp(20, 39) : 17;
}

class UniversalLogo extends StatelessWidget {
  const UniversalLogo({super.key, this.compact = false});
  final bool compact;
  @override
  Widget build(BuildContext context) => Image.asset(
    'assets/images/mysztech-logo.png',
    key: const Key('mysztechLogo'),
    width: compact ? 146 : 172,
    height: compact ? 34 : 40,
    fit: BoxFit.contain,
    semanticLabel: 'MYSZTECH',
  );
}

class PrimaryActionButton extends StatelessWidget {
  const PrimaryActionButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.icon = Icons.arrow_forward,
    this.expanded = false,
    this.hero = false,
  });
  final String label;
  final VoidCallback? onPressed;
  final IconData? icon;
  final bool expanded;
  final bool hero;
  @override
  Widget build(BuildContext context) {
    final child = _ActionButton(
      label: label,
      onPressed: onPressed,
      icon: icon,
      primary: true,
      hero: hero,
    );
    return expanded ? SizedBox(width: double.infinity, child: child) : child;
  }
}

class SecondaryActionButton extends StatelessWidget {
  const SecondaryActionButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.icon,
  });
  final String label;
  final VoidCallback? onPressed;
  final IconData? icon;
  @override
  Widget build(BuildContext context) => _ActionButton(
    label: label,
    onPressed: onPressed,
    icon: icon,
    primary: false,
  );
}

class _ActionButton extends StatefulWidget {
  const _ActionButton({
    required this.label,
    required this.onPressed,
    required this.icon,
    required this.primary,
    this.hero = false,
  });
  final String label;
  final VoidCallback? onPressed;
  final IconData? icon;
  final bool primary;
  final bool hero;
  @override
  State<_ActionButton> createState() => _ActionButtonState();
}

class _ActionButtonState extends State<_ActionButton> {
  bool _focused = false;
  @override
  Widget build(BuildContext context) {
    final style = UniversalTheme.buttonStyle(primary: widget.primary).copyWith(
      minimumSize: WidgetStatePropertyAll(Size(49, widget.hero ? 54 : 49)),
      padding: WidgetStatePropertyAll(
        EdgeInsets.symmetric(horizontal: widget.hero ? 19 : 17, vertical: 10),
      ),
      // The wrapper draws the keyboard ring outside the button, with a 3px gap.
      side: WidgetStateProperty.resolveWith(
        (states) => widget.primary
            ? BorderSide.none
            : BorderSide(
                color: states.contains(WidgetState.hovered)
                    ? const Color(0xFFCFC0B2)
                    : UniversalColors.line,
              ),
      ),
    );
    return Opacity(
      opacity: widget.onPressed == null ? .44 : 1,
      child: DecoratedBox(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(11),
          boxShadow: _focused
              ? [
                  const BoxShadow(
                    color: UniversalColors.focus,
                    spreadRadius: 6,
                  ),
                  const BoxShadow(
                    color: UniversalColors.canvas,
                    spreadRadius: 3,
                  ),
                ]
              : [],
        ),
        child: TextButton(
          onPressed: widget.onPressed,
          onFocusChange: (focused) => setState(() => _focused = focused),
          style: style,
          child: Row(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              if (widget.icon != null) ...[
                Icon(widget.icon, size: 18),
                const SizedBox(width: 10),
              ],
              Flexible(child: Text(widget.label, textAlign: TextAlign.center)),
            ],
          ),
        ),
      ),
    );
  }
}

class SectionHeading extends StatelessWidget {
  const SectionHeading({super.key, required this.title, this.subtitle});
  final String title;
  final String? subtitle;
  @override
  Widget build(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Text(
        title,
        style: UniversalType.heading.copyWith(
          fontSize: UniversalLayout.of(context).headingSize,
        ),
      ),
      if (subtitle != null) ...[
        const SizedBox(height: 8),
        Text(
          subtitle!,
          style: const TextStyle(
            fontSize: 14,
            height: 1.45,
            color: UniversalColors.muted,
          ),
        ),
      ],
    ],
  );
}
