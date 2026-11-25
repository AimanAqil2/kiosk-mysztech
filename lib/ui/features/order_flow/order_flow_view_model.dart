import 'package:flutter/foundation.dart';

import '../../../data/repositories/catalog_repository.dart';
import '../../../data/repositories/checkout_repository.dart';
import '../../../domain/models/menu_product.dart';
import '../../../domain/models/order.dart';

enum KioskScreen {
  welcome,
  orderType,
  menu,
  customize,
  cart,
  table,
  payment,
  success,
}

class OrderFlowViewModel extends ChangeNotifier {
  OrderFlowViewModel({
    required this.catalogRepository,
    required this.checkoutRepository,
  });

  final CatalogRepository catalogRepository;
  final CheckoutRepository checkoutRepository;

  bool isLoading = true;
  bool isSubmitting = false;
  String? errorMessage;
  KioskScreen screen = KioskScreen.welcome;
  List<MenuProduct> products = const [];
  List<CartLine> cart = const [];
  OrderType? orderType;
  MenuCategory? selectedCategory;
  MenuProduct? activeProduct;
  CartLine? activeLine;
  String tableNumber = '';
  String orderRemarks = '';
  SubmittedOrder? submittedOrder;

  List<MenuProduct> get visibleProducts {
    final category = selectedCategory;
    if (category == null) {
      return products;
    }
    if (category == MenuCategory.featured) {
      return products.where((product) => product.isFeatured).toList();
    }
    return products.where((product) => product.category == category).toList();
  }

  int get itemCount => cart.fold(0, (total, line) => total + line.quantity);

  int get totalMinor =>
      cart.fold(0, (total, line) => total + line.totalPriceMinor);

  bool get canCheckout => cart.isNotEmpty && orderType != null;

  bool get canGoBack =>
      screen != KioskScreen.welcome && screen != KioskScreen.success;

  Future<void> loadCatalog() async {
    isLoading = true;
    errorMessage = null;
    notifyListeners();
    try {
      products = await catalogRepository.loadMenu();
    } catch (_) {
      errorMessage = 'The menu could not be loaded. Please try again.';
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  void beginOrder() {
    _clearDraft();
    screen = KioskScreen.orderType;
    notifyListeners();
  }

  void chooseOrderType(OrderType value) {
    orderType = value;
    selectedCategory ??= MenuCategory.featured;
    screen = KioskScreen.menu;
    notifyListeners();
  }

  void openOrderTypePicker() {
    screen = KioskScreen.orderType;
    notifyListeners();
  }

  void updateOrderType(OrderType value) {
    orderType = value;
    if (value == OrderType.takeaway) {
      tableNumber = '';
    }
    notifyListeners();
  }

  void chooseCategory(MenuCategory? category) {
    selectedCategory = category;
    notifyListeners();
  }

  void openProduct(MenuProduct product, {CartLine? line}) {
    activeProduct = product;
    activeLine = line;
    screen = KioskScreen.customize;
    notifyListeners();
  }

  void saveLine({
    required MenuProduct product,
    required MenuOption variant,
    required List<MenuOption> modifiers,
    required int quantity,
    required String remarks,
  }) {
    final existing = activeLine;
    final nextLine = CartLine(
      id:
          existing?.id ??
          '${product.id}-${DateTime.now().microsecondsSinceEpoch}',
      product: product,
      variant: variant,
      modifiers: List.unmodifiable(modifiers),
      quantity: quantity,
      remarks: remarks.trim(),
    );
    if (existing == null) {
      cart = [...cart, nextLine];
    } else {
      cart = [
        for (final line in cart)
          if (line.id == existing.id) nextLine else line,
      ];
    }
    activeProduct = null;
    activeLine = null;
    screen = KioskScreen.menu;
    notifyListeners();
  }

  void changeLineQuantity(String lineId, int quantity) {
    if (quantity <= 0) {
      removeLine(lineId);
      return;
    }
    cart = [
      for (final line in cart)
        if (line.id == lineId) line.copyWith(quantity: quantity) else line,
    ];
    notifyListeners();
  }

  void removeLine(String lineId) {
    cart = cart.where((line) => line.id != lineId).toList();
    notifyListeners();
  }

  void openCart() {
    if (cart.isEmpty) {
      return;
    }
    screen = KioskScreen.cart;
    notifyListeners();
  }

  void beginCheckout() {
    if (!canCheckout) {
      return;
    }
    screen = orderType == OrderType.dineIn
        ? KioskScreen.table
        : KioskScreen.payment;
    notifyListeners();
  }

  void saveTableNumber(String value) {
    final normalized = value.trim().toUpperCase();
    if (normalized.isEmpty) {
      return;
    }
    tableNumber = normalized;
    screen = KioskScreen.payment;
    notifyListeners();
  }

  void updateOrderRemarks(String value) {
    orderRemarks = value;
    notifyListeners();
  }

  Future<void> confirmPayAtCounterOrder() async {
    final type = orderType;
    if (type == null ||
        cart.isEmpty ||
        isSubmitting ||
        (type == OrderType.dineIn && tableNumber.trim().isEmpty)) {
      return;
    }
    isSubmitting = true;
    errorMessage = null;
    notifyListeners();
    try {
      submittedOrder = await checkoutRepository.submit(
        OrderSubmission(
          type: type,
          lines: cart,
          tableNumber: type == OrderType.dineIn ? tableNumber : null,
          remarks: orderRemarks,
        ),
      );
      screen = KioskScreen.success;
    } catch (_) {
      errorMessage =
          'We could not create your order. Please ask a staff member.';
    } finally {
      isSubmitting = false;
      notifyListeners();
    }
  }

  void startNewOrder() {
    _clearDraft();
    screen = KioskScreen.welcome;
    notifyListeners();
  }

  void goBack() {
    switch (screen) {
      case KioskScreen.orderType:
        screen = KioskScreen.welcome;
      case KioskScreen.menu:
        screen = KioskScreen.orderType;
      case KioskScreen.customize:
        activeProduct = null;
        activeLine = null;
        screen = KioskScreen.menu;
      case KioskScreen.cart:
        screen = KioskScreen.menu;
      case KioskScreen.table:
        screen = KioskScreen.cart;
      case KioskScreen.payment:
        screen = orderType == OrderType.dineIn
            ? KioskScreen.table
            : KioskScreen.cart;
      case KioskScreen.welcome:
      case KioskScreen.success:
        return;
    }
    notifyListeners();
  }

  void _clearDraft() {
    cart = const [];
    orderType = null;
    selectedCategory = null;
    activeProduct = null;
    activeLine = null;
    tableNumber = '';
    orderRemarks = '';
    submittedOrder = null;
    errorMessage = null;
  }
}
