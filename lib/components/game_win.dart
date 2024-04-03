import 'package:flutter/material.dart';
import 'package:word_link/main_menu.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class GameWinDialog extends StatelessWidget {
  final Function(Locale) onLocaleChange;
  const GameWinDialog({super.key, required this.onLocaleChange});

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(AppLocalizations.of(context)!.congratulations),
      content: Text(AppLocalizations.of(context)!.youWon),
      actions: [
        TextButton(
          onPressed: () {
            Navigator.pop(context);
            Navigator.pushReplacement(
                context,
                MaterialPageRoute(
                    builder: (context) =>
                        MainMenu(onLocaleChange: onLocaleChange)));
          },
          child: Text(AppLocalizations.of(context)!.ok),
        ),
      ],
    );
  }
}
