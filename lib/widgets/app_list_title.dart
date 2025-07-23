import 'package:flutter/material.dart';

class AppListTitle extends StatelessWidget {
  final String title;
  final Widget? trailing;
  final VoidCallback? onPressed;
  final bool border;
  final TextStyle? textStyle;

  const AppListTitle({
    Key? key,
    required this.title, // <-- now required
    this.trailing,
    this.onPressed,
    this.border = true,
    this.textStyle,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onPressed,
      child: Container(
        decoration: BoxDecoration(
          border: border
              ? Border(
                  bottom: BorderSide(
                    width: 1,
                    color: Theme.of(context).dividerColor,
                  ),
                )
              : null,
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: <Widget>[
            Padding(
              padding: const EdgeInsets.only(top: 20, bottom: 20),
              child: Text(
                title,
                style: textStyle ?? Theme.of(context).textTheme.titleMedium,
              ),
            ),
            trailing ?? const SizedBox.shrink(), // <-- no null errors
          ],
        ),
      ),
    );
  }
}
