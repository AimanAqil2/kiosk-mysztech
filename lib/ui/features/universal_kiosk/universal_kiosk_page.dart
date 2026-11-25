import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../domain/models/universal_kiosk_models.dart';
import '../../core/money.dart';
import '../../core/universal_brand.dart';
import 'universal_kiosk_view_model.dart';

class UniversalKioskPage extends StatelessWidget {
  const UniversalKioskPage({super.key, required this.viewModel});

  final UniversalKioskViewModel viewModel;

  @override
  Widget build(BuildContext context) => AnimatedBuilder(
    animation: viewModel,
    builder: (context, _) {
      final screen = viewModel.screen;
      return LayoutBuilder(
        builder: (context, constraints) => MediaQuery(
          data: MediaQuery.of(context).copyWith(size: constraints.biggest),
          child: Scaffold(
            body: SafeArea(
              child: screen == UniversalScreen.welcome
                  ? _WelcomeScreen(viewModel: viewModel)
                  : _KioskShell(
                      viewModel: viewModel,
                      child: _screenFor(screen),
                    ),
            ),
          ),
        ),
      );
    },
  );

  Widget _screenFor(UniversalScreen screen) => switch (screen) {
    UniversalScreen.foodOrderType => _OrderTypeScreen(viewModel: viewModel),
    UniversalScreen.foodTable => _TableNumberScreen(viewModel: viewModel),
    UniversalScreen.foodCatalog ||
    UniversalScreen.retailCatalog ||
    UniversalScreen.serviceCatalog => _CatalogScreen(viewModel: viewModel),
    UniversalScreen.productDetail => _ProductDetailScreen(viewModel: viewModel),
    UniversalScreen.orderSummary => _OrderSummaryScreen(viewModel: viewModel),
    UniversalScreen.payment => _PaymentScreen(viewModel: viewModel),
    UniversalScreen.serviceBooking => _ServiceBookingScreen(
      viewModel: viewModel,
    ),
    UniversalScreen.success => _SuccessScreen(viewModel: viewModel),
    UniversalScreen.adminWelcome => _AdminWelcomeScreen(viewModel: viewModel),
    UniversalScreen.adminBusinessInfo => _BusinessInformationScreen(
      viewModel: viewModel,
    ),
    UniversalScreen.adminBusinessMode => _BusinessModeScreen(
      viewModel: viewModel,
    ),
    UniversalScreen.adminCatalog => _AdminCatalogScreen(viewModel: viewModel),
    UniversalScreen.adminDisplay => _DisplayReceiptScreen(viewModel: viewModel),
    UniversalScreen.adminReview => _ReviewActivateScreen(viewModel: viewModel),
    UniversalScreen.welcome => const SizedBox.shrink(),
  };
}

class _KioskShell extends StatelessWidget {
  const _KioskShell({required this.viewModel, required this.child});
  final UniversalKioskViewModel viewModel;
  final Widget child;

  @override
  Widget build(BuildContext context) => Column(
    children: [
      _TopBar(viewModel: viewModel),
      Expanded(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(
              maxWidth: UniversalLayout.frameWidth,
            ),
            child: Padding(
              padding: EdgeInsets.all(UniversalLayout.of(context).pageInset),
              child: LayoutBuilder(
                builder: (context, constraints) {
                  final admin = viewModel.isAdmin;
                  final hasCategories =
                      !admin &&
                      [
                        UniversalScreen.foodCatalog,
                        UniversalScreen.retailCatalog,
                        UniversalScreen.serviceCatalog,
                        UniversalScreen.productDetail,
                        UniversalScreen.serviceBooking,
                        UniversalScreen.orderSummary,
                        UniversalScreen.payment,
                      ].contains(viewModel.screen);
                  final wide = UniversalLayout.of(context).isTablet;
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (!admin) ...[
                        _Progress(
                          steps: const [
                            'Browse',
                            'Review',
                            'Payment',
                            'Complete',
                          ],
                          active: switch (viewModel.screen) {
                            UniversalScreen.orderSummary => 1,
                            UniversalScreen.payment => 2,
                            UniversalScreen.success => 3,
                            _ => 0,
                          },
                        ),
                        const SizedBox(height: 22),
                      ],
                      if (!wide && admin) ...[
                        _AdminSteps(viewModel: viewModel, horizontal: true),
                        const SizedBox(height: 16),
                      ],
                      if (!wide && hasCategories) ...[
                        _CategoryRail(viewModel: viewModel, horizontal: true),
                        const SizedBox(height: 16),
                      ],
                      Expanded(
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            if (wide && (admin || hasCategories)) ...[
                              SizedBox(
                                width: admin
                                    ? UniversalLayout.adminSidebarWidth
                                    : UniversalLayout.customerSidebarWidth,
                                child: SingleChildScrollView(
                                  child: admin
                                      ? _AdminSteps(viewModel: viewModel)
                                      : _CategoryRail(viewModel: viewModel),
                                ),
                              ),
                              const SizedBox(width: UniversalLayout.sidebarGap),
                            ],
                            Expanded(child: child),
                          ],
                        ),
                      ),
                    ],
                  );
                },
              ),
            ),
          ),
        ),
      ),
      const _Footer(),
    ],
  );
}

class _TopBar extends StatelessWidget {
  const _TopBar({required this.viewModel});
  final UniversalKioskViewModel viewModel;

  @override
  Widget build(BuildContext context) {
    final layout = UniversalLayout.of(context);
    // Collapse labels, never the touch targets, when the header is constrained.
    final compact =
        !layout.isTablet || MediaQuery.textScalerOf(context).scale(1) > 1.2;
    final cartLabel =
        '${viewModel.activeMode == BusinessMode.services ? 'Booking' : 'Cart'} ${viewModel.itemCount}';
    final adminLabel = viewModel.isAdmin ? 'Exit setup' : 'Admin setup';
    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(bottom: BorderSide(color: UniversalColors.line)),
      ),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(
            maxWidth: UniversalLayout.frameWidth,
          ),
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: layout.pageInset),
            child: ConstrainedBox(
              constraints: BoxConstraints(minHeight: layout.headerHeight),
              child: Row(
                children: [
                  InkWell(
                    onTap: viewModel.isAdmin
                        ? viewModel.exitAdminSetup
                        : viewModel.startNewOrder,
                    child: const SizedBox(
                      height: 48,
                      child: UniversalLogo(compact: true),
                    ),
                  ),
                  const Spacer(),
                  if (!viewModel.isAdmin && viewModel.activeMode != null) ...[
                    if (layout.width > 900 && !compact) ...[
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 8,
                        ),
                        decoration: BoxDecoration(
                          color: UniversalColors.orangeSoft,
                          borderRadius: BorderRadius.circular(24),
                        ),
                        child: Text(
                          viewModel.activeMode!.label,
                          style: const TextStyle(
                            color: UniversalColors.orangeDark,
                            fontSize: 14,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                    ],
                    if (viewModel.screen != UniversalScreen.success) ...[
                      if (compact)
                        IconButton(
                          tooltip: cartLabel,
                          onPressed: viewModel.openSummary,
                          icon: Badge(
                            isLabelVisible: viewModel.itemCount > 0,
                            label: Text('${viewModel.itemCount}'),
                            child: Icon(
                              viewModel.activeMode == BusinessMode.services
                                  ? Icons.calendar_month_outlined
                                  : Icons.shopping_bag_outlined,
                            ),
                          ),
                        )
                      else
                        SecondaryActionButton(
                          label: cartLabel,
                          icon: Icons.shopping_bag_outlined,
                          onPressed: viewModel.openSummary,
                        ),
                      const SizedBox(width: 8),
                    ],
                  ],
                  if (compact)
                    IconButton(
                      tooltip: adminLabel,
                      icon: Icon(
                        viewModel.isAdmin
                            ? Icons.close
                            : Icons.settings_outlined,
                      ),
                      onPressed: viewModel.isAdmin
                          ? viewModel.exitAdminSetup
                          : viewModel.beginAdminSetup,
                    )
                  else
                    SecondaryActionButton(
                      label: adminLabel,
                      icon: viewModel.isAdmin
                          ? Icons.close
                          : Icons.settings_outlined,
                      onPressed: viewModel.isAdmin
                          ? viewModel.exitAdminSetup
                          : viewModel.beginAdminSetup,
                    ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _AdminSteps extends StatelessWidget {
  const _AdminSteps({required this.viewModel, this.horizontal = false});
  final UniversalKioskViewModel viewModel;
  final bool horizontal;

  @override
  Widget build(BuildContext context) {
    const steps = [
      (UniversalScreen.adminWelcome, 'Welcome'),
      (UniversalScreen.adminBusinessInfo, 'Business information'),
      (UniversalScreen.adminBusinessMode, 'Business mode'),
      (UniversalScreen.adminCatalog, 'Catalog'),
      (UniversalScreen.adminDisplay, 'Checkout & receipt'),
      (UniversalScreen.adminReview, 'Review & activate'),
    ];
    final current = steps.indexWhere((entry) => entry.$1 == viewModel.screen);
    final tiles = [
      for (var i = 0; i < steps.length; i++)
        InkWell(
          borderRadius: BorderRadius.circular(8),
          onTap: i <= current
              ? () => viewModel.openAdminStep(steps[i].$1)
              : null,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 12),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(8),
              color: current == i
                  ? UniversalColors.orangeSoft
                  : Colors.transparent,
            ),
            child: Row(
              mainAxisSize: horizontal ? MainAxisSize.min : MainAxisSize.max,
              children: [
                CircleAvatar(
                  radius: 12,
                  backgroundColor: current == i
                      ? UniversalColors.orangeDark
                      : UniversalColors.canvas,
                  child: i < current
                      ? const Icon(
                          Icons.check,
                          size: 12,
                          color: UniversalColors.muted,
                        )
                      : Text(
                          '${i + 1}',
                          style: TextStyle(
                            fontSize: 12,
                            color: current == i
                                ? Colors.white
                                : UniversalColors.muted,
                          ),
                        ),
                ),
                const SizedBox(width: 8),
                Flexible(
                  fit: FlexFit.loose,
                  child: Text(
                    steps[i].$2,
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: current == i
                          ? FontWeight.w800
                          : FontWeight.w500,
                      color: current == i
                          ? UniversalColors.orangeDark
                          : UniversalColors.ink,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
    ];
    if (horizontal) {
      return SizedBox(
        height: 28 + MediaQuery.textScalerOf(context).scale(24),
        child: ListView(scrollDirection: Axis.horizontal, children: tiles),
      );
    }
    return _Panel(
      padding: const EdgeInsets.all(10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Padding(
            padding: EdgeInsets.all(8),
            child: Text(
              'ADMIN SETUP',
              style: TextStyle(
                color: UniversalColors.orange,
                letterSpacing: 1.5,
                fontWeight: FontWeight.w800,
                fontSize: 12,
              ),
            ),
          ),
          ...tiles,
        ],
      ),
    );
  }
}

class _Footer extends StatelessWidget {
  const _Footer();
  @override
  Widget build(BuildContext context) => Padding(
    padding: EdgeInsets.symmetric(
      horizontal: UniversalLayout.of(context).pageInset,
      vertical: 8,
    ),
    child: Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: UniversalLayout.frameWidth),
        child: const Row(
          children: [
            Text(
              'MYSZTECH',
              style: TextStyle(
                fontSize: 12,
                color: UniversalColors.muted,
                fontWeight: FontWeight.w700,
              ),
            ),
            SizedBox(width: 12),
            Expanded(
              child: Text(
                'Demo · Pay at Counter',
                textAlign: TextAlign.end,
                style: TextStyle(fontSize: 12, color: UniversalColors.muted),
              ),
            ),
          ],
        ),
      ),
    ),
  );
}

class _WelcomeScreen extends StatelessWidget {
  const _WelcomeScreen({required this.viewModel});

  final UniversalKioskViewModel viewModel;

  @override
  Widget build(BuildContext context) {
    final layout = UniversalLayout.of(context);
    return Column(
      children: [
        _TopBar(viewModel: viewModel),
        Expanded(
          child: SingleChildScrollView(
            padding: EdgeInsets.all(layout.pageInset),
            child: Center(
              child: ConstrainedBox(
                constraints: BoxConstraints(maxWidth: layout.contentMaxWidth),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _WelcomeHero(viewModel: viewModel),
                    const SizedBox(height: 28),
                    const Text(
                      'Explore a business mode',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    const SizedBox(height: 14),
                    _ModeCards(viewModel: viewModel),
                  ],
                ),
              ),
            ),
          ),
        ),
        const _Footer(),
      ],
    );
  }
}

class _WelcomeHero extends StatelessWidget {
  const _WelcomeHero({required this.viewModel});

  final UniversalKioskViewModel viewModel;

  @override
  Widget build(BuildContext context) => LayoutBuilder(
    builder: (context, constraints) {
      final split = constraints.maxWidth >= 700;
      final copy = Expanded(
        flex: split ? 9 : 0,
        child: Padding(
          padding: EdgeInsets.all(UniversalLayout.of(context).panelInset),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'SELF-SERVICE KIOSK',
                style: TextStyle(
                  color: UniversalColors.orange,
                  fontWeight: FontWeight.w900,
                  fontSize: 14,
                  letterSpacing: 1.2,
                ),
              ),
              const SizedBox(height: 16),
              Text(
                viewModel.isActivated
                    ? viewModel.welcomeHeading
                    : 'Welcome to\nMYSZTECH.',
                style: Theme.of(context).textTheme.headlineLarge?.copyWith(
                  fontSize: (constraints.maxWidth * (split ? .06 : .10)).clamp(
                    split ? 45.6 : 42.4,
                    split ? 82.4 : 62.4,
                  ),
                  height: .99,
                  fontVariations: const [FontVariation('wght', 820)],
                ),
              ),
              const SizedBox(height: 15),
              const Text(
                'Order food, shop products or book a service.\nStart here, then pay at the counter.',
                style: TextStyle(
                  fontSize: 16,
                  height: 1.5,
                  color: UniversalColors.muted,
                ),
              ),
              const SizedBox(height: 26),
              PrimaryActionButton(
                key: const Key('getStartedButton'),
                label: 'Get started',
                hero: true,
                icon: Icons.point_of_sale_outlined,
                onPressed: () => viewModel.startMode(
                  viewModel.isActivated
                      ? viewModel.configuredMode
                      : BusinessMode.food,
                ),
              ),
            ],
          ),
        ),
      );
      final image = Expanded(
        flex: split ? 11 : 0,
        child: ClipRRect(
          borderRadius: split
              ? const BorderRadius.horizontal(right: Radius.circular(18))
              : const BorderRadius.vertical(bottom: Radius.circular(18)),
          child: AspectRatio(
            aspectRatio: split ? 1.15 : 1.65,
            child: Image.asset(
              'assets/images/universal-kiosk-hero.png',
              fit: BoxFit.cover,
            ),
          ),
        ),
      );
      return Container(
        decoration: BoxDecoration(
          color: const Color(0xFFFFFBF7),
          border: Border.all(color: UniversalColors.line),
          borderRadius: BorderRadius.circular(18),
        ),
        clipBehavior: Clip.antiAlias,
        child: split
            ? Row(children: [copy, image])
            : Column(children: [copy, image]),
      );
    },
  );
}

