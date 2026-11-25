import 'package:flutter_test/flutter_test.dart';
import 'package:kiosk/data/repositories/universal_catalog_repository.dart';
import 'package:kiosk/data/repositories/kiosk_settings_store.dart';
import 'package:kiosk/domain/models/universal_kiosk_models.dart';
import 'package:kiosk/ui/features/universal_kiosk/universal_kiosk_view_model.dart';

void main() {
  group('UniversalKioskViewModel', () {
    late UniversalKioskViewModel viewModel;

    setUp(() {
      viewModel = UniversalKioskViewModel(
        repository: const LocalUniversalCatalogRepository(),
      );
    });

    test(
      'opens the retail catalog and adds a selected item to the order',
      () async {
        await viewModel.startMode(BusinessMode.retail);

        expect(viewModel.screen, UniversalScreen.retailCatalog);
        expect(viewModel.products, isNotEmpty);

        viewModel.selectProduct(viewModel.products.first);
        expect(viewModel.screen, UniversalScreen.productDetail);

        viewModel.addSelectedProduct(quantity: 2, optionLabel: 'Standard');

        expect(viewModel.screen, UniversalScreen.retailCatalog);
        expect(viewModel.itemCount, 2);
        expect(viewModel.totalMinor, viewModel.products.first.priceMinor * 2);
      },
    );

    test('adds a service booking with the selected date and time', () async {
      await viewModel.startMode(BusinessMode.services);
      viewModel.addAppointmentTime('14:30');
      viewModel.selectProduct(viewModel.products.first);
      final date = UniversalKioskViewModel.dateValue(
        UniversalKioskViewModel.malaysiaToday.add(const Duration(days: 1)),
      );
      viewModel.chooseBookingDate(date);
      viewModel.chooseBookingTime('14:30');

      viewModel.confirmBooking();

      expect(viewModel.screen, UniversalScreen.orderSummary);
      expect(viewModel.cart.single.optionLabel, '$date · 14:30');
    });

    test(
      'validates a numeric table number against the configured range',
      () async {
        await viewModel.startMode(BusinessMode.food);
        await viewModel.chooseOrderType(OrderType.dineIn);

        expect(await viewModel.saveTableNumber('T01'), isFalse);
        expect(viewModel.screen, UniversalScreen.foodTable);
        expect(await viewModel.saveTableNumber('21'), isFalse);
        expect(await viewModel.saveTableNumber('20'), isTrue);
        expect(viewModel.tableNumber, '20');
        expect(viewModel.screen, UniversalScreen.foodCatalog);
      },
    );

    test(
      'keeps variant and add-on charges in an independently editable line',
      () async {
        await viewModel.startMode(BusinessMode.food);
        await viewModel.chooseOrderType(OrderType.takeaway);
        final burger = viewModel.products.first;
        viewModel.selectProduct(burger);
        viewModel.addSelectedProduct(
          variant: burger.variants.last,
          addOns: [burger.addOns.first],
          remark: 'No onions',
        );

        final line = viewModel.cart.single;
        expect(line.totalMinor, 2190);
        expect(line.details, contains('No onions'));
        expect(viewModel.variantTotalMinor, 400);
        expect(viewModel.addOnTotalMinor, 200);
      },
    );

    test('requires a time before a service booking can be confirmed', () async {
      await viewModel.startMode(BusinessMode.services);
      viewModel.selectProduct(viewModel.products.first);
      viewModel.confirmBooking();

      expect(viewModel.cart, isEmpty);
      expect(viewModel.screen, UniversalScreen.serviceBooking);
    });

    test('keeps Admin Setup settings after activation', () async {
      viewModel.updateBusinessInformation(
        name: 'MYSZTECH Studio',
        email: 'studio@example.com',
        phone: '0123456789',
        address: 'Kuala Lumpur',
      );
      viewModel.setConfiguredMode(BusinessMode.retail);
      await viewModel.continueAdminMode();
      viewModel.continueAdminCatalog();
      viewModel.updateDisplaySettings(
        receiptEnabled: false,
        welcomeHeading: 'Welcome to the studio',
        receiptHeader: 'MYSZTECH Studio',
        receiptFooter: 'See you again.',
      );

      await viewModel.activateKiosk();

      expect(viewModel.isActivated, isTrue);
      expect(viewModel.profile.mode, BusinessMode.retail);
      expect(viewModel.profile.receiptEnabled, isFalse);
      expect(viewModel.welcomeHeading, 'Welcome to the studio');
      expect(viewModel.screen, UniversalScreen.retailCatalog);
    });

    for (final mode in BusinessMode.values) {
      test(
        'activation and restart open the saved ${mode.name} catalog',
        () async {
          final store = MemoryKioskSettingsStore();
          final vm = UniversalKioskViewModel(
            repository: const LocalUniversalCatalogRepository(),
            settingsStore: store,
          );
          addTearDown(vm.dispose);
          await vm.beginAdminSetup();
          vm.setConfiguredMode(mode);
          await vm.continueAdminMode();
          vm.addCategory('New category');
          vm.addCatalogItem(
            name: 'Custom item',
            category: 'New category',
            priceMinor: 1200,
            durationMinutes: 30,
          );
          vm.addAppointmentTime('14:30');
          vm.updateDisplaySettings(receiptEnabled: false);
          await vm.activateKiosk();

          final expectedScreen = switch (mode) {
            BusinessMode.food => UniversalScreen.foodCatalog,
            BusinessMode.retail => UniversalScreen.retailCatalog,
            BusinessMode.services => UniversalScreen.serviceCatalog,
          };
          expect(vm.screen, expectedScreen);
          expect(vm.activeMode, mode);
          expect(store.value, isNotNull);

          final restarted = UniversalKioskViewModel(
            repository: const LocalUniversalCatalogRepository(),
            settingsStore: store,
          );
          addTearDown(restarted.dispose);
          await restarted.initialize();
          expect(restarted.screen, expectedScreen);
          expect(
            restarted.products.any((item) => item.name == 'Custom item'),
            isTrue,
          );
          expect(restarted.categories, contains('New category'));
          expect(restarted.appointmentTimes, ['14:30']);
          expect(restarted.receiptEnabled, isFalse);
          await restarted.startNewOrder();
          expect(restarted.screen, expectedScreen);
          expect(restarted.cart, isEmpty);
        },
      );
    }

    test(
      'admin times are unique, sorted and enforced for every service',
      () async {
        expect(viewModel.appointmentTimes, isEmpty);
        expect(viewModel.addAppointmentTime('14:30'), isTrue);
        expect(viewModel.addAppointmentTime('10:00'), isTrue);
        expect(viewModel.addAppointmentTime('25:00'), isFalse);
        expect(viewModel.addAppointmentTime('14:30'), isFalse);
        expect(viewModel.appointmentTimes, ['10:00', '14:30']);
        await viewModel.startMode(BusinessMode.services);
        viewModel.selectProduct(viewModel.products.first);
        viewModel.chooseBookingTime('11:00');
        viewModel.confirmBooking();
        expect(viewModel.cart, isEmpty);
        viewModel.chooseBookingTime('14:30');
        viewModel.confirmBooking();
        expect(viewModel.cart.single.appointmentTime, '14:30');
        viewModel.selectProduct(viewModel.products.last);
        expect(viewModel.bookingTime, isEmpty);
        viewModel.chooseBookingTime('10:00');
        viewModel.confirmBooking();
        expect(viewModel.cart, hasLength(1));
        expect(viewModel.cart.single.product, viewModel.products.last);
      },
    );

    test(
      'exiting setup discards edits and keeps the previously saved catalog',
      () async {
        await viewModel.beginAdminSetup();
        await viewModel.continueAdminMode();
        await viewModel.activateKiosk();
        final originalName = viewModel.products.first.name;
        await viewModel.beginAdminSetup();
        await viewModel.continueAdminMode();
        final item = viewModel.catalogForMode(BusinessMode.food).first;
        viewModel.updateCatalogItem(item.copyWith(name: 'Unsaved rename'));
        viewModel.renameCategory('Burgers', 'Unsaved category');
        viewModel.addAppointmentTime('16:00');
        viewModel.exitAdminSetup();
        expect(viewModel.screen, UniversalScreen.foodCatalog);
        expect(viewModel.products.first.name, originalName);
        expect(viewModel.categories, contains('Burgers'));
        expect(viewModel.appointmentTimes, isEmpty);
      },
    );

    test(
      'category rename moves its items and populated category cannot be removed',
      () async {
        await viewModel.beginAdminSetup();
        await viewModel.continueAdminMode();
        expect(viewModel.removeCategory('Burgers'), isFalse);
        expect(
          viewModel.renameCategory('Burgers', 'Signature burgers'),
          isTrue,
        );
        expect(
          viewModel.catalogForMode(BusinessMode.food).first.category,
          'Signature burgers',
        );
        expect(viewModel.addCategory('Empty category'), isTrue);
        expect(viewModel.removeCategory('Empty category'), isTrue);
      },
    );
  });
}
