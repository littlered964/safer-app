import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:safer/configs/config.dart';
import 'package:safer/models/model.dart';
import 'package:safer/widgets/widget.dart';

class AppMessageItem extends StatelessWidget {
  final MessageModel item;
  final VoidCallback onPressed;
  final bool border;

  const AppMessageItem({
    Key? key,
    required this.item,
    required this.onPressed,
    this.border = true,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onPressed,
      child: Container(
        padding: const EdgeInsets.only(top: 8, bottom: 8, left: 20, right: 20),
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
            AppGroupCircleAvatar(
              size: 48,
              member: item.member,
            ),
            Expanded(
              child: Container(
                padding: const EdgeInsets.only(left: 8, right: 8),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: <Widget>[
                        Expanded(
                          child: Text(
                            item.roomName,
                            maxLines: 1,
                            style: Theme.of(context)
                                .textTheme
                                .titleSmall
                                ?.copyWith(fontWeight: FontWeight.w600),
                          ),
                        ),
                        Text(
                          DateFormat(
                            'EEE MMM d yyyy',
                            AppLanguage.defaultLanguage.languageCode,
                          ).format(item.date),
                          style: Theme.of(context).textTheme.bodySmall,
                        ),
                      ],
                    ),
                    const Padding(
                      padding: EdgeInsets.only(top: 3),
                    ),
                    Text(
                      item.message,
                      maxLines: 1,
                      style: Theme.of(context)
                          .textTheme
                          .bodySmall
                          ?.copyWith(fontWeight: FontWeight.w500),
                    )
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
