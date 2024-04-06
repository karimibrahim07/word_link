import 'dart:collection';
import 'dart:convert';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:word_link/widgets/build_word_row.dart';

class WordLinkGameLogic {
  late String startingWord = ''; // Mot de départ
  late String endingWord = ''; // Mot de fin
  late String currentWord = ''; // Mot actuel
  final Set<String> guessedWords = {}; // Mots devinés
  late List<String> dictionary; // Dictionnaire
  late List<Widget> wordList = []; // Liste des mots

  // Charge le dictionnaire à partir d'un fichier JSON
  Future<void> loadDictionaryFromJson(Locale locale) async {
    final String fileName = (locale.languageCode == 'fr') ? 'dictionary_fr.json' : 'dictionary_en.json';
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

    // Filtrer le dictionnaire pour obtenir uniquement les mots de moins de 3 lettres
    List<String> shortWords = dictionary.where((word) => word.length < 4).toList();

    if (shortWords.isNotEmpty) {
      // Sélectionner aléatoirement un mot parmi les mots courts comme mot de départ
      startingWord = shortWords[random.nextInt(shortWords.length)];

      // Initialiser currentWord avec startingWord
      currentWord = startingWord;

      // Utiliser la logique pour trouver un mot de fin approprié
      // Note : Assurez-vous que findEndingWord ou une logique similaire est adaptée pour utiliser startingWord
      // pour initier la recherche d'un mot de fin qui suit vos critères spécifiques.
      findEndingWord();
    } else {
      // Gérer le cas où aucun mot court n'est disponible
      print("Aucun mot de moins de 3 lettres trouvé dans le dictionnaire.");
      startingWord = '';
      endingWord = '';
      currentWord = '';
    }
  }

  void findEndingWord() {
    String currentWord = startingWord;
    List<String> path = [currentWord];

    while (currentWord.length < startingWord.length + 3) {
      List<String> neighbors = _getNeighbors(currentWord, dictionary);
      if (neighbors.isEmpty) {
        print("Aucun chemin possible pour prolonger le mot de départ");
        return;
      }

      // Choisissez le premier voisin comme prochaine étape; vous pouvez rendre cela plus sophistiqué
      currentWord = neighbors.first;
      path.add(currentWord);
    }

    endingWord = currentWord;
    print("Chemin trouvé: ${path.join(' -> ')}");
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
        String guessedWord = guessedWords.firstWhere((word) => word.length == i);
        wordList.add(buildWordRow(guessedWord));
      }
    }
  }

  // Vérifie s'il existe un chemin valide
// Tente de trouver une chaîne de mots valide
  bool verifyPath() {
    List<String> path = [startingWord]; // Initialise la liste de chemin avec le mot de départ
    Set<String> visited = {startingWord}; // Ensemble pour suivre les mots visités

    // Tente de trouver un chemin
    bool foundPath = _dfs(startingWord, startingWord.length + 3, visited, dictionary, path);

    if (!foundPath) {
      print("Aucun chemin valide trouvé à partir de '$startingWord'.");
    } else {
      // Mise à jour du mot de fin avec le dernier mot de la chaîne valide trouvée
      endingWord = path.last;
      print("Chemin valide trouvé : ${path.join(' -> ')}");
    }

    return foundPath;
  }

  bool _dfs(String current, int targetLength, Set<String> visited, List<String> dictionary, List<String> path) {
    if (current.length == targetLength) {
      endingWord = path.last; // Assurez-vous que cette ligne est correcte selon votre logique.
      return true;
    }

    List<String> neighbors = _getNeighbors(current, dictionary, visited).where((word) => word.length == current.length + 1).toList();

    print("neighbors: ${neighbors}");
    for (String nextWord in neighbors) {
      if (!visited.contains(nextWord)) {
        print("Exploring: " + nextWord); // Débogage
        visited.add(nextWord);
        path.add(nextWord);

        if (_dfs(nextWord, targetLength, visited, dictionary, path)) {
          return true; // Chemin valide trouvé
        }

        // Si ce chemin ne mène pas à une solution, backtrack
        visited.remove(nextWord);
        path.removeLast();
      }
    }

    return false;
  }

  List<String> _getNeighbors(String word, List<String> dictionary, [Set<String>? visited]) {
    Set<String> neighbors = HashSet();
    visited ??= {};

    // Pour chaque mot dans le dictionnaire...
    for (String dictWord in dictionary) {
      if (!visited.contains(dictWord) && dictWord.length == word.length + 1) {
        // Compter combien de fois chaque lettre apparaît dans les deux mots
        Map<String, int> wordCount = {}, dictWordCount = {};
        for (int i = 0; i < word.length; i++) {
          wordCount[word[i]] = (wordCount[word[i]] ?? 0) + 1;
        }
        for (int i = 0; i < dictWord.length; i++) {
          dictWordCount[dictWord[i]] = (dictWordCount[dictWord[i]] ?? 0) + 1;
        }

        // Vérifier si en retirant une lettre de dictWord on peut obtenir word
        bool isValidNeighbor = true;
        for (String letter in dictWordCount.keys) {
          if (dictWordCount[letter]! > (wordCount[letter] ?? 0)) {
            if (dictWordCount[letter]! - (wordCount[letter] ?? 0) > 1) {
              isValidNeighbor = false;
              break;
            }
          } else if (wordCount[letter] == null) {
            isValidNeighbor = false;
            break;
          }
        }

        if (isValidNeighbor) {
          neighbors.add(dictWord);
        }
      }
    }

    return neighbors.toList();
  }
}
