import 'dart:io';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kiosk/app/kiosk_app.dart';
import 'package:kiosk/data/repositories/universal_catalog_repository.dart';
import 'package:kiosk/domain/models/universal_kiosk_models.dart';
import 'package:kiosk/ui/features/universal_kiosk/universal_kiosk_view_model.dart';

const _capture = bool.fromEnvironment('CAPTURE_KIOSK');

Future<void> _captureScreen(WidgetTester tester, String name) async {
  if (!_capture) return;
  await tester.runAsync(() async {
    final context = tester.element(find.byKey(const Key('mysztechLogo')));
    await Future.wait([
      precacheImage(
        const AssetImage('assets/images/mysztech-logo.png'),
        context,
      ),
      for (var i = 1; i <= 12; i++)
        precacheImage(
          AssetImage(
            'assets/images/catalog-${i.toString().padLeft(2, '0')}.webp',
          ),
          context,
        ),
    ]);
  });
  await tester.pumpAndSettle();
  await tester.runAsync(() async {
    final boundary = tester.renderObject<RenderRepaintBoundary>(
      find.byKey(const Key('reviewRoot')),
    );
    final screenshot = await boundary.toImage(pixelRatio: 1);
    final bytes = await screenshot.toByteData(format: ui.ImageByteFormat.png);
    final directory = Directory('.dart_tool/kiosk-review');
    await directory.create(recursive: true);
    await File(
      '${directory.path}/$name.png',
    ).writeAsBytes(bytes!.buffer.asUint8List());
    screenshot.dispose();
  });
}

