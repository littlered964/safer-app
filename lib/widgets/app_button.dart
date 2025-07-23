import 'package:flutter/material.dart';

class AppButton extends StatelessWidget {
  final VoidCallback? onPressed;
  final String text;
  final TextStyle? font;
  final bool loading;
  final bool disableTouchWhenLoading;
  final OutlinedBorder? shape;

  const AppButton({
    Key? key,
    required this.onPressed,
    required this.text,
    this.font,
    this.loading = false,
    this.disableTouchWhenLoading = false,
    this.shape,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      style: ElevatedButton.styleFrom(shape: shape),
      onPressed: disableTouchWhenLoading && loading ? null : onPressed,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            text,
            style: font ??
                Theme.of(context)
                    .textTheme
                    .labelLarge
                    ?.copyWith(color: Colors.white, fontWeight: FontWeight.w600),
          ),
          if (loading) ...[
            const SizedBox(width: 10),
            const SizedBox(
              width: 14,
              height: 14,
              child: CircularProgressIndicator(strokeWidth: 2),
            ),
          ],
        ],
      ),
    );
  }
}
