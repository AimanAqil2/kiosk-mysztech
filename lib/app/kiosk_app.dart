import 'package:flutter/material.dart';

import '../data/repositories/universal_catalog_repository.dart';
import '../data/repositories/kiosk_settings_store.dart';
import '../ui/core/universal_brand.dart';
import '../ui/features/universal_kiosk/universal_kiosk_page.dart';
import '../ui/features/universal_kiosk/universal_kiosk_view_model.dart';

class KioskApp extends StatefulWidget {
  const KioskApp({super.key, this.viewModel});

  final UniversalKioskViewModel? viewModel;

  @override
  State<KioskApp> createState() => _KioskAppState();
}

class _KioskAppState extends State<KioskApp> {
  late final UniversalKioskViewModel _viewModel;
  late final bool _ownsViewModel;
  late final Future<void> _ready;

  @override
  void initState() {
    super.initState();
    final suppliedViewModel = widget.viewModel;
    if (suppliedViewModel != null) {
      _viewModel = suppliedViewModel;
      _ownsViewModel = false;
      _ready = Future<void>.value();
    } else {
      _viewModel = UniversalKioskViewModel(
        repository: const LocalUniversalCatalogRepository(),
        settingsStore: DeviceKioskSettingsStore(),
      );
      _ownsViewModel = true;
      _ready = _viewModel.initialize();
    }
  }

  @override
  void dispose() {
    if (_ownsViewModel) {
      _viewModel.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'MYSZTECH Universal Kiosk',
      debugShowCheckedModeBanner: false,
      theme: UniversalTheme.theme,
      home: FutureBuilder<void>(
        future: _ready,
        builder: (context, snapshot) =>
            snapshot.connectionState == ConnectionState.done
            ? UniversalKioskPage(viewModel: _viewModel)
            : const Scaffold(body: Center(child: CircularProgressIndicator())),
      ),
    );
  }
}
