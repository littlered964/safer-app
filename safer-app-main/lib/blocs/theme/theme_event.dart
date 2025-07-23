import 'package:safer/configs/config.dart';
import 'package:safer/models/model.dart';
import 'package:meta/meta.dart';

@immutable
abstract class ThemeEvent {}

class ChangeTheme extends ThemeEvent {
  final ThemeModel theme;
  final String font;
  final DarkOption darkOption;

  ChangeTheme({
    required this.theme,
    required this.font,
    required this.darkOption,
  });
}

class ChangeDarkOption extends ThemeEvent {
  final DarkOption darkOption;

  ChangeDarkOption({required this.darkOption});
}