class _ModeCards extends StatelessWidget {
  const _ModeCards({required this.viewModel});

  final UniversalKioskViewModel viewModel;

  @override
  Widget build(BuildContext context) => LayoutBuilder(
    builder: (context, constraints) {
      final columns = constraints.maxWidth >= 760 ? 3 : 1;
      final cards = [
        _ModeCard(
          icon: Icons.restaurant_outlined,
          iconColor: UniversalColors.foodIcon,
          iconSurface: UniversalColors.foodSurface,
          title: 'Food & Beverage',
          description: 'Cafés, restaurants and takeaway counters.',
          onTap: () => viewModel.startMode(BusinessMode.food),
        ),
        _ModeCard(
          icon: Icons.shopping_bag_outlined,
          iconColor: UniversalColors.retailIcon,
          iconSurface: UniversalColors.retailSurface,
          title: 'Retail',
          description: 'Boutiques, shops and product counters.',
          onTap: () => viewModel.startMode(BusinessMode.retail),
        ),
        _ModeCard(
          icon: Icons.calendar_month_outlined,
          iconColor: UniversalColors.servicesIcon,
          iconSurface: UniversalColors.servicesSurface,
          title: 'Services',
          description: 'Salons, studios and appointment desks.',
          onTap: () => viewModel.startMode(BusinessMode.services),
        ),
      ];
      if (columns == 1) {
        return Column(
          children: [
            for (final card in cards) ...[card, const SizedBox(height: 10)],
          ],
        );
      }
      return Row(
        children: [
          for (final card in cards) ...[
            Expanded(child: card),
            if (card != cards.last) const SizedBox(width: 14),
          ],
        ],
      );
    },
  );
}

class _ModeCard extends StatelessWidget {
  const _ModeCard({
    required this.icon,
    required this.iconColor,
    required this.iconSurface,
    required this.title,
    required this.description,
    required this.onTap,
  });

  final IconData icon;
  final Color iconColor;
  final Color iconSurface;
  final String title;
  final String description;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) => Material(
    color: Colors.white,
    borderRadius: BorderRadius.circular(14),
    child: InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(14),
      child: Container(
        constraints: const BoxConstraints(minHeight: 106),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          border: Border.all(color: UniversalColors.line),
          borderRadius: BorderRadius.circular(14),
        ),
        child: Row(
          children: [
            Container(
              width: 42,
              height: 42,
              decoration: BoxDecoration(
                color: iconSurface,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, color: iconColor),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                  const SizedBox(height: 3),
                  Text(
                    description,
                    style: const TextStyle(
                      fontSize: 14,
                      color: UniversalColors.muted,
                    ),
                  ),
                ],
              ),
            ),
            const Icon(
              Icons.arrow_forward,
              color: UniversalColors.muted,
              size: 18,
            ),
          ],
        ),
      ),
    ),
  );
}

class _OrderTypeScreen extends StatelessWidget {
  const _OrderTypeScreen({required this.viewModel});

  final UniversalKioskViewModel viewModel;

  @override
  Widget build(BuildContext context) => _CenteredFlow(
    child: SingleChildScrollView(
      child: _Panel(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SectionHeading(
              title: 'Choose your order type',
              subtitle: 'How would you like to enjoy your order?',
            ),
            const SizedBox(height: 24),
            LayoutBuilder(
              builder: (context, constraints) {
                final sideBySide = constraints.maxWidth > 540;
                final cards = [
                  _ChoiceCard(
                    icon: Icons.restaurant_outlined,
                    title: 'Dine-in',
                    detail: 'Enjoy your meal here.',
                    onTap: () => viewModel.chooseOrderType(OrderType.dineIn),
                  ),
                  _ChoiceCard(
                    icon: Icons.shopping_bag_outlined,
                    title: 'Takeaway',
                    detail: 'Take your order to go.',
                    onTap: () => viewModel.chooseOrderType(OrderType.takeaway),
                  ),
                ];
                return sideBySide
                    ? Row(
                        children: [
                          Expanded(child: cards[0]),
                          const SizedBox(width: 14),
                          Expanded(child: cards[1]),
                        ],
                      )
                    : Column(
                        children: [
                          cards[0],
                          const SizedBox(height: 12),
                          cards[1],
                        ],
                      );
              },
            ),
          ],
        ),
      ),
    ),
  );
}

class _TableNumberScreen extends StatefulWidget {
  const _TableNumberScreen({required this.viewModel});

  final UniversalKioskViewModel viewModel;

  @override
  State<_TableNumberScreen> createState() => _TableNumberScreenState();
}

class _TableNumberScreenState extends State<_TableNumberScreen> {
  late final TextEditingController _controller;
  String? _error;

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
  Widget build(BuildContext context) => _CenteredFlow(
    child: SingleChildScrollView(
      child: _Panel(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SectionHeading(
              title: 'Enter your table number',
              subtitle: 'Look for the number on your table card.',
            ),
            const SizedBox(height: 22),
            TextField(
              key: const Key('tableNumberField'),
              controller: _controller,
              keyboardType: TextInputType.number,
              inputFormatters: [FilteringTextInputFormatter.digitsOnly],
              onChanged: (_) => setState(() => _error = null),
              decoration: InputDecoration(
                hintText: 'Enter 1 to ${widget.viewModel.maxTableNumber}',
                prefixIcon: Icon(Icons.table_restaurant_outlined),
                errorText: _error,
              ),
            ),
            const SizedBox(height: 15),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                for (final table in [1, 2, 3, 4, 5])
                  ChoiceChip(
                    label: Text('$table'),
                    selected: _controller.text == '$table',
                    onSelected: (_) => setState(() {
                      _controller.text = '$table';
                      _error = null;
                    }),
                  ),
              ],
            ),
            const SizedBox(height: 26),
            Wrap(
              alignment: WrapAlignment.end,
              spacing: 10,
              runSpacing: 10,
              children: [
                SecondaryActionButton(
                  label: 'Back',
                  onPressed: widget.viewModel.goBack,
                  icon: Icons.arrow_back,
                ),
                const SizedBox(width: 10),
                PrimaryActionButton(
                  key: const Key('tableContinueButton'),
                  label: 'Continue',
                  onPressed: _controller.text.trim().isEmpty
                      ? null
                      : () async {
                          final saved = await widget.viewModel.saveTableNumber(
                            _controller.text,
                          );
                          if (!saved && mounted) {
                            setState(() {
                              _error =
                                  'Enter a number from 1 to ${widget.viewModel.maxTableNumber}.';
                            });
                          }
                        },
                ),
              ],
            ),
          ],
        ),
      ),
    ),
  );
}

IconData _categoryIcon(String category, BusinessMode? mode) {
  final name = category.toLowerCase();
  if (name == 'all') return Icons.grid_view_outlined;
  if (name.contains('burger')) return Icons.lunch_dining_outlined;
  if (name.contains('drink') || name.contains('lifestyle')) {
    return Icons.local_cafe_outlined;
  }
  if (name.contains('hair')) return Icons.content_cut;
  if (name.contains('wellness')) return Icons.favorite_border;
  if (name.contains('consult')) return Icons.person_outline;
  if (name.contains('apparel') ||
      name.contains('top') ||
      name.contains('outer')) {
    return Icons.checkroom_outlined;
  }
  if (name.contains('accessor')) return Icons.shopping_bag_outlined;
  return switch (mode) {
    BusinessMode.retail => Icons.shopping_bag_outlined,
    BusinessMode.services => Icons.calendar_month_outlined,
    _ => Icons.restaurant_outlined,
  };
}

class _CatalogScreen extends StatelessWidget {
  const _CatalogScreen({required this.viewModel});
  final UniversalKioskViewModel viewModel;

