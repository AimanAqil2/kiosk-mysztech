import 'dart:convert';

import 'package:flutter/foundation.dart';

import '../../../data/repositories/kiosk_settings_store.dart';

import '../../../data/repositories/universal_catalog_repository.dart';
import '../../../domain/models/universal_kiosk_models.dart';

/// Owns the anonymous demo session and the locally saved kiosk configuration.
class UniversalKioskViewModel extends ChangeNotifier {
  UniversalKioskViewModel({
    required this.repository,
    KioskSettingsStore? settingsStore,
  }) : settingsStore = settingsStore ?? MemoryKioskSettingsStore();

  final KioskSettingsStore settingsStore;
  final Map<BusinessMode, List<String>> _categoryNames = {};
  List<String> _appointmentTimes = [];
  String? _setupBackup;
  UniversalScreen _setupReturnScreen = UniversalScreen.welcome;
  bool _isSaving = false;
  String? _settingsError;

  bool get isSaving => _isSaving;
  String? get settingsError => _settingsError;
  List<String> get appointmentTimes => List.unmodifiable(_appointmentTimes);
  static DateTime get malaysiaToday {
    final now = DateTime.now().toUtc().add(const Duration(hours: 8));
    return DateTime(now.year, now.month, now.day);
  }

  static String dateValue(DateTime date) =>
      '${date.year.toString().padLeft(4, '0')}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';

  static String timeLabel(String time) {
    final parts = time.split(':');
    final hour = int.parse(parts.first);
    return '${hour % 12 == 0 ? 12 : hour % 12}:${parts.last} ${hour < 12 ? 'AM' : 'PM'}';
  }

  Future<void> initialize() async {
    try {
      final saved = await settingsStore.read();
      if (saved != null) _restore(saved);
      if (_isActivated) await _openConfiguredMode();
    } catch (_) {
      _settingsError =
          'Could not load kiosk settings. Open Admin setup to try again.';
    }
  }

  final UniversalCatalogRepository repository;
  final List<UniversalScreen> _history = [];
  final List<CartLine> _cart = [];
  final Map<BusinessMode, List<UniversalProduct>> _catalogs = {};

  UniversalScreen _screen = UniversalScreen.welcome;
  BusinessMode? _activeMode;
  BusinessMode _configuredMode = BusinessMode.food;
  OrderType? _orderType;
  UniversalProduct? _selectedProduct;
  CartLine? _editingLine;
  List<UniversalProduct> _products = [];
  String _selectedCategory = 'All';
  String _searchQuery = '';
  String _tableNumber = '';
  String _bookingDate = dateValue(malaysiaToday.add(const Duration(days: 1)));
  String _bookingTime = '';
  String _businessName = 'MYSZTECH Demo Store';
  String _companyEmail = 'kiosk@example.com';
  String _phone = '';
  String _address = 'Kuala Lumpur';
  String _welcomeHeading = 'Welcome to MYSZTECH';
  String _receiptHeader = '';
  String _receiptFooter = 'Thank you for visiting.';
  bool _receiptEnabled = true;
  bool _tableEntryEnabled = true;
  int _maxTableNumber = 20;
  bool _isLoading = false;
  bool _isActivated = false;
  int _referenceSequence = 104;
  String? _reference;

