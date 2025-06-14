import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/datasources/application_settings_api.dart';
import '../../../../shared/types/result.dart';
import '../../domain/application_setting.dart';

final settingsProvider = FutureProvider<ApplicationSettingsStore>((ref) async {
  final api = ApplicationSettingsApi();
  final result = await api.getSettings();

  switch (result) {
    case Success(:final data):
      return ApplicationSettingsStore(data);
    case Failure(:final message):
      throw Exception(message);
  }
});

class ApplicationSettingsStore {
  final List<ApplicationSetting> _settings;

  ApplicationSettingsStore(this._settings);

  T? get<T>(String key) {
    final match = _settings.firstWhere(
          (s) => s.key == key,
      orElse: () => ApplicationSetting(
        id: -1,
        key: key,
        value: '',
        settingType: '',
        typedValue: null,
      ),
    );

    final value = match.typedValue;
    if (value is T) return value;
    return null;
  }
}
