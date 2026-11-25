import 'package:flutter/material.dart';

import '../../../domain/models/menu_product.dart';
import '../../../domain/models/order.dart';
import '../../core/kiosk_brand.dart';
import '../../core/money.dart';
import 'order_flow_view_model.dart';

class WelcomeScreen extends StatelessWidget {
  const WelcomeScreen({super.key, required this.viewModel});

  final OrderFlowViewModel viewModel;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final isCompact = constraints.maxHeight < 690;
        final horizontalPadding = constraints.maxWidth > 520 ? 42.0 : 28.0;
        final minimumHeight =
            constraints.maxHeight.isFinite && constraints.maxHeight > 46
            ? constraints.maxHeight - 46
            : 0.0;
        return SingleChildScrollView(
          padding: EdgeInsets.fromLTRB(
            horizontalPadding,
            18,
            horizontalPadding,
            28,
          ),
          child: ConstrainedBox(
            constraints: BoxConstraints(minHeight: minimumHeight),
            child: IntrinsicHeight(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const MysztechLogo(height: 29),
                      LanguagePill(onTap: () => _languageNotice(context)),
                    ],
                  ),
                  SizedBox(height: isCompact ? 26 : 44),
                  _WelcomeHero(height: isCompact ? 174 : 205),
                  SizedBox(height: isCompact ? 20 : 28),
                  Text(
                    'Welcome!',
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.headlineLarge?.copyWith(
                      fontSize: isCompact ? 30 : 34,
                    ),
                  ),
                  const SizedBox(height: 6),
                  const Text(
                    'How would you like to order?',
                    textAlign: TextAlign.center,
                    style: TextStyle(color: KioskColors.mutedInk),
                  ),
                  const SizedBox(height: 26),
                  Row(
                    children: [
                      Expanded(
                        child: _WelcomeOrderTypeCard(
                          key: const Key('welcomeDineInButton'),
                          icon: Icons.restaurant_outlined,
                          title: 'Dine-In',
                          detail: 'Enjoy your meal here',
                          onPressed: () =>
                              viewModel.chooseOrderType(OrderType.dineIn),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _WelcomeOrderTypeCard(
                          key: const Key('welcomeTakeawayButton'),
                          icon: Icons.shopping_bag_outlined,
                          title: 'Takeaway',
                          detail: 'Take your meal to go',
                          onPressed: () =>
                              viewModel.chooseOrderType(OrderType.takeaway),
                        ),
                      ),
                    ],
                  ),
                  const Spacer(),
                  const SizedBox(height: 28),
                  const Text(
                    'Tap an option to start your order',
                    textAlign: TextAlign.center,
                    style: TextStyle(color: KioskColors.mutedInk, fontSize: 12),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}

class _WelcomeHero extends StatelessWidget {
  const _WelcomeHero({required this.height});

  final double height;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: height,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        gradient: const LinearGradient(
          colors: [Color(0xFFFF9518), KioskColors.orange],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      clipBehavior: Clip.antiAlias,
      child: Stack(
        children: [
          Positioned(
            right: -height * .22,
            top: -height * .32,
            child: Container(
              width: height * .9,
              height: height * .9,
              decoration: const BoxDecoration(
                color: Color(0x33FFFFFF),
                shape: BoxShape.circle,
              ),
            ),
          ),
          Positioned(
            left: 14,
            top: 18,
            child: Text(
              'FRESHLY PREPARED',
              style: TextStyle(
                color: Colors.white,
                fontSize: height * .056,
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
          Positioned(
            left: 14,
            bottom: 16,
            child: Text(
              'Good food. Great moments.',
              style: TextStyle(
                color: Colors.white,
                fontSize: height * .09,
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
          Positioned(
            right: 17,
            bottom: 3,
            child: FoodArtwork(kind: FoodArtKind.burger, size: height * .82),
          ),
          Positioned(
            right: height * .49,
            top: height * .34,
            child: FoodArtwork(kind: FoodArtKind.fries, size: height * .28),
          ),
        ],
      ),
    );
  }
}

class _WelcomeOrderTypeCard extends StatelessWidget {
  const _WelcomeOrderTypeCard({
    super.key,
    required this.icon,
    required this.title,
    required this.detail,
    required this.onPressed,
  });

  final IconData icon;
  final String title;
  final String detail;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(14),
      elevation: 1,
      shadowColor: const Color(0x22000000),
      child: InkWell(
        borderRadius: BorderRadius.circular(14),
        onTap: onPressed,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 19),
          child: Column(
            children: [
              CircleAvatar(
                radius: 19,
                backgroundColor: KioskColors.orangeSoft,
                child: Icon(icon, color: KioskColors.orange, size: 21),
              ),
              const SizedBox(height: 12),
              Text(title, style: Theme.of(context).textTheme.titleMedium),
              const SizedBox(height: 4),
              Text(
                detail,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 10,
                  color: KioskColors.mutedInk,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class OrderTypeScreen extends StatelessWidget {
  const OrderTypeScreen({super.key, required this.viewModel});

  final OrderFlowViewModel viewModel;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const Spacer(),
          Text(
            'How would you like to order?',
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.headlineSmall,
          ),
          const SizedBox(height: 10),
          const Text(
            'Your cart will be kept when you change this later.',
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 32),
          _PickerOption(
            icon: Icons.restaurant_outlined,
            title: 'Dine-In',
            detail: 'Enjoy your meal here',
            onTap: () => viewModel.chooseOrderType(OrderType.dineIn),
          ),
          const SizedBox(height: 14),
          _PickerOption(
            icon: Icons.shopping_bag_outlined,
            title: 'Takeaway',
            detail: 'Take your meal to go',
            onTap: () => viewModel.chooseOrderType(OrderType.takeaway),
          ),
          const Spacer(flex: 2),
        ],
      ),
    );
  }
}

class _PickerOption extends StatelessWidget {
  const _PickerOption({
    required this.icon,
    required this.title,
    required this.detail,
    required this.onTap,
  });

  final IconData icon;
  final String title;
  final String detail;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(14),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(14),
        child: Container(
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(
            border: Border.all(color: KioskColors.line),
            borderRadius: BorderRadius.circular(14),
          ),
          child: Row(
            children: [
              CircleAvatar(
                backgroundColor: KioskColors.orangeSoft,
                child: Icon(icon, color: KioskColors.orange),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(title, style: Theme.of(context).textTheme.titleLarge),
                    Text(detail),
                  ],
                ),
              ),
              const Icon(Icons.arrow_forward, color: KioskColors.orange),
            ],
          ),
        ),
      ),
    );
  }
}

class MenuScreen extends StatelessWidget {
  const MenuScreen({super.key, required this.viewModel});

  final OrderFlowViewModel viewModel;

  @override
  Widget build(BuildContext context) {
    final layout = KioskLayout.of(context);
    final isKiosk = layout.isKioskViewport;
    final pagePadding = layout.pagePadding;
    return Column(
      children: [
        Padding(
          padding: EdgeInsets.symmetric(horizontal: pagePadding),
          child: _OrderTypeToggle(viewModel: viewModel, large: isKiosk),
        ),
        SizedBox(height: isKiosk ? 16 : 10),
        Padding(
          padding: EdgeInsets.symmetric(horizontal: pagePadding),
          child: _MenuHero(height: isKiosk ? 148 : 87),
        ),
        SizedBox(height: isKiosk ? 18 : 12),
        Expanded(
          child: LayoutBuilder(
            builder: (context, constraints) {
              final railWidth = isKiosk ? 126.0 : 76.0;
              final columns = constraints.maxWidth >= 1180
                  ? 4
                  : constraints.maxWidth >= 940
                  ? 3
                  : 2;
              final tileHeight = isKiosk ? 324.0 : 205.0;
              return Row(
                children: [
                  SizedBox(
                    width: pagePadding + railWidth,
                    child: Padding(
                      padding: EdgeInsets.only(left: pagePadding),
                      child: _CategoryRail(
                        viewModel: viewModel,
                        large: isKiosk,
                      ),
                    ),
                  ),
                  Expanded(
                    child: GridView.builder(
                      padding: EdgeInsets.fromLTRB(
                        isKiosk ? 12 : 4,
                        0,
                        pagePadding,
                        isKiosk ? 22 : 14,
                      ),
                      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: columns,
                        mainAxisExtent: tileHeight,
                        mainAxisSpacing: isKiosk ? 18 : 10,
                        crossAxisSpacing: isKiosk ? 18 : 10,
                      ),
                      itemCount: viewModel.visibleProducts.length,
                      itemBuilder: (context, index) {
                        final product = viewModel.visibleProducts[index];
                        return _ProductTile(
                          product: product,
                          onTap: () => viewModel.openProduct(product),
                        );
                      },
                    ),
                  ),
                ],
              );
            },
          ),
        ),
        if (viewModel.cart.isNotEmpty)
          _CartFooter(viewModel: viewModel, large: isKiosk),
      ],
    );
  }
}

class _OrderTypeToggle extends StatelessWidget {
  const _OrderTypeToggle({required this.viewModel, required this.large});

  final OrderFlowViewModel viewModel;
  final bool large;

  @override
  Widget build(BuildContext context) {
    final orderType = viewModel.orderType;
    return Container(
      height: large ? 58 : 38,
      padding: EdgeInsets.all(large ? 5 : 3),
      decoration: BoxDecoration(
        color: const Color(0xFFF5F3F5),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Row(
        children: [
          Expanded(
            child: _ToggleButton(
              icon: Icons.restaurant_outlined,
              label: 'Dine-In',
              selected: orderType == OrderType.dineIn,
              onTap: () => viewModel.updateOrderType(OrderType.dineIn),
              large: large,
            ),
          ),
          Expanded(
            child: _ToggleButton(
              icon: Icons.shopping_bag_outlined,
              label: 'Takeaway',
              selected: orderType == OrderType.takeaway,
              onTap: () => viewModel.updateOrderType(OrderType.takeaway),
              large: large,
            ),
          ),
        ],
      ),
    );
  }
}

class _ToggleButton extends StatelessWidget {
  const _ToggleButton({
    required this.icon,
    required this.label,
    required this.selected,
    required this.onTap,
    required this.large,
  });

  final IconData icon;
  final String label;
  final bool selected;
  final VoidCallback onTap;
  final bool large;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(999),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 160),
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: selected ? KioskColors.orange : Colors.transparent,
          borderRadius: BorderRadius.circular(999),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              size: large ? 21 : 14,
              color: selected ? Colors.white : KioskColors.ink,
            ),
            SizedBox(width: large ? 9 : 6),
            Text(
              label,
              style: TextStyle(
                fontSize: large ? 16 : 12,
                color: selected ? Colors.white : KioskColors.ink,
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _MenuHero extends StatelessWidget {
  const _MenuHero({required this.height});

  final double height;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: height,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(14),
        gradient: const LinearGradient(
          colors: [Color(0xFFFF9518), KioskColors.orange],
        ),
      ),
      clipBehavior: Clip.antiAlias,
      child: Stack(
        children: [
          Positioned(
            left: height * .16,
            top: height * .15,
            child: Text(
              'Better Meals\nStart Here',
              style: TextStyle(
                color: Colors.white,
                fontSize: height * .195,
                height: 1.05,
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
          Positioned(
            left: height * .16,
            bottom: height * .15,
            child: Text(
              'Freshly prepared favourites\njust for you.',
              style: TextStyle(
                color: Colors.white,
                fontSize: height * .105,
                height: 1.1,
              ),
            ),
          ),
          Positioned(
            right: height * .18,
            bottom: -height * .11,
            child: FoodArtwork(kind: FoodArtKind.burger, size: height * 1.24),
          ),
          Positioned(
            right: height * 1.05,
            top: height * .14,
            child: Container(
              width: height * .09,
              height: height * .035,
              color: Colors.white,
            ),
          ),
          Positioned(
            right: height * .91,
            top: height * .14,
            child: Container(
              width: height * .09,
              height: height * .035,
              color: const Color(0x77FFFFFF),
            ),
          ),
        ],
      ),
    );
  }
}

class _CategoryRail extends StatelessWidget {
  const _CategoryRail({required this.viewModel, required this.large});

  final OrderFlowViewModel viewModel;
  final bool large;

  @override
  Widget build(BuildContext context) {
    final categories = <(MenuCategory?, IconData, String)>[
      (MenuCategory.featured, Icons.star_outline, 'Featured'),
      (MenuCategory.burgers, Icons.lunch_dining_outlined, 'Burgers'),
      (MenuCategory.chicken, Icons.restaurant_outlined, 'Chicken'),
      (MenuCategory.sides, Icons.fastfood_outlined, 'Sides'),
      (MenuCategory.drinks, Icons.local_drink_outlined, 'Drinks'),
      (MenuCategory.desserts, Icons.icecream_outlined, 'Desserts'),
    ];
    return ListView.separated(
      padding: EdgeInsets.fromLTRB(large ? 6 : 12, 0, large ? 12 : 6, 12),
      itemCount: categories.length,
      separatorBuilder: (_, _) => SizedBox(height: large ? 9 : 5),
      itemBuilder: (context, index) {
        final (category, icon, label) = categories[index];
        final isSelected = viewModel.selectedCategory == category;
        return InkWell(
          borderRadius: BorderRadius.circular(10),
          onTap: () => viewModel.chooseCategory(category),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 150),
            padding: EdgeInsets.symmetric(
              vertical: large ? 15 : 8,
              horizontal: large ? 7 : 4,
            ),
            decoration: BoxDecoration(
              color: isSelected ? KioskColors.orangeSoft : Colors.transparent,
              border: isSelected
                  ? const Border(
                      left: BorderSide(color: KioskColors.orange, width: 3),
                    )
                  : null,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Column(
              children: [
                Icon(
                  icon,
                  size: large ? 28 : 19,
                  color: isSelected ? KioskColors.orange : KioskColors.ink,
                ),
                SizedBox(height: large ? 6 : 3),
                Text(
                  label,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: large ? 13 : 8,
                    fontWeight: isSelected ? FontWeight.w800 : FontWeight.w600,
                    color: KioskColors.ink,
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _ProductTile extends StatelessWidget {
  const _ProductTile({required this.product, required this.onTap});

  final MenuProduct product;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final artKind = foodArtFor(product);
    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(11),
      child: InkWell(
        key: Key('product-${product.id}'),
        borderRadius: BorderRadius.circular(11),
        onTap: onTap,
        child: LayoutBuilder(
          builder: (context, constraints) {
            final large = constraints.maxWidth >= 210;
            final padding = large ? 14.0 : 8.0;
            final artworkSize = (constraints.maxWidth * .48).clamp(76.0, 138.0);
            return Padding(
              padding: EdgeInsets.all(padding),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Container(
                      width: double.infinity,
                      decoration: BoxDecoration(
                        color: KioskColors.orangeSoft,
                        borderRadius: BorderRadius.circular(large ? 14 : 9),
                      ),
                      child: Center(
                        child: FoodArtwork(kind: artKind, size: artworkSize),
                      ),
                    ),
                  ),
                  SizedBox(height: large ? 12 : 8),
                  Text(
                    product.name,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: large ? 16 : 11,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  SizedBox(height: large ? 5 : 3),
                  Text(
                    product.description,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: large ? 11 : 8,
                      color: KioskColors.mutedInk,
                      height: 1.2,
                    ),
                  ),
                  SizedBox(height: large ? 12 : 8),
                  Row(
                    children: [
                      Text(
                        formatMoney(product.basePriceMinor),
                        style: TextStyle(
                          fontSize: large ? 16 : 11,
                          color: KioskColors.orange,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      const Spacer(),
                      CircleAvatar(
                        radius: large ? 16 : 10,
                        backgroundColor: KioskColors.orangeSoft,
                        child: Icon(
                          Icons.add,
                          size: large ? 21 : 14,
                          color: KioskColors.orange,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}

class _CartFooter extends StatelessWidget {
  const _CartFooter({required this.viewModel, required this.large});

  final OrderFlowViewModel viewModel;
  final bool large;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.fromLTRB(
        large ? 30 : 18,
        2,
        large ? 30 : 18,
        large ? 20 : 12,
      ),
      padding: EdgeInsets.fromLTRB(
        large ? 20 : 13,
        large ? 13 : 8,
        large ? 13 : 8,
        large ? 13 : 8,
      ),
      decoration: BoxDecoration(
        color: KioskColors.orange,
        borderRadius: BorderRadius.circular(13),
      ),
      child: Row(
        children: [
          Stack(
            clipBehavior: Clip.none,
            children: [
              Icon(
                Icons.shopping_cart_outlined,
                color: Colors.white,
                size: large ? 34 : 25,
              ),
              Positioned(
                right: -7,
                top: -7,
                child: CircleAvatar(
                  radius: large ? 11 : 8,
                  backgroundColor: Colors.white,
                  child: Text(
                    '${viewModel.itemCount}',
                    style: TextStyle(
                      color: KioskColors.orange,
                      fontSize: large ? 12 : 9,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
              ),
            ],
          ),
          SizedBox(width: large ? 16 : 11),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Your Order',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: large ? 16 : 11,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                Text(
                  '${viewModel.itemCount} items · ${formatMoney(viewModel.totalMinor)}',
                  style: const TextStyle(color: Colors.white, fontSize: 9),
                ),
              ],
            ),
          ),
          ElevatedButton(
            key: const Key('viewCartButton'),
            onPressed: viewModel.openCart,
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.white,
              foregroundColor: KioskColors.orange,
              elevation: 0,
              minimumSize: Size(large ? 138 : 92, large ? 48 : 34),
              padding: EdgeInsets.symmetric(horizontal: large ? 16 : 10),
            ),
            child: Text(
              'View Cart ›',
              style: TextStyle(
                fontSize: large ? 14 : 10,
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class CustomizationScreen extends StatefulWidget {
  const CustomizationScreen({super.key, required this.viewModel});

  final OrderFlowViewModel viewModel;

  @override
  State<CustomizationScreen> createState() => _CustomizationScreenState();
}

class _CustomizationScreenState extends State<CustomizationScreen> {
  late MenuOption _variant;
  late Set<String> _selectedModifierIds;
  late TextEditingController _remarksController;
  late int _quantity;

  @override
  void initState() {
    super.initState();
    final product = widget.viewModel.activeProduct!;
    final line = widget.viewModel.activeLine;
    _variant = line?.variant ?? product.variantGroup.options.first;
    _selectedModifierIds = {
      for (final modifier in line?.modifiers ?? const <MenuOption>[])
        modifier.id,
    };
    _remarksController = TextEditingController(text: line?.remarks ?? '');
    _quantity = line?.quantity ?? 1;
  }

  @override
  void dispose() {
    _remarksController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final product = widget.viewModel.activeProduct;
    if (product == null) {
      return const SizedBox.shrink();
    }
    final selectedModifiers = product.modifierGroup.options
        .where((option) => _selectedModifierIds.contains(option.id))
        .toList();
    final modifierCost = selectedModifiers.fold<int>(
      0,
      (sum, option) => sum + option.priceDeltaMinor,
    );
    final unitTotal =
        product.basePriceMinor + _variant.priceDeltaMinor + modifierCost;
    final itemTotal = unitTotal * _quantity;
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(22, 9, 22, 8),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Customize your order',
                style: Theme.of(
                  context,
                ).textTheme.headlineSmall?.copyWith(fontSize: 25),
              ),
              const SizedBox(height: 2),
              const Text(
                'Choose your preferred options.',
                style: TextStyle(fontSize: 12),
              ),
            ],
          ),
        ),
        Expanded(
          child: ListView(
            padding: const EdgeInsets.fromLTRB(22, 0, 22, 8),
            children: [
              _ProductSummaryCard(product: product),
              const SizedBox(height: 15),
              _ChoiceSectionLabel(
                label: product.variantGroup.name,
                detail: product.variantGroup.isRequired
                    ? 'REQUIRED · Choose 1'
                    : 'OPTIONAL',
              ),
              const SizedBox(height: 8),
              for (final option in product.variantGroup.options)
                Padding(
                  padding: const EdgeInsets.only(bottom: 7),
                  child: _OptionCard(
                    selected: _variant.id == option.id,
                    type: _OptionCardType.radio,
                    name: option.name,
                    priceDelta: option.priceDeltaMinor,
                    onTap: () => setState(() => _variant = option),
                  ),
                ),
              const SizedBox(height: 9),
              _ChoiceSectionLabel(
                label: product.modifierGroup.name,
                detail:
                    'OPTIONAL · Choose up to ${product.modifierGroup.maxSelections}',
              ),
              const SizedBox(height: 8),
              for (final option in product.modifierGroup.options)
                Padding(
                  padding: const EdgeInsets.only(bottom: 7),
                  child: _OptionCard(
                    selected: _selectedModifierIds.contains(option.id),
                    type: _OptionCardType.check,
                    name: option.name,
                    priceDelta: option.priceDeltaMinor,
                    onTap: () => _toggleModifier(product, option),
                  ),
                ),
              const SizedBox(height: 10),
              const _ChoiceSectionLabel(
                label: 'Item remarks',
                detail: 'OPTIONAL',
              ),
              const SizedBox(height: 7),
              TextField(
                controller: _remarksController,
                maxLength: 150,
                maxLines: 1,
                style: const TextStyle(fontSize: 11),
                decoration: const InputDecoration(
                  prefixIcon: Icon(Icons.chat_bubble_outline, size: 14),
                  hintText: 'Sauce on the side, please.',
                ),
              ),
              const SizedBox(height: 4),
              Row(
                children: [
                  const Text(
                    'Quantity',
                    style: TextStyle(fontWeight: FontWeight.w800),
                  ),
                  const Spacer(),
                  _QuantityControl(
                    quantity: _quantity,
                    onChanged: (value) => setState(() => _quantity = value),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              _PriceBreakdown(
                base: product.basePriceMinor * _quantity,
                options: (_variant.priceDeltaMinor + modifierCost) * _quantity,
                total: itemTotal,
              ),
            ],
          ),
        ),
        Container(
          padding: const EdgeInsets.fromLTRB(22, 12, 22, 18),
          decoration: const BoxDecoration(
            color: Colors.white,
            border: Border(top: BorderSide(color: KioskColors.line)),
          ),
          child: Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: widget.viewModel.goBack,
                  style: OutlinedButton.styleFrom(
                    minimumSize: const Size.fromHeight(48),
                    side: const BorderSide(color: KioskColors.line),
                  ),
                  child: const Text('Cancel'),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                flex: 2,
                child: KioskPrimaryButton(
                  label: 'Add to cart · ${formatMoney(itemTotal)}',
                  onPressed: () => widget.viewModel.saveLine(
                    product: product,
                    variant: _variant,
                    modifiers: selectedModifiers,
                    quantity: _quantity,
                    remarks: _remarksController.text,
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  void _toggleModifier(MenuProduct product, MenuOption option) {
    final selected = _selectedModifierIds.contains(option.id);
    if (!selected &&
        _selectedModifierIds.length >= product.modifierGroup.maxSelections) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Choose up to ${product.modifierGroup.maxSelections} options.',
          ),
        ),
      );
      return;
    }
    setState(() {
      if (selected) {
        _selectedModifierIds.remove(option.id);
      } else {
        _selectedModifierIds.add(option.id);
      }
    });
  }
}

class _ProductSummaryCard extends StatelessWidget {
  const _ProductSummaryCard({required this.product});

  final MenuProduct product;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 89,
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(
        color: KioskColors.orangeSoft,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          FoodArtwork(kind: foodArtFor(product), size: 70),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  product.name,
                  style: const TextStyle(fontWeight: FontWeight.w800),
                ),
                const SizedBox(height: 3),
                Text(
                  product.description,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 9,
                    color: KioskColors.mutedInk,
                  ),
                ),
                const SizedBox(height: 7),
                Text(
                  'From ${formatMoney(product.basePriceMinor)}',
                  style: const TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w800,
                    color: KioskColors.orange,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _ChoiceSectionLabel extends StatelessWidget {
  const _ChoiceSectionLabel({required this.label, required this.detail});

  final String label;
  final String detail;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Text(
            label,
            style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w800),
          ),
        ),
        Text(
          detail,
          style: const TextStyle(
            fontSize: 8,
            color: KioskColors.orange,
            fontWeight: FontWeight.w700,
          ),
        ),
      ],
    );
  }
}

enum _OptionCardType { radio, check }

class _OptionCard extends StatelessWidget {
  const _OptionCard({
    required this.selected,
    required this.type,
    required this.name,
    required this.priceDelta,
    required this.onTap,
  });

  final bool selected;
  final _OptionCardType type;
  final String name;
  final int priceDelta;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final mark = type == _OptionCardType.radio
        ? Container(
            width: 17,
            height: 17,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(
                color: selected ? KioskColors.orange : KioskColors.line,
                width: selected ? 5 : 1.5,
              ),
            ),
          )
        : Container(
            width: 17,
            height: 17,
            decoration: BoxDecoration(
              color: selected ? KioskColors.orange : Colors.white,
              border: Border.all(
                color: selected ? KioskColors.orange : KioskColors.line,
              ),
              borderRadius: BorderRadius.circular(4),
            ),
            child: selected
                ? const Icon(Icons.check, size: 13, color: Colors.white)
                : null,
          );
    return Material(
      color: selected ? KioskColors.orangeSoft : Colors.white,
      borderRadius: BorderRadius.circular(10),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(10),
        child: Container(
          height: 43,
          padding: const EdgeInsets.symmetric(horizontal: 12),
          decoration: BoxDecoration(
            border: Border.all(
              color: selected ? KioskColors.orange : KioskColors.line,
            ),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Row(
            children: [
              mark,
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  name,
                  style: const TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              Text(
                priceDelta == 0 ? 'Free' : '+ ${formatMoney(priceDelta)}',
                style: TextStyle(
                  fontSize: 10,
                  color: priceDelta == 0
                      ? KioskColors.mutedInk
                      : KioskColors.orange,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _QuantityControl extends StatelessWidget {
  const _QuantityControl({required this.quantity, required this.onChanged});

  final int quantity;
  final ValueChanged<int> onChanged;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: KioskColors.line),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          _TinyIconButton(
            icon: Icons.remove,
            onTap: quantity > 1 ? () => onChanged(quantity - 1) : null,
          ),
          SizedBox(
            width: 26,
            child: Text(
              '$quantity',
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700),
            ),
          ),
          _TinyIconButton(
            icon: Icons.add,
            onTap: () => onChanged(quantity + 1),
            orange: true,
          ),
        ],
      ),
    );
  }
}

class _TinyIconButton extends StatelessWidget {
  const _TinyIconButton({
    required this.icon,
    required this.onTap,
    this.orange = false,
  });

  final IconData icon;
  final VoidCallback? onTap;
  final bool orange;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: SizedBox(
        width: 30,
        height: 30,
        child: Icon(
          icon,
          size: 14,
          color: orange ? KioskColors.orange : KioskColors.ink,
        ),
      ),
    );
  }
}

class _PriceBreakdown extends StatelessWidget {
  const _PriceBreakdown({
    required this.base,
    required this.options,
    required this.total,
  });

  final int base;
  final int options;
  final int total;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _SmallPriceRow(label: 'Base price', value: formatMoney(base)),
        _SmallPriceRow(
          label: 'Variant & modifiers',
          value: '+ ${formatMoney(options)}',
        ),
        const Divider(height: 14),
        Row(
          children: [
            const Text(
              'Item total',
              style: TextStyle(fontWeight: FontWeight.w800),
            ),
            const Spacer(),
            Text(
              formatMoney(total),
              style: const TextStyle(
                color: KioskColors.orange,
                fontSize: 17,
                fontWeight: FontWeight.w900,
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class _SmallPriceRow extends StatelessWidget {
  const _SmallPriceRow({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.symmetric(vertical: 2),
    child: Row(
      children: [
        Text(
          label,
          style: const TextStyle(fontSize: 10, color: KioskColors.mutedInk),
        ),
        const Spacer(),
        Text(
          value,
          style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w700),
        ),
      ],
    ),
  );
}

class CartScreen extends StatefulWidget {
  const CartScreen({super.key, required this.viewModel});

  final OrderFlowViewModel viewModel;

  @override
  State<CartScreen> createState() => _CartScreenState();
}

class _CartScreenState extends State<CartScreen> {
  late TextEditingController _remarksController;

  @override
  void initState() {
    super.initState();
    _remarksController = TextEditingController(
      text: widget.viewModel.orderRemarks,
    );
  }

  @override
  void dispose() {
    _remarksController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final viewModel = widget.viewModel;
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(22, 8, 22, 0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Your order',
                style: Theme.of(
                  context,
                ).textTheme.headlineSmall?.copyWith(fontSize: 25),
              ),
              const SizedBox(height: 2),
              const Text(
                'Review your items, options and remarks.',
                style: TextStyle(fontSize: 12),
              ),
              const SizedBox(height: 14),
              _CartOrderTypeLine(viewModel: viewModel),
            ],
          ),
        ),
        Expanded(
          child: ListView(
            padding: const EdgeInsets.fromLTRB(22, 10, 22, 6),
            children: [
              for (final line in viewModel.cart) ...[
                _CartLineCard(viewModel: viewModel, line: line),
                const SizedBox(height: 10),
              ],
              Align(
                alignment: Alignment.center,
                child: TextButton.icon(
                  onPressed: viewModel.goBack,
                  icon: const Icon(Icons.add, size: 14),
                  label: const Text(
                    'Add more items',
                    style: TextStyle(
                      fontSize: 11,
                      color: KioskColors.orange,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 14),
              const _ChoiceSectionLabel(
                label: 'Order remarks',
                detail: 'OPTIONAL',
              ),
              const SizedBox(height: 8),
              TextField(
                controller: _remarksController,
                maxLength: 150,
                maxLines: 1,
                style: const TextStyle(fontSize: 11),
                onChanged: viewModel.updateOrderRemarks,
                decoration: const InputDecoration(
                  prefixIcon: Icon(Icons.chat_bubble_outline, size: 14),
                  hintText: 'Please serve all items together.',
                ),
              ),
            ],
          ),
        ),
        Container(
          padding: const EdgeInsets.fromLTRB(22, 12, 22, 18),
          decoration: const BoxDecoration(
            color: Colors.white,
            border: Border(top: BorderSide(color: KioskColors.line)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                children: [
                  Text(
                    'Total (${viewModel.itemCount} items)',
                    style: const TextStyle(fontWeight: FontWeight.w800),
                  ),
                  const Spacer(),
                  Text(
                    formatMoney(viewModel.totalMinor),
                    style: const TextStyle(
                      color: KioskColors.orange,
                      fontSize: 19,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              KioskPrimaryButton(
                label: 'Proceed to payment',
                icon: const Icon(Icons.arrow_forward, size: 17),
                onPressed: viewModel.canCheckout
                    ? viewModel.beginCheckout
                    : null,
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _CartOrderTypeLine extends StatelessWidget {
  const _CartOrderTypeLine({required this.viewModel});

  final OrderFlowViewModel viewModel;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      decoration: BoxDecoration(
        color: KioskColors.orangeSoft,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          Text(
            '${viewModel.orderType?.label ?? ''} · ${viewModel.itemCount} items',
            style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w800),
          ),
          const Spacer(),
          TextButton(
            onPressed: viewModel.openOrderTypePicker,
            style: TextButton.styleFrom(
              minimumSize: Size.zero,
              padding: EdgeInsets.zero,
            ),
            child: const Text(
              'Change',
              style: TextStyle(
                fontSize: 10,
                color: KioskColors.orange,
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _CartLineCard extends StatelessWidget {
  const _CartLineCard({required this.viewModel, required this.line});

  final OrderFlowViewModel viewModel;
  final CartLine line;

  @override
  Widget build(BuildContext context) {
    final selections = [
      line.variant.name,
      ...line.modifiers.map((modifier) => modifier.name),
    ];
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 60,
          height: 60,
          decoration: BoxDecoration(
            color: KioskColors.orangeSoft,
            borderRadius: BorderRadius.circular(9),
          ),
          child: Center(
            child: FoodArtwork(kind: foodArtFor(line.product), size: 53),
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      line.product.name,
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ),
                  Text(
                    formatMoney(line.totalPriceMinor),
                    style: const TextStyle(
                      fontSize: 12,
                      color: KioskColors.orange,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 2),
              Text(
                selections.join(' · '),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  fontSize: 9,
                  color: KioskColors.mutedInk,
                ),
              ),
              if (line.remarks.isNotEmpty)
                Text(
                  'Note: ${line.remarks}',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 9,
                    color: KioskColors.orange,
                  ),
                ),
              const SizedBox(height: 5),
              Row(
                children: [
                  TextButton(
                    onPressed: () =>
                        viewModel.openProduct(line.product, line: line),
                    style: TextButton.styleFrom(
                      minimumSize: Size.zero,
                      padding: EdgeInsets.zero,
                    ),
                    child: const Text(
                      'Edit options',
                      style: TextStyle(
                        fontSize: 9,
                        color: KioskColors.orange,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ),
                  const Spacer(),
                  _QuantityControl(
                    quantity: line.quantity,
                    onChanged: (quantity) =>
                        viewModel.changeLineQuantity(line.id, quantity),
                  ),
                  IconButton(
                    onPressed: () => viewModel.removeLine(line.id),
                    icon: const Icon(Icons.delete_outline, size: 16),
                    color: KioskColors.mutedInk,
                    padding: const EdgeInsets.only(left: 7),
                    constraints: const BoxConstraints(),
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class TableNumberScreen extends StatefulWidget {
  const TableNumberScreen({super.key, required this.viewModel});

  final OrderFlowViewModel viewModel;

  @override
  State<TableNumberScreen> createState() => _TableNumberScreenState();
}

class _TableNumberScreenState extends State<TableNumberScreen> {
  late TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.viewModel.tableNumber);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    const keys = ['1', '2', '3', '4', '5', '6', '7', '8', '9', 'T', '0'];
    return Padding(
      padding: const EdgeInsets.fromLTRB(22, 9, 22, 18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const KioskStepIndicator(activeStep: 1),
          const SizedBox(height: 23),
          Text(
            'Enter your table number',
            style: Theme.of(
              context,
            ).textTheme.headlineSmall?.copyWith(fontSize: 25),
          ),
          const SizedBox(height: 4),
          const Text(
            'Use the number on your table card.',
            style: TextStyle(fontSize: 12),
          ),
          const SizedBox(height: 20),
          TextField(
            key: const Key('tableNumberField'),
            controller: _controller,
            readOnly: true,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w800,
              color: KioskColors.ink,
            ),
            decoration: InputDecoration(
              suffixIcon: IconButton(
                onPressed: () => setState(_controller.clear),
                icon: const Icon(Icons.close, color: KioskColors.orange),
              ),
            ),
          ),
          const SizedBox(height: 17),
          Expanded(
            child: GridView.count(
              physics: const NeverScrollableScrollPhysics(),
              crossAxisCount: 3,
              mainAxisSpacing: 10,
              crossAxisSpacing: 10,
              childAspectRatio: 1.75,
              children: [
                for (final key in keys)
                  _KeypadButton(
                    label: key,
                    onTap: () => setState(() => _controller.text += key),
                  ),
                _KeypadButton(
                  icon: Icons.backspace_outlined,
                  onTap: _controller.text.isEmpty
                      ? null
                      : () => setState(
                          () => _controller.text = _controller.text.substring(
                            0,
                            _controller.text.length - 1,
                          ),
                        ),
                ),
              ],
            ),
          ),
          const _TableHint(),
          const SizedBox(height: 15),
          KioskPrimaryButton(
            key: const Key('tableConfirmButton'),
            label: 'Confirm & continue',
            icon: const Icon(Icons.arrow_forward, size: 17),
            onPressed: _controller.text.trim().isEmpty
                ? null
                : () => widget.viewModel.saveTableNumber(_controller.text),
          ),
        ],
      ),
    );
  }
}

class _KeypadButton extends StatelessWidget {
  const _KeypadButton({this.label, this.icon, required this.onTap});

  final String? label;
  final IconData? icon;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(9),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(9),
        child: Container(
          decoration: BoxDecoration(
            border: Border.all(color: KioskColors.line),
            borderRadius: BorderRadius.circular(9),
          ),
          alignment: Alignment.center,
          child: icon == null
              ? Text(
                  label!,
                  style: const TextStyle(fontWeight: FontWeight.w700),
                )
              : Icon(icon, size: 18),
        ),
      ),
    );
  }
}

class _TableHint extends StatelessWidget {
  const _TableHint();

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.all(11),
    decoration: BoxDecoration(
      color: KioskColors.orangeSoft,
      borderRadius: BorderRadius.circular(9),
    ),
    child: const Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(Icons.info_outline, size: 15, color: KioskColors.orange),
        SizedBox(width: 8),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Where can I find my number?',
                style: TextStyle(fontSize: 10, fontWeight: FontWeight.w800),
              ),
              SizedBox(height: 3),
              Text(
                'Look for the table card placed on your table. For example: T01, T02 or T05.',
                style: TextStyle(fontSize: 9, color: KioskColors.mutedInk),
              ),
            ],
          ),
        ),
      ],
    ),
  );
}

class PaymentScreen extends StatelessWidget {
  const PaymentScreen({super.key, required this.viewModel});

  final OrderFlowViewModel viewModel;

  @override
  Widget build(BuildContext context) {
    final orderType = viewModel.orderType;
    return Padding(
      padding: const EdgeInsets.fromLTRB(22, 9, 22, 18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const KioskStepIndicator(activeStep: 3),
          const SizedBox(height: 23),
          Text(
            'Payment method',
            style: Theme.of(
              context,
            ).textTheme.headlineSmall?.copyWith(fontSize: 25),
          ),
          const SizedBox(height: 4),
          const Text(
            'Review and confirm your order.',
            style: TextStyle(fontSize: 12),
          ),
          const SizedBox(height: 20),
          Container(
            padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 18),
            decoration: BoxDecoration(
              color: Colors.white,
              border: Border.all(color: KioskColors.orange),
              borderRadius: BorderRadius.circular(13),
            ),
            child: Column(
              children: [
                const CircleAvatar(
                  radius: 25,
                  backgroundColor: KioskColors.orangeSoft,
                  child: Icon(
                    Icons.point_of_sale_outlined,
                    color: KioskColors.orange,
                    size: 28,
                  ),
                ),
                const SizedBox(height: 10),
                Text(
                  'Pay at Counter',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                const SizedBox(height: 5),
                const Text(
                  'Pay at the cashier after placing your order.',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 10),
                ),
              ],
            ),
          ),
          const SizedBox(height: 22),
          Text('Order summary', style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: Colors.white,
              border: Border.all(color: KioskColors.line),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              children: [
                _SummaryRow(label: 'Order type', value: orderType?.label ?? ''),
                if (orderType == OrderType.dineIn)
                  _SummaryRow(
                    label: 'Table number',
                    value: viewModel.tableNumber,
                  ),
                _SummaryRow(
                  label: 'Total items',
                  value: '${viewModel.itemCount}',
                ),
                const Divider(height: 22),
                _SummaryRow(
                  label: 'Total amount',
                  value: formatMoney(viewModel.totalMinor),
                  emphasized: true,
                ),
              ],
            ),
          ),
          if (viewModel.orderRemarks.isNotEmpty) ...[
            const SizedBox(height: 14),
            Container(
              padding: const EdgeInsets.all(11),
              decoration: BoxDecoration(
                color: KioskColors.orangeSoft,
                borderRadius: BorderRadius.circular(9),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Order remarks',
                    style: TextStyle(fontSize: 10, fontWeight: FontWeight.w800),
                  ),
                  const SizedBox(height: 3),
                  Text(
                    viewModel.orderRemarks,
                    style: const TextStyle(
                      fontSize: 9,
                      color: KioskColors.mutedInk,
                    ),
                  ),
                ],
              ),
            ),
          ],
          if (viewModel.errorMessage != null)
            Padding(
              padding: const EdgeInsets.only(top: 10),
              child: Text(
                viewModel.errorMessage!,
                style: TextStyle(
                  fontSize: 11,
                  color: Theme.of(context).colorScheme.error,
                ),
              ),
            ),
          const Spacer(),
          const Text(
            'You will receive your order number after confirmation.',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 9, color: KioskColors.mutedInk),
          ),
          const SizedBox(height: 12),
          KioskPrimaryButton(
            key: const Key('confirmOrderButton'),
            label: viewModel.isSubmitting
                ? 'Confirming order…'
                : 'Confirm order',
            icon: viewModel.isSubmitting
                ? const SizedBox.square(
                    dimension: 17,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: Colors.white,
                    ),
                  )
                : const Icon(Icons.arrow_forward, size: 17),
            onPressed: viewModel.isSubmitting
                ? null
                : viewModel.confirmPayAtCounterOrder,
          ),
        ],
      ),
    );
  }
}

class _SummaryRow extends StatelessWidget {
  const _SummaryRow({
    required this.label,
    required this.value,
    this.emphasized = false,
  });

  final String label;
  final String value;
  final bool emphasized;

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.symmetric(vertical: 4),
    child: Row(
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: emphasized ? 12 : 10,
            fontWeight: emphasized ? FontWeight.w800 : FontWeight.w500,
            color: emphasized ? KioskColors.ink : KioskColors.mutedInk,
          ),
        ),
        const Spacer(),
        Text(
          value,
          style: TextStyle(
            fontSize: emphasized ? 15 : 10,
            fontWeight: FontWeight.w800,
            color: emphasized ? KioskColors.orange : KioskColors.ink,
          ),
        ),
      ],
    ),
  );
}

class SuccessScreen extends StatelessWidget {
  const SuccessScreen({super.key, required this.viewModel});

  final OrderFlowViewModel viewModel;

  @override
  Widget build(BuildContext context) {
    final order = viewModel.submittedOrder;
    return Padding(
      padding: const EdgeInsets.fromLTRB(28, 18, 28, 28),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const Center(child: MysztechLogo(height: 29)),
          const SizedBox(height: 26),
          const KioskStepIndicator(activeStep: 4),
          const Spacer(),
          Container(
            width: 104,
            height: 104,
            alignment: Alignment.center,
            decoration: const BoxDecoration(
              color: Color(0x1F55D890),
              shape: BoxShape.circle,
            ),
            child: Container(
              width: 71,
              height: 71,
              alignment: Alignment.center,
              decoration: const BoxDecoration(
                color: Color(0x3355D890),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.check,
                color: KioskColors.green,
                size: 39,
              ),
            ),
          ),
          const SizedBox(height: 25),
          Text(
            'Order received!',
            textAlign: TextAlign.center,
            style: Theme.of(
              context,
            ).textTheme.headlineMedium?.copyWith(fontSize: 26),
          ),
          const SizedBox(height: 5),
          const Text(
            'Thank you for ordering with us.',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 12),
          ),
          const SizedBox(height: 28),
          Container(
            padding: const EdgeInsets.symmetric(vertical: 19),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              boxShadow: const [
                BoxShadow(
                  color: Color(0x11000000),
                  blurRadius: 12,
                  offset: Offset(0, 4),
                ),
              ],
            ),
            child: Column(
              children: [
                const Text(
                  'YOUR ORDER NUMBER',
                  style: TextStyle(
                    fontSize: 9,
                    fontWeight: FontWeight.w700,
                    color: KioskColors.mutedInk,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  '#${order?.orderNumber ?? '—'}',
                  style: const TextStyle(
                    color: KioskColors.orange,
                    fontSize: 32,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  viewModel.orderType == OrderType.dineIn
                      ? 'Dine-In · Table ${viewModel.tableNumber}'
                      : 'Takeaway',
                  style: const TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 22),
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: KioskColors.orangeSoft,
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(
                  Icons.point_of_sale_outlined,
                  color: KioskColors.orange,
                  size: 20,
                ),
                SizedBox(width: 9),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Please proceed to the cashier.',
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      SizedBox(height: 3),
                      Text(
                        'Show your order number to make payment.',
                        style: TextStyle(
                          fontSize: 9,
                          color: KioskColors.mutedInk,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const Spacer(),
          KioskPrimaryButton(
            key: const Key('startNewOrderButton'),
            label: 'Start new order',
            onPressed: viewModel.startNewOrder,
          ),
        ],
      ),
    );
  }
}

FoodArtKind foodArtFor(MenuProduct product) {
  return switch (product.category) {
    MenuCategory.burgers => FoodArtKind.burger,
    MenuCategory.sides => FoodArtKind.fries,
    MenuCategory.chicken => FoodArtKind.chicken,
    _ => FoodArtKind.generic,
  };
}

void _languageNotice(BuildContext context) {
  ScaffoldMessenger.of(context).showSnackBar(
    const SnackBar(content: Text('Language selection will be available soon.')),
  );
}