  @override
  Widget build(BuildContext context) {
    final mode = viewModel.activeMode ?? BusinessMode.food;
    return LayoutBuilder(
      builder: (context, constraints) {
        final pinOrder = constraints.maxHeight >= 240;
        final orderBar = Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (viewModel.itemCount > 0) ...[
              const SizedBox(height: 12),
              _Panel(
                padding: const EdgeInsets.symmetric(
                  horizontal: 14,
                  vertical: 8,
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: Text(
                        '${viewModel.itemCount} ${mode == BusinessMode.services
                            ? 'appointment'
                            : viewModel.itemCount == 1
                            ? 'item'
                            : 'items'}',
                        style: const TextStyle(fontWeight: FontWeight.w700),
                      ),
                    ),
                    PrimaryActionButton(
                      label: mode == BusinessMode.services
                          ? 'View booking'
                          : 'View order',
                      icon: Icons.shopping_cart_outlined,
                      onPressed: viewModel.openSummary,
                    ),
                  ],
                ),
              ),
            ],
          ],
        );
        return Column(
          children: [
            Expanded(
              child: CustomScrollView(
                key: const Key('productCatalogScroll'),
                slivers: [
                  SliverToBoxAdapter(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        LayoutBuilder(
                          builder: (context, constraints) {
                            final heading = SectionHeading(
                              title: switch (mode) {
                                BusinessMode.food => 'Our menu',
                                BusinessMode.retail => 'Shop products',
                                BusinessMode.services => 'Browse services',
                              },
                            );
                            final search = TextFormField(
                              key: ValueKey('catalogSearchField-${mode.name}'),
                              initialValue: viewModel.searchQuery,
                              onChanged: viewModel.updateSearch,
                              decoration: InputDecoration(
                                hintText: mode == BusinessMode.food
                                    ? 'Search menu'
                                    : mode == BusinessMode.retail
                                    ? 'Search products'
                                    : 'Search services',
                                prefixIcon: const Icon(Icons.search, size: 18),
                                contentPadding: const EdgeInsets.symmetric(
                                  horizontal: 12,
                                  vertical: 12,
                                ),
                              ),
                            );
                            return constraints.maxWidth < 530
                                ? Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      heading,
                                      const SizedBox(height: 14),
                                      search,
                                    ],
                                  )
                                : Row(
                                    children: [
                                      Expanded(child: heading),
                                      const SizedBox(width: 18),
                                      SizedBox(width: 240, child: search),
                                    ],
                                  );
                          },
                        ),
                        const SizedBox(height: 16),
                        if (mode == BusinessMode.food) ...[
                          Container(
                            width: double.infinity,
                            padding: const EdgeInsets.symmetric(
                              horizontal: 14,
                              vertical: 8,
                            ),
                            decoration: BoxDecoration(
                              color: UniversalColors.orangeSoft,
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Row(
                              children: [
                                const Icon(
                                  Icons.shopping_bag_outlined,
                                  size: 17,
                                  color: UniversalColors.orange,
                                ),
                                const SizedBox(width: 10),
                                Expanded(
                                  child: Text(
                                    '${viewModel.orderType?.label ?? 'Take-away'}${viewModel.tableNumber.isEmpty ? '' : ' · Table ${viewModel.tableNumber}'}',
                                    style: const TextStyle(
                                      color: UniversalColors.orangeDark,
                                      fontWeight: FontWeight.w700,
                                      fontSize: 14,
                                    ),
                                  ),
                                ),
                                TextButton(
                                  onPressed: viewModel.editOrderType,
                                  child: const Text('Edit order type'),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 16),
                        ],
                        Text(
                          viewModel.selectedCategory == 'All'
                              ? (mode == BusinessMode.services
                                    ? 'All services'
                                    : 'All items')
                              : viewModel.selectedCategory,
                          style: const TextStyle(
                            fontWeight: FontWeight.w800,
                            color: UniversalColors.ink,
                          ),
                        ),
                        const SizedBox(height: 10),
                      ],
                    ),
                  ),
                  _ProductGrid(viewModel: viewModel, mode: mode),
                  if (!pinOrder) SliverToBoxAdapter(child: orderBar),
                ],
              ),
            ),
            if (pinOrder) orderBar,
          ],
        );
      },
    );
  }
}

class _CategoryRail extends StatelessWidget {
  const _CategoryRail({required this.viewModel, this.horizontal = false});
  final UniversalKioskViewModel viewModel;
  final bool horizontal;

  @override
  Widget build(BuildContext context) {
    final tiles = [
      for (final category in viewModel.categories)
        Padding(
          padding: EdgeInsets.only(
            bottom: horizontal ? 0 : 3,
            right: horizontal ? 8 : 0,
          ),
          child: Material(
            color: viewModel.selectedCategory == category
                ? UniversalColors.orangeSoft
                : Colors.transparent,
            borderRadius: BorderRadius.circular(9),
            child: InkWell(
              key: ValueKey('category-$category'),
              onTap: () => viewModel.chooseCategory(category),
              borderRadius: BorderRadius.circular(9),
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 14,
                ),
                child: Row(
                  mainAxisSize: horizontal
                      ? MainAxisSize.min
                      : MainAxisSize.max,
                  children: [
                    Icon(
                      _categoryIcon(category, viewModel.activeMode),
                      size: 18,
                      color: viewModel.selectedCategory == category
                          ? UniversalColors.orangeDark
                          : UniversalColors.muted,
                    ),
                    const SizedBox(width: 10),
                    Flexible(
                      fit: FlexFit.loose,
                      child: Text(
                        category == 'All'
                            ? viewModel.activeMode == BusinessMode.services
                                  ? 'All services'
                                  : 'All items'
                            : category,
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: viewModel.selectedCategory == category
                              ? FontWeight.w800
                              : FontWeight.w600,
                          color: viewModel.selectedCategory == category
                              ? UniversalColors.orangeDark
                              : UniversalColors.ink,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
    ];
    if (horizontal) {
      return SizedBox(
        height: 28 + MediaQuery.textScalerOf(context).scale(24),
        child: ListView(scrollDirection: Axis.horizontal, children: tiles),
      );
    }
    return _Panel(
      padding: const EdgeInsets.all(10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Padding(
            padding: EdgeInsets.fromLTRB(10, 6, 10, 12),
            child: Text(
              'Categories',
              style: TextStyle(fontSize: 14, fontWeight: FontWeight.w800),
            ),
          ),
          ...tiles,
        ],
      ),
    );
  }
}

class _ProductGrid extends StatelessWidget {
  const _ProductGrid({required this.viewModel, required this.mode});
  final UniversalKioskViewModel viewModel;
  final BusinessMode mode;

  @override
  Widget build(BuildContext context) {
    if (viewModel.isLoading) {
      return const SliverFillRemaining(
        hasScrollBody: false,
        child: Center(child: CircularProgressIndicator()),
      );
    }
    if (viewModel.visibleProducts.isEmpty) {
      return const SliverFillRemaining(
        hasScrollBody: false,
        child: Center(
          child: Text(
            'No matches in this category. Try another category or search.',
            textAlign: TextAlign.center,
          ),
        ),
      );
    }
    return SliverLayoutBuilder(
      builder: (context, constraints) {
        final viewport = MediaQuery.sizeOf(context).width;
        final preferred = viewport > 1160
            ? 4
            : viewport > 900
            ? 3
            : 2;
        final scaled = MediaQuery.textScalerOf(context).scale(17) / 17;
        final minimumWidth = 168 * scaled.clamp(1, 1.4);
        final fit = ((constraints.crossAxisExtent + 14) / (minimumWidth + 14))
            .floor()
            .clamp(1, 4);
        final count = preferred.clamp(1, fit);
        final width = (constraints.crossAxisExtent - (count - 1) * 14) / count;
        return SliverPadding(
          padding: const EdgeInsets.only(bottom: 8),
          sliver: SliverGrid(
            key: const Key('productCatalogGrid'),
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: count,
              mainAxisExtent: width + 26 + 148 * scaled,
              crossAxisSpacing: 14,
              mainAxisSpacing: 14,
            ),
            delegate: SliverChildBuilderDelegate((context, index) {
              final product = viewModel.visibleProducts[index];
              return _ProductCard(
                product: product,
                onTap: () => viewModel.selectProduct(product),
              );
            }, childCount: viewModel.visibleProducts.length),
          ),
        );
      },
    );
  }
}

class _ProductCard extends StatelessWidget {
  const _ProductCard({required this.product, required this.onTap});
  final UniversalProduct product;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) => Material(
    color: Colors.white,
    clipBehavior: Clip.antiAlias,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(17),
      side: const BorderSide(color: UniversalColors.line),
    ),
    child: InkWell(
      key: Key('product-${product.id}'),
      onTap: onTap,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          AspectRatio(aspectRatio: 1, child: _ProductArtwork(product: product)),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(13),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    product.name,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 17,
                      height: 1.2,
                      fontWeight: FontWeight.w800,
                      color: UniversalColors.ink,
                    ),
                  ),
                  const SizedBox(height: 5),
                  Expanded(
                    child: Text(
                      product.description,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 14,
                        height: 1.35,
                        color: UniversalColors.muted,
                      ),
                    ),
                  ),
                  Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              formatMoney(product.priceMinor),
                              style: const TextStyle(
                                fontWeight: FontWeight.w800,
                                fontVariations: [FontVariation('wght', 780)],
                                color: UniversalColors.orangeDark,
                                fontSize: 16,
                                fontFeatures: UniversalType.figures,
                              ),
                            ),
                            if (product.durationMinutes != null)
                              Text(
                                '${product.durationMinutes} min',
                                style: const TextStyle(
                                  fontSize: 14,
                                  color: UniversalColors.muted,
                                ),
                              ),
                          ],
                        ),
                      ),
                      IconButton(
                        onPressed: onTap,
                        tooltip: 'Customize ${product.name}',
                        style: IconButton.styleFrom(
                          backgroundColor: UniversalColors.orangeSoft,
                          foregroundColor: UniversalColors.orangeDark,
                        ),
                        icon: const Icon(Icons.add, size: 20),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    ),
  );
}

class _ProductArtwork extends StatelessWidget {
  const _ProductArtwork({required this.product});
  final UniversalProduct product;

  @override
  Widget build(BuildContext context) {
    if (product.imageAsset != null) {
      return Image.asset(
        product.imageAsset!,
        fit: BoxFit.cover,
        errorBuilder: (_, _, _) => _fallback(),
      );
    }
    return _fallback();
  }

  Widget _fallback() => Container(
    color: switch (product.mode) {
      BusinessMode.food => UniversalColors.foodSurface,
      BusinessMode.retail => UniversalColors.retailSurface,
      BusinessMode.services => UniversalColors.servicesSurface,
    },
    alignment: Alignment.center,
    child: Icon(
      _categoryIcon(product.category, product.mode),
      size: 54,
      color: switch (product.mode) {
        BusinessMode.food => UniversalColors.foodIcon,
        BusinessMode.retail => UniversalColors.retailIcon,
        BusinessMode.services => UniversalColors.servicesIcon,
      },
    ),
  );
}

class _ProductDetailScreen extends StatefulWidget {
  const _ProductDetailScreen({required this.viewModel});

  final UniversalKioskViewModel viewModel;

  @override
  State<_ProductDetailScreen> createState() => _ProductDetailScreenState();
}

class _ProductDetailScreenState extends State<_ProductDetailScreen> {
  int _quantity = 1;
  String _selection = 'Original';
  final Set<String> _selectedAddOns = {};
  late final TextEditingController _remark;

  @override
  void initState() {
    super.initState();
    final product = widget.viewModel.selectedProduct;
    final editing = widget.viewModel.editingLine;
    _quantity = editing?.quantity ?? 1;
    _selection =
        editing?.variant?.name ??
        (product?.variants.isNotEmpty == true
            ? product!.variants.first.name
            : 'Standard');
    _selectedAddOns.addAll(editing?.addOns.map((option) => option.name) ?? []);
    _remark = TextEditingController(text: editing?.remark ?? '');
  }

