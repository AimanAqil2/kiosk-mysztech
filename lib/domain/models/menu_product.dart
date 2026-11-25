enum MenuCategory { featured, burgers, chicken, sides, drinks, desserts }

extension MenuCategoryLabel on MenuCategory {
  String get label => switch (this) {
    MenuCategory.featured => 'Featured',
    MenuCategory.burgers => 'Burgers',
    MenuCategory.chicken => 'Chicken',
    MenuCategory.sides => 'Sides',
    MenuCategory.drinks => 'Drinks',
    MenuCategory.desserts => 'Desserts',
  };
}

class MenuOption {
  const MenuOption({
    required this.id,
    required this.name,
    this.priceDeltaMinor = 0,
  });

  final String id;
  final String name;
  final int priceDeltaMinor;
}

class OptionGroup {
  const OptionGroup({
    required this.id,
    required this.name,
    required this.options,
    this.isRequired = false,
    this.maxSelections = 1,
  });

  final String id;
  final String name;
  final List<MenuOption> options;
  final bool isRequired;
  final int maxSelections;
}

class MenuProduct {
  const MenuProduct({
    required this.id,
    required this.name,
    required this.description,
    required this.category,
    required this.basePriceMinor,
    required this.variantGroup,
    required this.modifierGroup,
    this.isFeatured = false,
  });

  final String id;
  final String name;
  final String description;
  final MenuCategory category;
  final int basePriceMinor;
  final OptionGroup variantGroup;
  final OptionGroup modifierGroup;
  final bool isFeatured;
}