  UniversalScreen get screen => _screen;
  BusinessMode? get activeMode => _activeMode;
  BusinessMode get configuredMode => _configuredMode;
  OrderType? get orderType => _orderType;
  UniversalProduct? get selectedProduct => _selectedProduct;
  CartLine? get editingLine => _editingLine;
  List<UniversalProduct> get products => List.unmodifiable(_products);
  String get selectedCategory => _selectedCategory;
  String get searchQuery => _searchQuery;
  String get tableNumber => _tableNumber;
  String get bookingDate => _bookingDate;
  String get bookingTime => _bookingTime;
  String get businessName => _businessName;
  String get companyEmail => _companyEmail;
  String get phone => _phone;
  String get businessLocation => _address;
  String get welcomeHeading => _welcomeHeading;
  String get receiptHeader => _receiptHeader;
  String get receiptFooter => _receiptFooter;
  bool get receiptEnabled => _receiptEnabled;
  bool get tableEntryEnabled => _tableEntryEnabled;
  int get maxTableNumber => _maxTableNumber;
  bool get isLoading => _isLoading;
  bool get isActivated => _isActivated;
  String? get reference => _reference;
  int get orderNumber => _referenceSequence;
  List<CartLine> get cart => List.unmodifiable(_cart);
  int get itemCount => _cart.fold(0, (sum, line) => sum + line.quantity);
  int get baseSubtotalMinor => _cart.fold(
    0,
    (sum, line) => sum + line.product.priceMinor * line.quantity,
  );
  int get variantTotalMinor => _cart.fold(
    0,
    (sum, line) => sum + (line.variant?.surchargeMinor ?? 0) * line.quantity,
  );
  int get addOnTotalMinor => _cart.fold(
    0,
    (sum, line) =>
        sum +
        line.addOns.fold(
              0,
              (addOnSum, addOn) => addOnSum + addOn.surchargeMinor,
            ) *
            line.quantity,
  );
  int get totalMinor => _cart.fold(0, (sum, line) => sum + line.totalMinor);
  bool get hasBooking => _cart.any((line) => line.isBooking);
  bool get canGoBack => _history.isNotEmpty;
  bool get isAdmin => _screen.index >= UniversalScreen.adminWelcome.index;

  List<String> get categories => [
    'All',
    ...categoriesForMode(_activeMode ?? _configuredMode),
  ];

  List<UniversalProduct> get visibleProducts {
    final query = _searchQuery.trim().toLowerCase();
    return _products.where((product) {
      final categoryMatches =
          _selectedCategory == 'All' || product.category == _selectedCategory;
      final searchMatches =
          query.isEmpty ||
          product.name.toLowerCase().contains(query) ||
          product.description.toLowerCase().contains(query);
      return categoryMatches && searchMatches;
    }).toList();
  }

  Future<void> startMode(BusinessMode mode) async {
    _activeMode = mode;
    _selectedProduct = null;
    _editingLine = null;
    _selectedCategory = 'All';
    _searchQuery = '';
    _cart.clear();
    _orderType = null;
    _tableNumber = '';
    _bookingTime = '';
    _bookingDate = dateValue(malaysiaToday.add(const Duration(days: 1)));
    _reference = null;
    if (mode == BusinessMode.food) {
      _navigate(UniversalScreen.foodOrderType);
      return;
    }
    await _loadProducts(mode);
    _navigate(
      mode == BusinessMode.retail
          ? UniversalScreen.retailCatalog
          : UniversalScreen.serviceCatalog,
    );
  }

  Future<void> chooseOrderType(OrderType type) async {
    _orderType = type;
    if (type == OrderType.dineIn && _tableEntryEnabled) {
      _navigate(UniversalScreen.foodTable);
    } else {
      _tableNumber = '';
      await _openFoodCatalog();
    }
  }

  bool isValidTableNumber(String value) {
    final number = int.tryParse(value.trim());
    return number != null && number >= 1 && number <= _maxTableNumber;
  }

  Future<bool> saveTableNumber(String number) async {
    if (!isValidTableNumber(number)) return false;
    _tableNumber = number.trim();
    await _openFoodCatalog();
    return true;
  }

  Future<void> _openFoodCatalog() async {
    await _loadProducts(BusinessMode.food);
    _navigate(UniversalScreen.foodCatalog);
  }

  Future<void> _loadProducts(BusinessMode mode) async {
    _isLoading = true;
    notifyListeners();
    final catalog = _catalogs[mode] ??= List.of(
      await repository.getProducts(mode),
    );
    _categoryNames.putIfAbsent(
      mode,
      () => catalog.map((item) => item.category).toSet().toList(),
    );
    _products = List.of(catalog);
    _isLoading = false;
    notifyListeners();
  }

  void chooseCategory(String category) {
    _selectedCategory = category;
    if (!isAdmin) _screen = catalogScreen;
    notifyListeners();
  }

