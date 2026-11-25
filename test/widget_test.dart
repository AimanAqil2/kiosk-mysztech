import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kiosk/app/kiosk_app.dart';
import 'package:kiosk/data/repositories/universal_catalog_repository.dart';
import 'package:kiosk/domain/models/universal_kiosk_models.dart';
import 'package:kiosk/ui/features/universal_kiosk/universal_kiosk_view_model.dart';

void main() {
  testWidgets(
    'renders the Universal Kiosk welcome and starts the food journey',
    (tester) async {
      await tester.pumpWidget(const KioskApp());
      await tester.pumpAndSettle();

      expect(find.text('Welcome to\nMYSZTECH.'), findsOneWidget);
      expect(find.byKey(const Key('mysztechLogo')), findsOneWidget);
      expect(find.text('Food & Beverage'), findsOneWidget);
      expect(find.byKey(const Key('getStartedButton')), findsOneWidget);

      await tester.scrollUntilVisible(
        find.byKey(const Key('getStartedButton')),
        300,
      );
      await tester.tap(find.byKey(const Key('getStartedButton')));
      await tester.pumpAndSettle();

      expect(find.text('Choose your order type'), findsOneWidget);
      expect(find.text('Dine-in'), findsOneWidget);
    },
  );

  testWidgets('keeps the payment confirmation reachable on a short viewport', (
    tester,
  ) async {
    await tester.binding.setSurfaceSize(const Size(800, 600));
    addTearDown(() => tester.binding.setSurfaceSize(null));

    final viewModel = UniversalKioskViewModel(
      repository: const LocalUniversalCatalogRepository(),
    );
    await viewModel.startMode(BusinessMode.food);
    await viewModel.chooseOrderType(OrderType.dineIn);
    await viewModel.saveTableNumber('1');
    viewModel.selectProduct(viewModel.products.first);
    viewModel.addSelectedProduct(optionLabel: 'Original');
    viewModel.startPayment();

    await tester.pumpWidget(KioskApp(viewModel: viewModel));
    await tester.pumpAndSettle();

    await tester.ensureVisible(
      find.byKey(const Key('confirmPayAtCounterButton')),
    );
    expect(find.byKey(const Key('confirmPayAtCounterButton')), findsOneWidget);
  });
}
