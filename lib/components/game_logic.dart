import 'dart:collection';
import 'dart:convert';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:word_link/widgets/build_word_row.dart';

class WordLinkGameLogic {
  late String startingWord; // Mot de départ
  late String endingWord; // Mot de fin
  late String currentWord; // Mot actuel
  final Set<String> guessedWords = {}; // Mots devinés
  late List<String> dictionary; // Dictionnaire
  late List<Widget> wordList = []; // Liste des mots

  // Charge le dictionnaire à partir d'un fichier JSON
  Future<void> loadDictionaryFromJson(Locale locale) async {
    final String fileName = (locale.languageCode == 'fr')
        ? 'dictionary_fr.json'
        : 'dictionary_en.json';
    final String filePath = 'assets/$fileName';

    // Charge le fichier JSON du dictionnaire basé sur le chemin déterminé
    final String response = await rootBundle.loadString(filePath);
    final data = json.decode(response) as Map<String, dynamic>;
    dictionary = List<String>.from(data['words']);

    // Après le chargement, vous pouvez maintenant générer la liste de mots basée sur le dictionnaire chargé
    _generateWordList();
  }

  void _generateWordList() {
    final random = Random();

    // Assurez-vous que le dictionnaire n'est pas vide
    if (dictionary.isNotEmpty) {
      // Filtre le dictionnaire pour les mots de moins de 4 caractères
      final shortWords = dictionary.where((word) => word.length < 4).toList();

      // Vérifie s'il y a des mots courts disponibles
      if (shortWords.isNotEmpty) {
        // Choisissez aléatoirement l'un des mots courts comme mot de départ
        startingWord = shortWords[random.nextInt(shortWords.length)];

        // Filtre le dictionnaire pour les mots qui ont 2 lettres ou plus de longueur que le mot de départ
        final possibleEndingWords = dictionary
            .where((word) => word.length >= startingWord.length + 2)
            .toList();

        // Vérifie s'il y a des mots de fin possibles
        if (possibleEndingWords.isNotEmpty) {
          // Choisissez aléatoirement l'un des mots de fin possibles
          endingWord =
              possibleEndingWords[random.nextInt(possibleEndingWords.length)];
        } else {
          // Gère le cas où aucun mot de fin valide n'est trouvé
          endingWord =
              startingWord; // Solution de repli ou à gérer différemment si nécessaire
        }
      } else {
        // Gère le cas où aucun mot de départ valide n'est trouvé
        startingWord =
            ''; // Solution de repli ou initialiser à une valeur par défaut si nécessaire
        endingWord =
            ''; // Solution de repli ou initialiser à une valeur par défaut si nécessaire
      }
    } else {
      // Gère le cas où le dictionnaire est vide
      startingWord = '';
      endingWord = '';
    }

    currentWord = startingWord;
  }

  // Vérifie si le mot est valide
  bool isValidWord(String word) {
    // Assurez-vous que le mot commence par le mot actuel et contient toutes ses lettres
    if (word.length == currentWord.length + 1) {
      // Vérifie si le mot est dans la liste prédéfinie de mots valides
      return dictionary.contains(word);
    }
    return false;
  }

  void updateCurrentWord(String word) {
    if (!guessedWords.contains(word)) {
      guessedWords.add(word);
    }

    if (isValidWord(word)) {
      currentWord = word;

      // Reconstruit la liste des mots vides pour refléter le nouvel état.
      buildEmptyWords();
    }
  }

  // Vérifie la condition de victoire
  bool checkWinCondition() {
    return currentWord.length == endingWord.length - 1;
  }

  void buildEmptyWords() {
    wordList.clear(); // Efface la liste existante pour la reconstruire.

    // Ajoute un espace réservé pour chaque longueur entre les longueurs des mots de départ et de fin.
    for (int i = startingWord.length + 1; i < endingWord.length; i++) {
      String placeholder = '';
      // Ajoute autant de traits de soulignement que la longueur du mot à deviner.
      for (int j = 0; j < i; j++) {
        placeholder += '_';
      }
      // Ajoute seulement l'espace réservé s'il ne correspond à aucun mot deviné.
      if (!guessedWords.any((word) => word.length == i)) {
        wordList.add(buildWordRow(placeholder));
      } else {
        // Si un mot deviné de cette longueur existe, ajoutez ce mot à la place.
        String guessedWord =
            guessedWords.firstWhere((word) => word.length == i);
        wordList.add(buildWordRow(guessedWord));
      }
    }
  }

  // Vérifie s'il existe un chemin valide
  bool verifyPath() {
    List<String> path = []; // Initialise la liste de chemin
    bool foundPath =
        _dfs(startingWord, endingWord, <String>{}, dictionary, path);
    if (!foundPath) {
      print("Aucun chemin valide trouvé de '$startingWord' à '$endingWord'.");
    }
    return foundPath;
  }

  // Fonction d'aide DFS
  bool _dfs(String current, String target, Set<String> visited,
      List<String> dictionary, List<String> path) {
    path.add(current); // Ajoute le mot actuel au chemin

    if (current == target) {
      print(
          "Chemin valide trouvé : ${path.join(' -> ')}"); // Imprime le chemin valide
      return true;
    }

    visited.add(current);

    for (String nextWord in _getNeighbors(current, dictionary)) {
      if (!visited.contains(nextWord)) {
        List<String> newPath =
            List.from(path); // Fait une copie du chemin actuel
        if (_dfs(nextWord, target, visited, dictionary, newPath)) {
          // Pas besoin de retirer le dernier mot du chemin ici, car nous faisons une copie du chemin pour chaque appel récursif
          return true; // Trouve un chemin valide vers la cible
        }
      }
    }

    path.removeLast(); // Retour en arrière : retire le mot actuel du chemin si aucun chemin valide n'est trouvé
    return false; // Aucun chemin valide trouvé à partir de ce mot
  }

  // Génère tous les voisins possibles d'un mot (mots qui peuvent être atteints en ajoutant une lettre)
  List<String> _getNeighbors(String word, List<String> dictionary) {
    Set<String> neighbors = HashSet();

    for (int charCode = 'a'.codeUnitAt(0);
        charCode <= 'z'.codeUnitAt(0);
        charCode++) {
      // Ajoute une lettre à chaque position possible avant de générer des permutations
      for (int i = 0; i <= word.length; i++) {
        String newWord = word.substring(0, i) +
            String.fromCharCode(charCode) +
            word.substring(i);
        Set<String> permutations = getPermutations(newWord);

        // Vérifie chaque permutation par rapport au dictionnaire
        for (String permutedWord in permutations) {
          if (dictionary.contains(permutedWord) &&
              permutedWord.length == word.length + 1) {
            neighbors.add(permutedWord);
          }
        }
      }
    }

    return neighbors.toList();
  }

  // Génère les permutations d'une chaîne
  Set<String> getPermutations(String str) {
    Set<String> permutations = HashSet();

    void _permute(String prefix, String remaining) {
      int n = remaining.length;
      if (n == 0) {
        permutations.add(prefix);
      } else {
        for (int i = 0; i < n; i++) {
          _permute(prefix + remaining[i],
              remaining.substring(0, i) + remaining.substring(i + 1, n));
        }
      }
    }

    _permute("", str);
    return permutations;
  }
}