  UniversalScreen get catalogScreen => switch (_activeMode) {
    BusinessMode.retail => UniversalScreen.retailCatalog,
    BusinessMode.services => UniversalScreen.serviceCatalog,
    _ => UniversalScreen.foodCatalog,
  };

  void continueBrowsing() {
    _selectedProduct = null;
    _editingLine = null;
    _screen = catalogScreen;
    _history.clear();
    notifyListeners();
  }

  void editOrderType() => _navigate(UniversalScreen.foodOrderType);

  Future<void> _openConfiguredMode() async {
    await startMode(_configuredMode);
    if (_configuredMode == BusinessMode.food) {
      // Setup opens the menu immediately; the customer can choose Dine-in.
      await chooseOrderType(OrderType.takeaway);
    }
    _history.clear();
    notifyListeners();
  }

  void updateSearch(String query) {
    _searchQuery = query;
    notifyListeners();
  }

  void selectProduct(UniversalProduct product, {CartLine? editLine}) {
    _selectedProduct = product;
    _editingLine = editLine;
    if (product.mode == BusinessMode.services) {
      _bookingDate =
          editLine?.appointmentDate ??
          dateValue(malaysiaToday.add(const Duration(days: 1)));
      _bookingTime = editLine?.appointmentTime ?? '';
    }
    _navigate(
      product.mode == BusinessMode.services
          ? UniversalScreen.serviceBooking
          : UniversalScreen.productDetail,
    );
  }

  void addSelectedProduct({
    int quantity = 1,
    String? optionLabel,
    KioskOption? variant,
    List<KioskOption> addOns = const [],
    String remark = '',
  }) {
    final product = _selectedProduct;
    if (product == null) return;
    final line = CartLine(
      product: product,
      quantity: product.mode == BusinessMode.services ? 1 : quantity,
      optionLabel: optionLabel,
      variant: variant,
      addOns: addOns,
      remark: remark.trim(),
      appointmentDate: product.mode == BusinessMode.services
          ? _bookingDate
          : null,
      appointmentTime: product.mode == BusinessMode.services
          ? _bookingTime
          : null,
    );
    final editingLine = _editingLine;
    if (product.mode == BusinessMode.services) {
      _cart
        ..clear()
        ..add(line);
    } else if (editingLine != null) {
      final index = _cart.indexOf(editingLine);
      if (index >= 0) _cart[index] = line;
    } else {
      _cart.add(line);
    }
    _editingLine = null;
    if (editingLine != null || product.mode == BusinessMode.services) {
      _screen = UniversalScreen.orderSummary;
      _history.clear();
      _history.add(catalogScreen);
      notifyListeners();
    } else {
      continueBrowsing();
    }
  }

  void editLine(CartLine line) => selectProduct(line.product, editLine: line);

  void removeLine(CartLine line) {
    _cart.remove(line);
    notifyListeners();
  }

  void changeQuantity(CartLine line, int quantity) {
    final index = _cart.indexOf(line);
    if (index < 0) return;
    if (quantity <= 0) {
      _cart.removeAt(index);
    } else {
      _cart[index] = line.copyWith(quantity: line.isBooking ? 1 : quantity);
    }
    notifyListeners();
  }

  void openSummary() {
    if (_cart.isNotEmpty) _navigate(UniversalScreen.orderSummary);
  }

  void startPayment() {
    if (_cart.isNotEmpty) _navigate(UniversalScreen.payment);
  }

  void completePayment() {
    if (_cart.isEmpty ||
        _activeMode == null ||
        _screen != UniversalScreen.payment) {
      return;
    }
    _referenceSequence++;
    final prefix = _activeMode == BusinessMode.services ? 'BKG' : 'ORD';
    _reference = '$prefix-${_referenceSequence.toString().padLeft(4, '0')}';
    _navigate(UniversalScreen.success);
  }

  void chooseBookingDate(String value) {
    final date = DateTime.tryParse(value);
    if (date == null || date.isBefore(malaysiaToday)) return;
    _bookingDate = dateValue(date);
    _bookingTime = '';
    notifyListeners();
  }

