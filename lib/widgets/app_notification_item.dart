import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:safer/configs/config.dart';
import 'package:safer/models/model.dart';

class AppNotificationItem extends StatelessWidget {
  final NotificationModel item;
  final VoidCallback onPressed;
  final bool border;

  const AppNotificationItem({
    super.key,
    required this.item,
    required this.onPressed,
    this.border = true,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onPressed,
      child: Container(
        padding: EdgeInsets.only(top: 8, bottom: 8, left: 20, right: 20),
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
          crossAxisAlignment: CrossAxisAlignment.center,
          children: <Widget>[
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: item.category.color,
              ),
              child: Icon(
                item.category.icon,
                color: Colors.white,
              ),
            ),
            Expanded(
              child: Container(
                padding: EdgeInsets.only(left: 8, right: 8),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: <Widget>[
                        Expanded(
                          child: Text(
                            item.title,
                            maxLines: 1,
                            style: Theme.of(context).textTheme.titleSmall,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        Text(
                          DateFormat(
                            'hh:mm, MMM dd yyyy',
                            AppLanguage.defaultLanguage.languageCode,
                          ).format(item.date),
                          style: Theme.of(context).textTheme.bodySmall,
                        )
                      ],
                    ),
                    Padding(
                      padding: EdgeInsets.only(top: 3),
                    ),
                    Text(
                      item.subtitle,
                      maxLines: 1,
                      style: Theme.of(context)
                        .textTheme
                        .bodySmall
                        ?.copyWith(fontWeight: FontWeight.w500),
                      overflow: TextOverflow.ellipsis,
                    )
                  ],
                ),
              ),
            )
          ],
        ),
      ),
    );
  }
}
