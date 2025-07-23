import 'package:flutter/material.dart';
import 'package:safer/models/model.dart';

enum AppUserType { basic, information }

class AppUserInfo extends StatelessWidget {
  final UserModel user;
  final VoidCallback? onPressed;
  final AppUserType type;

  const AppUserInfo({
    super.key,
    required this.user,
    this.onPressed,
    this.type = AppUserType.basic,
  });

  @override
  Widget build(BuildContext context) {
    switch (type) {
      case AppUserType.information:
        return InkWell(
          onTap: onPressed,
          child: Row(
            children: <Widget>[
              Stack(
                alignment: Alignment.bottomRight,
                children: <Widget>[
                  Container(
                    width: 60,
                    height: 60,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      image: DecorationImage(
                        image: AssetImage(user.image),
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                  Container(
                    padding: EdgeInsets.all(5),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: Theme.of(context).primaryColor,
                    ),
                    child: Text(
                      "${user.rate}",
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 8,
                      ),
                    ),
                  )
                ],
              ),
              Expanded(
                child: Padding(
                  padding: EdgeInsets.only(left: 10, right: 10),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Text(
                        user.name,
                        maxLines: 1,
                        style: Theme.of(context).textTheme.titleSmall,
                      ),
                      Padding(
                        padding: EdgeInsets.symmetric(vertical: 3),
                        child: Text(
                          user.description,
                          maxLines: 1,
                          style: Theme.of(context).textTheme.bodySmall,
                        ),
                      ),
                      Text(
                        user.tag,
                        maxLines: 1,
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        );

      default:
        return Row(
          children: <Widget>[
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                image: DecorationImage(
                  image: AssetImage(user.image),
                  fit: BoxFit.cover,
                ),
              ),
            ),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text(
                    user.name,
                    style: Theme.of(context)
                        .textTheme
                        .titleMedium
                        ?.copyWith(fontWeight: FontWeight.w600),
                  ),
                  Text(
                    user.description,
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                ],
              ),
            )
          ],
        );
    }
  }
}