  void chooseBookingTime(String value) {
    if (!_appointmentTimes.contains(value)) return;
    _bookingTime = value;
    notifyListeners();
  }

  void confirmBooking({
    KioskOption? variant,
    List<KioskOption> addOns = const [],
    String remark = '',
  }) {
    if (!_appointmentTimes.contains(_bookingTime)) return;
    addSelectedProduct(
      optionLabel: '$_bookingDate · $_bookingTime',
      variant: variant,
      addOns: addOns,
      remark: remark,
    );
  }

  Future<void> startNewOrder() async {
    _history.clear();
    _cart.clear();
    _selectedProduct = null;
    _editingLine = null;
    _activeMode = null;
    _orderType = null;
    _tableNumber = '';
    _searchQuery = '';
    _bookingTime = '';
    _reference = null;
    _screen = UniversalScreen.welcome;
    if (_isActivated) await _openConfiguredMode();
    notifyListeners();
  }

  Future<void> beginAdminSetup() async {
    if (isAdmin) return;
    for (final mode in BusinessMode.values) {
      await ensureCatalogForMode(mode);
    }
    _setupBackup = _serialize();
    _setupReturnScreen = _screen;
    _settingsError = null;
    _navigate(UniversalScreen.adminWelcome);
  }

  void exitAdminSetup() {
    if (_setupBackup != null) _restore(_setupBackup!);
    _screen = _setupReturnScreen;
    _setupBackup = null;
    _history.clear();
    if (_activeMode != null) _products = List.of(_catalogs[_activeMode] ?? []);
    notifyListeners();
  }

  void openAdminStep(UniversalScreen step) {
    if (step.index < UniversalScreen.adminWelcome.index) return;
    _navigate(step);
  }

  void updateBusinessInformation({
    required String name,
    required String email,
    String phone = '',
    String address = '',
  }) {
    if (name.trim().isEmpty || email.trim().isEmpty) return;
    _businessName = name.trim();
    _companyEmail = email.trim();
    _phone = phone.trim();
    _address = address.trim();
    _navigate(UniversalScreen.adminBusinessMode);
  }

  void setConfiguredMode(BusinessMode mode) {
    _configuredMode = mode;
    notifyListeners();
  }

  Future<void> continueAdminMode() async {
    await _loadProducts(_configuredMode);
    _navigate(UniversalScreen.adminCatalog);
  }

  void continueAdminCatalog() => _navigate(UniversalScreen.adminDisplay);

  List<UniversalProduct> catalogForMode(BusinessMode mode) =>
      List.unmodifiable(_catalogs[mode] ?? const []);

  Future<void> ensureCatalogForMode(BusinessMode mode) async {
    if (_catalogs.containsKey(mode)) return;
    _catalogs[mode] = List.of(await repository.getProducts(mode));
    _categoryNames.putIfAbsent(
      mode,
      () => _catalogs[mode]!.map((item) => item.category).toSet().toList(),
    );
    notifyListeners();
  }

  void addCatalogItem({
    required String name,
    required String category,
    required int priceMinor,
    String description = 'Local demo catalogue item.',
    int? durationMinutes,
    List<KioskOption> variants = const [],
    List<KioskOption> addOns = const [],
  }) {
    if (name.trim().isEmpty || category.trim().isEmpty || priceMinor < 0) {
      return;
    }
    final catalog = _catalogs.putIfAbsent(_configuredMode, () => []);
    addCategory(category);
    catalog.add(
      UniversalProduct(
        id: 'local-${DateTime.now().microsecondsSinceEpoch}',
        name: name.trim(),
        description: description.trim().isEmpty
            ? 'Local demo catalogue item.'
            : description.trim(),
        category: category.trim(),
        priceMinor: priceMinor,
        mode: _configuredMode,
        durationMinutes: durationMinutes,
        variants: variants,
        addOns: addOns,
      ),
    );
    notifyListeners();
  }

