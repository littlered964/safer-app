import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:safer/blocs/theme/bloc.dart';
import 'package:safer/configs/config.dart';
import 'package:safer/utils/utils.dart';

const DARK_DYNAMIC = 'dynamic';
const DARK_ALWAYS_OFF = 'off';
const DARK_ALWAYS_ON = 'on';

class ThemeBloc extends Bloc<ThemeEvent, ThemeState> {
  ThemeBloc() : super(InitialThemeState()) {
    on<ChangeTheme>(_onChangeTheme);
  }

  Future<void> _onChangeTheme(ChangeTheme event, Emitter<ThemeState> emit) async {
    emit(ThemeUpdating());

    AppTheme.currentTheme = event.theme;
    AppTheme.currentFont = event.font;
    AppTheme.darkThemeOption = event.darkOption;

    switch (AppTheme.darkThemeOption) {
      case DarkOption.dynamic:
        AppTheme.lightTheme = CollectionTheme.getCollectionTheme(
          theme: AppTheme.currentTheme.lightTheme,
          font: AppTheme.currentFont,
        );
        AppTheme.darkTheme = CollectionTheme.getCollectionTheme(
          theme: AppTheme.currentTheme.darkTheme,
          font: AppTheme.currentFont,
        );
        break;
      case DarkOption.alwaysOn:
        AppTheme.lightTheme = CollectionTheme.getCollectionTheme(
          theme: AppTheme.currentTheme.darkTheme,
          font: AppTheme.currentFont,
        );
        AppTheme.darkTheme = CollectionTheme.getCollectionTheme(
          theme: AppTheme.currentTheme.darkTheme,
          font: AppTheme.currentFont,
        );
        break;
      case DarkOption.alwaysOff:
        AppTheme.lightTheme = CollectionTheme.getCollectionTheme(
          theme: AppTheme.currentTheme.lightTheme,
          font: AppTheme.currentFont,
        );
        AppTheme.darkTheme = CollectionTheme.getCollectionTheme(
          theme: AppTheme.currentTheme.lightTheme,
          font: AppTheme.currentFont,
        );
        break;
      }

    UtilPreferences.setString(Preferences.location, AppTheme.currentLocation);
    UtilPreferences.setString(Preferences.theme, AppTheme.currentTheme.name);
    UtilPreferences.setString(Preferences.font, AppTheme.currentFont);

    switch (AppTheme.darkThemeOption) {
      case DarkOption.dynamic:
        UtilPreferences.setString(Preferences.darkOption, DARK_DYNAMIC);
        break;
      case DarkOption.alwaysOn:
        UtilPreferences.setString(Preferences.darkOption, DARK_ALWAYS_ON);
        break;
      case DarkOption.alwaysOff:
        UtilPreferences.setString(Preferences.darkOption, DARK_ALWAYS_OFF);
        break;
      }

    emit(ThemeUpdated());
  }
}
