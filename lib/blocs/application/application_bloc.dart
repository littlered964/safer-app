import 'dart:async';
import 'package:bloc/bloc.dart';
import 'package:flutter/material.dart';
import 'package:safer/blocs/bloc.dart';
import 'package:safer/configs/config.dart';
import 'package:safer/models/model.dart';
import 'package:safer/utils/utils.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ApplicationBloc extends Bloc<ApplicationEvent, ApplicationState> {
  final ThemeBloc themeBloc;
  final LanguageBloc languageBloc;

  ApplicationBloc({
    required this.themeBloc,
    required this.languageBloc,
  }) : super(InitialApplicationState()) {
    on<SetupApplication>(_onSetupApplication);
    on<OnCompletedIntro>(_onCompletedIntro);
  }

  Future<void> _onSetupApplication(
    SetupApplication event,
    Emitter<ApplicationState> emit,
  ) async {
    emit(ApplicationWaiting());

    Application.preferences = await SharedPreferences.getInstance();

    final oldTheme = UtilPreferences.getString(Preferences.theme);
    final oldFont = UtilPreferences.getString(Preferences.font);
    final oldLanguage = UtilPreferences.getString(Preferences.language);
    final oldDarkOption = UtilPreferences.getString(Preferences.darkOption);

    ThemeModel? theme;
    String? font;
    DarkOption? darkOption;

    final String? savedLanguage = UtilPreferences.getString(Preferences.language);

    languageBloc.add(
      ChangeLanguage(
        (savedLanguage?.isNotEmpty ?? false)
            ? Locale(savedLanguage!)
            : AppLanguage.defaultLanguage,
      ),
    );

    final fontAvailable = AppTheme.fontSupport.where((item) => item == oldFont).toList();
    final themeAvailable = AppTheme.themeSupport.where((item) => item.name == oldTheme).toList();

    if (fontAvailable.isNotEmpty) font = fontAvailable.first;
    if (themeAvailable.isNotEmpty) theme = themeAvailable.first;

    switch (oldDarkOption) {
      case DARK_ALWAYS_OFF:
        darkOption = DarkOption.alwaysOff;
        break;
      case DARK_ALWAYS_ON:
        darkOption = DarkOption.alwaysOn;
        break;
      default:
        darkOption = DarkOption.alwaysOff;
    }

    themeBloc.add(ChangeTheme(
      theme: theme ?? AppTheme.currentTheme,
      font: font ?? AppTheme.currentFont,
      darkOption: darkOption,
    ));

    final hasReview = UtilPreferences.containsKey(
      '${Preferences.reviewIntro}.${Application.version}',
    );

    if (hasReview) {
      emit(ApplicationSetupCompleted());
    } else {
      emit(ApplicationIntroView());
    }
  }

  Future<void> _onCompletedIntro(
    OnCompletedIntro event,
    Emitter<ApplicationState> emit,
  ) async {
    await UtilPreferences.setBool(
      '${Preferences.reviewIntro}.${Application.version}',
      true,
    );
    emit(ApplicationSetupCompleted());
  }
}