  @override
  void dispose() {
    _remark.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final product = widget.viewModel.selectedProduct;
    if (product == null) return const SizedBox.shrink();
    final selectedVariant = product.variants
        .where((option) => option.name == _selection)
        .firstOrNull;
    final selectedAddOns = product.addOns
        .where((option) => _selectedAddOns.contains(option.name))
        .toList();
    final detailTotal =
        (product.priceMinor +
            (selectedVariant?.surchargeMinor ?? 0) +
            selectedAddOns.fold<int>(
              0,
              (sum, option) => sum + option.surchargeMinor,
            )) *
        _quantity;
    return _CenteredFlow(
      maxWidth: 840,
      child: SingleChildScrollView(
        child: _Panel(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _Breadcrumb(
                label: product.mode == BusinessMode.food
                    ? 'Food menu'
                    : 'Retail catalog',
              ),
              const SizedBox(height: 18),
              LayoutBuilder(
                builder: (context, constraints) {
                  final split = constraints.maxWidth > 620;
                  final visual = SizedBox(
                    height: split ? 275 : 190,
                    child: _ProductArtwork(product: product),
                  );
                  final details = _ProductDetails(
                    product: product,
                    customizable:
                        product.variants.isNotEmpty ||
                        product.addOns.isNotEmpty,
                    selection: _selection,
                    quantity: _quantity,
                    variants: product.variants,
                    addOns: product.addOns,
                    selectedAddOns: _selectedAddOns,
                    remarkController: _remark,
                    totalMinor: detailTotal,
                    onSelection: (value) => setState(() => _selection = value),
                    onToggleAddOn: (option, selected) => setState(() {
                      if (selected) {
                        _selectedAddOns.add(option.name);
                      } else {
                        _selectedAddOns.remove(option.name);
                      }
                    }),
                    onQuantity: (value) => setState(() => _quantity = value),
                    onAdd: () => widget.viewModel.addSelectedProduct(
                      quantity: _quantity,
                      optionLabel: _selection,
                      variant: selectedVariant,
                      addOns: selectedAddOns,
                      remark: _remark.text,
                    ),
                    onBack: widget.viewModel.goBack,
                  );
                  return split
                      ? Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Expanded(child: visual),
                            const SizedBox(width: 28),
                            Expanded(flex: 2, child: details),
                          ],
                        )
                      : Column(
                          children: [
                            visual,
                            const SizedBox(height: 24),
                            details,
                          ],
                        );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ProductDetails extends StatelessWidget {
  const _ProductDetails({
    required this.product,
    required this.customizable,
    required this.selection,
    required this.quantity,
    required this.variants,
    required this.addOns,
    required this.selectedAddOns,
    required this.remarkController,
    required this.totalMinor,
    required this.onSelection,
    required this.onToggleAddOn,
    required this.onQuantity,
    required this.onAdd,
    required this.onBack,
  });

  final UniversalProduct product;
  final bool customizable;
  final String selection;
  final int quantity;
  final List<KioskOption> variants;
  final List<KioskOption> addOns;
  final Set<String> selectedAddOns;
  final TextEditingController remarkController;
  final int totalMinor;
  final ValueChanged<String> onSelection;
  final void Function(KioskOption option, bool selected) onToggleAddOn;
  final ValueChanged<int> onQuantity;
  final VoidCallback onAdd;
  final VoidCallback onBack;

  @override
  Widget build(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Text(
        product.category.toUpperCase(),
        style: const TextStyle(
          color: UniversalColors.orange,
          fontSize: 12,
          fontWeight: FontWeight.w900,
          letterSpacing: .8,
        ),
      ),
      const SizedBox(height: 7),
      Text(
        product.name,
        style: Theme.of(context).textTheme.headlineSmall?.copyWith(
          fontSize: UniversalLayout.of(context).detailHeadingSize,
        ),
      ),
      const SizedBox(height: 8),
      Text(
        product.description,
        style: const TextStyle(color: UniversalColors.muted, height: 1.45),
      ),
      const SizedBox(height: 15),
      Text(
        formatMoney(product.priceMinor),
        style: UniversalType.price.copyWith(fontSize: 21),
      ),
      if (customizable) ...[
        const SizedBox(height: 22),
        if (variants.isNotEmpty) ...[
          const Text(
            'Choose an option',
            style: TextStyle(fontWeight: FontWeight.w900),
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              for (final option in variants)
                ChoiceChip(
                  label: Text(
                    option.surchargeMinor == 0
                        ? option.name
                        : '${option.name} (+${formatMoney(option.surchargeMinor)})',
                  ),
                  selected: selection == option.name,
                  onSelected: (_) => onSelection(option.name),
                ),
            ],
          ),
        ],
        if (addOns.isNotEmpty) ...[
          const SizedBox(height: 18),
          const Text('Add-ons', style: TextStyle(fontWeight: FontWeight.w900)),
          const SizedBox(height: 7),
          for (final option in addOns)
            CheckboxListTile(
              contentPadding: EdgeInsets.zero,
              dense: true,
              value: selectedAddOns.contains(option.name),
              activeColor: UniversalColors.orange,
              onChanged: (selected) => onToggleAddOn(option, selected ?? false),
              title: Text(option.name, style: const TextStyle(fontSize: 16)),
              subtitle: option.surchargeMinor == 0
                  ? null
                  : Text('+ ${formatMoney(option.surchargeMinor)}'),
            ),
        ],
      ],
      const SizedBox(height: 18),
      TextField(
        controller: remarkController,
        maxLines: 2,
        textInputAction: TextInputAction.done,
        decoration: const InputDecoration(
          labelText: 'Remarks (optional)',
          hintText: 'e.g. No ice, gift message',
          prefixIcon: Icon(Icons.edit_note_outlined),
        ),
      ),
      const SizedBox(height: 22),
      Row(
        children: [
          const Text('Quantity', style: TextStyle(fontWeight: FontWeight.w900)),
          const Spacer(),
          _QuantityStepper(quantity: quantity, onChanged: onQuantity),
        ],
      ),
      const SizedBox(height: 24),
      LayoutBuilder(
        builder: (context, constraints) => constraints.maxWidth < 350
            ? Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  SecondaryActionButton(
                    label: 'Back',
                    onPressed: onBack,
                    icon: Icons.arrow_back,
                  ),
                  const SizedBox(height: 10),
                  PrimaryActionButton(
                    label: 'Add to order · ${formatMoney(totalMinor)}',
                    onPressed: onAdd,
                    expanded: true,
                  ),
                ],
              )
            : Row(
                children: [
                  SecondaryActionButton(
                    label: 'Back',
                    onPressed: onBack,
                    icon: Icons.arrow_back,
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: PrimaryActionButton(
                      label: 'Add to order · ${formatMoney(totalMinor)}',
                      onPressed: onAdd,
                      expanded: true,
                    ),
                  ),
                ],
              ),
      ),
    ],
  );
}

class _QuantityStepper extends StatelessWidget {
  const _QuantityStepper({required this.quantity, required this.onChanged});

  final int quantity;
  final ValueChanged<int> onChanged;

  @override
  Widget build(BuildContext context) => Container(
    decoration: BoxDecoration(
      border: Border.all(color: UniversalColors.line),
      borderRadius: BorderRadius.circular(9),
    ),
    child: Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        IconButton(
          onPressed: quantity > 1 ? () => onChanged(quantity - 1) : null,
          icon: const Icon(Icons.remove, size: 18),
        ),
        SizedBox(
          width: 25,
          child: Text(
            '$quantity',
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontWeight: FontWeight.w800,
              fontFeatures: UniversalType.figures,
            ),
          ),
        ),
        IconButton(
          onPressed: () => onChanged(quantity + 1),
          icon: const Icon(Icons.add, size: 18, color: UniversalColors.orange),
        ),
      ],
    ),
  );
}

String _lineDetails(CartLine line) => [
  if (line.variant != null)
    '${line.variant!.name}${line.variant!.surchargeMinor > 0 ? ' (+${formatMoney(line.variant!.surchargeMinor)})' : ''}',
  for (final option in line.addOns)
    'Add-on: ${option.name}${option.surchargeMinor > 0 ? ' (+${formatMoney(option.surchargeMinor)})' : ''}',
  if (line.isBooking)
    '${line.appointmentDate} · ${UniversalKioskViewModel.timeLabel(line.appointmentTime!)} · ${line.product.durationMinutes} min',
  if (!line.isBooking) 'Quantity: ${line.quantity}',
  if (line.remark.isNotEmpty) 'Remarks: ${line.remark}',
].join('\n');

class _OrderSummaryScreen extends StatelessWidget {
  const _OrderSummaryScreen({required this.viewModel});
  final UniversalKioskViewModel viewModel;

  @override
  Widget build(BuildContext context) => _CenteredFlow(
    maxWidth: 820,
    child: SingleChildScrollView(
      child: _Panel(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SectionHeading(
              title: viewModel.hasBooking ? 'Booking summary' : 'Order summary',
              subtitle: 'Review your selections before continuing.',
            ),
            const SizedBox(height: 24),
            if (viewModel.tableNumber.isNotEmpty)
              Padding(
                padding: const EdgeInsets.only(bottom: 14),
                child: Text(
                  'Dine-in · Table ${viewModel.tableNumber}',
                  style: const TextStyle(
                    color: UniversalColors.orange,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            if (viewModel.cart.isEmpty)
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 24),
                child: Text(
                  'Your selection is empty. Continue browsing to add an item.',
                ),
              )
            else ...[
              for (final line in viewModel.cart) ...[
                LayoutBuilder(
                  builder: (context, constraints) {
                    final narrow = constraints.maxWidth < 410;
                    final details = Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          line.product.name,
                          style: const TextStyle(
                            fontWeight: FontWeight.w800,
                            color: UniversalColors.ink,
                          ),
                        ),
                        const SizedBox(height: 5),
                        Text(
                          _lineDetails(line),
                          style: const TextStyle(
                            fontSize: 14,
                            color: UniversalColors.muted,
                            height: 1.5,
                          ),
                        ),
                      ],
                    );
                    final actions = Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(
                          formatMoney(line.product.priceMinor),
                          style: const TextStyle(
                            fontWeight: FontWeight.w800,
                            fontFeatures: UniversalType.figures,
                          ),
                        ),
                        if (line.quantity > 1)
                          const Text(
                            'each',
                            style: TextStyle(
                              fontSize: 12,
                              color: UniversalColors.muted,
                            ),
                          ),
                        Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            IconButton(
                              tooltip: 'Edit ${line.product.name}',
                              onPressed: () => viewModel.editLine(line),
                              icon: const Icon(Icons.edit_outlined, size: 18),
                            ),
                            IconButton(
                              tooltip: 'Remove ${line.product.name}',
                              onPressed: () => viewModel.removeLine(line),
                              icon: const Icon(Icons.delete_outline, size: 18),
                            ),
                          ],
                        ),
                      ],
                    );
                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            ClipRRect(
                              borderRadius: BorderRadius.circular(8),
                              child: SizedBox(
                                width: 64,
                                height: 64,
                                child: _ProductArtwork(product: line.product),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(child: details),
                            if (!narrow) ...[
                              const SizedBox(width: 14),
                              actions,
                            ],
                          ],
                        ),
                        if (narrow)
                          Align(
                            alignment: Alignment.centerRight,
                            child: actions,
                          ),
                      ],
                    );
                  },
                ),
                const Divider(height: 26),
              ],
              _PriceBreakdown(viewModel: viewModel),
            ],
            const SizedBox(height: 20),
            Wrap(
              alignment: WrapAlignment.end,
              spacing: 10,
              runSpacing: 10,
              children: [
                SecondaryActionButton(
                  label: 'Continue browsing',
                  onPressed: viewModel.continueBrowsing,
                ),
                PrimaryActionButton(
                  label: 'Proceed to payment',
                  icon: Icons.point_of_sale_outlined,
                  onPressed: viewModel.cart.isEmpty
                      ? null
                      : viewModel.startPayment,
                ),
              ],
            ),
          ],
        ),
      ),
    ),
  );
}

class _PriceBreakdown extends StatelessWidget {
  const _PriceBreakdown({required this.viewModel});
  final UniversalKioskViewModel viewModel;
  @override
  Widget build(BuildContext context) => Column(
    children: [
      _SummaryDetailRow(
        label: 'Base subtotal',
        value: formatMoney(viewModel.baseSubtotalMinor),
      ),
      if (viewModel.variantTotalMinor > 0)
        _SummaryDetailRow(
          label: 'Variant charges',
          value: formatMoney(viewModel.variantTotalMinor),
        ),
      if (viewModel.addOnTotalMinor > 0)
        _SummaryDetailRow(
          label: 'Add-ons',
          value: formatMoney(viewModel.addOnTotalMinor),
        ),
      const Divider(height: 22),
      _SummaryDetailRow(
        label: 'Total',
        value: formatMoney(viewModel.totalMinor),
        emphasized: true,
      ),
    ],
  );
}

class _PaymentScreen extends StatelessWidget {
  const _PaymentScreen({required this.viewModel});
  final UniversalKioskViewModel viewModel;

