import 'package:flutter/material.dart';

class ActionButton extends StatelessWidget {
  const ActionButton({super.key, this.actionText, this.onPressed});
  final String? actionText;
  final void Function()? onPressed;

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      clipBehavior: Clip.none,
      style: ElevatedButton.styleFrom(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        backgroundColor: Theme.of(context).colorScheme.error,
        foregroundColor: Theme.of(context).colorScheme.onPrimary,
      ),
      onPressed: onPressed,
      child: Text('OK',
          style: TextStyle(
              color: Theme.of(context).colorScheme.onPrimary, fontSize: 18)),
    );
  }
}

Future<void> showErrorDialog(BuildContext context, String message) {
  return showDialog<void>(
    context: context,
    builder: (ctx) => AlertDialog(
      content: Text(message,
          style: TextStyle(
              color: Theme.of(context).colorScheme.error, fontSize: 16)),
      actions: <Widget>[
        Center(
          child: ActionButton(
            onPressed: () => Navigator.of(ctx).pop(),
          ),
        )
      ],
    ),
  );
}
