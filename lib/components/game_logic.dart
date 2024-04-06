import 'dart:collection';
import 'dart:convert';
import 'dart:io';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:word_link/widgets/build_word_row.dart';
import 'package:http/http.dart' as http;

class WordLinkGameLogic {
  late String startingWord = ''; 
  late String endingWord = '';
  late String currentWord = ''; 
  final Set<String> guessedWords = {}; 
  late List<String> dictionary; 
  late List<Widget> wordList = []; 
  late final String _apiBaseUrl = _determineAPIBaseUrl();
  
  String _determineAPIBaseUrl() {
    String baseUrl = "http://localhost:3000";

    try {
      if (Platform.isAndroid) {
        baseUrl = "http://10.0.2.2:3000";
      }
    // ignore: empty_catches
    } catch (e) {
      
    }

    return baseUrl;
  }

  // Charge le dictionnaire à partir d'un fichier JSON
  Future<void> loadDictionaryFromJson(Locale locale) async {
    final String fileName = (locale.languageCode == 'fr')
        ? 'dictionary_fr.json'
        : 'dictionary_en.json';
    final String filePath = 'assets/$fileName';

    // Charge le fichier JSON du dictionnaire basé sur le chemin déterminé
    final String response = await rootBundle.loadString(filePath);
    final List<dynamic> data = json.decode(response);
    dictionary = data.cast<String>();

    // Après le chargement, générer la liste de mots basée sur le dictionnaire chargé
    _generateWordList();
  }

  Future<void> loadDictionaryFromAPI() async {
    try {
      final response = await http.get(Uri.parse('$_apiBaseUrl/dictionary'));

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        dictionary = data.cast<String>();
        _generateWordList();
      } else {
        throw Exception("Failed to load dictionary from API. Status code: ${response.statusCode}");
      }
    } catch (e) {
      throw Exception("Error loading dictionary from API: $e");
    }
  }

  void _generateWordList() {
    final random = Random();

    // Mélange le dictionnaire pour obtenir un ordre aléatoire des mots
    List<String> shortWords =
        dictionary.where((word) => word.length < 4).toList();
    shortWords.shuffle(random);

    // Essaye chaque mot court comme mot de départ jusqu'à ce qu'un chemin soit trouvé
    for (String word in shortWords) {
      startingWord = word;
      currentWord = startingWord;

      // Utilise la logique pour essayer de trouver un mot de fin approprié
      if (verifyPath()) {
        print("Chemin trouvé avec le mot de départ '$startingWord'.");
        return;
      }
    }

    // Si la boucle se termine sans trouver un chemin
    print(
        "Aucun chemin valide trouvé pour les mots de moins de 4 lettres dans le dictionnaire.");
    startingWord = '';
    endingWord = '';
    currentWord = '';
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

      currentWord = neighbors.first;
      path.add(currentWord);
    }

    endingWord = currentWord;
    print("Chemin trouvé: ${path.join(' -> ')}");
  }

  // Vérifie si le mot est valide
  bool isValidWord(String word) {
    if (word.length == currentWord.length + 1) {
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
      // Ajoute autant de '_' que la longueur du mot à deviner.
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

  // Vérifie si un chemin valide existe
  bool verifyPath() {
    List<String> path = [
      startingWord
    ]; // Initialise la liste de chemin avec le mot de départ
    Set<String> visited = {
      startingWord
    }; // Ensemble pour suivre les mots visités

    // Tente de trouver un chemin
    bool foundPath =
        _dfs(startingWord, startingWord.length + 3, visited, dictionary, path);

    if (!foundPath) {
      print("Aucun chemin valide trouvé à partir de '$startingWord'.");
    } else {
      // Mise à jour du mot de fin avec le dernier mot de la chaîne valide trouvée
      endingWord = path.last;
      print("Chemin valide trouvé : ${path.join(' -> ')}");
    }

    return foundPath;
  }

  bool _dfs(String current, int targetLength, Set<String> visited,
      List<String> dictionary, List<String> path) {
    if (current.length == targetLength) {
      endingWord = path.last;
      return true;
    }

    List<String> neighbors = _getNeighbors(current, dictionary, visited)
        .where((word) => word.length == current.length + 1)
        .toList();

    for (String nextWord in neighbors) {
      if (!visited.contains(nextWord)) {
        visited.add(nextWord);
        path.add(nextWord);

        if (_dfs(nextWord, targetLength, visited, dictionary, path)) {
          return true; // Chemin valide trouvé
        }

        // Si le chemin ne mène pas à une solution, backtrack
        visited.remove(nextWord);
        path.removeLast();
      }
    }

    return false;
  }

  // J'aime pas ce jeu. 
  List<String> _getNeighbors(String word, List<String> dictionary,
      [Set<String>? visited]) {
    Set<String> neighbors = HashSet();
    visited ??= {};

    for (String dictWord in dictionary) {
      // Continue seulement si dictWord n'a pas été visité et a exactement une lettre de plus que word
      if (!visited.contains(dictWord) && dictWord.length == word.length + 1) {
        Map<String, int> wordLetterCounts = _getLetterCounts(word);
        Map<String, int> dictWordLetterCounts = _getLetterCounts(dictWord);

        bool isValidNeighbor = true;
        // Pour chaque lettre dans word, vérifiez que dictWord a la même quantité ou une de plus
        for (String letter in wordLetterCounts.keys) {
          if (dictWordLetterCounts[letter] == null ||
              dictWordLetterCounts[letter]! < wordLetterCounts[letter]!) {
            isValidNeighbor = false;
            break;
          }
        }

        // Si dictWord est un voisin valide, ajoutez-le aux voisins
        if (isValidNeighbor) {
          neighbors.add(dictWord);
        }
      }
    }

    return neighbors.toList();
  }

  Map<String, int> _getLetterCounts(String word) {
    Map<String, int> letterCounts = {};
    for (var letter in word.split('')) {
      letterCounts[letter] = (letterCounts[letter] ?? 0) + 1;
    }
    return letterCounts;
  }
}
