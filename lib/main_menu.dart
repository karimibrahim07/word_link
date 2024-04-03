import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class MainMenu extends StatelessWidget {
  final Function(Locale) onLocaleChange;

  const MainMenu({super.key, required this.onLocaleChange});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(AppLocalizations.of(context)!.mainMenu),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            DropdownButton<String>(
              value: Localizations.localeOf(context).languageCode,
              items: const [
                DropdownMenuItem(value: "en", child: Text("English")),
                DropdownMenuItem(value: "fr", child: Text("Français")),
              ],
              onChanged: (String? value) {
                if (value != null) {
                  Locale newLocale = Locale(value);
                  onLocaleChange(newLocale);
                }
              },
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.pushReplacementNamed(context, '/game');
              },
              child: Text(AppLocalizations.of(context)!.startGame),
            ),
          ],
        ),
      ),
    );
  }
}
