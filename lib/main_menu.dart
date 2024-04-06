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
        backgroundColor: Colors.lightBlue,
        foregroundColor: Colors.white,
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              const SizedBox(height: 40),
              Image.asset('assets/image.png'),
              const SizedBox(height: 120), 
              DropdownButton<String>(
                value: Localizations.localeOf(context).languageCode,
                underline: Container(
                  height: 2,
                  color: Colors.lightBlue,
                ),
                icon: const Icon(Icons.language, color: Colors.lightBlue),
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
              const SizedBox(height: 40),
              ElevatedButton(
                onPressed: () {
                  Navigator.pushReplacementNamed(context, '/game', arguments: {'loadData':'json'});
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.lightBlue, 
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(horizontal: 50, vertical: 20),
                  textStyle: const TextStyle(fontSize: 18),
                ),
                child: Text(AppLocalizations.of(context)!.startGame),
              ),
              const SizedBox(height: 40),
              const Text("OR"),
              const SizedBox(height: 40),
              ElevatedButton(
                onPressed: () {
                  Navigator.pushReplacementNamed(context, '/game', arguments: {'loadData':'api'});
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.lightBlue, 
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(horizontal: 50, vertical: 20),
                  textStyle: const TextStyle(fontSize: 18), 
                ),
                child: Text(AppLocalizations.of(context)!.startGameExternal),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