  void removeCatalogItem(UniversalProduct item) {
    _catalogs[item.mode]?.removeWhere((candidate) => candidate.id == item.id);
    notifyListeners();
  }

  void updateDisplaySettings({
    required bool receiptEnabled,
    String? welcomeHeading,
    String? receiptHeader,
    String? receiptFooter,
    bool? tableEntryEnabled,
    int? maxTableNumber,
  }) {
    _receiptEnabled = receiptEnabled;
    if (welcomeHeading != null && welcomeHeading.trim().isNotEmpty) {
      _welcomeHeading = welcomeHeading.trim();
    }
    if (receiptHeader != null) {
      _receiptHeader = receiptHeader.trim();
    }
    if (receiptFooter != null && receiptFooter.trim().isNotEmpty) {
      _receiptFooter = receiptFooter.trim();
    }
    if (tableEntryEnabled != null) {
      _tableEntryEnabled = tableEntryEnabled;
    }
    if (maxTableNumber != null &&
        maxTableNumber >= 1 &&
        maxTableNumber <= 999) {
      _maxTableNumber = maxTableNumber;
    }
    _navigate(UniversalScreen.adminReview);
  }

  Future<void> activateKiosk() async {
    if (_isSaving) return;
    if (_businessName.trim().isEmpty || !_companyEmail.contains('@')) {
      _settingsError = 'Enter a business name and a valid company email.';
      _navigate(UniversalScreen.adminBusinessInfo);
      return;
    }
    _isSaving = true;
    _settingsError = null;
    notifyListeners();
    try {
      final settings = _serialize(activated: true);
      await settingsStore.write(settings);
      _isActivated = true;
      _setupBackup = null;
      await startNewOrder();
    } catch (_) {
      _settingsError = 'Settings could not be saved. Please try again.';
    } finally {
      _isSaving = false;
      notifyListeners();
    }
  }

  void goBack() {
    if (_history.isEmpty) {
      startNewOrder();
      return;
    }
    _screen = _history.removeLast();
    notifyListeners();
  }

  void _navigate(UniversalScreen destination) {
    if (_screen != destination) _history.add(_screen);
    _screen = destination;
    notifyListeners();
  }

  List<String> categoriesForMode(BusinessMode mode) => List.unmodifiable(
    _categoryNames[mode] ??
        (_catalogs[mode] ?? []).map((item) => item.category).toSet().toList(),
  );

  bool addCategory(String name) {
    final value = name.trim();
    final names = _categoryNames.putIfAbsent(_configuredMode, () => []);
    if (value.isEmpty ||
        names.any((entry) => entry.toLowerCase() == value.toLowerCase())) {
      return false;
    }
    names.add(value);
    notifyListeners();
    return true;
  }

  bool renameCategory(String original, String name) {
    final names = _categoryNames[_configuredMode];
    final value = name.trim();
    if (names == null || value.isEmpty || value == 'All') return false;
    if (value != original &&
        names.any((entry) => entry.toLowerCase() == value.toLowerCase())) {
      return false;
    }
    final index = names.indexOf(original);
    if (index < 0) return false;
    names[index] = value;
    final catalog = _catalogs[_configuredMode] ?? [];
    for (var i = 0; i < catalog.length; i++) {
      if (catalog[i].category == original) {
        catalog[i] = catalog[i].copyWith(category: value);
      }
    }
    notifyListeners();
    return true;
  }

  bool removeCategory(String name) {
    if (catalogForMode(_configuredMode).any((item) => item.category == name)) {
      return false;
    }
    _categoryNames[_configuredMode]?.remove(name);
    notifyListeners();
    return true;
  }

  void updateCatalogItem(UniversalProduct updated) {
    final catalog = _catalogs[updated.mode];
    final index = catalog?.indexWhere((item) => item.id == updated.id) ?? -1;
    if (index < 0) return;
    addCategory(updated.category);
    catalog![index] = updated;
    notifyListeners();
  }

