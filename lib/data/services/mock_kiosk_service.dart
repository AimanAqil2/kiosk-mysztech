import '../../domain/models/menu_product.dart';
import '../../domain/models/order.dart';
import '../repositories/catalog_repository.dart';
import '../repositories/checkout_repository.dart';

/// Local-only data source used until an approved kiosk backend exists.
class MockKioskService implements CatalogRepository, CheckoutRepository {
  int _nextOrderNumber = 101;

  @override
  Future<List<MenuProduct>> loadMenu() async => const [
    MenuProduct(
      id: 'chicken-burger',
      name: 'Chicken Burger',
      description: 'Crispy chicken patty with fresh lettuce.',
      category: MenuCategory.burgers,
      basePriceMinor: 990,
      isFeatured: true,
      variantGroup: OptionGroup(
        id: 'flavour',
        name: 'Flavour',
        isRequired: true,
        options: [
          MenuOption(id: 'original', name: 'Original'),
          MenuOption(id: 'spicy', name: 'Spicy'),
        ],
      ),
      modifierGroup: OptionGroup(
        id: 'burger-add-ons',
        name: 'Modifiers & add-ons',
        maxSelections: 3,
        options: [
          MenuOption(id: 'cheese', name: 'Extra cheese', priceDeltaMinor: 150),
          MenuOption(id: 'no-lettuce', name: 'No lettuce'),
          MenuOption(
            id: 'extra-sauce',
            name: 'Extra sauce',
            priceDeltaMinor: 50,
          ),
        ],
      ),
    ),
    MenuProduct(
      id: 'double-cheese-burger',
      name: 'Double Cheese Burger',
      description: 'Two juicy patties with cheese.',
      category: MenuCategory.burgers,
      basePriceMinor: 1490,
      isFeatured: true,
      variantGroup: OptionGroup(
        id: 'flavour',
        name: 'Flavour',
        isRequired: true,
        options: [
          MenuOption(id: 'original', name: 'Original'),
          MenuOption(id: 'spicy', name: 'Spicy'),
        ],
      ),
      modifierGroup: OptionGroup(
        id: 'double-burger-add-ons',
        name: 'Modifiers & add-ons',
        maxSelections: 3,
        options: [
          MenuOption(
            id: 'extra-cheese',
            name: 'Extra cheese',
            priceDeltaMinor: 150,
          ),
          MenuOption(id: 'no-onion', name: 'No onion'),
        ],
      ),
    ),
    MenuProduct(
      id: 'fried-chicken',
      name: 'Fried Chicken (2 pcs)',
      description: 'Crispy, juicy and flavourful.',
      category: MenuCategory.chicken,
      basePriceMinor: 1290,
      isFeatured: true,
      variantGroup: OptionGroup(
        id: 'spice',
        name: 'Spice level',
        isRequired: true,
        options: [
          MenuOption(id: 'regular', name: 'Regular'),
          MenuOption(id: 'hot', name: 'Hot'),
        ],
      ),
      modifierGroup: OptionGroup(
        id: 'chicken-add-ons',
        name: 'Modifiers & add-ons',
        maxSelections: 2,
        options: [
          MenuOption(
            id: 'extra-sauce',
            name: 'Extra sauce',
            priceDeltaMinor: 50,
          ),
          MenuOption(id: 'cutlery', name: 'Cutlery'),
        ],
      ),
    ),
    MenuProduct(
      id: 'french-fries',
      name: 'French Fries',
      description: 'Golden and crispy fries.',
      category: MenuCategory.sides,
      basePriceMinor: 500,
      isFeatured: true,
      variantGroup: OptionGroup(
        id: 'portion-size',
        name: 'Portion size',
        isRequired: true,
        options: [
          MenuOption(id: 'regular', name: 'Regular'),
          MenuOption(id: 'large', name: 'Large', priceDeltaMinor: 200),
        ],
      ),
      modifierGroup: OptionGroup(
        id: 'fries-add-ons',
        name: 'Modifiers & add-ons',
        maxSelections: 3,
        options: [
          MenuOption(
            id: 'cheese-sauce',
            name: 'Cheese sauce',
            priceDeltaMinor: 150,
          ),
          MenuOption(id: 'no-salt', name: 'No salt'),
          MenuOption(id: 'ketchup', name: 'Ketchup'),
        ],
      ),
    ),
  ];

  @override
  Future<SubmittedOrder> submit(OrderSubmission submission) async {
    // Replaced later by the approved create-order/payment backend contract.
    return SubmittedOrder(orderNumber: 'A${_nextOrderNumber++}');
  }
}
