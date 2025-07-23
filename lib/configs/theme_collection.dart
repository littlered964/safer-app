import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class CollectionTheme {
  // Get collection theme
  //
  //  primaryLight/primaryDark/brownLight/brownDark/pinkLight/pinkDark
  static ThemeData getCollectionTheme(
      {String theme = "primaryLight", String font = "Raleway"}) {
    switch (theme) {
      case "primaryLight":
        return ThemeData(
          fontFamily: font,
          brightness: Brightness.light,
          primaryColor: Color(0xffe5634d),
          primaryColorLight: Color(0xffFF8A65),
          primaryColorDark: Color(0xff862413),
          canvasColor: Color(0xfffafafa),
          scaffoldBackgroundColor: Color(0xfffafafa),
          cardColor: Color(0xffffffff),
          dividerColor: Color(0x1f000000),
          highlightColor: Color(0x66bcbcbc),
          splashColor: Color(0x66c8c8c8),
          unselectedWidgetColor: Color(0x8a000000),
          disabledColor: Color(0x61000000),
          secondaryHeaderColor: Color(0xfffcebe9),
          indicatorColor: Color(0xff4A90A4),
          hintColor: Color(0x8a000000),
          buttonTheme: ButtonThemeData(
            textTheme: ButtonTextTheme.accent,
            minWidth: 88,
            height: 48,
            padding: EdgeInsets.only(left: 16, right: 16),
            shape: RoundedRectangleBorder(
              side: BorderSide(
                color: Color(0xff000000),
                width: 0,
                style: BorderStyle.none,
              ),
              borderRadius: BorderRadius.all(
                Radius.circular(8),
              ),
            ),
            buttonColor: Color(0xffe5634d),
            disabledColor: Color(0x61000000),
            highlightColor: Color(0x29000000),
            splashColor: Color(0x1f000000),
            focusColor: Color(0x1f000000),
            hoverColor: Color(0x0a000000),
          ),
          inputDecorationTheme: InputDecorationTheme(
            contentPadding: EdgeInsets.only(
              top: 12,
              bottom: 12,
              left: 15,
              right: 15,
            ),
          ),
          chipTheme: ChipThemeData(
            backgroundColor: Color(0x1f000000),
            brightness: Brightness.light,
            deleteIconColor: Color(0xffdf3c20),
            disabledColor: Color(0x0c000000),
            labelPadding: EdgeInsets.only(left: 8, right: 8),
            labelStyle: TextStyle(
              fontSize: 12,
              fontFamily: font,
              color: Colors.black,
              fontWeight: FontWeight.w400,
              fontStyle: FontStyle.normal,
            ),
            padding: EdgeInsets.all(4),
            secondaryLabelStyle: TextStyle(
              fontSize: 12,
              fontFamily: font,
              color: Colors.black,
              fontWeight: FontWeight.w400,
              fontStyle: FontStyle.normal,
            ),
            secondarySelectedColor: Color(0x3de5634d),
            selectedColor: Color(0x3de5634d),
            shape: StadiumBorder(
              side: BorderSide(
                color: Color(0xff000000),
                width: 0,
                style: BorderStyle.none,
              ),
            ),
          ),
          dialogTheme: DialogTheme(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.all(
                Radius.circular(8),
              ),
            ),
          ),
          cardTheme: CardTheme(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ), textSelectionTheme: TextSelectionThemeData(cursorColor: Color(0xff4285f4), selectionColor: Color(0xff4A90A4), selectionHandleColor: Color(0xff4A90A4),), checkboxTheme: CheckboxThemeData(
 fillColor: WidgetStateProperty.resolveWith<Color?>((Set<WidgetState> states) {
 if (states.contains(WidgetState.disabled)) { return null; }
 if (states.contains(WidgetState.selected)) { return Color(0xff4A90A4); }
 return null;
 }),
 ), radioTheme: RadioThemeData(
 fillColor: WidgetStateProperty.resolveWith<Color?>((Set<WidgetState> states) {
 if (states.contains(WidgetState.disabled)) { return null; }
 if (states.contains(WidgetState.selected)) { return Color(0xff4A90A4); }
 return null;
 }),
 ), switchTheme: SwitchThemeData(
 thumbColor: WidgetStateProperty.resolveWith<Color?>((Set<WidgetState> states) {
 if (states.contains(WidgetState.disabled)) { return null; }
 if (states.contains(WidgetState.selected)) { return Color(0xff4A90A4); }
 return null;
 }),
 trackColor: WidgetStateProperty.resolveWith<Color?>((Set<WidgetState> states) {
 if (states.contains(WidgetState.disabled)) { return null; }
 if (states.contains(WidgetState.selected)) { return Color(0xff4A90A4); }
 return null;
 }),
 ), bottomAppBarTheme: BottomAppBarTheme(color: Color(0xffffffff)), colorScheme: ColorScheme.fromSwatch(primarySwatch: MaterialColor(4293223245, {
            50: Color(0xfffcebe9),
            100: Color(0xfff9d8d3),
            200: Color(0xfff2b1a6),
            300: Color(0xffec8a79),
            400: Color(0xffe5634d),
            500: Color(0xffdf3c20),
            600: Color(0xffb2301a),
            700: Color(0xff862413),
            800: Color(0xff59180d),
            900: Color(0xff2d0c06)
          })).copyWith(secondary: Color(0xff4A90A4)).copyWith(surface: Color(0xfff2b1a6)).copyWith(error: Color(0xffd32f2f)),
        );
      case "primaryDark":
        return ThemeData(
          fontFamily: font,
          brightness: Brightness.dark,
          primaryColor: Color(0xffe5634d),
          primaryColorLight: Color(0xffFF8A65),
          primaryColorDark: Color(0xff000000),
          canvasColor: Colors.grey[900],
          scaffoldBackgroundColor: Color(0xff303030),
          cardColor: Color(0xff424242),
          dividerColor: Color(0x1fffffff),
          highlightColor: Color(0x40cccccc),
          splashColor: Color(0x40cccccc),
          unselectedWidgetColor: Color(0xb3ffffff),
          disabledColor: Color(0x62ffffff),
          secondaryHeaderColor: Color(0xff616161),
          indicatorColor: Color(0xff4A90A4),
          hintColor: Color(0x80ffffff),
          appBarTheme: AppBarTheme(
            color: Colors.grey[900], systemOverlayStyle: SystemUiOverlayStyle.light,
          ),
          buttonTheme: ButtonThemeData(
            textTheme: ButtonTextTheme.accent,
            minWidth: 88,
            height: 48,
            padding: EdgeInsets.only(left: 16, right: 16),
            shape: RoundedRectangleBorder(
              side: BorderSide(
                color: Color(0xff000000),
                width: 0,
                style: BorderStyle.none,
              ),
              borderRadius: BorderRadius.all(
                Radius.circular(8),
              ),
            ),
            buttonColor: Color(0xffe5634d),
            disabledColor: Color(0x61ffffff),
            highlightColor: Color(0x29ffffff),
            splashColor: Color(0x1fffffff),
            focusColor: Color(0x1fffffff),
            hoverColor: Color(0x0affffff),
          ),
          inputDecorationTheme: InputDecorationTheme(
            contentPadding: EdgeInsets.only(
              top: 12,
              bottom: 12,
              left: 15,
              right: 15,
            ),
          ),
          chipTheme: ChipThemeData(
            backgroundColor: Color(0x1fffffff),
            brightness: Brightness.dark,
            deleteIconColor: Color(0xdeffffff),
            disabledColor: Color(0x0cffffff),
            labelPadding: EdgeInsets.only(left: 8, right: 8),
            labelStyle: TextStyle(
              fontSize: 12,
              fontFamily: font,
              color: Color(0xb3ffffff),
              fontWeight: FontWeight.w400,
              fontStyle: FontStyle.normal,
            ),
            padding: EdgeInsets.all(4),
            secondaryLabelStyle: TextStyle(
              fontSize: 12,
              fontFamily: font,
              color: Color(0xb3ffffff),
              fontWeight: FontWeight.w400,
              fontStyle: FontStyle.normal,
            ),
            secondarySelectedColor: Color(0x3d212121),
            selectedColor: Color(0x3dffffff),
            shape: StadiumBorder(
              side: BorderSide(
                color: Color(0xff000000),
                width: 0,
                style: BorderStyle.none,
              ),
            ),
          ),
          sliderTheme: SliderThemeData.fromPrimaryColors(
            primaryColor: Color(0xffe5634d),
            primaryColorLight: Color(0xfff9d8d3),
            primaryColorDark: Color(0xff862413),
            valueIndicatorTextStyle: TextStyle(
              color: Color(0xffffffff),
              fontWeight: FontWeight.w400,
              fontStyle: FontStyle.normal,
            ),
          ),
          dialogTheme: DialogTheme(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.all(
                Radius.circular(8),
              ),
            ),
          ),
          cardTheme: CardTheme(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ), textSelectionTheme: TextSelectionThemeData(cursorColor: Color(0xff4285f4), selectionColor: Color(0xff4A90A4), selectionHandleColor: Color(0xff4A90A4),), checkboxTheme: CheckboxThemeData(
 fillColor: WidgetStateProperty.resolveWith<Color?>((Set<WidgetState> states) {
 if (states.contains(WidgetState.disabled)) { return null; }
 if (states.contains(WidgetState.selected)) { return Color(0xff4A90A4); }
 return null;
 }),
 ), radioTheme: RadioThemeData(
 fillColor: WidgetStateProperty.resolveWith<Color?>((Set<WidgetState> states) {
 if (states.contains(WidgetState.disabled)) { return null; }
 if (states.contains(WidgetState.selected)) { return Color(0xff4A90A4); }
 return null;
 }),
 ), switchTheme: SwitchThemeData(
 thumbColor: WidgetStateProperty.resolveWith<Color?>((Set<WidgetState> states) {
 if (states.contains(WidgetState.disabled)) { return null; }
 if (states.contains(WidgetState.selected)) { return Color(0xff4A90A4); }
 return null;
 }),
 trackColor: WidgetStateProperty.resolveWith<Color?>((Set<WidgetState> states) {
 if (states.contains(WidgetState.disabled)) { return null; }
 if (states.contains(WidgetState.selected)) { return Color(0xff4A90A4); }
 return null;
 }),
 ), bottomAppBarTheme: BottomAppBarTheme(color: Color(0xff424242)), colorScheme: ColorScheme.fromSwatch(primarySwatch: MaterialColor(4280361249, {
            50: Color(0xfff2f2f2),
            100: Color(0xffe6e6e6),
            200: Color(0xffcccccc),
            300: Color(0xffb3b3b3),
            400: Color(0xff999999),
            500: Color(0xff808080),
            600: Color(0xff666666),
            700: Color(0xff4d4d4d),
            800: Color(0xff333333),
            900: Color(0xff191919)
          })).copyWith(secondary: Color(0xff4A90A4)).copyWith(surface: Color(0xff616161)).copyWith(error: Color(0xffd32f2f)),
        );
      case "brownLight":
        return ThemeData(
          fontFamily: font,
          brightness: Brightness.light,
          primaryColor: Color(0xffa1887f),
          primaryColorLight: Color(0xffe9e4e2),
          primaryColorDark: Color(0xff584741),
          canvasColor: Color(0xfffafafa),
          scaffoldBackgroundColor: Color(0xfffafafa),
          cardColor: Color(0xffffffff),
          dividerColor: Color(0x1f000000),
          highlightColor: Color(0x66bcbcbc),
          splashColor: Color(0x66c8c8c8),
          unselectedWidgetColor: Color(0x8a000000),
          disabledColor: Color(0x61000000),
          secondaryHeaderColor: Color(0xfff4f1f0),
          indicatorColor: Color(0xff93766c),
          hintColor: Color(0x8a000000),
          buttonTheme: ButtonThemeData(
            textTheme: ButtonTextTheme.accent,
            minWidth: 88,
            height: 48,
            padding: EdgeInsets.only(left: 16, right: 16),
            shape: RoundedRectangleBorder(
              side: BorderSide(
                color: Color(0xff000000),
                width: 0,
                style: BorderStyle.none,
              ),
              borderRadius: BorderRadius.all(
                Radius.circular(8),
              ),
            ),
            buttonColor: Color(0xffa1887f),
            disabledColor: Color(0x61000000),
            highlightColor: Color(0x29000000),
            splashColor: Color(0x1f000000),
            focusColor: Color(0x1f000000),
            hoverColor: Color(0x0a000000),
          ),
          inputDecorationTheme: InputDecorationTheme(
            contentPadding: EdgeInsets.only(
              top: 12,
              bottom: 12,
              left: 15,
              right: 15,
            ),
          ),
          chipTheme: ChipThemeData(
            backgroundColor: Color(0x1f000000),
            brightness: Brightness.light,
            deleteIconColor: Color(0xff93766c),
            disabledColor: Color(0x0c000000),
            labelPadding: EdgeInsets.only(left: 8, right: 8),
            labelStyle: TextStyle(
              fontSize: 12,
              fontFamily: font,
              color: Colors.black,
              fontWeight: FontWeight.w400,
              fontStyle: FontStyle.normal,
            ),
            padding: EdgeInsets.all(4),
            secondaryLabelStyle: TextStyle(
              fontSize: 12,
              fontFamily: font,
              color: Colors.black,
              fontWeight: FontWeight.w400,
              fontStyle: FontStyle.normal,
            ),
            secondarySelectedColor: Color(0x3da1887f),
            selectedColor: Color(0x3da1887f),
            shape: StadiumBorder(
              side: BorderSide(
                color: Color(0xff000000),
                width: 0,
                style: BorderStyle.none,
              ),
            ),
          ),
          dialogTheme: DialogTheme(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.all(
                Radius.circular(8),
              ),
            ),
          ),
          cardTheme: CardTheme(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ), textSelectionTheme: TextSelectionThemeData(cursorColor: Color(0xff4285f4), selectionColor: Color(0xffd4c8c4), selectionHandleColor: Color(0xffbeada7),), checkboxTheme: CheckboxThemeData(
 fillColor: WidgetStateProperty.resolveWith<Color?>((Set<WidgetState> states) {
 if (states.contains(WidgetState.disabled)) { return null; }
 if (states.contains(WidgetState.selected)) { return Color(0xff765f56); }
 return null;
 }),
 ), radioTheme: RadioThemeData(
 fillColor: WidgetStateProperty.resolveWith<Color?>((Set<WidgetState> states) {
 if (states.contains(WidgetState.disabled)) { return null; }
 if (states.contains(WidgetState.selected)) { return Color(0xff765f56); }
 return null;
 }),
 ), switchTheme: SwitchThemeData(
 thumbColor: WidgetStateProperty.resolveWith<Color?>((Set<WidgetState> states) {
 if (states.contains(WidgetState.disabled)) { return null; }
 if (states.contains(WidgetState.selected)) { return Color(0xff765f56); }
 return null;
 }),
 trackColor: WidgetStateProperty.resolveWith<Color?>((Set<WidgetState> states) {
 if (states.contains(WidgetState.disabled)) { return null; }
 if (states.contains(WidgetState.selected)) { return Color(0xff765f56); }
 return null;
 }),
 ), bottomAppBarTheme: BottomAppBarTheme(color: Color(0xffffffff)), colorScheme: ColorScheme.fromSwatch(primarySwatch: MaterialColor(4288776319, {
            50: Color(0xfff4f1f0),
            100: Color(0xffe9e4e2),
            200: Color(0xffd4c8c4),
            300: Color(0xffbeada7),
            400: Color(0xffa99289),
            500: Color(0xff93766c),
            600: Color(0xff765f56),
            700: Color(0xff584741),
            800: Color(0xff3b2f2b),
            900: Color(0xff1d1816)
          })).copyWith(secondary: Color(0xff93766c)).copyWith(surface: Color(0xffd4c8c4)).copyWith(error: Color(0xffd32f2f)),
        );
      case "brownDark":
        return ThemeData(
          fontFamily: font,
          brightness: Brightness.dark,
          primaryColor: Color(0xffa1887f),
          primaryColorLight: Color(0xff9e9e9e),
          primaryColorDark: Color(0xff000000),
          canvasColor: Colors.grey[900],
          scaffoldBackgroundColor: Color(0xff303030),
          cardColor: Color(0xff424242),
          dividerColor: Color(0x1fffffff),
          highlightColor: Color(0x40cccccc),
          splashColor: Color(0x40cccccc),
          unselectedWidgetColor: Color(0xb3ffffff),
          disabledColor: Color(0x62ffffff),
          secondaryHeaderColor: Color(0xff616161),
          indicatorColor: Color(0xff93766c),
          hintColor: Color(0x80ffffff),
          appBarTheme: AppBarTheme(
            color: Colors.grey[900], systemOverlayStyle: SystemUiOverlayStyle.light,
          ),
          buttonTheme: ButtonThemeData(
            textTheme: ButtonTextTheme.accent,
            minWidth: 88,
            height: 48,
            padding: EdgeInsets.only(left: 16, right: 16),
            shape: RoundedRectangleBorder(
              side: BorderSide(
                color: Color(0xff000000),
                width: 0,
                style: BorderStyle.none,
              ),
              borderRadius: BorderRadius.all(
                Radius.circular(8.0),
              ),
            ),
            buttonColor: Color(0xffa1887f),
            disabledColor: Color(0x61ffffff),
            highlightColor: Color(0x29ffffff),
            splashColor: Color(0x1fffffff),
            focusColor: Color(0x1fffffff),
            hoverColor: Color(0x0affffff),
          ),
          inputDecorationTheme: InputDecorationTheme(
            contentPadding: EdgeInsets.only(
              top: 12,
              bottom: 12,
              left: 15,
              right: 15,
            ),
          ),
          chipTheme: ChipThemeData(
            backgroundColor: Color(0x1fffffff),
            brightness: Brightness.dark,
            deleteIconColor: Color(0xdeffffff),
            disabledColor: Color(0x0cffffff),
            labelPadding: EdgeInsets.only(left: 8, right: 8),
            labelStyle: TextStyle(
              fontSize: 12,
              fontFamily: font,
              color: Color(0xdeffffff),
              fontWeight: FontWeight.w400,
              fontStyle: FontStyle.normal,
            ),
            padding: EdgeInsets.all(4),
            secondaryLabelStyle: TextStyle(
              fontSize: 12,
              fontFamily: font,
              color: Color(0x3dffffff),
              fontWeight: FontWeight.w400,
              fontStyle: FontStyle.normal,
            ),
            secondarySelectedColor: Color(0x3d212121),
            selectedColor: Color(0x3dffffff),
            shape: StadiumBorder(
              side: BorderSide(
                color: Color(0xff000000),
                width: 0,
                style: BorderStyle.none,
              ),
            ),
          ),
          sliderTheme: SliderThemeData.fromPrimaryColors(
            primaryColor: Color(0xffa1887f),
            primaryColorLight: Color(0xffe9e4e2),
            primaryColorDark: Color(0xff584741),
            valueIndicatorTextStyle: TextStyle(
              color: Color(0xffffffff),
              fontWeight: FontWeight.w400,
              fontStyle: FontStyle.normal,
            ),
          ),
          dialogTheme: DialogTheme(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.all(
                Radius.circular(8),
              ),
            ),
          ),
          cardTheme: CardTheme(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ), textSelectionTheme: TextSelectionThemeData(cursorColor: Color(0xff4285f4), selectionColor: Color(0xffd4c8c4), selectionHandleColor: Color(0xffbeada7),), checkboxTheme: CheckboxThemeData(
 fillColor: WidgetStateProperty.resolveWith<Color?>((Set<WidgetState> states) {
 if (states.contains(WidgetState.disabled)) { return null; }
 if (states.contains(WidgetState.selected)) { return Color(0xff765f56); }
 return null;
 }),
 ), radioTheme: RadioThemeData(
 fillColor: WidgetStateProperty.resolveWith<Color?>((Set<WidgetState> states) {
 if (states.contains(WidgetState.disabled)) { return null; }
 if (states.contains(WidgetState.selected)) { return Color(0xff765f56); }
 return null;
 }),
 ), switchTheme: SwitchThemeData(
 thumbColor: WidgetStateProperty.resolveWith<Color?>((Set<WidgetState> states) {
 if (states.contains(WidgetState.disabled)) { return null; }
 if (states.contains(WidgetState.selected)) { return Color(0xff765f56); }
 return null;
 }),
 trackColor: WidgetStateProperty.resolveWith<Color?>((Set<WidgetState> states) {
 if (states.contains(WidgetState.disabled)) { return null; }
 if (states.contains(WidgetState.selected)) { return Color(0xff765f56); }
 return null;
 }),
 ), bottomAppBarTheme: BottomAppBarTheme(color: Color(0xff424242)), colorScheme: ColorScheme.fromSwatch(primarySwatch: MaterialColor(4280361249, {
            50: Color(0xfff2f2f2),
            100: Color(0xffe6e6e6),
            200: Color(0xffcccccc),
            300: Color(0xffb3b3b3),
            400: Color(0xff999999),
            500: Color(0xff808080),
            600: Color(0xff666666),
            700: Color(0xff4d4d4d),
            800: Color(0xff333333),
            900: Color(0xff191919)
          })).copyWith(secondary: Color(0xff93766c)).copyWith(surface: Color(0xff616161)).copyWith(error: Color(0xffd32f2f)),
        );
      case "pinkLight":
        return ThemeData(
          fontFamily: font,
          brightness: Brightness.light,
          primaryColor: Color(0xffe0a6c1),
          primaryColorLight: Color(0xfff2d9e5),
          primaryColorDark: Color(0xff71284a),
          canvasColor: Color(0xfffafafa),
          scaffoldBackgroundColor: Color(0xfffafafa),
          cardColor: Color(0xffffffff),
          dividerColor: Color(0x1f000000),
          highlightColor: Color(0x66bcbcbc),
          splashColor: Color(0x66c8c8c8),
          unselectedWidgetColor: Color(0x8a000000),
          disabledColor: Color(0x61000000),
          secondaryHeaderColor: Color(0xfff8ecf2),
          indicatorColor: Color(0xffbd427b),
          hintColor: Color(0x8a000000),
          buttonTheme: ButtonThemeData(
            textTheme: ButtonTextTheme.accent,
            minWidth: 88,
            height: 48,
            padding: EdgeInsets.only(left: 16, right: 16),
            shape: RoundedRectangleBorder(
              side: BorderSide(
                color: Color(0xff000000),
                width: 0,
                style: BorderStyle.none,
              ),
              borderRadius: BorderRadius.all(
                Radius.circular(8),
              ),
            ),
            buttonColor: Color(0xffe0a6c1),
            disabledColor: Color(0x61000000),
            highlightColor: Color(0x29000000),
            splashColor: Color(0x1f000000),
            focusColor: Color(0x1f000000),
            hoverColor: Color(0x0a000000),
          ),
          inputDecorationTheme: InputDecorationTheme(
            contentPadding: EdgeInsets.only(
              top: 12,
              bottom: 12,
              left: 15,
              right: 15,
            ),
          ),
          chipTheme: ChipThemeData(
            backgroundColor: Color(0x1f000000),
            brightness: Brightness.light,
            deleteIconColor: Color(0xffbd427b),
            disabledColor: Color(0x0c000000),
            labelPadding: EdgeInsets.only(left: 8, right: 8),
            labelStyle: TextStyle(
              fontSize: 12,
              fontFamily: font,
              color: Colors.black,
              fontWeight: FontWeight.w400,
              fontStyle: FontStyle.normal,
            ),
            padding: EdgeInsets.all(4),
            secondaryLabelStyle: TextStyle(
              fontSize: 12,
              fontFamily: font,
              color: Colors.black,
              fontWeight: FontWeight.w400,
              fontStyle: FontStyle.normal,
            ),
            secondarySelectedColor: Color(0x3de5634d),
            selectedColor: Color(0x3de5634d),
            shape: StadiumBorder(
              side: BorderSide(
                color: Color(0xff000000),
                width: 0,
                style: BorderStyle.none,
              ),
            ),
          ),
          dialogTheme: DialogTheme(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.all(
                Radius.circular(8),
              ),
            ),
          ),
          cardTheme: CardTheme(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ), textSelectionTheme: TextSelectionThemeData(cursorColor: Color(0xff4285f4), selectionColor: Color(0xffe5b3ca), selectionHandleColor: Color(0xffd78eb0),), checkboxTheme: CheckboxThemeData(
 fillColor: WidgetStateProperty.resolveWith<Color?>((Set<WidgetState> states) {
 if (states.contains(WidgetState.disabled)) { return null; }
 if (states.contains(WidgetState.selected)) { return Color(0xff973563); }
 return null;
 }),
 ), radioTheme: RadioThemeData(
 fillColor: WidgetStateProperty.resolveWith<Color?>((Set<WidgetState> states) {
 if (states.contains(WidgetState.disabled)) { return null; }
 if (states.contains(WidgetState.selected)) { return Color(0xff973563); }
 return null;
 }),
 ), switchTheme: SwitchThemeData(
 thumbColor: WidgetStateProperty.resolveWith<Color?>((Set<WidgetState> states) {
 if (states.contains(WidgetState.disabled)) { return null; }
 if (states.contains(WidgetState.selected)) { return Color(0xff973563); }
 return null;
 }),
 trackColor: WidgetStateProperty.resolveWith<Color?>((Set<WidgetState> states) {
 if (states.contains(WidgetState.disabled)) { return null; }
 if (states.contains(WidgetState.selected)) { return Color(0xff973563); }
 return null;
 }),
 ), bottomAppBarTheme: BottomAppBarTheme(color: Color(0xffffffff)), colorScheme: ColorScheme.fromSwatch(primarySwatch: MaterialColor(4292912833, {
            50: Color(0xfff8ecf2),
            100: Color(0xfff2d9e5),
            200: Color(0xffe5b3ca),
            300: Color(0xffd78eb0),
            400: Color(0xffca6896),
            500: Color(0xffbd427b),
            600: Color(0xff973563),
            700: Color(0xff71284a),
            800: Color(0xff4c1a31),
            900: Color(0xff260d19)
          })).copyWith(secondary: Color(0xffbd427b)).copyWith(surface: Color(0xffe5b3ca)).copyWith(error: Color(0xffd32f2f)),
        );
      case "pinkDark":
        return ThemeData(
          fontFamily: font,
          brightness: Brightness.dark,
          primaryColor: Color(0xffe0a6c1),
          primaryColorLight: Color(0xff9e9e9e),
          primaryColorDark: Color(0xff000000),
          canvasColor: Colors.grey[900],
          scaffoldBackgroundColor: Color(0xff303030),
          cardColor: Color(0xff424242),
          dividerColor: Color(0x1fffffff),
          highlightColor: Color(0x40cccccc),
          splashColor: Color(0x40cccccc),
          unselectedWidgetColor: Color(0xb3ffffff),
          disabledColor: Color(0x62ffffff),
          secondaryHeaderColor: Color(0xff616161),
          indicatorColor: Color(0xffbd427b),
          hintColor: Color(0x80ffffff),
          appBarTheme: AppBarTheme(
            color: Colors.grey[900], systemOverlayStyle: SystemUiOverlayStyle.light,
          ),
          buttonTheme: ButtonThemeData(
            textTheme: ButtonTextTheme.accent,
            minWidth: 88,
            height: 48,
            padding: EdgeInsets.only(left: 16, right: 16),
            shape: RoundedRectangleBorder(
              side: BorderSide(
                color: Color(0xff000000),
                width: 0,
                style: BorderStyle.none,
              ),
              borderRadius: BorderRadius.all(
                Radius.circular(8),
              ),
            ),
            buttonColor: Color(0xffe0a6c1),
            disabledColor: Color(0x61ffffff),
            highlightColor: Color(0x29ffffff),
            splashColor: Color(0x1fffffff),
            focusColor: Color(0x1fffffff),
            hoverColor: Color(0x0affffff),
          ),
          inputDecorationTheme: InputDecorationTheme(
            contentPadding: EdgeInsets.only(
              top: 12,
              bottom: 12,
              left: 15,
              right: 15,
            ),
          ),
          chipTheme: ChipThemeData(
            backgroundColor: Color(0x1fffffff),
            brightness: Brightness.dark,
            deleteIconColor: Color(0xdeffffff),
            disabledColor: Color(0x0cffffff),
            labelPadding: EdgeInsets.only(left: 8, right: 8),
            labelStyle: TextStyle(
              fontSize: 12,
              fontFamily: font,
              color: Color(0xb3ffffff),
              fontWeight: FontWeight.w400,
              fontStyle: FontStyle.normal,
            ),
            padding: EdgeInsets.all(0),
            secondaryLabelStyle: TextStyle(
              fontSize: 12,
              fontFamily: font,
              color: Color(0xb3ffffff),
              fontWeight: FontWeight.w400,
              fontStyle: FontStyle.normal,
            ),
            secondarySelectedColor: Color(0x3d212121),
            selectedColor: Color(0x3dffffff),
            shape: StadiumBorder(
              side: BorderSide(
                color: Color(0xff000000),
                width: 0,
                style: BorderStyle.none,
              ),
            ),
          ),
          sliderTheme: SliderThemeData.fromPrimaryColors(
            primaryColor: Color(0xffe0a6c1),
            primaryColorLight: Color(0xfff2d9e5),
            primaryColorDark: Color(0xff71284a),
            valueIndicatorTextStyle: TextStyle(
              color: Color(0xffffffff),
              fontWeight: FontWeight.w400,
              fontStyle: FontStyle.normal,
            ),
          ),
          dialogTheme: DialogTheme(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.all(
                Radius.circular(8),
              ),
            ),
          ),
          cardTheme: CardTheme(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ), textSelectionTheme: TextSelectionThemeData(cursorColor: Color(0xff4285f4), selectionColor: Color(0xfff2b1a6), selectionHandleColor: Color(0xffec8a79),), checkboxTheme: CheckboxThemeData(
 fillColor: WidgetStateProperty.resolveWith<Color?>((Set<WidgetState> states) {
 if (states.contains(WidgetState.disabled)) { return null; }
 if (states.contains(WidgetState.selected)) { return Color(0xffbd427b); }
 return null;
 }),
 ), radioTheme: RadioThemeData(
 fillColor: WidgetStateProperty.resolveWith<Color?>((Set<WidgetState> states) {
 if (states.contains(WidgetState.disabled)) { return null; }
 if (states.contains(WidgetState.selected)) { return Color(0xffbd427b); }
 return null;
 }),
 ), switchTheme: SwitchThemeData(
 thumbColor: WidgetStateProperty.resolveWith<Color?>((Set<WidgetState> states) {
 if (states.contains(WidgetState.disabled)) { return null; }
 if (states.contains(WidgetState.selected)) { return Color(0xffbd427b); }
 return null;
 }),
 trackColor: WidgetStateProperty.resolveWith<Color?>((Set<WidgetState> states) {
 if (states.contains(WidgetState.disabled)) { return null; }
 if (states.contains(WidgetState.selected)) { return Color(0xffbd427b); }
 return null;
 }),
 ), bottomAppBarTheme: BottomAppBarTheme(color: Color(0xff424242)), colorScheme: ColorScheme.fromSwatch(primarySwatch: MaterialColor(4280361249, {
            50: Color(0xfff2f2f2),
            100: Color(0xffe6e6e6),
            200: Color(0xffcccccc),
            300: Color(0xffb3b3b3),
            400: Color(0xff999999),
            500: Color(0xff808080),
            600: Color(0xff666666),
            700: Color(0xff4d4d4d),
            800: Color(0xff333333),
            900: Color(0xff191919)
          })).copyWith(secondary: Color(0xffbd427b)).copyWith(surface: Color(0xff616161)).copyWith(error: Color(0xffd32f2f)),
        );
      case "pastelOrangeLight":
        return ThemeData(
          fontFamily: font,
          brightness: Brightness.light,
          primaryColor: Color(0xfff6bb41),
          primaryColorLight: Color(0xfffdeece),
          primaryColorDark: Color(0xff926507),
          canvasColor: Color(0xfffafafa),
          scaffoldBackgroundColor: Color(0xfffafafa),
          cardColor: Color(0xffffffff),
          dividerColor: Color(0x1f000000),
          highlightColor: Color(0x66bcbcbc),
          splashColor: Color(0x66c8c8c8),
          unselectedWidgetColor: Color(0x8a000000),
          disabledColor: Color(0x61000000),
          secondaryHeaderColor: Color(0xfffef6e7),
          indicatorColor: Color(0xfff3a80c),
          hintColor: Color(0x8a000000),
          buttonTheme: ButtonThemeData(
            textTheme: ButtonTextTheme.accent,
            minWidth: 88,
            height: 48,
            padding: EdgeInsets.only(left: 16, right: 16),
            shape: RoundedRectangleBorder(
              side: BorderSide(
                color: Color(0xff000000),
                width: 0,
                style: BorderStyle.none,
              ),
              borderRadius: BorderRadius.all(
                Radius.circular(8.0),
              ),
            ),
            buttonColor: Color(0xfff6bb41),
            disabledColor: Color(0x61000000),
            highlightColor: Color(0x29000000),
            splashColor: Color(0x1f000000),
            focusColor: Color(0x1f000000),
            hoverColor: Color(0x0a000000),
          ),
          inputDecorationTheme: InputDecorationTheme(
            contentPadding: EdgeInsets.only(
              top: 12,
              bottom: 12,
              left: 15,
              right: 15,
            ),
          ),
          chipTheme: ChipThemeData(
            backgroundColor: Color(0x1f000000),
            brightness: Brightness.light,
            deleteIconColor: Color(0xfff6bb41),
            disabledColor: Color(0x0c000000),
            labelPadding: EdgeInsets.only(left: 8, right: 8),
            labelStyle: TextStyle(
              fontSize: 12,
              fontFamily: font,
              color: Colors.black,
              fontWeight: FontWeight.w400,
              fontStyle: FontStyle.normal,
            ),
            padding: EdgeInsets.only(top: 4, bottom: 4, left: 4, right: 4),
            secondaryLabelStyle: TextStyle(
              fontSize: 12,
              fontFamily: font,
              color: Colors.black,
              fontWeight: FontWeight.w400,
              fontStyle: FontStyle.normal,
            ),
            secondarySelectedColor: Color(0x3df6bb41),
            selectedColor: Color(0x3df6bb41),
            shape: StadiumBorder(
              side: BorderSide(
                color: Color(0xff000000),
                width: 0,
                style: BorderStyle.none,
              ),
            ),
          ),
          dialogTheme: DialogTheme(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.all(
                Radius.circular(8),
              ),
            ),
          ),
          cardTheme: CardTheme(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ), textSelectionTheme: TextSelectionThemeData(cursorColor: Color(0xff4285f4), selectionColor: Color(0xfffadc9e), selectionHandleColor: Color(0xfff8cb6d),), checkboxTheme: CheckboxThemeData(
 fillColor: WidgetStateProperty.resolveWith<Color?>((Set<WidgetState> states) {
 if (states.contains(WidgetState.disabled)) { return null; }
 if (states.contains(WidgetState.selected)) { return Color(0xffc38609); }
 return null;
 }),
 ), radioTheme: RadioThemeData(
 fillColor: WidgetStateProperty.resolveWith<Color?>((Set<WidgetState> states) {
 if (states.contains(WidgetState.disabled)) { return null; }
 if (states.contains(WidgetState.selected)) { return Color(0xffc38609); }
 return null;
 }),
 ), switchTheme: SwitchThemeData(
 thumbColor: WidgetStateProperty.resolveWith<Color?>((Set<WidgetState> states) {
 if (states.contains(WidgetState.disabled)) { return null; }
 if (states.contains(WidgetState.selected)) { return Color(0xffc38609); }
 return null;
 }),
 trackColor: WidgetStateProperty.resolveWith<Color?>((Set<WidgetState> states) {
 if (states.contains(WidgetState.disabled)) { return null; }
 if (states.contains(WidgetState.selected)) { return Color(0xffc38609); }
 return null;
 }),
 ), bottomAppBarTheme: BottomAppBarTheme(color: Color(0xffffffff)), colorScheme: ColorScheme.fromSwatch(primarySwatch: MaterialColor(4294359873, {
            50: Color(0xfffef6e7),
            100: Color(0xfffdeece),
            200: Color(0xfffadc9e),
            300: Color(0xfff8cb6d),
            400: Color(0xfff6b93c),
            500: Color(0xfff3a80c),
            600: Color(0xffc38609),
            700: Color(0xff926507),
            800: Color(0xff614305),
            900: Color(0xff312202)
          })).copyWith(secondary: Color(0xfff3a80c)).copyWith(surface: Color(0xfffadc9e)).copyWith(error: Color(0xffd32f2f)),
        );
      case "pastelOrangeDark":
        return ThemeData(
          fontFamily: font,
          brightness: Brightness.dark,
          primaryColor: Color(0xfff6bb41),
          primaryColorLight: Color(0xff9e9e9e),
          primaryColorDark: Color(0xff000000),
          canvasColor: Colors.grey[900],
          scaffoldBackgroundColor: Color(0xff303030),
          cardColor: Color(0xff424242),
          dividerColor: Color(0x1fffffff),
          highlightColor: Color(0x40cccccc),
          splashColor: Color(0x40cccccc),
          unselectedWidgetColor: Color(0xb3ffffff),
          disabledColor: Color(0x62ffffff),
          secondaryHeaderColor: Color(0xff616161),
          indicatorColor: Color(0xfff3a80c),
          hintColor: Color(0x80ffffff),
          appBarTheme: AppBarTheme(
            color: Colors.grey[900], systemOverlayStyle: SystemUiOverlayStyle.light,
          ),
          buttonTheme: ButtonThemeData(
            textTheme: ButtonTextTheme.accent,
            minWidth: 88,
            height: 48,
            padding: EdgeInsets.only(left: 16, right: 16),
            shape: RoundedRectangleBorder(
              side: BorderSide(
                color: Color(0xff000000),
                width: 0,
                style: BorderStyle.none,
              ),
              borderRadius: BorderRadius.all(
                Radius.circular(8.0),
              ),
            ),
            buttonColor: Color(0xfff6bb41),
            disabledColor: Color(0x61ffffff),
            highlightColor: Color(0x29ffffff),
            splashColor: Color(0x1fffffff),
            focusColor: Color(0x1fffffff),
            hoverColor: Color(0x0affffff),
          ),
          inputDecorationTheme: InputDecorationTheme(
            contentPadding: EdgeInsets.only(
              top: 12,
              bottom: 12,
              left: 15,
              right: 15,
            ),
          ),
          sliderTheme: SliderThemeData.fromPrimaryColors(
            primaryColor: Color(0xfff6bb41),
            primaryColorLight: Color(0xfffdeece),
            primaryColorDark: Color(0xff926507),
            valueIndicatorTextStyle: TextStyle(
              color: Color(0xffffffff),
              fontWeight: FontWeight.w400,
              fontStyle: FontStyle.normal,
            ),
          ),
          chipTheme: ChipThemeData(
            backgroundColor: Color(0x1fffffff),
            brightness: Brightness.dark,
            deleteIconColor: Color(0xdeffffff),
            disabledColor: Color(0x0cffffff),
            labelPadding: EdgeInsets.only(left: 8, right: 8),
            labelStyle: TextStyle(
              color: Color(0xdeffffff),
              fontSize: 12,
              fontFamily: font,
              fontWeight: FontWeight.w400,
              fontStyle: FontStyle.normal,
            ),
            padding: EdgeInsets.only(top: 4, bottom: 4, left: 4, right: 4),
            secondaryLabelStyle: TextStyle(
              color: Color(0x3dffffff),
              fontSize: 12,
              fontFamily: font,
              fontWeight: FontWeight.w400,
              fontStyle: FontStyle.normal,
            ),
            secondarySelectedColor: Color(0x3d212121),
            selectedColor: Color(0x3dffffff),
            shape: StadiumBorder(
                side: BorderSide(
              color: Color(0xff000000),
              width: 0,
              style: BorderStyle.none,
            )),
          ),
          dialogTheme: DialogTheme(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.all(
                Radius.circular(8),
              ),
            ),
          ),
          cardTheme: CardTheme(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ), textSelectionTheme: TextSelectionThemeData(cursorColor: Color(0xff4285f4), selectionColor: Color(0xfff3a80c), selectionHandleColor: Color(0xfff3a80c),), checkboxTheme: CheckboxThemeData(
 fillColor: WidgetStateProperty.resolveWith<Color?>((Set<WidgetState> states) {
 if (states.contains(WidgetState.disabled)) { return null; }
 if (states.contains(WidgetState.selected)) { return Color(0xfff3a80c); }
 return null;
 }),
 ), radioTheme: RadioThemeData(
 fillColor: WidgetStateProperty.resolveWith<Color?>((Set<WidgetState> states) {
 if (states.contains(WidgetState.disabled)) { return null; }
 if (states.contains(WidgetState.selected)) { return Color(0xfff3a80c); }
 return null;
 }),
 ), switchTheme: SwitchThemeData(
 thumbColor: WidgetStateProperty.resolveWith<Color?>((Set<WidgetState> states) {
 if (states.contains(WidgetState.disabled)) { return null; }
 if (states.contains(WidgetState.selected)) { return Color(0xfff3a80c); }
 return null;
 }),
 trackColor: WidgetStateProperty.resolveWith<Color?>((Set<WidgetState> states) {
 if (states.contains(WidgetState.disabled)) { return null; }
 if (states.contains(WidgetState.selected)) { return Color(0xfff3a80c); }
 return null;
 }),
 ), bottomAppBarTheme: BottomAppBarTheme(color: Color(0xff424242)), colorScheme: ColorScheme.fromSwatch(primarySwatch: MaterialColor(4280361249, {
            50: Color(0xfff2f2f2),
            100: Color(0xffe6e6e6),
            200: Color(0xffcccccc),
            300: Color(0xffb3b3b3),
            400: Color(0xff999999),
            500: Color(0xff808080),
            600: Color(0xff666666),
            700: Color(0xff4d4d4d),
            800: Color(0xff333333),
            900: Color(0xff191919)
          })).copyWith(secondary: Color(0xfff3a80c)).copyWith(surface: Color(0xff616161)).copyWith(error: Color(0xffd32f2f)),
        );
      case "greenLight":
        return ThemeData(
          fontFamily: font,
          brightness: Brightness.light,
          primaryColor: Color(0xff93b7b0),
          primaryColorLight: Color(0xffe0ebe9),
          primaryColorDark: Color(0xff3d5c56),
          canvasColor: Color(0xfffafafa),
          scaffoldBackgroundColor: Color(0xfffafafa),
          cardColor: Color(0xffffffff),
          dividerColor: Color(0x1f000000),
          highlightColor: Color(0x66bcbcbc),
          splashColor: Color(0x66c8c8c8),
          unselectedWidgetColor: Color(0x8a000000),
          disabledColor: Color(0x61000000),
          secondaryHeaderColor: Color(0xfff0f5f4),
          indicatorColor: Color(0xff66998f),
          hintColor: Color(0x8a000000),
          buttonTheme: ButtonThemeData(
            textTheme: ButtonTextTheme.accent,
            minWidth: 88,
            height: 48,
            padding: EdgeInsets.only(left: 16, right: 16),
            shape: RoundedRectangleBorder(
              side: BorderSide(
                color: Color(0xff000000),
                width: 0,
                style: BorderStyle.none,
              ),
              borderRadius: BorderRadius.all(
                Radius.circular(8.0),
              ),
            ),
            buttonColor: Color(0xff93b7b0),
            disabledColor: Color(0x61000000),
            highlightColor: Color(0x29000000),
            splashColor: Color(0x1f000000),
            focusColor: Color(0x1f000000),
            hoverColor: Color(0x0a000000),
          ),
          inputDecorationTheme: InputDecorationTheme(
            contentPadding: EdgeInsets.only(
              top: 12,
              bottom: 12,
              left: 15,
              right: 15,
            ),
          ),
          chipTheme: ChipThemeData(
            backgroundColor: Color(0x1f000000),
            brightness: Brightness.light,
            deleteIconColor: Color(0xde000000),
            disabledColor: Color(0x0c000000),
            labelPadding: EdgeInsets.only(left: 8, right: 8),
            labelStyle: TextStyle(
              fontSize: 12,
              fontFamily: font,
              color: Colors.black,
              fontWeight: FontWeight.w400,
              fontStyle: FontStyle.normal,
            ),
            padding: EdgeInsets.only(top: 4, bottom: 4, left: 4, right: 4),
            secondaryLabelStyle: TextStyle(
              fontSize: 12,
              fontFamily: font,
              color: Colors.black,
              fontWeight: FontWeight.w400,
              fontStyle: FontStyle.normal,
            ),
            secondarySelectedColor: Color(0x3d93b7b0),
            selectedColor: Color(0x3d93b7b0),
            shape: StadiumBorder(
              side: BorderSide(
                color: Color(0xff000000),
                width: 0,
                style: BorderStyle.none,
              ),
            ),
          ),
          dialogTheme: DialogTheme(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.all(
                Radius.circular(8),
              ),
            ),
          ),
          cardTheme: CardTheme(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ), textSelectionTheme: TextSelectionThemeData(cursorColor: Color(0xff4285f4), selectionColor: Color(0xffc2d6d2), selectionHandleColor: Color(0xffa3c2bc),), checkboxTheme: CheckboxThemeData(
 fillColor: WidgetStateProperty.resolveWith<Color?>((Set<WidgetState> states) {
 if (states.contains(WidgetState.disabled)) { return null; }
 if (states.contains(WidgetState.selected)) { return Color(0xff527a72); }
 return null;
 }),
 ), radioTheme: RadioThemeData(
 fillColor: WidgetStateProperty.resolveWith<Color?>((Set<WidgetState> states) {
 if (states.contains(WidgetState.disabled)) { return null; }
 if (states.contains(WidgetState.selected)) { return Color(0xff527a72); }
 return null;
 }),
 ), switchTheme: SwitchThemeData(
 thumbColor: WidgetStateProperty.resolveWith<Color?>((Set<WidgetState> states) {
 if (states.contains(WidgetState.disabled)) { return null; }
 if (states.contains(WidgetState.selected)) { return Color(0xff527a72); }
 return null;
 }),
 trackColor: WidgetStateProperty.resolveWith<Color?>((Set<WidgetState> states) {
 if (states.contains(WidgetState.disabled)) { return null; }
 if (states.contains(WidgetState.selected)) { return Color(0xff527a72); }
 return null;
 }),
 ), bottomAppBarTheme: BottomAppBarTheme(color: Color(0xffffffff)), colorScheme: ColorScheme.fromSwatch(primarySwatch: MaterialColor(4287870896, {
            50: Color(0xfff0f5f4),
            100: Color(0xffe0ebe9),
            200: Color(0xffc2d6d2),
            300: Color(0xffa3c2bc),
            400: Color(0xff85ada5),
            500: Color(0xff66998f),
            600: Color(0xff527a72),
            700: Color(0xff3d5c56),
            800: Color(0xff293d39),
            900: Color(0xff141f1d)
          })).copyWith(secondary: Color(0xff66998f)).copyWith(surface: Color(0xffc2d6d2)).copyWith(error: Color(0xffd32f2f)),
        );
      case "greenDark":
        return ThemeData(
          fontFamily: font,
          brightness: Brightness.dark,
          primaryColor: Color(0xff93b7b0),
          primaryColorLight: Color(0xff9e9e9e),
          primaryColorDark: Color(0xff000000),
          canvasColor: Colors.grey[900],
          scaffoldBackgroundColor: Color(0xff303030),
          cardColor: Color(0xff424242),
          dividerColor: Color(0x1fffffff),
          highlightColor: Color(0x40cccccc),
          splashColor: Color(0x40cccccc),
          unselectedWidgetColor: Color(0xb3ffffff),
          disabledColor: Color(0x62ffffff),
          secondaryHeaderColor: Color(0xff616161),
          indicatorColor: Color(0xff3d5c56),
          hintColor: Color(0x80ffffff),
          appBarTheme: AppBarTheme(
            color: Colors.grey[900], systemOverlayStyle: SystemUiOverlayStyle.light,
          ),
          buttonTheme: ButtonThemeData(
            textTheme: ButtonTextTheme.accent,
            minWidth: 88,
            height: 48,
            padding: EdgeInsets.only(left: 16, right: 16),
            shape: RoundedRectangleBorder(
              side: BorderSide(
                color: Color(0xff000000),
                width: 0,
                style: BorderStyle.none,
              ),
              borderRadius: BorderRadius.all(
                Radius.circular(8.0),
              ),
            ),
            buttonColor: Color(0xff93b7b0),
            disabledColor: Color(0x61ffffff),
            highlightColor: Color(0x29ffffff),
            splashColor: Color(0x1fffffff),
            focusColor: Color(0x1fffffff),
            hoverColor: Color(0x0affffff),
          ),
          inputDecorationTheme: InputDecorationTheme(
            contentPadding: EdgeInsets.only(
              top: 12,
              bottom: 12,
              left: 15,
              right: 15,
            ),
          ),
          sliderTheme: SliderThemeData.fromPrimaryColors(
            primaryColor: Color(0xff93b7b0),
            primaryColorLight: Color(0xffe0ebe9),
            primaryColorDark: Color(0xff3d5c56),
            valueIndicatorTextStyle: TextStyle(
              color: Color(0xffffffff),
              fontWeight: FontWeight.w400,
              fontStyle: FontStyle.normal,
            ),
          ),
          chipTheme: ChipThemeData(
            backgroundColor: Color(0x1fffffff),
            brightness: Brightness.dark,
            deleteIconColor: Color(0xdeffffff),
            disabledColor: Color(0x0cffffff),
            labelPadding: EdgeInsets.only(left: 8, right: 8),
            labelStyle: TextStyle(
              fontSize: 12,
              fontFamily: font,
              color: Color(0xb3ffffff),
              fontWeight: FontWeight.w400,
              fontStyle: FontStyle.normal,
            ),
            padding: EdgeInsets.only(top: 4, bottom: 4, left: 4, right: 4),
            secondaryLabelStyle: TextStyle(
              fontSize: 12,
              fontFamily: font,
              color: Color(0xb3ffffff),
              fontWeight: FontWeight.w400,
              fontStyle: FontStyle.normal,
            ),
            secondarySelectedColor: Color(0x3d212121),
            selectedColor: Color(0x3dffffff),
            shape: StadiumBorder(
              side: BorderSide(
                color: Color(0xff000000),
                width: 0,
                style: BorderStyle.none,
              ),
            ),
          ),
          dialogTheme: DialogTheme(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.all(
                Radius.circular(8),
              ),
            ),
          ),
          cardTheme: CardTheme(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ), textSelectionTheme: TextSelectionThemeData(cursorColor: Color(0xff4285f4), selectionColor: Color(0xff3d5c56), selectionHandleColor: Color(0xff3d5c56),), checkboxTheme: CheckboxThemeData(
 fillColor: WidgetStateProperty.resolveWith<Color?>((Set<WidgetState> states) {
 if (states.contains(WidgetState.disabled)) { return null; }
 if (states.contains(WidgetState.selected)) { return Color(0xff3d5c56); }
 return null;
 }),
 ), radioTheme: RadioThemeData(
 fillColor: WidgetStateProperty.resolveWith<Color?>((Set<WidgetState> states) {
 if (states.contains(WidgetState.disabled)) { return null; }
 if (states.contains(WidgetState.selected)) { return Color(0xff3d5c56); }
 return null;
 }),
 ), switchTheme: SwitchThemeData(
 thumbColor: WidgetStateProperty.resolveWith<Color?>((Set<WidgetState> states) {
 if (states.contains(WidgetState.disabled)) { return null; }
 if (states.contains(WidgetState.selected)) { return Color(0xff3d5c56); }
 return null;
 }),
 trackColor: WidgetStateProperty.resolveWith<Color?>((Set<WidgetState> states) {
 if (states.contains(WidgetState.disabled)) { return null; }
 if (states.contains(WidgetState.selected)) { return Color(0xff3d5c56); }
 return null;
 }),
 ), bottomAppBarTheme: BottomAppBarTheme(color: Color(0xff424242)), colorScheme: ColorScheme.fromSwatch(primarySwatch: MaterialColor(4280361249, {
            50: Color(0xfff2f2f2),
            100: Color(0xffe6e6e6),
            200: Color(0xffcccccc),
            300: Color(0xffb3b3b3),
            400: Color(0xff999999),
            500: Color(0xff808080),
            600: Color(0xff666666),
            700: Color(0xff4d4d4d),
            800: Color(0xff333333),
            900: Color(0xff191919)
          })).copyWith(secondary: Color(0xff3d5c56)).copyWith(surface: Color(0xff616161)).copyWith(error: Color(0xffd32f2f)),
        );

      default:
        return ThemeData(
          fontFamily: font,
          brightness: Brightness.light,
          primaryColor: Color(0xffe5634d),
          primaryColorLight: Color(0xffFF8A65),
          primaryColorDark: Color(0xff862413),
          canvasColor: Color(0xfffafafa),
          scaffoldBackgroundColor: Color(0xfffafafa),
          cardColor: Color(0xffffffff),
          dividerColor: Color(0x1f000000),
          highlightColor: Color(0x66bcbcbc),
          splashColor: Color(0x66c8c8c8),
          unselectedWidgetColor: Color(0x8a000000),
          disabledColor: Color(0x61000000),
          secondaryHeaderColor: Color(0xfffcebe9),
          indicatorColor: Color(0xff4A90A4),
          hintColor: Color(0x8a000000),
          buttonTheme: ButtonThemeData(
            textTheme: ButtonTextTheme.accent,
            minWidth: 88,
            height: 48,
            padding: EdgeInsets.only(left: 16, right: 16),
            shape: RoundedRectangleBorder(
              side: BorderSide(
                color: Color(0xff000000),
                width: 0,
                style: BorderStyle.none,
              ),
              borderRadius: BorderRadius.all(
                Radius.circular(8),
              ),
            ),
            buttonColor: Color(0xffe5634d),
            disabledColor: Color(0x61000000),
            highlightColor: Color(0x29000000),
            splashColor: Color(0x1f000000),
            focusColor: Color(0x1f000000),
            hoverColor: Color(0x0a000000),
          ),
          inputDecorationTheme: InputDecorationTheme(
            contentPadding: EdgeInsets.only(
              top: 12,
              bottom: 12,
              left: 15,
              right: 15,
            ),
          ),
          chipTheme: ChipThemeData(
            backgroundColor: Color(0x1f000000),
            brightness: Brightness.light,
            deleteIconColor: Color(0xffdf3c20),
            disabledColor: Color(0x0c000000),
            labelPadding: EdgeInsets.only(left: 8, right: 8),
            labelStyle: TextStyle(
              fontSize: 12,
              fontFamily: font,
              color: Colors.black,
              fontWeight: FontWeight.w400,
              fontStyle: FontStyle.normal,
            ),
            padding: EdgeInsets.all(4),
            secondaryLabelStyle: TextStyle(
              fontSize: 12,
              fontFamily: font,
              color: Colors.black,
              fontWeight: FontWeight.w400,
              fontStyle: FontStyle.normal,
            ),
            secondarySelectedColor: Color(0x3de5634d),
            selectedColor: Color(0x3de5634d),
            shape: StadiumBorder(
              side: BorderSide(
                color: Color(0xff000000),
                width: 0,
                style: BorderStyle.none,
              ),
            ),
          ),
          dialogTheme: DialogTheme(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.all(
                Radius.circular(8),
              ),
            ),
          ),
          cardTheme: CardTheme(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ), textSelectionTheme: TextSelectionThemeData(cursorColor: Color(0xff4285f4), selectionColor: Color(0xff4A90A4), selectionHandleColor: Color(0xff4A90A4),), checkboxTheme: CheckboxThemeData(
 fillColor: WidgetStateProperty.resolveWith<Color?>((Set<WidgetState> states) {
 if (states.contains(WidgetState.disabled)) { return null; }
 if (states.contains(WidgetState.selected)) { return Color(0xff4A90A4); }
 return null;
 }),
 ), radioTheme: RadioThemeData(
 fillColor: WidgetStateProperty.resolveWith<Color?>((Set<WidgetState> states) {
 if (states.contains(WidgetState.disabled)) { return null; }
 if (states.contains(WidgetState.selected)) { return Color(0xff4A90A4); }
 return null;
 }),
 ), switchTheme: SwitchThemeData(
 thumbColor: WidgetStateProperty.resolveWith<Color?>((Set<WidgetState> states) {
 if (states.contains(WidgetState.disabled)) { return null; }
 if (states.contains(WidgetState.selected)) { return Color(0xff4A90A4); }
 return null;
 }),
 trackColor: WidgetStateProperty.resolveWith<Color?>((Set<WidgetState> states) {
 if (states.contains(WidgetState.disabled)) { return null; }
 if (states.contains(WidgetState.selected)) { return Color(0xff4A90A4); }
 return null;
 }),
 ), bottomAppBarTheme: BottomAppBarTheme(color: Color(0xffffffff)), colorScheme: ColorScheme.fromSwatch(primarySwatch: MaterialColor(4293223245, {
            50: Color(0xfffcebe9),
            100: Color(0xfff9d8d3),
            200: Color(0xfff2b1a6),
            300: Color(0xffec8a79),
            400: Color(0xffe5634d),
            500: Color(0xffdf3c20),
            600: Color(0xffb2301a),
            700: Color(0xff862413),
            800: Color(0xff59180d),
            900: Color(0xff2d0c06)
          })).copyWith(secondary: Color(0xff4A90A4)).copyWith(surface: Color(0xfff2b1a6)).copyWith(error: Color(0xffd32f2f)),
        );
    }
  }

  // Singleton factory
  static final CollectionTheme _instance = CollectionTheme._internal();

  factory CollectionTheme() {
    return _instance;
  }

  CollectionTheme._internal();
}
