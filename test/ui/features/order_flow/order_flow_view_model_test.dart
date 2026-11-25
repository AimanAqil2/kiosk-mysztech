import 'package:flutter_test/flutter_test.dart';
import 'package:kiosk/data/repositories/catalog_repository.dart';
import 'package:kiosk/data/repositories/checkout_repository.dart';
import 'package:kiosk/domain/models/menu_product.dart';
import 'package:kiosk/domain/models/order.dart';
import 'package:kiosk/ui/features/order_flow/order_flow_view_model.dart';

void main() {
  group('OrderFlowViewModel', () {
    late _FakeCatalogRepository catalogRepository;
    late _FakeCheckoutRepository checkoutRepository;
    late OrderFlowViewModel viewModel;

    setUp(() async {
      catalogRepository = _FakeCatalogRepository();
      checkoutRepository = _FakeCheckoutRepository();
      viewModel = OrderFlowViewModel(
        catalogRepository: catalogRepository,
        checkoutRepository: checkoutRepository,
      );
      await viewModel.loadCatalog();
    });

    test('creates a dine-in mock order with the chosen table', () async {
      final product = viewModel.products.single;

      viewModel.beginOrder();
      viewModel.chooseOrderType(OrderType.dineIn);
      viewModel.openProduct(product);
      viewModel.saveLine(
        product: product,
        variant: product.variantGroup.options.first,
        modifiers: [product.modifierGroup.options.single],
        quantity: 2,
        remarks: 'Less ice',
      );

      expect(viewModel.totalMinor, 1200);
      expect(viewModel.itemCount, 2);

      viewModel.openCart();
      viewModel.updateOrderRemarks('Please serve together');
      viewModel.beginCheckout();
      expect(viewModel.screen, KioskScreen.table);

      viewModel.saveTableNumber('t05');
      await viewModel.confirmPayAtCounterOrder();

      expect(viewModel.screen, KioskScreen.success);
      expect(viewModel.submittedOrder?.orderNumber, 'A101');
      expect(checkoutRepository.lastSubmission?.tableNumber, 'T05');
      expect(
        checkoutRepository.lastSubmission?.remarks,
        'Please serve together',
      );
    });

    test('does not submit a dine-in order without a table number', () async {
      final product = viewModel.products.single;
      viewModel.beginOrder();
      viewModel.chooseOrderType(OrderType.dineIn);
      viewModel.saveLine(
        product: product,
        variant: product.variantGroup.options.first,
        modifiers: const [],
        quantity: 1,
        remarks: '',
      );

      await viewModel.confirmPayAtCounterOrder();

      expect(checkoutRepository.lastSubmission, isNull);
      expect(viewModel.screen, KioskScreen.menu);
    });
  });
}

class _FakeCatalogRepository implements CatalogRepository {
  @override
  Future<List<MenuProduct>> loadMenu() async => const [
    MenuProduct(
      id: 'iced-tea',
      name: 'Iced tea',
      description: 'A tea.',
      category: MenuCategory.drinks,
      basePriceMinor: 500,
      variantGroup: OptionGroup(
        id: 'size',
        name: 'Size',
        isRequired: true,
        options: [MenuOption(id: 'regular', name: 'Regular')],
      ),
      modifierGroup: OptionGroup(
        id: 'add-ons',
        name: 'Add-ons',
        options: [MenuOption(id: 'lemon', name: 'Lemon', priceDeltaMinor: 100)],
      ),
    ),
  ];
}

class _FakeCheckoutRepository implements CheckoutRepository {
  OrderSubmission? lastSubmission;

  @override
  Future<SubmittedOrder> submit(OrderSubmission submission) async {
    lastSubmission = submission;
    return const SubmittedOrder(orderNumber: 'A101');
  }
}