  @override
  Widget build(BuildContext context) => _CenteredFlow(
    maxWidth: 820,
    child: SingleChildScrollView(
      child: _Panel(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SectionHeading(
              title: 'Payment method',
              subtitle: 'Confirm your selection, then pay at the counter.',
            ),
            const SizedBox(height: 24),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                border: Border.all(color: UniversalColors.counterBorder),
                color: UniversalColors.counterSurface,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                children: [
                  const Icon(
                    Icons.point_of_sale_outlined,
                    color: UniversalColors.orange,
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Pay at Counter',
                          style: TextStyle(
                            fontWeight: FontWeight.w800,
                            color: UniversalColors.ink,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Show your ${viewModel.hasBooking ? 'booking' : 'order'} number to the cashier.',
                          style: const TextStyle(
                            fontSize: 14,
                            color: UniversalColors.muted,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 10),
                  const Icon(
                    Icons.check_circle,
                    color: UniversalColors.orange,
                    size: 22,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 22),
            _PriceBreakdown(viewModel: viewModel),
            const SizedBox(height: 24),
            Wrap(
              alignment: WrapAlignment.end,
              spacing: 10,
              runSpacing: 10,
              children: [
                SecondaryActionButton(
                  label: 'Back to review',
                  onPressed: viewModel.openSummary,
                ),
                PrimaryActionButton(
                  key: const Key('confirmPayAtCounterButton'),
                  label: viewModel.hasBooking
                      ? 'Confirm booking'
                      : 'Confirm order',
                  icon: Icons.check,
                  onPressed: viewModel.completePayment,
                ),
              ],
            ),
          ],
        ),
      ),
    ),
  );
}

class _SummaryDetailRow extends StatelessWidget {
  const _SummaryDetailRow({
    required this.label,
    required this.value,
    this.emphasized = false,
  });
  final String label;
  final String value;
  final bool emphasized;
  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.symmetric(vertical: 5),
    child: Row(
      children: [
        Expanded(
          child: Text(
            label,
            style: TextStyle(
              color: emphasized ? UniversalColors.ink : UniversalColors.muted,
              fontWeight: emphasized ? FontWeight.w800 : FontWeight.w500,
            ),
          ),
        ),
        const SizedBox(width: 16),
        Flexible(
          fit: FlexFit.tight,
          child: Text(
            value,
            textAlign: TextAlign.right,
            style: TextStyle(
              color: UniversalColors.ink,
              fontWeight: emphasized ? FontWeight.w900 : FontWeight.w600,
              fontSize: emphasized ? 20 : 16,
              fontFeatures: UniversalType.figures,
            ),
          ),
        ),
      ],
    ),
  );
}

class _ServiceBookingScreen extends StatefulWidget {
  const _ServiceBookingScreen({required this.viewModel});

  final UniversalKioskViewModel viewModel;

  @override
  State<_ServiceBookingScreen> createState() => _ServiceBookingScreenState();
}

class _ServiceBookingScreenState extends State<_ServiceBookingScreen> {
  final Set<String> _selectedAddOns = {};
  String? _variantName;
  late final TextEditingController _remark;

  @override
  void initState() {
    super.initState();
    final editing = widget.viewModel.editingLine;
    _variantName = editing?.variant?.name;
    _selectedAddOns.addAll(editing?.addOns.map((option) => option.name) ?? []);
    _remark = TextEditingController(text: editing?.remark ?? '');
  }

  @override
  void dispose() {
    _remark.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final service = widget.viewModel.selectedProduct;
    if (service == null) return const SizedBox.shrink();
    final variant = service.variants
        .where((option) => option.name == _variantName)
        .firstOrNull;
    final addOns = service.addOns
        .where((option) => _selectedAddOns.contains(option.name))
        .toList();
    return _CenteredFlow(
      maxWidth: 850,
      child: SingleChildScrollView(
        child: _Panel(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const _Breadcrumb(label: 'Services catalog'),
              const SizedBox(height: 20),
              Row(
                children: [
                  SizedBox(
                    width: 94,
                    height: 94,
                    child: _ProductArtwork(product: service),
                  ),
                  const SizedBox(width: 18),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          service.name,
                          style: UniversalType.heading.copyWith(
                            fontSize: UniversalLayout.of(
                              context,
                            ).detailHeadingSize,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          service.description,
                          style: const TextStyle(color: UniversalColors.muted),
                        ),
                        const SizedBox(height: 7),
                        Text(
                          formatMoney(service.priceMinor),
                          style: UniversalType.price,
                        ),
                        if (service.durationMinutes != null)
                          Text(
                            '${service.durationMinutes} minutes',
                            style: const TextStyle(
                              color: UniversalColors.muted,
                              fontSize: 14,
                            ),
                          ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 28),
              const Text(
                'Choose a date',
                style: TextStyle(fontWeight: FontWeight.w900),
              ),
              const SizedBox(height: 10),
              SecondaryActionButton(
                key: const Key('bookingDatePicker'),
                label: widget.viewModel.bookingDate,
                icon: Icons.calendar_today_outlined,
                onPressed: () async {
                  final today = UniversalKioskViewModel.malaysiaToday;
                  final date = await showDatePicker(
                    context: context,
                    initialDate:
                        DateTime.tryParse(widget.viewModel.bookingDate) ??
                        today,
                    firstDate: today,
                    lastDate: DateTime(today.year + 2, today.month, today.day),
                  );
                  if (date != null && mounted) {
                    widget.viewModel.chooseBookingDate(
                      UniversalKioskViewModel.dateValue(date),
                    );
                  }
                },
              ),
              const SizedBox(height: 22),
              const Text(
                'Choose a time (Malaysia)',
                style: TextStyle(fontWeight: FontWeight.w900),
              ),
              const SizedBox(height: 10),
              if (widget.viewModel.appointmentTimes.isEmpty)
                const Padding(
                  padding: EdgeInsets.symmetric(vertical: 12),
                  child: Text(
                    'No appointment times are available. Please ask at the counter.',
                    style: TextStyle(color: UniversalColors.muted),
                  ),
                )
              else
                Wrap(
                  spacing: 9,
                  runSpacing: 9,
                  children: [
                    for (final time in widget.viewModel.appointmentTimes)
                      ChoiceChip(
                        key: ValueKey('booking-time-$time'),
                        label: Text(UniversalKioskViewModel.timeLabel(time)),
                        selected: widget.viewModel.bookingTime == time,
                        onSelected: (_) =>
                            widget.viewModel.chooseBookingTime(time),
                      ),
                  ],
                ),
              if (service.variants.isNotEmpty) ...[
                const SizedBox(height: 22),
                const Text(
                  'Service options',
                  style: TextStyle(fontWeight: FontWeight.w900),
                ),
                const SizedBox(height: 10),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    for (final option in service.variants)
                      ChoiceChip(
                        label: Text(
                          option.surchargeMinor == 0
                              ? option.name
                              : '${option.name} (+${formatMoney(option.surchargeMinor)})',
                        ),
                        selected: _variantName == option.name,
                        onSelected: (_) =>
                            setState(() => _variantName = option.name),
                      ),
                  ],
                ),
              ],
              if (service.addOns.isNotEmpty) ...[
                const SizedBox(height: 18),
                const Text(
                  'Add-ons',
                  style: TextStyle(fontWeight: FontWeight.w900),
                ),
                for (final option in service.addOns)
                  CheckboxListTile(
                    contentPadding: EdgeInsets.zero,
                    dense: true,
                    value: _selectedAddOns.contains(option.name),
                    activeColor: UniversalColors.orange,
                    onChanged: (selected) => setState(() {
                      if (selected ?? false) {
                        _selectedAddOns.add(option.name);
                      } else {
                        _selectedAddOns.remove(option.name);
                      }
                    }),
                    title: Text(option.name),
                    subtitle: option.surchargeMinor == 0
                        ? null
                        : Text('+ ${formatMoney(option.surchargeMinor)}'),
                  ),
              ],
              const SizedBox(height: 16),
              TextField(
                controller: _remark,
                maxLines: 2,
                decoration: const InputDecoration(
                  labelText: 'Remarks (optional)',
                  prefixIcon: Icon(Icons.edit_note_outlined),
                ),
              ),
              const SizedBox(height: 30),
              Wrap(
                alignment: WrapAlignment.end,
                spacing: 10,
                runSpacing: 10,
                children: [
                  SecondaryActionButton(
                    label: 'Back',
                    onPressed: widget.viewModel.goBack,
                    icon: Icons.arrow_back,
                  ),
                  const SizedBox(width: 10),
                  PrimaryActionButton(
                    label: widget.viewModel.bookingTime.isEmpty
                        ? 'Choose a time to continue'
                        : 'Review booking',
                    onPressed: widget.viewModel.bookingTime.isEmpty
                        ? null
                        : () => widget.viewModel.confirmBooking(
                            variant: variant,
                            addOns: addOns,
                            remark: _remark.text,
                          ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _SuccessScreen extends StatelessWidget {
  const _SuccessScreen({required this.viewModel});

  final UniversalKioskViewModel viewModel;

  @override
  Widget build(BuildContext context) => _CenteredFlow(
    maxWidth: 640,
    child: SingleChildScrollView(
      child: _Panel(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 88,
              height: 88,
              decoration: const BoxDecoration(
                color: UniversalColors.greenSoft,
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.check,
                color: UniversalColors.success,
                size: 47,
              ),
            ),
            const SizedBox(height: 22),
            Text(
              viewModel.hasBooking ? 'Booking received!' : 'Order received!',
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                fontSize: UniversalLayout.of(context).headingSize,
              ),
            ),
            const SizedBox(height: 7),
            const Text(
              'Thank you for ordering with us.',
              style: TextStyle(color: UniversalColors.muted),
            ),
            const SizedBox(height: 25),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 13, vertical: 20),
              decoration: BoxDecoration(
                color: UniversalColors.orangeSoft,
                borderRadius: BorderRadius.circular(14),
              ),
              child: Column(
                children: [
                  Text(
                    viewModel.hasBooking
                        ? 'YOUR BOOKING REFERENCE'
                        : 'YOUR ORDER REFERENCE',
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w900,
                      color: UniversalColors.muted,
                      letterSpacing: .8,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    viewModel.reference ??
                        'ORD-${viewModel.orderNumber.toString().padLeft(4, '0')}',
                    style: const TextStyle(
                      color: UniversalColors.orangeDark,
                      fontWeight: FontWeight.w800,
                      fontSize: 36,
                      fontFeatures: UniversalType.figures,
                    ),
                  ),
                  const SizedBox(height: 4),
                  const Text(
                    'Payment pending · Please proceed to the cashier.',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 14,
                      color: UniversalColors.orangeDark,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            if (viewModel.receiptEnabled) ...[
              SecondaryActionButton(
                label: 'Print receipt',
                icon: Icons.receipt_long_outlined,
                onPressed: () => showDialog<void>(
                  context: context,
                  barrierColor: UniversalColors.dialogBarrier,
                  builder: (context) =>
                      _ReceiptPreviewDialog(viewModel: viewModel),
                ),
              ),
              const SizedBox(height: 10),
            ],
            PrimaryActionButton(
              key: const Key('startNewUniversalOrderButton'),
              label: 'Back to home',
              onPressed: viewModel.startNewOrder,
              expanded: true,
            ),
          ],
        ),
      ),
    ),
  );
}

class _ReceiptPreviewDialog extends StatelessWidget {
  const _ReceiptPreviewDialog({required this.viewModel});

  final UniversalKioskViewModel viewModel;

  @override
  Widget build(BuildContext context) => Dialog(
    child: ConstrainedBox(
      constraints: const BoxConstraints(maxWidth: 436),
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              viewModel.receiptHeader.isEmpty
                  ? viewModel.businessName
                  : viewModel.receiptHeader,
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w900),
            ),
            const SizedBox(height: 4),
            Text(
              viewModel.activeMode?.label ?? '',
              style: const TextStyle(color: UniversalColors.muted),
            ),
            const Divider(height: 28),
            Text(
              viewModel.reference ?? '',
              style: const TextStyle(
                fontWeight: FontWeight.w800,
                fontFeatures: UniversalType.figures,
              ),
            ),
            if (viewModel.tableNumber.isNotEmpty)
              Text(
                'Dine-in · Table ${viewModel.tableNumber}',
                style: const TextStyle(
                  fontSize: 14,
                  color: UniversalColors.muted,
                ),
              ),
            for (final line in viewModel.cart) ...[
              const SizedBox(height: 14),
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Text(
                      '${line.quantity} × ${line.product.name}',
                      style: const TextStyle(
                        fontWeight: FontWeight.w800,
                        fontFeatures: UniversalType.figures,
                      ),
                    ),
                  ),
                  Text(
                    formatMoney(line.totalMinor),
                    style: const TextStyle(
                      fontWeight: FontWeight.w800,
                      fontFeatures: UniversalType.figures,
                    ),
                  ),
                ],
              ),
              if (line.details.isNotEmpty)
                Text(
                  line.details,
                  style: const TextStyle(
                    fontSize: 14,
                    color: UniversalColors.muted,
                  ),
                ),
            ],
            const Divider(height: 28),
            _SummaryDetailRow(
              label: 'Total',
              value: formatMoney(viewModel.totalMinor),
              emphasized: true,
            ),
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: UniversalColors.orangeSoft,
                borderRadius: BorderRadius.circular(9),
              ),
              child: const Text(
                'Pay at Counter · Payment pending',
                style: TextStyle(
                  color: UniversalColors.orangeDark,
                  fontSize: 14,
                ),
              ),
            ),
            const SizedBox(height: 5),
            Text(
              viewModel.receiptFooter,
              style: const TextStyle(color: UniversalColors.muted),
            ),
            const SizedBox(height: 22),
            Wrap(
              alignment: WrapAlignment.end,
              spacing: 8,
              runSpacing: 8,
              children: [
                TextButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: const Text('Close'),
                ),
                const SizedBox(width: 8),
                ElevatedButton.icon(
                  onPressed: () {
                    Navigator.of(context).pop();
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text(
                          'Demo print complete. Payment is still pending.',
                        ),
                      ),
                    );
                  },
                  icon: const Icon(Icons.print_outlined),
                  label: const Text('Print'),
                ),
              ],
            ),
          ],
        ),
      ),
    ),
  );
}

