import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:safer/blocs/bloc.dart';
import 'package:safer/configs/config.dart';
import 'package:safer/utils/utils.dart';
import 'package:safer/widgets/widget.dart';

class FontSetting extends StatefulWidget {
  const FontSetting({Key? key}) : super(key: key);

  @override
  _FontSettingState createState() => _FontSettingState();
}

class _FontSettingState extends State<FontSetting> {
  late ThemeBloc _themeBloc;
  String _currentFont = AppTheme.currentFont;

  @override
  void initState() {
    _themeBloc = BlocProvider.of<ThemeBloc>(context);
    super.initState();
  }

  // On change Font
  void _onChange() async {
    final currentTheme = AppTheme.currentTheme;
    final currentDarkOption = AppTheme.darkThemeOption;

    _themeBloc.add(ChangeTheme(
      theme: currentTheme,
      font: _currentFont,
      darkOption: currentDarkOption,
    ));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: Text(Translate.of(context).translate('font')),
      ),
      body: SafeArea(
        child: Column(
          children: <Widget>[
            Expanded(
              child: ListView.builder(
                padding: const EdgeInsets.only(left: 20, right: 20, top: 10),
                itemCount: AppTheme.fontSupport.length,
                itemBuilder: (context, index) {
                  final item = AppTheme.fontSupport[index];
                  final trailing = item == _currentFont
                      ? Icon(Icons.check, color: Theme.of(context).primaryColor)
                      : const SizedBox.shrink();

                  final baseStyle = Theme.of(context).textTheme.titleMedium ??
                      const TextStyle(fontSize: 16);

                  return AppListTitle(
                    title: item,
                    trailing: trailing,
                    onPressed: () {
                      setState(() {
                        _currentFont = item;
                      });
                    },
                    textStyle: baseStyle.copyWith(fontFamily: item),
                  );
                },
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
              child: BlocBuilder<ThemeBloc, ThemeState>(
                builder: (context, theme) {
                  return AppButton(
                    onPressed: _onChange,
                    text: Translate.of(context).translate('apply'),
                    loading: theme is ThemeUpdating,
                    disableTouchWhenLoading: true,
                  );
                },
              ),
            )
          ],
        ),
      ),
    );
  }
}
