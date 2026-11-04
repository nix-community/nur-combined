import '../../Core/ThemeManager/LanguageSwitcher.dart';
import '../../Widgets/Components/ScreenState.dart';
import 'SettingsCategories.dart';

class SettingsCategoryState extends ScreenState {
  final SettingsCategory category;

  SettingsCategoryState(this.category);

  String get title => category.title;

  String get hint => getString.searchCategory(category.title.toLowerCase());
}
