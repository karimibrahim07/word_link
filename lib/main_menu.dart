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
        backgroundColor: Colors.lightBlue, // Changement de la couleur de la barre d'application
        foregroundColor: Colors.white,
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20.0), // Ajout de padding horizontal
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              SizedBox(height: 40),
              Image.asset('assets/image.png'),
              SizedBox(height: 120), // Ajoute un peu d'espace
              DropdownButton<String>(
                value: Localizations.localeOf(context).languageCode,
                underline: Container(
                  height: 2,
                  color: Colors.lightBlue, // Souligne la sélection avec une couleur
                ),
                icon: const Icon(Icons.language, color: Colors.lightBlue), // Icône de langue
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
              SizedBox(height: 40), // Plus d'espace avant le bouton
              ElevatedButton(
                onPressed: () {
                  Navigator.pushReplacementNamed(context, '/game', arguments: {'loadData':'json'});
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.lightBlue, // Couleur du bouton
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(horizontal: 50, vertical: 20), // Taille du bouton
                  textStyle: const TextStyle(fontSize: 18), // Taille du texte
                ),
                child: Text(AppLocalizations.of(context)!.startGame),
              ),
              SizedBox(height: 40),
              Text("OR"),
              SizedBox(height: 40), // Plus d'espace avant le bouton
              ElevatedButton(
                onPressed: () {
                  Navigator.pushReplacementNamed(context, '/game', arguments: {'loadData':'api'});
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.lightBlue, // Couleur du bouton
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(horizontal: 50, vertical: 20), // Taille du bouton
                  textStyle: const TextStyle(fontSize: 18), // Taille du texte
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