class _AdminWelcomeScreen extends StatelessWidget {
  const _AdminWelcomeScreen({required this.viewModel});

  final UniversalKioskViewModel viewModel;

  @override
  Widget build(BuildContext context) => _CenteredFlow(
    maxWidth: 720,
    child: SingleChildScrollView(
      child: _Panel(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 64,
              height: 64,
              decoration: BoxDecoration(
                color: UniversalColors.orangeSoft,
                borderRadius: BorderRadius.circular(18),
              ),
              child: const Icon(
                Icons.settings_suggest_outlined,
                color: UniversalColors.orange,
                size: 34,
              ),
            ),
            const SizedBox(height: 22),
            Text(
              'Set up your kiosk',
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                fontSize: UniversalLayout.of(context).detailHeadingSize,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'Add your business details and choose the experience your customers will use.',
              textAlign: TextAlign.center,
              style: TextStyle(color: UniversalColors.muted, height: 1.45),
            ),
            const SizedBox(height: 28),
            PrimaryActionButton(
              label: 'Get started',
              onPressed: () =>
                  viewModel.openAdminStep(UniversalScreen.adminBusinessInfo),
            ),
          ],
        ),
      ),
    ),
  );
}

class _BusinessInformationScreen extends StatefulWidget {
  const _BusinessInformationScreen({required this.viewModel});

  final UniversalKioskViewModel viewModel;

  @override
  State<_BusinessInformationScreen> createState() =>
      _BusinessInformationScreenState();
}

class _BusinessInformationScreenState
    extends State<_BusinessInformationScreen> {
  final _form = GlobalKey<FormState>();
  late final TextEditingController _name;
  late final TextEditingController _email;
  late final TextEditingController _phone;
  late final TextEditingController _address;

  @override
  void initState() {
    super.initState();
    _name = TextEditingController(text: widget.viewModel.businessName);
    _email = TextEditingController(text: widget.viewModel.companyEmail);
    _phone = TextEditingController(text: widget.viewModel.phone);
    _address = TextEditingController(text: widget.viewModel.businessLocation);
  }

  @override
  void dispose() {
    for (final controller in [_name, _email, _phone, _address]) {
      controller.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => _AdminFrame(
    title: 'Business information',
    subtitle: 'These details identify your kiosk and appear on the receipt.',
    child: Form(
      key: _form,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          LayoutBuilder(
            builder: (context, constraints) {
              final width = constraints.maxWidth >= 560
                  ? (constraints.maxWidth - 16) / 2
                  : constraints.maxWidth;
              return Wrap(
                spacing: 16,
                runSpacing: 16,
                children: [
                  SizedBox(
                    width: width,
                    child: TextFormField(
                      key: const Key('businessNameField'),
                      controller: _name,
                      decoration: const InputDecoration(
                        labelText: 'Business name',
                      ),
                      validator: (value) => (value?.trim().isEmpty ?? true)
                          ? 'Enter a business name.'
                          : null,
                    ),
                  ),
                  SizedBox(
                    width: width,
                    child: TextFormField(
                      key: const Key('companyEmailField'),
                      controller: _email,
                      decoration: const InputDecoration(
                        labelText: 'Company email',
                      ),
                      keyboardType: TextInputType.emailAddress,
                      validator: (value) =>
                          RegExp(
                            r'^[^@\s]+@[^@\s]+\.[^@\s]+$',
                          ).hasMatch(value?.trim() ?? '')
                          ? null
                          : 'Enter a valid email address.',
                    ),
                  ),
                  SizedBox(
                    width: width,
                    child: TextFormField(
                      controller: _phone,
                      decoration: const InputDecoration(
                        labelText: 'Phone number (optional)',
                      ),
                      keyboardType: TextInputType.phone,
                    ),
                  ),
                  SizedBox(
                    width: width,
                    child: TextFormField(
                      controller: _address,
                      decoration: const InputDecoration(
                        labelText: 'Business address (optional)',
                      ),
                    ),
                  ),
                ],
              );
            },
          ),
          const SizedBox(height: 26),
          Wrap(
            alignment: WrapAlignment.end,
            spacing: 10,
            runSpacing: 10,
            children: [
              SecondaryActionButton(
                label: 'Back',
                onPressed: widget.viewModel.goBack,
              ),
              PrimaryActionButton(
                label: 'Continue',
                icon: null,
                onPressed: () {
                  if (!_form.currentState!.validate()) return;
                  widget.viewModel.updateBusinessInformation(
                    name: _name.text,
                    email: _email.text,
                    phone: _phone.text,
                    address: _address.text,
                  );
                },
              ),
            ],
          ),
        ],
      ),
    ),
  );
}

class _BusinessModeScreen extends StatelessWidget {
  const _BusinessModeScreen({required this.viewModel});

  final UniversalKioskViewModel viewModel;

  @override
  Widget build(BuildContext context) => _AdminFrame(
    title: 'Choose a business mode',
    subtitle: 'This decides what customers can do on the kiosk.',
    child: Column(
      children: [
        for (final option in [
          BusinessMode.food,
          BusinessMode.retail,
          BusinessMode.services,
        ])
          Padding(
            padding: const EdgeInsets.only(bottom: 10),
            child: _AdminModeTile(
              mode: option,
              selected: option == viewModel.configuredMode,
              onTap: () => viewModel.setConfiguredMode(option),
            ),
          ),
        const SizedBox(height: 16),
        Wrap(
          alignment: WrapAlignment.end,
          spacing: 10,
          runSpacing: 10,
          children: [
            SecondaryActionButton(
              label: 'Back',
              icon: Icons.arrow_back,
              onPressed: viewModel.goBack,
            ),
            const SizedBox(width: 10),
            PrimaryActionButton(
              label: 'Continue',
              onPressed: viewModel.continueAdminMode,
            ),
          ],
        ),
      ],
    ),
  );
}

class _AdminModeTile extends StatelessWidget {
  const _AdminModeTile({
    required this.mode,
    required this.selected,
    required this.onTap,
  });

  final BusinessMode mode;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final (icon, description, color, surface) = switch (mode) {
      BusinessMode.food => (
        Icons.restaurant_outlined,
        'Menus, dine-in, takeaway and counter payment.',
        UniversalColors.foodIcon,
        UniversalColors.foodSurface,
      ),
      BusinessMode.retail => (
        Icons.shopping_bag_outlined,
        'Product catalogues and counter checkout.',
        UniversalColors.retailIcon,
        UniversalColors.retailSurface,
      ),
      BusinessMode.services => (
        Icons.calendar_month_outlined,
        'Service catalogues and appointment booking.',
        UniversalColors.servicesIcon,
        UniversalColors.servicesSurface,
      ),
    };
    return Material(
      color: selected ? UniversalColors.adminSelectedSurface : Colors.white,
      borderRadius: BorderRadius.circular(12),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            border: Border.all(
              color: selected
                  ? UniversalColors.adminSelectedBorder
                  : UniversalColors.line,
            ),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(
            children: [
              CircleAvatar(
                backgroundColor: surface,
                child: Icon(icon, color: color),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      mode.label,
                      style: const TextStyle(
                        fontWeight: FontWeight.w800,
                        fontFeatures: UniversalType.figures,
                      ),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      description,
                      style: const TextStyle(
                        fontSize: 14,
                        color: UniversalColors.muted,
                      ),
                    ),
                  ],
                ),
              ),
              Icon(
                selected ? Icons.check_circle : Icons.radio_button_unchecked,
                color: selected
                    ? UniversalColors.orange
                    : UniversalColors.muted,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _AdminCatalogScreen extends StatefulWidget {
  const _AdminCatalogScreen({required this.viewModel});
  final UniversalKioskViewModel viewModel;
  @override
  State<_AdminCatalogScreen> createState() => _AdminCatalogScreenState();
}

class _AdminCatalogScreenState extends State<_AdminCatalogScreen> {
  TimeOfDay? _time;

  @override
  Widget build(BuildContext context) {
    final vm = widget.viewModel;
    final mode = vm.configuredMode;
    final entries = vm.catalogForMode(mode);
    final categories = vm.categoriesForMode(mode);
    return _AdminFrame(
      title: 'Set up your catalog',
      subtitle: 'Manage the categories and selections shown on the kiosk.',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              SecondaryActionButton(
                key: const Key('addCategoryButton'),
                label: 'Add category',
                icon: Icons.add,
                onPressed: () => _showCategoryEditor(context, vm),
              ),
              SecondaryActionButton(
                key: const Key('addCatalogItemButton'),
                label: mode == BusinessMode.services
                    ? 'Add service'
                    : 'Add item',
                icon: Icons.add,
                onPressed: categories.isEmpty
                    ? () => _showCategoryEditor(context, vm)
                    : () => _showCatalogEditor(context, vm),
              ),
            ],
          ),
          const SizedBox(height: 14),
          SizedBox(
            height: categories.isEmpty ? 100 : 330,
            child: Scrollbar(
              child: ListView.builder(
                key: const Key('adminCatalogList'),
                primary: false,
                itemCount: categories.isEmpty ? 1 : categories.length,
                itemBuilder: (context, index) {
                  if (categories.isEmpty) {
                    return const Padding(
                      padding: EdgeInsets.all(24),
                      child: Text(
                        'Add a category to start building your catalog.',
                      ),
                    );
                  }
                  final category = categories[index];
                  final items = entries
                      .where((item) => item.category == category)
                      .toList();
                  return Container(
                    margin: const EdgeInsets.only(bottom: 10),
                    clipBehavior: Clip.antiAlias,
                    decoration: BoxDecoration(
                      border: Border.all(color: UniversalColors.line),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Column(
                      children: [
                        Container(
                          color: UniversalColors.canvas,
                          padding: const EdgeInsets.only(left: 12, right: 4),
                          child: Row(
                            children: [
                              Icon(_categoryIcon(category, mode), size: 16),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  category,
                                  style: const TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w800,
                                  ),
                                ),
                              ),
                              IconButton(
                                tooltip: 'Rename $category',
                                onPressed: () => _showCategoryEditor(
                                  context,
                                  vm,
                                  original: category,
                                ),
                                icon: const Icon(Icons.edit_outlined, size: 16),
                              ),
                              IconButton(
                                tooltip: items.isEmpty
                                    ? 'Remove $category'
                                    : 'Remove items before deleting this category',
                                onPressed: items.isEmpty
                                    ? () => vm.removeCategory(category)
                                    : null,
                                icon: const Icon(
                                  Icons.delete_outline,
                                  size: 16,
                                ),
                              ),
                            ],
                          ),
                        ),
                        for (final item in items)
                          Container(
                            padding: const EdgeInsets.only(left: 12, right: 4),
                            decoration: const BoxDecoration(
                              border: Border(
                                top: BorderSide(color: UniversalColors.line),
                              ),
                            ),
                            child: Row(
                              children: [
                                Expanded(
                                  child: Text(
                                    item.name,
                                    style: const TextStyle(
                                      fontSize: 14,
                                      color: UniversalColors.ink,
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Text(
                                  formatMoney(item.priceMinor),
                                  style: const TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                                IconButton(
                                  tooltip: 'Edit ${item.name}',
                                  onPressed: () => _showCatalogEditor(
                                    context,
                                    vm,
                                    item: item,
                                  ),
                                  icon: const Icon(
                                    Icons.edit_outlined,
                                    size: 16,
                                  ),
                                ),
                                IconButton(
                                  tooltip: 'Remove ${item.name}',
                                  onPressed: () =>
                                      _confirmRemoveItem(context, vm, item),
                                  icon: const Icon(
                                    Icons.delete_outline,
                                    size: 16,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        if (items.isEmpty)
                          const Padding(
                            padding: EdgeInsets.all(16),
                            child: Text(
                              'No items in this category yet.',
                              style: TextStyle(
                                fontSize: 14,
                                color: UniversalColors.muted,
                              ),
                            ),
                          ),
                      ],
                    ),
                  );
                },
              ),
            ),
          ),
          if (mode == BusinessMode.services) ...[
            const SizedBox(height: 16),
            _Panel(
              padding: const EdgeInsets.all(14),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Appointment times',
                    style: TextStyle(fontWeight: FontWeight.w800, fontSize: 16),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Set the same booking times for all services and dates. Customers will only see the times you add.',
                    style: TextStyle(
                      fontSize: 14,
                      height: 1.5,
                      color: UniversalColors.muted,
                    ),
                  ),
                  const SizedBox(height: 10),
                  const Text(
                    'Time (Malaysia)',
                    style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700),
                  ),
                  const SizedBox(height: 6),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      SecondaryActionButton(
                        key: const Key('appointmentTimePicker'),
                        label: _time == null
                            ? 'Choose time'
                            : UniversalKioskViewModel.timeLabel(
                                _timeValue(_time!),
                              ),
                        icon: Icons.schedule_outlined,
                        onPressed: () async {
                          final selected = await showTimePicker(
                            context: context,
                            initialTime:
                                _time ?? const TimeOfDay(hour: 10, minute: 0),
                          );
                          if (selected != null && mounted) {
                            setState(() => _time = selected);
                          }
                        },
                      ),
                      SecondaryActionButton(
                        key: const Key('addAppointmentTimeButton'),
                        label: 'Add time',
                        icon: Icons.add,
                        onPressed: _time == null
                            ? null
                            : () {
                                final added = vm.addAppointmentTime(
                                  _timeValue(_time!),
                                );
                                if (!added) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                      content: Text(
                                        'That appointment time is already in the list.',
                                      ),
                                    ),
                                  );
                                }
                                setState(() => _time = null);
                              },
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  if (vm.appointmentTimes.isEmpty)
                    const Text(
                      'No appointment times added.',
                      style: TextStyle(
                        fontSize: 14,
                        color: UniversalColors.muted,
                      ),
                    )
                  else
                    Wrap(
                      spacing: 8,
                      runSpacing: 4,
                      children: [
                        for (final time in vm.appointmentTimes)
                          InputChip(
                            label: Text(
                              UniversalKioskViewModel.timeLabel(time),
                            ),
                            onDeleted: () => vm.removeAppointmentTime(time),
                            deleteButtonTooltipMessage:
                                'Remove ${UniversalKioskViewModel.timeLabel(time)}',
                          ),
                      ],
                    ),
                ],
              ),
            ),
          ],
          const SizedBox(height: 22),
          Wrap(
            alignment: WrapAlignment.end,
            spacing: 10,
            runSpacing: 10,
            children: [
              SecondaryActionButton(label: 'Back', onPressed: vm.goBack),
              PrimaryActionButton(
                label: 'Continue',
                onPressed: vm.continueAdminCatalog,
                icon: null,
              ),
            ],
          ),
        ],
      ),
    );
  }

  String _timeValue(TimeOfDay time) =>
      '${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}';
}

