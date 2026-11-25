import 'package:shared_preferences/shared_preferences.dart';

abstract interface class KioskSettingsStore {
  Future<String?> read();
  Future<void> write(String value);
}

class DeviceKioskSettingsStore implements KioskSettingsStore {
  static const _key = 'mysztech.universal-kiosk.settings.v1';

  @override
  Future<String?> read() => SharedPreferencesAsync().getString(_key);

  @override
  Future<void> write(String value) =>
      SharedPreferencesAsync().setString(_key, value);
}

class MemoryKioskSettingsStore implements KioskSettingsStore {
  String? value;

  @override
  Future<String?> read() async => value;

  @override
  Future<void> write(String value) async => this.value = value;
}
