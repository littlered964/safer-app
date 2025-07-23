import 'package:flutter/material.dart';
import 'package:safer/utils/utils.dart';

class AppProfilePerformance extends StatelessWidget {
  final List<Map<String, dynamic>> data;
  final Function(Map<String, dynamic>) onPressed;

  const AppProfilePerformance({
    super.key,
    required this.data,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(top: 10),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: data.map((item) {
          return InkWell(
            onTap: () {
              onPressed(item);
            },
            child: Column(
              children: <Widget>[
                Text(
                  item['value'],
                  style: Theme.of(context).textTheme.titleSmall,
                ),
                Text(
                  Translate.of(context).translate(
                    item['title'],
                  ),
                  style: Theme.of(context).textTheme.bodySmall,
                )
              ],
            ),
          );
        }).toList(),
      ),
    );
  }
}
