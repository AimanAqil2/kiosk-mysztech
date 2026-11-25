import 'package:flutter/material.dart';

import '../../core/kiosk_brand.dart';
import 'order_flow_screens.dart';
import 'order_flow_view_model.dart';

class OrderFlowPage extends StatelessWidget {
  const OrderFlowPage({super.key, required this.viewModel});

  final OrderFlowViewModel viewModel;

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: viewModel,
      builder: (context, _) {
        if (viewModel.isLoading) {
          return const _StatusPage(
            message: 'Preparing your menu…',
            isLoading: true,
          );
        }
        if (viewModel.products.isEmpty) {
          return _StatusPage(
            message:
                viewModel.errorMessage ?? 'The menu is unavailable right now.',
            actionLabel: 'Try again',
            onAction: viewModel.loadCatalog,
          );
        }

        final usesSharedHeader = switch (viewModel.screen) {
          KioskScreen.welcome || KioskScreen.success => false,
          _ => true,
        };
        return Scaffold(
          body: SafeArea(
            child: Column(
              children: [
                if (usesSharedHeader) KioskHeader(viewModel: viewModel),
                Expanded(child: _screenFor(viewModel)),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _screenFor(OrderFlowViewModel viewModel) {
    return switch (viewModel.screen) {
      KioskScreen.welcome => WelcomeScreen(viewModel: viewModel),
      KioskScreen.orderType => OrderTypeScreen(viewModel: viewModel),
      KioskScreen.menu => MenuScreen(viewModel: viewModel),
      KioskScreen.customize => CustomizationScreen(viewModel: viewModel),
      KioskScreen.cart => CartScreen(viewModel: viewModel),
      KioskScreen.table => TableNumberScreen(viewModel: viewModel),
      KioskScreen.payment => PaymentScreen(viewModel: viewModel),
      KioskScreen.success => SuccessScreen(viewModel: viewModel),
    };
  }
}

class KioskHeader extends StatelessWidget {
  const KioskHeader({super.key, required this.viewModel});

  final OrderFlowViewModel viewModel;

  @override
  Widget build(BuildContext context) {
    final showBack =
        viewModel.screen != KioskScreen.menu && viewModel.canGoBack;
    final layout = KioskLayout.of(context);
    final iconSize = layout.isKioskViewport ? 50.0 : 34.0;
    return Padding(
      padding: EdgeInsets.fromLTRB(
        layout.pagePadding,
        layout.isKioskViewport ? 18 : 12,
        layout.pagePadding,
        layout.isKioskViewport ? 10 : 6,
      ),
      child: SizedBox(
        height: layout.headerHeight,
        child: Stack(
          alignment: Alignment.center,
          children: [
            Align(
              alignment: Alignment.centerLeft,
              child: showBack
                  ? _HeaderIconButton(
                      icon: Icons.arrow_back,
                      onPressed: viewModel.goBack,
                      size: iconSize,
                    )
                  : SizedBox(width: iconSize),
            ),
            Center(
              child: MysztechLogo(height: layout.isKioskViewport ? 34 : 25),
            ),
            Align(
              alignment: Alignment.centerRight,
              child: LanguagePill(
                large: layout.isKioskViewport,
                onTap: () => ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Language selection will be available soon.'),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _HeaderIconButton extends StatelessWidget {
  const _HeaderIconButton({
    required this.icon,
    required this.onPressed,
    required this.size,
  });

  final IconData icon;
  final VoidCallback onPressed;
  final double size;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(size * .28),
      child: InkWell(
        borderRadius: BorderRadius.circular(size * .28),
        onTap: onPressed,
        child: SizedBox(
          width: size,
          height: size,
          child: Icon(icon, size: size * .53),
        ),
      ),
    );
  }
}

class _StatusPage extends StatelessWidget {
  const _StatusPage({
    required this.message,
    this.isLoading = false,
    this.actionLabel,
    this.onAction,
  });

  final String message;
  final bool isLoading;
  final String? actionLabel;
  final VoidCallback? onAction;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(28),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const MysztechLogo(height: 38),
              const SizedBox(height: 24),
              Text(message, textAlign: TextAlign.center),
              if (isLoading) ...[
                const SizedBox(height: 18),
                const CircularProgressIndicator(color: KioskColors.orange),
              ],
              if (actionLabel != null && onAction != null) ...[
                const SizedBox(height: 18),
                KioskPrimaryButton(label: actionLabel!, onPressed: onAction),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