void main() {
  setUpAll(() async {
    // Test the same bundled typeface and font metrics as the installed app.
    final inter = FontLoader('Inter');
    inter.addFont(rootBundle.load('assets/fonts/Inter-Variable.ttf'));
    await inter.load();
    final artifacts = File(Platform.resolvedExecutable).parent.parent.parent;
    final iconFont = File(
      '${artifacts.path}/material_fonts/MaterialIcons-Regular.otf',
    );
    if (await iconFont.exists()) {
      final loader = FontLoader('MaterialIcons');
      loader.addFont(
        Future.value(ByteData.sublistView(await iconFont.readAsBytes())),
      );
      await loader.load();
    }
  });

  for (final size in [
    const Size(1280, 800),
    const Size(800, 1280),
    const Size(390, 844),
    const Size(800, 600),
    const Size(320, 568),
    const Size(630, 900),
    const Size(631, 900),
    const Size(900, 600),
    const Size(1160, 720),
    const Size(1080, 1920),
    const Size(1920, 1080),
    const Size(800, 480),
  ]) {
    testWidgets('all modes and setup fit ${size.width}x${size.height}', (
      tester,
    ) async {
      await tester.binding.setSurfaceSize(size);
      addTearDown(() => tester.binding.setSurfaceSize(null));
      final vm = UniversalKioskViewModel(
        repository: const LocalUniversalCatalogRepository(),
      );
      final reportError = FlutterError.onError;
      FlutterError.onError = (details) {
        debugPrint(details.toString());
        reportError?.call(details);
      };
      addTearDown(() => FlutterError.onError = reportError);
      addTearDown(vm.dispose);
      await tester.pumpWidget(
        RepaintBoundary(
          key: const Key('reviewRoot'),
          child: KioskApp(viewModel: vm),
        ),
      );
      await tester.pumpAndSettle();
      if (size.width == 1280 || size.width == 390) {
        await _captureScreen(tester, 'welcome-${size.width.toInt()}');
      }
      for (final mode in BusinessMode.values) {
        await vm.beginAdminSetup();
        vm.setConfiguredMode(mode);
        await vm.continueAdminMode();
        vm.addAppointmentTime('10:00');
        vm.addAppointmentTime('14:30');
        await tester.pumpAndSettle();
        for (final step in [
          UniversalScreen.adminWelcome,
          UniversalScreen.adminBusinessInfo,
          UniversalScreen.adminBusinessMode,
          UniversalScreen.adminDisplay,
          UniversalScreen.adminReview,
          UniversalScreen.adminCatalog,
        ]) {
          vm.openAdminStep(step);
          await tester.pumpAndSettle();
          expect(tester.takeException(), isNull, reason: step.name);
        }
        expect(find.byKey(const Key('addCategoryButton')), findsOneWidget);
        expect(tester.takeException(), isNull);
        if (mode == BusinessMode.services) {
          await _captureScreen(tester, 'admin-${size.width.toInt()}');
        }
        await vm.activateKiosk();
        await tester.pumpAndSettle();
        expect(vm.activeMode, mode);
        expect(find.byKey(const Key('mysztechLogo')), findsOneWidget);
        expect(tester.takeException(), isNull);
        await _captureScreen(tester, '${mode.name}-${size.width.toInt()}');
        vm.selectProduct(vm.products.first);
        await tester.pumpAndSettle();
        expect(tester.takeException(), isNull);
        if (size.width == 1280 || size.width == 390) {
          await _captureScreen(
            tester,
            '${mode.name}-detail-${size.width.toInt()}',
          );
        }
        if (mode == BusinessMode.services) {
          expect(find.byKey(const Key('booking-time-10:00')), findsOneWidget);
          expect(find.byKey(const Key('booking-time-11:00')), findsNothing);
          vm.chooseBookingTime('10:00');
          vm.confirmBooking();
        } else {
          vm.addSelectedProduct();
          vm.openSummary();
        }
        await tester.pumpAndSettle();
        expect(tester.takeException(), isNull);
        vm.startPayment();
        await tester.pumpAndSettle();
        expect(tester.takeException(), isNull);
        if (size.width == 1280 || size.width == 390) {
          await _captureScreen(
            tester,
            '${mode.name}-payment-${size.width.toInt()}',
          );
        }
        await tester.ensureVisible(
          find.byKey(const Key('confirmPayAtCounterButton')),
        );
        await tester.tap(find.byKey(const Key('confirmPayAtCounterButton')));
        await tester.pumpAndSettle();
        expect(vm.screen, UniversalScreen.success);
        expect(tester.takeException(), isNull);
        if (size.width == 1280 || size.width == 390) {
          await _captureScreen(
            tester,
            '${mode.name}-success-${size.width.toInt()}',
          );
        }
        await tester.ensureVisible(find.text('Print receipt'));
        await tester.tap(find.text('Print receipt'));
        await tester.pumpAndSettle();
        expect(find.text('Close'), findsOneWidget);
        expect(tester.takeException(), isNull);
        await tester.ensureVisible(find.text('Close'));
        await tester.tap(find.text('Close'));
        await tester.pumpAndSettle();
      }
    });
  }

  for (final profile in [
    (size: const Size(390, 844), density: 3.0, textScale: 1.3, keyboard: 0.0),
    (size: const Size(631, 900), density: 2.0, textScale: 1.5, keyboard: 0.0),
    (size: const Size(1280, 800), density: 2.0, textScale: 1.5, keyboard: 0.0),
    (size: const Size(1080, 1920), density: 2.0, textScale: 1.0, keyboard: 0.0),
    (size: const Size(800, 600), density: 1.0, textScale: 1.0, keyboard: 300.0),
  ]) {
    testWidgets('adapts to $profile', (tester) async {
      tester.view.devicePixelRatio = profile.density;
      tester.view.physicalSize = profile.size * profile.density;
      tester.view.viewInsets = FakeViewPadding(
        bottom: profile.keyboard * profile.density,
      );
      tester.platformDispatcher.textScaleFactorTestValue = profile.textScale;
      addTearDown(tester.view.reset);
      addTearDown(tester.platformDispatcher.clearAllTestValues);
      final vm = UniversalKioskViewModel(
        repository: const LocalUniversalCatalogRepository(),
      );
      addTearDown(vm.dispose);
      await tester.pumpWidget(KioskApp(viewModel: vm));
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull);
      for (final mode in BusinessMode.values) {
        await vm.beginAdminSetup();
        vm.setConfiguredMode(mode);
        await vm.continueAdminMode();
        vm.addAppointmentTime('10:00');
        for (final step in [
          UniversalScreen.adminWelcome,
          UniversalScreen.adminBusinessInfo,
          UniversalScreen.adminBusinessMode,
          UniversalScreen.adminCatalog,
          UniversalScreen.adminDisplay,
          UniversalScreen.adminReview,
        ]) {
          vm.openAdminStep(step);
          await tester.pumpAndSettle();
          expect(tester.takeException(), isNull, reason: step.name);
        }
        await vm.activateKiosk();
        await tester.pumpAndSettle();
        expect(tester.takeException(), isNull, reason: 'catalog');
        vm.selectProduct(vm.products.first);
        await tester.pumpAndSettle();
        expect(tester.takeException(), isNull, reason: 'detail / booking');
        if (mode == BusinessMode.services) {
          vm.chooseBookingTime('10:00');
          vm.confirmBooking();
        } else {
          vm.addSelectedProduct();
          vm.openSummary();
        }
        await tester.pumpAndSettle();
        expect(tester.takeException(), isNull, reason: 'summary');
        vm.startPayment();
        await tester.pumpAndSettle();
        expect(tester.takeException(), isNull, reason: 'payment');
        await tester.ensureVisible(
          find.byKey(const Key('confirmPayAtCounterButton')),
        );
        await tester.tap(find.byKey(const Key('confirmPayAtCounterButton')));
        await tester.pumpAndSettle();
        expect(vm.screen, UniversalScreen.success);
        expect(tester.takeException(), isNull, reason: 'confirmation');
        await tester.ensureVisible(find.text('Print receipt'));
        await tester.tap(find.text('Print receipt'));
        await tester.pumpAndSettle();
        expect(tester.takeException(), isNull, reason: 'receipt');
        await tester.ensureVisible(find.text('Close'));
        await tester.tap(find.text('Close'));
        await tester.pumpAndSettle();
      }
    });
  }

  testWidgets('admin time picker adds and removes the customer time', (
    tester,
  ) async {
    await tester.binding.setSurfaceSize(const Size(1280, 900));
    addTearDown(() => tester.binding.setSurfaceSize(null));
    final vm = UniversalKioskViewModel(
      repository: const LocalUniversalCatalogRepository(),
    );
    addTearDown(vm.dispose);
    await vm.beginAdminSetup();
    vm.setConfiguredMode(BusinessMode.services);
    await vm.continueAdminMode();
    await tester.pumpWidget(KioskApp(viewModel: vm));
    await tester.pumpAndSettle();
    await tester.ensureVisible(find.byKey(const Key('appointmentTimePicker')));
    await tester.tap(find.byKey(const Key('appointmentTimePicker')));
    await tester.pumpAndSettle();
    await tester.tap(find.text('OK'));
    await tester.pumpAndSettle();
    await tester.ensureVisible(
      find.byKey(const Key('addAppointmentTimeButton')),
    );
    await tester.tap(find.byKey(const Key('addAppointmentTimeButton')));
    await tester.pumpAndSettle();
    expect(vm.appointmentTimes, ['10:00']);
    await tester.tap(find.byTooltip('Remove 10:00 AM'));
    await tester.pumpAndSettle();
    expect(vm.appointmentTimes, isEmpty);
    expect(tester.takeException(), isNull);
  });

  testWidgets('catalog editor saves a service and activation opens Services', (
    tester,
  ) async {
    await tester.binding.setSurfaceSize(const Size(1280, 900));
    addTearDown(() => tester.binding.setSurfaceSize(null));
    final vm = UniversalKioskViewModel(
      repository: const LocalUniversalCatalogRepository(),
    );
    addTearDown(vm.dispose);
    await vm.beginAdminSetup();
    vm.setConfiguredMode(BusinessMode.services);
    await vm.continueAdminMode();
    await tester.pumpWidget(KioskApp(viewModel: vm));
    await tester.pumpAndSettle();

    await tester.tap(find.byKey(const Key('addCategoryButton')));
    await tester.pumpAndSettle();
    await tester.enterText(find.byKey(const Key('categoryNameField')), 'Spa');
    await tester.tap(find.text('Save'));
    await tester.pumpAndSettle();
    expect(vm.categoriesForMode(BusinessMode.services), contains('Spa'));

    await tester.tap(find.byTooltip('Edit Haircut'));
    await tester.pumpAndSettle();
    final fields = find.byType(TextFormField);
    await tester.enterText(fields.at(0), 'Signature haircut');
    await tester.enterText(fields.at(2), '35.50');
    await tester.enterText(fields.at(3), '45');
    await tester.tap(find.text('Save'));
    await tester.pumpAndSettle();
    final service = vm.catalogForMode(BusinessMode.services).first;
    expect(service.name, 'Signature haircut');
    expect(service.priceMinor, 3550);
    expect(service.durationMinutes, 45);
    expect(service.imageAsset, isNotNull);

    await tester.ensureVisible(find.text('Continue'));
    await tester.tap(find.text('Continue'));
    await tester.pumpAndSettle();
    await tester.ensureVisible(find.text('Continue'));
    await tester.tap(find.text('Continue'));
    await tester.pumpAndSettle();
    await tester.ensureVisible(find.byKey(const Key('activateKioskButton')));
    await tester.tap(find.byKey(const Key('activateKioskButton')));
    await tester.pumpAndSettle();
    expect(vm.screen, UniversalScreen.serviceCatalog);
    expect(find.text('Browse services'), findsOneWidget);
    expect(find.text('Signature haircut'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
}