Future<void> _confirmRemoveItem(
  BuildContext context,
  UniversalKioskViewModel vm,
  UniversalProduct item,
) async {
  final remove = await showDialog<bool>(
    context: context,
    builder: (context) => AlertDialog(
      title: const Text('Remove catalog item?'),
      content: Text('Remove ${item.name} from this catalog?'),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context, false),
          child: const Text('Cancel'),
        ),
        TextButton(
          onPressed: () => Navigator.pop(context, true),
          child: const Text('Remove'),
        ),
      ],
    ),
  );
  if (remove == true) vm.removeCatalogItem(item);
}

Future<void> _showCategoryEditor(
  BuildContext context,
  UniversalKioskViewModel vm, {
  String? original,
}) async {
  final controller = TextEditingController(text: original ?? '');
  final form = GlobalKey<FormState>();
  await showDialog<void>(
    context: context,
    builder: (context) => AlertDialog(
      title: Text(original == null ? 'Add category' : 'Rename category'),
      content: Form(
        key: form,
        child: TextFormField(
          key: const Key('categoryNameField'),
          controller: controller,
          autofocus: true,
          decoration: const InputDecoration(labelText: 'Category name'),
          validator: (value) {
            final name = value?.trim() ?? '';
            if (name.isEmpty) return 'Enter a category name.';
            if (name == 'All') return 'Choose another category name.';
            if (vm
                .categoriesForMode(vm.configuredMode)
                .any(
                  (entry) =>
                      entry != original &&
                      entry.toLowerCase() == name.toLowerCase(),
                )) {
              return 'This category already exists.';
            }
            return null;
          },
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: () {
            if (!form.currentState!.validate()) return;
            if (original == null) {
              vm.addCategory(controller.text);
            } else {
              vm.renameCategory(original, controller.text);
            }
            Navigator.pop(context);
          },
          child: const Text('Save'),
        ),
      ],
    ),
  );
  // Dialog fields are disposed after their route animation finishes.
}

Future<void> _showCatalogEditor(
  BuildContext context,
  UniversalKioskViewModel vm, {
  UniversalProduct? item,
}) => showDialog<void>(
  context: context,
  builder: (context) => _CatalogEditorDialog(viewModel: vm, item: item),
);

class _CatalogEditorDialog extends StatefulWidget {
  const _CatalogEditorDialog({required this.viewModel, this.item});
  final UniversalKioskViewModel viewModel;
  final UniversalProduct? item;
  @override
  State<_CatalogEditorDialog> createState() => _CatalogEditorDialogState();
}

class _CatalogEditorDialogState extends State<_CatalogEditorDialog> {
  final _form = GlobalKey<FormState>();
  late final TextEditingController _name;
  late final TextEditingController _description;
  late final TextEditingController _price;
  late final TextEditingController _duration;
  late final TextEditingController _variants;
  late final TextEditingController _addOns;
  late String _category;

  @override
  void initState() {
    super.initState();
    final item = widget.item;
    _name = TextEditingController(text: item?.name ?? '');
    _description = TextEditingController(text: item?.description ?? '');
    _price = TextEditingController(
      text: item == null ? '' : (item.priceMinor / 100).toStringAsFixed(2),
    );
    _duration = TextEditingController(text: '${item?.durationMinutes ?? 30}');
    _variants = TextEditingController(text: _optionText(item?.variants ?? []));
    _addOns = TextEditingController(text: _optionText(item?.addOns ?? []));
    _category =
        item?.category ??
        widget.viewModel
            .categoriesForMode(widget.viewModel.configuredMode)
            .first;
  }

  String _optionText(List<KioskOption> options) => options
      .map(
        (option) =>
            '${option.name} | ${(option.surchargeMinor / 100).toStringAsFixed(2)}',
      )
      .join('\n');

  @override
  void dispose() {
    for (final controller in [
      _name,
      _description,
      _price,
      _duration,
      _variants,
      _addOns,
    ]) {
      controller.dispose();
    }
    super.dispose();
  }

  int? _money(String value) {
    final clean = value.trim();
    if (!RegExp(r'^\d+(\.\d{1,2})?$').hasMatch(clean)) return null;
    final parts = clean.split('.');
    return int.parse(parts[0]) * 100 +
        (parts.length == 1 ? 0 : int.parse(parts[1].padRight(2, '0')));
  }

  List<KioskOption>? _options(String value) {
    if (value.trim().isEmpty) return [];
    final result = <KioskOption>[];
    for (final line in value.trim().split('\n')) {
      final parts = line.split('|');
      final price = parts.length == 2 ? _money(parts.last) : 0;
      if (parts.length > 2 || parts.first.trim().isEmpty || price == null) {
        return null;
      }
      result.add(KioskOption(name: parts.first.trim(), surchargeMinor: price));
    }
    return result;
  }

  @override
  Widget build(BuildContext context) {
    final services = widget.viewModel.configuredMode == BusinessMode.services;
    return AlertDialog(
      title: Text(
        widget.item == null
            ? services
                  ? 'Add service'
                  : 'Add item'
            : 'Edit ${services ? 'service' : 'item'}',
      ),
      content: SizedBox(
        width: 520,
        child: SingleChildScrollView(
          child: Form(
            key: _form,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextFormField(
                  controller: _name,
                  decoration: const InputDecoration(labelText: 'Name'),
                  validator: (value) => value == null || value.trim().isEmpty
                      ? 'Enter a name.'
                      : null,
                ),
                const SizedBox(height: 12),
                DropdownButtonFormField<String>(
                  initialValue: _category,
                  isExpanded: true,
                  decoration: const InputDecoration(labelText: 'Category'),
                  items: [
                    for (final category in widget.viewModel.categoriesForMode(
                      widget.viewModel.configuredMode,
                    ))
                      DropdownMenuItem(value: category, child: Text(category)),
                  ],
                  onChanged: (value) => _category = value!,
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: _description,
                  decoration: const InputDecoration(labelText: 'Description'),
                  maxLines: 2,
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: _price,
                  decoration: const InputDecoration(
                    labelText: 'Original price (RM)',
                  ),
                  keyboardType: const TextInputType.numberWithOptions(
                    decimal: true,
                  ),
                  validator: (value) => _money(value ?? '') == null
                      ? 'Enter a valid price, e.g. 15.90.'
                      : null,
                ),
                if (services) ...[
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: _duration,
                    decoration: const InputDecoration(
                      labelText: 'Duration (minutes)',
                    ),
                    keyboardType: TextInputType.number,
                    validator: (value) => (int.tryParse(value ?? '') ?? 0) <= 0
                        ? 'Enter a duration above zero.'
                        : null,
                  ),
                ],
                const SizedBox(height: 12),
                TextFormField(
                  controller: _variants,
                  decoration: const InputDecoration(
                    labelText: 'Variants',
                    helperText: 'One per line: name | extra price in RM',
                    hintText: 'Regular | 0.00\nLarge | 4.00',
                  ),
                  minLines: 2,
                  maxLines: 5,
                  validator: (value) => _options(value ?? '') == null
                      ? 'Use name | price on each line.'
                      : null,
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: _addOns,
                  decoration: const InputDecoration(
                    labelText: 'Optional add-ons',
                    helperText: 'One per line: name | extra price in RM',
                    hintText: 'Extra cheese | 2.00',
                  ),
                  minLines: 2,
                  maxLines: 5,
                  validator: (value) => _options(value ?? '') == null
                      ? 'Use name | price on each line.'
                      : null,
                ),
              ],
            ),
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: () {
            if (!_form.currentState!.validate()) return;
            final item = widget.item;
            if (item == null) {
              widget.viewModel.addCatalogItem(
                name: _name.text,
                category: _category,
                priceMinor: _money(_price.text)!,
                description: _description.text,
                durationMinutes: services ? int.parse(_duration.text) : null,
                variants: _options(_variants.text)!,
                addOns: _options(_addOns.text)!,
              );
            } else {
              widget.viewModel.updateCatalogItem(
                item.copyWith(
                  name: _name.text.trim(),
                  category: _category,
                  priceMinor: _money(_price.text)!,
                  description: _description.text.trim(),
                  durationMinutes: services ? int.parse(_duration.text) : null,
                  variants: _options(_variants.text)!,
                  addOns: _options(_addOns.text)!,
                ),
              );
            }
            Navigator.pop(context);
          },
          child: const Text('Save'),
        ),
      ],
    );
  }
}

class _DisplayReceiptScreen extends StatefulWidget {
  const _DisplayReceiptScreen({required this.viewModel});

  final UniversalKioskViewModel viewModel;

