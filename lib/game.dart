import 'package:confetti/confetti.dart';
import 'package:flutter/material.dart';
import 'package:word_link/components/game_logic.dart';
import 'package:word_link/components/game_timer.dart';
import 'package:word_link/components/game_win.dart';
import 'package:word_link/components/game_over.dart';
import 'package:word_link/main_menu.dart';
import 'package:word_link/widgets/build_word_row.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class WordLinkGameWidget extends StatefulWidget {
  final Function(Locale) onLocaleChange;
  const WordLinkGameWidget({super.key, required this.onLocaleChange});

  @override
  _WordLinkGameWidgetState createState() => _WordLinkGameWidgetState();
}

class _WordLinkGameWidgetState extends State<WordLinkGameWidget> {
  late GameTimer _gameTimer;
  late ConfettiController _confettiController;
  int _secondsRemaining = 120; // 2 minutes
  late WordLinkGameLogic _gameLogic;
  final TextEditingController _userInputController = TextEditingController();
  late List<Widget> wordList = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _gameTimer = GameTimer(_updateTimerUI);
    _gameLogic = WordLinkGameLogic();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadGame();
    });
    _confettiController =
        ConfettiController(duration: const Duration(seconds: 10));
  }

  Future<void> _loadGame() async {
    try {
      // Retrieve arguments passed to the route
      final args =
          ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>?;
      final loadDataMethod = args?['loadData'] ?? 'json'; // Default to 'json'

      print("Load data method: $loadDataMethod");

      if (loadDataMethod == 'api') {
        // Attempt to load data from an API
        await _gameLogic
            .loadDictionaryFromAPI(); // Make sure this method is properly implemented
      } else {
        // Fallback to loading data from a local JSON file
        print(Localizations.localeOf(context));
        await _gameLogic
            .loadDictionaryFromJson(Localizations.localeOf(context));
      }

      _gameLogic.buildEmptyWords();
      if (!_gameLogic.verifyPath()) throw Exception("No valid path found.");

      setState(() {
        _isLoading = false;
      });
      _gameTimer.start(_secondsRemaining);
    } catch (e) {
      // If an error occurs, show an error dialog
      _showErrorDialog();
    }
  }

  @override
  void dispose() {
    _gameTimer.stop();
    _confettiController.dispose();
    super.dispose();
  }

  void _updateTimerUI(int secondsRemaining) {
    setState(() {
      _secondsRemaining = secondsRemaining;
      if (_secondsRemaining <= 0) {
        _showGameOverDialog();
      }
    });
  }

  void _showGameOverDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return const GameOverDialog();
      },
    );
  }

  void _showWinDialog() {
    _confettiController.play();

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return GameWinDialog(onLocaleChange: widget.onLocaleChange);
      },
    );
  }

  void _showErrorDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(AppLocalizations.of(context)!.errorTitle),
        content: Text(AppLocalizations.of(context)!.errorMessage),
        actions: [
          TextButton(
            onPressed: () {
            Navigator.pop(context);
            Navigator.pushReplacement(
                context,
                MaterialPageRoute(
                    builder: (context) =>
                        MainMenu(onLocaleChange: widget.onLocaleChange)));
          }, // Closes the dialog
            child: Text(AppLocalizations.of(context)!.ok),
          ),
        ],
      ),
    );
  }

  void _checkWord(String word) {
    if (_gameLogic.isValidWord(word)) {
      setState(() {
        _gameLogic.updateCurrentWord(word);
        if (_gameLogic.checkWinCondition()) {
          _showWinDialog();
        }
      });
    } else {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text(AppLocalizations.of(context)!.incorrect),
        duration: const Duration(seconds: 2),
      ));
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Scaffold(
        appBar: AppBar(
          title: Text(AppLocalizations.of(context)!.gameTitle),
        ),
        body: const Center(
          child: CircularProgressIndicator(),
        ),
      );
    } else {
      return Scaffold(
        appBar: AppBar(
          title: Text(AppLocalizations.of(context)!.gameTitle),
        ),
        body: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              Text(
                '$_secondsRemaining ${AppLocalizations.of(context)!.secondsLeft}',
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 20.0),
              ),
              const SizedBox(height: 20.0),
              buildWordRow(_gameLogic.startingWord),
              ..._gameLogic.wordList,
              buildWordRow(_gameLogic.endingWord),
              const SizedBox(height: 20.0),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Expanded(
                    child: TextField(
                      controller: _userInputController,
                      decoration: InputDecoration(
                        hintText: AppLocalizations.of(context)!.nextWord,
                        border: const OutlineInputBorder(),
                      ),
                      textAlign: TextAlign.center,
                      onSubmitted: _checkWord,
                      maxLength: _gameLogic.currentWord.length + 1,
                    ),
                  ),
                  const SizedBox(width: 10.0),
                  ElevatedButton(
                    onPressed: () {
                      _checkWord(_userInputController.text);
                      _userInputController.clear();
                    },
                    child: Text(AppLocalizations.of(context)!.submit),
                  ),
                ],
              ),
              Align(
                alignment: Alignment.topCenter,
                child: ConfettiWidget(
                  confettiController: _confettiController,
                  blastDirectionality: BlastDirectionality
                      .explosive, // explose dans toutes les directions
                  shouldLoop: false, // La répétition est désactivée
                  colors: const [
                    Colors.green,
                    Colors.blue,
                    Colors.pink,
                    Colors.orange,
                    Colors.purple,
                  ], // Les couleurs des confettis
                ),
              ),
            ],
          ),
        ),
      );
    }
  }
}
