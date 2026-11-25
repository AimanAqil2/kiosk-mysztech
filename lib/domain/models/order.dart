import 'menu_product.dart';

enum OrderType { dineIn, takeaway }

extension OrderTypeLabel on OrderType {
  String get label => switch (this) {
    OrderType.dineIn => 'Dine-In',
    OrderType.takeaway => 'Takeaway',
  };
}

class CartLine {
  const CartLine({
    required this.id,
    required this.product,
    required this.variant,
    required this.modifiers,
    required this.quantity,
    required this.remarks,
  });

  final String id;
  final MenuProduct product;
  final MenuOption variant;
  final List<MenuOption> modifiers;
  final int quantity;
  final String remarks;

  int get unitPriceMinor =>
      product.basePriceMinor +
      variant.priceDeltaMinor +
      modifiers.fold(0, (total, modifier) => total + modifier.priceDeltaMinor);

  int get totalPriceMinor => unitPriceMinor * quantity;

  CartLine copyWith({
    int? quantity,
    String? remarks,
    MenuOption? variant,
    List<MenuOption>? modifiers,
  }) {
    return CartLine(
      id: id,
      product: product,
      variant: variant ?? this.variant,
      modifiers: modifiers ?? this.modifiers,
      quantity: quantity ?? this.quantity,
      remarks: remarks ?? this.remarks,
    );
  }
}

class OrderSubmission {
  const OrderSubmission({
    required this.type,
    required this.lines,
    required this.tableNumber,
    required this.remarks,
  });

  final OrderType type;
  final List<CartLine> lines;
  final String? tableNumber;
  final String remarks;
}

class SubmittedOrder {
  const SubmittedOrder({required this.orderNumber});

  final String orderNumber;
}