  @override
  State<_DisplayReceiptScreen> createState() => _DisplayReceiptScreenState();
}

class _DisplayReceiptScreenState extends State<_DisplayReceiptScreen> {
  late bool _receiptEnabled;
  late bool _tableEntryEnabled;
  late final TextEditingController _welcomeHeading;
  late final TextEditingController _receiptHeader;
  late final TextEditingController _receiptFooter;
  late final TextEditingController _maxTableNumber;

  @override
  void initState() {
    super.initState();
    _receiptEnabled = widget.viewModel.receiptEnabled;
    _tableEntryEnabled = widget.viewModel.tableEntryEnabled;
    _welcomeHeading = TextEditingController(
      text: widget.viewModel.welcomeHeading,
    );
    _receiptHeader = TextEditingController(
      text: widget.viewModel.receiptHeader,
    );
    _receiptFooter = TextEditingController(
      text: widget.viewModel.receiptFooter,
    );
    _maxTableNumber = TextEditingController(
      text: '${widget.viewModel.maxTableNumber}',
    );
  }

  @override
  void dispose() {
    _welcomeHeading.dispose();
    _receiptHeader.dispose();
    _receiptFooter.dispose();
    _maxTableNumber.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => _AdminFrame(
    title: 'Display and receipt',
    subtitle: 'Choose how the completed order is shown to your customers.',
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            border: Border.all(color: UniversalColors.counterBorder),
            color: UniversalColors.counterSurface,
            borderRadius: BorderRadius.circular(12),
          ),
          child: const Row(
            children: [
              Icon(Icons.point_of_sale_outlined, color: UniversalColors.orange),
              SizedBox(width: 11),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Pay at Counter',
                      style: TextStyle(fontWeight: FontWeight.w900),
                    ),
                    SizedBox(height: 2),
                    Text(
                      'Customers confirm at the kiosk and pay with a cashier.',
                      style: TextStyle(
                        fontSize: 14,
                        color: UniversalColors.muted,
                      ),
                    ),
                  ],
                ),
              ),
              Icon(Icons.check_circle, color: UniversalColors.orange),
            ],
          ),
        ),
        const SizedBox(height: 16),
        SwitchListTile.adaptive(
          contentPadding: EdgeInsets.zero,
          title: const Text(
            'Show a receipt preview',
            style: TextStyle(fontWeight: FontWeight.w800),
          ),
          subtitle: const Text(
            'Let customers see their order number after confirmation.',
          ),
          activeTrackColor: UniversalColors.orange,
          value: _receiptEnabled,
          onChanged: (value) => setState(() => _receiptEnabled = value),
        ),
        const SizedBox(height: 12),
        TextField(
          controller: _welcomeHeading,
          decoration: const InputDecoration(labelText: 'Welcome heading'),
        ),
        const SizedBox(height: 12),
        TextField(
          controller: _receiptHeader,
          decoration: const InputDecoration(labelText: 'Receipt header'),
        ),
        const SizedBox(height: 12),
        TextField(
          controller: _receiptFooter,
          decoration: const InputDecoration(labelText: 'Receipt footer'),
        ),
        if (widget.viewModel.configuredMode == BusinessMode.food) ...[
          const SizedBox(height: 12),
          SwitchListTile.adaptive(
            contentPadding: EdgeInsets.zero,
            title: const Text('Ask dine-in customers for a table number'),
            value: _tableEntryEnabled,
            activeTrackColor: UniversalColors.orange,
            onChanged: (value) => setState(() => _tableEntryEnabled = value),
          ),
          if (_tableEntryEnabled)
            TextField(
              controller: _maxTableNumber,
              keyboardType: TextInputType.number,
              inputFormatters: [FilteringTextInputFormatter.digitsOnly],
              decoration: const InputDecoration(
                labelText: 'Highest table number (1–999)',
              ),
            ),
        ],
        const SizedBox(height: 25),
        Wrap(
          alignment: WrapAlignment.end,
          spacing: 10,
          runSpacing: 10,
          children: [
            SecondaryActionButton(
              label: 'Back',
              icon: Icons.arrow_back,
              onPressed: widget.viewModel.goBack,
            ),
            const SizedBox(width: 10),
            PrimaryActionButton(
              label: 'Continue',
              onPressed: () => widget.viewModel.updateDisplaySettings(
                receiptEnabled: _receiptEnabled,
                welcomeHeading: _welcomeHeading.text,
                receiptHeader: _receiptHeader.text,
                receiptFooter: _receiptFooter.text,
                tableEntryEnabled: _tableEntryEnabled,
                maxTableNumber: int.tryParse(_maxTableNumber.text),
              ),
            ),
          ],
        ),
      ],
    ),
  );
}

class _ReviewActivateScreen extends StatelessWidget {
  const _ReviewActivateScreen({required this.viewModel});

  final UniversalKioskViewModel viewModel;

  @override
  Widget build(BuildContext context) {
    final profile = viewModel.profile;
    return _AdminFrame(
      title: 'Review your setup',
      subtitle: 'Check the configuration before activating your kiosk.',
      child: Column(
        children: [
          _ReviewRow(label: 'Business name', value: profile.name),
          _ReviewRow(label: 'Company email', value: profile.email),
          _ReviewRow(label: 'Business address', value: profile.address),
          _ReviewRow(label: 'Business mode', value: profile.mode.label),
          _ReviewRow(
            label: 'Catalog',
            value: '${viewModel.catalogForMode(profile.mode).length} items',
          ),
          _ReviewRow(
            label: 'Categories',
            value: viewModel.categoriesForMode(profile.mode).join(', '),
          ),
          if (profile.mode == BusinessMode.services)
            _ReviewRow(
              label: 'Appointment times',
              value: viewModel.appointmentTimes.isEmpty
                  ? 'No times added'
                  : viewModel.appointmentTimes
                        .map(UniversalKioskViewModel.timeLabel)
                        .join(', '),
            ),
          if (profile.mode == BusinessMode.food)
            _ReviewRow(
              label: 'Table numbers',
              value: profile.tableEntryEnabled
                  ? '1–${profile.maxTableNumber}'
                  : 'Disabled',
            ),
          _ReviewRow(label: 'Payment', value: 'Pay at Counter'),
          if (viewModel.settingsError != null)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 12),
              child: Text(
                viewModel.settingsError!,
                style: const TextStyle(color: UniversalColors.validation),
              ),
            ),
          _ReviewRow(
            label: 'Receipt preview',
            value: profile.receiptEnabled ? 'Enabled' : 'Disabled',
          ),
          const SizedBox(height: 26),
          Wrap(
            alignment: WrapAlignment.end,
            spacing: 10,
            runSpacing: 10,
            children: [
              SecondaryActionButton(
                label: 'Back',
                icon: Icons.arrow_back,
                onPressed: viewModel.goBack,
              ),
              const SizedBox(width: 10),
              PrimaryActionButton(
                key: const Key('activateKioskButton'),
                label: viewModel.isSaving ? 'Saving…' : 'Save & activate',
                onPressed: viewModel.isSaving ? null : viewModel.activateKiosk,
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _ReviewRow extends StatelessWidget {
  const _ReviewRow({required this.label, required this.value});
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 13, vertical: 13),
    decoration: const BoxDecoration(
      border: Border(bottom: BorderSide(color: UniversalColors.line)),
    ),
    child: LayoutBuilder(
      builder: (context, constraints) {
        final caption = Text(
          label,
          style: const TextStyle(color: UniversalColors.muted, fontSize: 14),
        );
        final content = Text(
          value,
          style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 16),
        );
        return constraints.maxWidth < 430
            ? Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [caption, const SizedBox(height: 6), content],
              )
            : Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(width: 160, child: caption),
                  const SizedBox(width: 12),
                  Expanded(child: content),
                ],
              );
      },
    ),
  );
}

class _AdminFrame extends StatelessWidget {
  const _AdminFrame({
    required this.title,
    required this.subtitle,
    required this.child,
  });

  final String title;
  final String subtitle;
  final Widget child;

  @override
  Widget build(BuildContext context) => _CenteredFlow(
    maxWidth: 820,
    child: SingleChildScrollView(
      child: _Panel(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SectionHeading(title: title, subtitle: subtitle),
            const SizedBox(height: 26),
            child,
          ],
        ),
      ),
    ),
  );
}

class _CenteredFlow extends StatelessWidget {
  const _CenteredFlow({required this.child, this.maxWidth = 680});

  final Widget child;
  final double maxWidth;

  @override
  Widget build(BuildContext context) => Align(
    alignment: Alignment.topCenter,
    child: ConstrainedBox(
      constraints: BoxConstraints(maxWidth: maxWidth),
      child: child,
    ),
  );
}

class _Panel extends StatelessWidget {
  const _Panel({required this.child, this.padding});

  final Widget child;
  final EdgeInsetsGeometry? padding;

  @override
  Widget build(BuildContext context) => LayoutBuilder(
    builder: (context, constraints) => Container(
      padding:
          padding ??
          EdgeInsets.all(
            constraints.maxWidth < 520
                ? 17
                : UniversalLayout.of(context).panelInset,
          ),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: UniversalColors.line),
        borderRadius: BorderRadius.circular(18),
        boxShadow: const [
          BoxShadow(
            color: UniversalColors.shadow,
            blurRadius: 22,
            offset: Offset(0, 6),
          ),
        ],
      ),
      child: Material(type: MaterialType.transparency, child: child),
    ),
  );
}

class _ChoiceCard extends StatelessWidget {
  const _ChoiceCard({
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
  Widget build(BuildContext context) => Material(
    color: UniversalColors.canvas,
    borderRadius: BorderRadius.circular(12),
    child: InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          border: Border.all(color: UniversalColors.line),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            CircleAvatar(
              backgroundColor: UniversalColors.orangeSoft,
              child: Icon(icon, color: UniversalColors.orange),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontWeight: FontWeight.w800,
                      fontFeatures: UniversalType.figures,
                    ),
                  ),
                  const SizedBox(height: 3),
                  Text(
                    detail,
                    style: const TextStyle(
                      fontSize: 14,
                      color: UniversalColors.muted,
                    ),
                  ),
                ],
              ),
            ),
            const Icon(Icons.arrow_forward, color: UniversalColors.orange),
          ],
        ),
      ),
    ),
  );
}

class _Progress extends StatelessWidget {
  const _Progress({required this.steps, required this.active});
  final List<String> steps;
  final int active;

  @override
  Widget build(BuildContext context) => SizedBox(
    height: 8 + MediaQuery.textScalerOf(context).scale(24),
    child: SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: [
          for (var i = 0; i < steps.length; i++) ...[
            if (i > 0)
              Container(
                margin: const EdgeInsets.symmetric(horizontal: 16),
                width: 32,
                height: 1,
                color: UniversalColors.line,
              ),
            CircleAvatar(
              radius: 12,
              backgroundColor: active == i
                  ? UniversalColors.orangeDark
                  : UniversalColors.line.withValues(alpha: .5),
              child: i < active
                  ? const Icon(
                      Icons.check,
                      size: 12,
                      color: UniversalColors.muted,
                    )
                  : Text(
                      '${i + 1}',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                        color: i == active
                            ? Colors.white
                            : UniversalColors.muted,
                      ),
                    ),
            ),
            const SizedBox(width: 7),
            Text(
              steps[i],
              style: TextStyle(
                fontSize: 14,
                fontWeight: active == i ? FontWeight.w800 : FontWeight.w500,
                color: active == i
                    ? UniversalColors.orangeDark
                    : UniversalColors.muted,
              ),
            ),
          ],
        ],
      ),
    ),
  );
}

class _Breadcrumb extends StatelessWidget {
  const _Breadcrumb({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) => Row(
    children: [
      const Text(
        'MYSZTECH',
        style: TextStyle(
          fontSize: 12,
          color: UniversalColors.muted,
          fontWeight: FontWeight.w800,
        ),
      ),
      const Padding(
        padding: EdgeInsets.symmetric(horizontal: 7),
        child: Icon(
          Icons.chevron_right,
          size: 14,
          color: UniversalColors.muted,
        ),
      ),
      Flexible(
        child: Text(
          label,
          style: const TextStyle(
            fontSize: 12,
            color: UniversalColors.orangeDark,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
    ],
  );
}