  bool addAppointmentTime(String time) {
    if (!RegExp(r'^([01]\d|2[0-3]):[0-5]\d$').hasMatch(time) ||
        _appointmentTimes.contains(time)) {
      return false;
    }
    _appointmentTimes = [..._appointmentTimes, time]..sort();
    notifyListeners();
    return true;
  }

  void removeAppointmentTime(String time) {
    _appointmentTimes.remove(time);
    if (_bookingTime == time) _bookingTime = '';
    notifyListeners();
  }

  String _serialize({bool? activated}) => jsonEncode({
    'activated': activated ?? _isActivated,
    'mode': _configuredMode.name,
    'name': _businessName,
    'email': _companyEmail,
    'phone': _phone,
    'address': _address,
    'welcome': _welcomeHeading,
    'receiptHeader': _receiptHeader,
    'receiptFooter': _receiptFooter,
    'receiptEnabled': _receiptEnabled,
    'tableEntryEnabled': _tableEntryEnabled,
    'maxTableNumber': _maxTableNumber,
    'appointmentTimes': _appointmentTimes,
    'categories': {
      for (final entry in _categoryNames.entries) entry.key.name: entry.value,
    },
    'catalogs': {
      for (final entry in _catalogs.entries)
        entry.key.name: [
          for (final item in entry.value)
            {
              'id': item.id,
              'name': item.name,
              'description': item.description,
              'category': item.category,
              'price': item.priceMinor,
              'duration': item.durationMinutes,
              'image': item.imageAsset,
              'variants': [
                for (final option in item.variants)
                  {'name': option.name, 'price': option.surchargeMinor},
              ],
              'addOns': [
                for (final option in item.addOns)
                  {'name': option.name, 'price': option.surchargeMinor},
              ],
            },
        ],
    },
  });

  void _restore(String value) {
    final data = Map<String, dynamic>.from(jsonDecode(value) as Map);
    _isActivated = data['activated'] as bool;
    _configuredMode = BusinessMode.values.byName(data['mode'] as String);
    _businessName = data['name'] as String;
    _companyEmail = data['email'] as String;
    _phone = data['phone'] as String;
    _address = data['address'] as String;
    _welcomeHeading = data['welcome'] as String;
    _receiptHeader = data['receiptHeader'] as String;
    _receiptFooter = data['receiptFooter'] as String;
    _receiptEnabled = data['receiptEnabled'] as bool;
    _tableEntryEnabled = data['tableEntryEnabled'] as bool;
    _maxTableNumber = data['maxTableNumber'] as int;
    _appointmentTimes = (data['appointmentTimes'] as List)
        .cast<String>()
        .toList();
    _categoryNames.clear();
    for (final entry in (data['categories'] as Map).entries) {
      _categoryNames[BusinessMode.values.byName(entry.key as String)] =
          (entry.value as List).cast<String>().toList();
    }
    _catalogs.clear();
    List<KioskOption> options(dynamic list) => [
      for (final option in list as List)
        KioskOption(
          name: option['name'] as String,
          surchargeMinor: option['price'] as int,
        ),
    ];
    for (final entry in (data['catalogs'] as Map).entries) {
      final mode = BusinessMode.values.byName(entry.key as String);
      _catalogs[mode] = [
        for (final item in entry.value as List)
          UniversalProduct(
            id: item['id'] as String,
            name: item['name'] as String,
            description: item['description'] as String,
            category: item['category'] as String,
            priceMinor: item['price'] as int,
            mode: mode,
            imageAsset: item['image'] as String?,
            durationMinutes: item['duration'] as int?,
            variants: options(item['variants']),
            addOns: options(item['addOns']),
          ),
      ];
    }
  }

  KioskBusinessProfile get profile => KioskBusinessProfile(
    name: _businessName,
    email: _companyEmail,
    phone: _phone,
    address: _address,
    mode: _configuredMode,
    receiptEnabled: _receiptEnabled,
    tableEntryEnabled: _tableEntryEnabled,
    maxTableNumber: _maxTableNumber,
    welcomeHeading: _welcomeHeading,
    receiptHeader: _receiptHeader,
    receiptFooter: _receiptFooter,
  );
}
