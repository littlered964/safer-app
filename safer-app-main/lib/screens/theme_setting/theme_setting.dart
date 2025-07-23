import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:safer/blocs/bloc.dart';
import 'package:safer/configs/config.dart';
import 'package:safer/models/model.dart';
import 'package:safer/utils/utils.dart';
import 'package:safer/widgets/widget.dart';

class ThemeSetting extends StatefulWidget {
  const ThemeSetting({Key? key}) : super(key: key);

  @override
  _ThemeSettingState createState() {
    return _ThemeSettingState();
  }
}

class _ThemeSettingState extends State<ThemeSetting> {
  late ThemeBloc _themeBloc;
  ThemeModel _currentTheme = AppTheme.currentTheme;

  @override
  void initState() {
    _themeBloc = BlocProvider.of<ThemeBloc>(context);
    super.initState();
  }

  void _onChange() {
    final currentFont = AppTheme.currentFont;
    final currentDarkOption = AppTheme.darkThemeOption;

    _themeBloc.add(ChangeTheme(
      theme: _currentTheme,
      font: currentFont,
      darkOption: currentDarkOption,
    ));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: Text(
          Translate.of(context).translate('theme'),
        ),
      ),
      body: SafeArea(
        child: Column(
          children: <Widget>[
            Expanded(
              child: ListView.builder(
                padding: const EdgeInsets.only(left: 20, right: 20, top: 10),
                itemBuilder: (context, index) {
                  final item = AppTheme.themeSupport[index];
                  final selected = item.name == _currentTheme.name;
                  return InkWell(
                    onTap: () {
                      setState(() {
                        _currentTheme = item;
                      });
                    },
                    child: Container(
                      decoration: BoxDecoration(
                        border: Border(
                          bottom: BorderSide(
                            width: 1,
                            color: Theme.of(context).dividerColor,
                          ),
                        ),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.only(top: 20, bottom: 20),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: <Widget>[
                            Row(
                              children: <Widget>[
                                Container(
                                  width: 24,
                                  height: 24,
                                  color: item.color,
                                ),
                                const Padding(
                                  padding: EdgeInsets.only(left: 10),
                                ),
                                Text(
                                  Translate.of(context).translate(item.name),
                                  style: Theme.of(context).textTheme.titleSmall,
                                )
                              ],
                            ),
                            selected
                                ? Icon(
                                    Icons.check,
                                    color: Theme.of(context).primaryColor,
                                  )
                                : Container()
                          ],
                        ),
                      ),
                    ),
                  );
                },
                itemCount: AppTheme.themeSupport.length,
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(
                left: 20,
                right: 20,
                top: 15,
                bottom: 15,
              ),
              child: BlocBuilder<ThemeBloc, ThemeState>(
                builder: (context, theme) {
                  return AppButton(
                    onPressed: _onChange,
                    text: Translate.of(context).translate('apply'),
                    font: Theme.of(context).textTheme.titleMedium,
                    loading: theme is ThemeUpdating,
                    disableTouchWhenLoading: true,
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
