enum BusinessMode { food, retail, services }

extension BusinessModeLabel on BusinessMode {
  String get label => switch (this) {
    BusinessMode.food => 'Food & Beverage',
    BusinessMode.retail => 'Retail',
    BusinessMode.services => 'Services',
  };

  String get shortLabel => switch (this) {
    BusinessMode.food => 'Food',
    BusinessMode.retail => 'Retail',
    BusinessMode.services => 'Services',
  };
}

enum UniversalScreen {
  welcome,
  foodOrderType,
  foodTable,
  foodCatalog,
  productDetail,
  orderSummary,
  payment,
  retailCatalog,
  serviceCatalog,
  serviceBooking,
  success,
  adminWelcome,
  adminBusinessInfo,
  adminBusinessMode,
  adminCatalog,
  adminDisplay,
  adminReview,
}

enum OrderType { dineIn, takeaway }

extension OrderTypeLabel on OrderType {
  String get label => this == OrderType.dineIn ? 'Dine-in' : 'Take-away';
}

class UniversalProduct {
  const UniversalProduct({
    required this.id,
    required this.name,
    required this.description,
    required this.category,
    required this.priceMinor,
    required this.mode,
    this.durationMinutes,
    this.imageAsset,
    this.variants = const [],
    this.addOns = const [],
  });

  final String id;
  final String name;
  final String description;
  final String category;
  final int priceMinor;
  final BusinessMode mode;
  final int? durationMinutes;
  final String? imageAsset;
  final List<KioskOption> variants;
  final List<KioskOption> addOns;

  UniversalProduct copyWith({
    String? name,
    String? description,
    String? category,
    int? priceMinor,
    int? durationMinutes,
    List<KioskOption>? variants,
    List<KioskOption>? addOns,
  }) => UniversalProduct(
    id: id,
    name: name ?? this.name,
    description: description ?? this.description,
    category: category ?? this.category,
    priceMinor: priceMinor ?? this.priceMinor,
    mode: mode,
    durationMinutes: durationMinutes ?? this.durationMinutes,
    imageAsset: imageAsset,
    variants: variants ?? this.variants,
    addOns: addOns ?? this.addOns,
  );
}

class KioskOption {
  const KioskOption({required this.name, this.surchargeMinor = 0});

  final String name;
  final int surchargeMinor;
}

class CartLine {
  const CartLine({
    required this.product,
    required this.quantity,
    this.optionLabel,
    this.variant,
    this.addOns = const [],
    this.remark = '',
    this.appointmentDate,
    this.appointmentTime,
  });

  final UniversalProduct product;
  final int quantity;
  final String? optionLabel;
  final KioskOption? variant;
  final List<KioskOption> addOns;
  final String remark;
  final String? appointmentDate;
  final String? appointmentTime;

  int get extrasPerUnitMinor =>
      (variant?.surchargeMinor ?? 0) +
      addOns.fold(0, (sum, option) => sum + option.surchargeMinor);

  int get totalMinor => (product.priceMinor + extrasPerUnitMinor) * quantity;

  bool get isBooking => appointmentDate != null && appointmentTime != null;

  String get details => [
    if (variant != null) variant!.name,
    ...addOns.map((option) => option.name),
    if (isBooking) '$appointmentDate · $appointmentTime',
    if (remark.trim().isNotEmpty) 'Remark: $remark',
  ].join(' · ');

  CartLine copyWith({
    int? quantity,
    String? optionLabel,
    KioskOption? variant,
    List<KioskOption>? addOns,
    String? remark,
    String? appointmentDate,
    String? appointmentTime,
  }) => CartLine(
    product: product,
    quantity: quantity ?? this.quantity,
    optionLabel: optionLabel ?? this.optionLabel,
    variant: variant ?? this.variant,
    addOns: addOns ?? this.addOns,
    remark: remark ?? this.remark,
    appointmentDate: appointmentDate ?? this.appointmentDate,
    appointmentTime: appointmentTime ?? this.appointmentTime,
  );
}

class KioskBusinessProfile {
  const KioskBusinessProfile({
    required this.name,
    required this.email,
    required this.phone,
    required this.address,
    required this.mode,
    required this.receiptEnabled,
    required this.tableEntryEnabled,
    required this.maxTableNumber,
    required this.welcomeHeading,
    required this.receiptHeader,
    required this.receiptFooter,
  });

  final String name;
  final String email;
  final String phone;
  final String address;
  final BusinessMode mode;
  final bool receiptEnabled;
  final bool tableEntryEnabled;
  final int maxTableNumber;
  final String welcomeHeading;
  final String receiptHeader;
  final String receiptFooter;
}
