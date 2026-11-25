import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kiosk/app/kiosk_app.dart';
import 'package:kiosk/data/repositories/universal_catalog_repository.dart';
import 'package:kiosk/domain/models/universal_kiosk_models.dart';
import 'package:kiosk/ui/core/universal_brand.dart';
import 'package:kiosk/ui/features/universal_kiosk/universal_kiosk_view_model.dart';

void main() {
  testWidgets(
    'selected and unselected option labels retain the font and readable colors',
    (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: UniversalTheme.theme,
          home: const Scaffold(
            body: Wrap(
              children: [
                ChoiceChip(label: Text('Regular'), selected: true),
                ChoiceChip(label: Text('Large'), selected: false),
              ],
            ),
          ),
        ),
      );
      for (final label in ['Regular', 'Large']) {
        final context = tester.element(find.text(label));
        final style = DefaultTextStyle.of(context).style;
        expect(style.fontFamily, 'Inter');
        expect(style.fontSize, 15.2);
        expect(
          style.color,
          label == 'Regular' ? UniversalColors.orangeDark : UniversalColors.ink,
        );
      }
    },
  );
  testWidgets(
    'shared controls follow the style guide and retain large touch targets',
    (tester) async {
      var presses = 0;
      await tester.pumpWidget(
        MaterialApp(
          theme: UniversalTheme.theme,
          home: Scaffold(
            body: Column(
              children: [
                PrimaryActionButton(
                  key: const Key('primary'),
                  label: 'Continue',
                  onPressed: () => presses++,
                ),
                const PrimaryActionButton(
                  key: Key('disabled'),
                  label: 'Unavailable',
                  onPressed: null,
                ),
                SecondaryActionButton(
                  key: const Key('secondary'),
                  label: 'Back',
                  onPressed: () {},
                ),
              ],
            ),
          ),
        ),
      );
      final context = tester.element(find.byKey(const Key('primary')));
      expect(Theme.of(context).textTheme.bodyMedium!.fontFamily, 'Inter');
      expect(Theme.of(context).textTheme.bodyMedium!.fontSize, 16);
      expect(
        Theme.of(context).scaffoldBackgroundColor,
        const Color(0xFFFAF8F5),
      );
      expect(UniversalColors.muted, const Color(0xFF625C56));
      expect(UniversalColors.line, const Color(0xFFE7E1DA));

      final primary = find.descendant(
        of: find.byKey(const Key('primary')),
        matching: find.byType(TextButton),
      );
      final style = tester.widget<TextButton>(primary).style!;
      expect(style.backgroundColor!.resolve({}), UniversalColors.orange);
      expect(
        style.backgroundColor!.resolve({WidgetState.hovered}),
        UniversalColors.orangeHover,
      );
      expect(style.textStyle!.resolve({})!.fontSize, 15.2);
      expect(tester.getSize(primary).height, greaterThanOrEqualTo(49));
      await tester.tap(primary);
      expect(presses, 1);

      final disabled = find.byKey(const Key('disabled'));
      final opacity = find.descendant(
        of: disabled,
        matching: find.byType(Opacity),
      );
      expect(tester.widget<Opacity>(opacity).opacity, .44);
      await tester.tap(disabled);
      expect(presses, 1);

      final secondary = tester.widget<TextButton>(
        find.descendant(
          of: find.byKey(const Key('secondary')),
          matching: find.byType(TextButton),
        ),
      );
      expect(secondary.style!.backgroundColor!.resolve({}), Colors.white);
      expect(
        secondary.style!.backgroundColor!.resolve({WidgetState.hovered}),
        const Color(0xFFFDF9F5),
      );
      expect(
        secondary.style!.side!.resolve({WidgetState.hovered})!.color,
        const Color(0xFFCFC0B2),
      );

      FocusManager.instance.primaryFocus?.unfocus();
      await tester.sendKeyEvent(LogicalKeyboardKey.tab);
      await tester.pumpAndSettle();
      final ring = find.descendant(
        of: find.byKey(const Key('primary')),
        matching: find.byWidgetPredicate(
          (widget) =>
              widget is DecoratedBox &&
              widget.decoration is BoxDecoration &&
              (widget.decoration as BoxDecoration).boxShadow?.any(
                    (shadow) =>
                        shadow.color == UniversalColors.focus &&
                        shadow.spreadRadius == 6,
                  ) ==
                  true,
        ),
      );
      expect(ring, findsOneWidget);
      expect(tester.takeException(), isNull);
    },
  );

  testWidgets(
    'catalogue reflows on rotation and the documented grid breakpoints',
    (tester) async {
      final inter = FontLoader('Inter')
        ..addFont(rootBundle.load('assets/fonts/Inter-Variable.ttf'));
      await inter.load();
      tester.view.devicePixelRatio = 2;
      addTearDown(tester.view.reset);
      final vm = UniversalKioskViewModel(
        repository: const LocalUniversalCatalogRepository(),
      );
      addTearDown(vm.dispose);
      await vm.startMode(BusinessMode.retail);
      vm.updateSearch('T-Shirt');
      for (final sample in [
        (size: const Size(900, 1200), columns: 2),
        (size: const Size(901, 600), columns: 3),
        (size: const Size(1160, 720), columns: 3),
        (size: const Size(1161, 720), columns: 4),
        (size: const Size(1920, 1080), columns: 4),
        (size: const Size(390, 844), columns: 2),
        (size: const Size(320, 568), columns: 1),
      ]) {
        tester.view.physicalSize = sample.size * 2;
        await tester.pumpWidget(KioskApp(viewModel: vm));
        await tester.pumpAndSettle();
        final grid = tester.widget<SliverGrid>(
          find.byKey(const Key('productCatalogGrid')),
        );
        final delegate =
            grid.gridDelegate as SliverGridDelegateWithFixedCrossAxisCount;
        expect(
          delegate.crossAxisCount,
          sample.columns,
          reason: '${sample.size}',
        );
        expect(delegate.crossAxisSpacing, 14);
        expect(find.byKey(const Key('product-tee')), findsOneWidget);
        expect(vm.searchQuery, 'T-Shirt');
        expect(vm.activeMode, BusinessMode.retail);
        expect(tester.takeException(), isNull);
      }
    },
  );
}
