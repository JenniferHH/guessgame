import 'dart:math';
import 'package:flutter/material.dart';
import 'dart:async';
import 'dart:ui';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: false,
      ),
      home: const MyHomePage(),
      debugShowCheckedModeBanner: false,
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key});

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> with SingleTickerProviderStateMixin {
  List<String> words = [
    'banana', 'cherry', 'bottle', 'castle', 'planet',
    'animal', 'garden', 'bridge', 'forest', 'island',
    'camera', 'office'
  ];

  String? selectedWord;
  bool _showInput = false;
  bool _showInitialImage = true;
  bool _showWinImage = false;
  bool _showLoseImage = false;
  bool _showHint = true;
  bool _showGuessWord = true;
  String? _resultMessage;
  int _stars = 6;
  List<String?> _letters = [];
  List<String> _incorrectLetters = [];
  String? _hint;

  late AnimationController _animationController;
  late Animation<double> _opacityAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(seconds: 3),
      vsync: this,
    );

    _opacityAnimation = Tween<double>(begin: 1.0, end: 0.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeOut),
    );

   Timer(const Duration(seconds: 1), () {
      if (mounted) {
        _animationController.forward().then((_) {
          setState(() {
            _showInitialImage = false;
          });
        });
      }
    });
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  void _startGame() {
    setState(() {
      _showInitialImage = false;
      _showLoseImage = false;
    });
  }

  void _guesswords() {
    final random = Random();
    setState(() {
      selectedWord = words[random.nextInt(words.length)];
      _letters = List.generate(selectedWord!.length, (_) => '');
      _showInput = true;
      _resultMessage = null;
      _stars = 6;
      _hint = _generateHint();
      _incorrectLetters.clear();
      _showWinImage = false;
      _showLoseImage = false;
      _showHint = true;
      _showGuessWord = true;
    });
  }

  String _generateHint() {
    if (selectedWord == null || selectedWord!.length < 3) return '';
    String firstLetter = selectedWord![0];
    String thirdLetter = selectedWord![2];
    return '$firstLetter _ $thirdLetter _ _ _';
  }

  void _checkGuess() {
    if (selectedWord == null) {
      setState(() {
        _resultMessage = 'No word selected. Please press the button to select a word.';
      });
      return;
    }

    List<String> wordLetters = splitWordIntoLetters(selectedWord!);
    bool allCorrect = true;

    for (int i = 0; i < _letters.length; i++) {
      if (_letters[i] == wordLetters[i]) {
        continue;
      } else {
        if (!_incorrectLetters.contains(_letters[i] ?? '')) {
          _incorrectLetters.add(_letters[i] ?? '');
          setState(() {
            _stars = (_stars - 1).clamp(0, 6);
          });
        }
        allCorrect = false;
      }
    }

    if (allCorrect && _letters.every((letter) => letter != null && letter.isNotEmpty)) {
      setState(() {
        _showWinImage = true;
        _showInput = false;
        _showHint = false;
        _showGuessWord = false;
      });
    } else if (_stars == 0) {
      setState(() {
        _showLoseImage = true;
        _showInput = false;
      });
    }
  }

  List<String> splitWordIntoLetters(String word) {
    return word.split('');
  }

  Color _getTextFieldColor(int index) {
    if (_letters[index] != null && _letters[index]!.isNotEmpty) {
      if (selectedWord != null) {
        if (_letters[index] == splitWordIntoLetters(selectedWord!)[index]) {
          return Colors.white;
        } else {
          return Colors.redAccent;
        }
      }
    }
    return Colors.white;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        fit: StackFit.expand,
        children: [
          if (!_showInitialImage)
            Stack(
              fit: StackFit.expand,
              children: [
                Image.asset(
                  'assets/background.png',
                  fit: BoxFit.cover,
                ),
                BackdropFilter(
                  filter: ImageFilter.blur(sigmaX: 10.0, sigmaY: 10.0),
                  child: Container(
                    color: Colors.black.withOpacity(0),
                  ),
                ),
              ],
            ),
          if (_showInitialImage)
            FadeTransition(
              opacity: _opacityAnimation,
              child: Center(
                child: GestureDetector(
                  onTap: _startGame,
                  child: Image.asset(
                    'assets/words.png',
                    width: 300,
                    height: 300,
                  ),
                ),
              ),
            )
          else if (_showLoseImage)
            Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    width: 400,
                    height: 500,
                    padding: const EdgeInsets.all(24.0),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.9),
                      borderRadius: BorderRadius.circular(16.0),
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(
                          padding: const EdgeInsets.all(16.0),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: List.generate(
                              6,
                                  (index) => Transform(
                                transform: Matrix4.identity()..translate(0.0, 80.0, 0.0),
                                child: Icon(
                                  Icons.star,
                                  size: 40.0,
                                  color: index < _stars ? Colors.amber : Colors.grey,
                                ),
                              ),
                            ),
                          ),
                        ),
                  SizedBox(height: 50),
                  Image.asset(
                    'assets/lose.png',
                    width: 250,
                    height: 250,
                  ),
                        Expanded(
                          child: Center(
                            child: GestureDetector(
                              onTap: _guesswords,
                              child: Image.asset(
                                'assets/play_button.png',
                                width: 200,
                                height: 200,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            )
          else
            Center(
              child: Stack(
                children: [
                  Center(
                    child: Container(
                      width: 400,
                      height: 500,
                      padding: const EdgeInsets.all(24.0),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.9),
                        borderRadius: BorderRadius.circular(16.0),
                      ),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Container(
                            padding: const EdgeInsets.all(16.0),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: List.generate(
                                6,
                                    (index) => Transform(
                                  transform: Matrix4.identity()..translate(0.0, 80.0, 0.0),
                                  child: Icon(
                                    Icons.star,
                                    size: 40.0,
                                    color: index < _stars ? Colors.amber : Colors.grey,
                                  ),
                                ),
                              ),
                            ),
                          ),
                          Expanded(
                            child: Stack(
                              children: [
                                Center(
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: <Widget>[
                                      if (_showGuessWord)
                                        const Text(
                                          'Guess Word:',
                                        ),
                                      if (_showGuessWord)
                                        Text(
                                          selectedWord != null
                                              ? _letters.asMap().entries.map((entry) {
                                            int index = entry.key;
                                            String? letter = entry.value;
                                            return letter != null && letter.isNotEmpty ? letter : '_';
                                          }).join(' ')
                                              : 'Let Us Start',
                                          style: TextStyle(fontSize: 24.0, fontWeight: FontWeight.bold),
                                        ),
                                      if (_hint != null && _showHint)
                                        Padding(
                                          padding: const EdgeInsets.all(8.0),
                                          child: Text(
                                            'Hint: $_hint',
                                            style: TextStyle(fontSize: 16.0, color: Colors.blue),
                                          ),
                                        ),
                                      if (_resultMessage != null)
                                        Padding(
                                          padding: const EdgeInsets.all(8.0),
                                          child: Text(
                                            _resultMessage!,
                                            style: TextStyle(
                                              fontSize: 16.0,
                                              color: _resultMessage!.startsWith('Congratulations')
                                                  ? Colors.green
                                                  : Colors.red,
                                            ),
                                          ),
                                        ),
                                      if (_showInput)
                                        SizedBox(
                                          width: 300,
                                          child: Row(
                                            mainAxisAlignment: MainAxisAlignment.center,
                                            children: List.generate(
                                              _letters.length,
                                                  (index) => Expanded(
                                                child: Padding(
                                                  padding: const EdgeInsets.symmetric(horizontal: 4.0),
                                                  child: TextField(
                                                    autofocus: true,
                                                    textAlign: TextAlign.center,
                                                    decoration: InputDecoration(
                                                      border: OutlineInputBorder(),
                                                      fillColor: _getTextFieldColor(index),
                                                      filled: true,
                                                      hintText: ' ',
                                                    ),
                                                    maxLength: null,
                                                    onChanged: (value) {
                                                      setState(() {
                                                        _letters[index] = value.toLowerCase();
                                                        if (_letters.every(
                                                                (letter) => letter != null && letter.isNotEmpty)) {
                                                          _checkGuess();
                                                        }
                                                      });
                                                    },
                                                  ),
                                                ),
                                              ),
                                            ),
                                          ),
                                        ),
                                      if (_incorrectLetters.isNotEmpty && _showInput)
                                        Padding(
                                          padding: const EdgeInsets.all(8.0),
                                          child: Text(
                                            'Retry Incorrect Letters',
                                            style: TextStyle(fontSize: 16.0, color: Colors.red),
                                          ),
                                        ),
                                    ],
                                  ),
                                ),
                                if (!_showInput)
                                  Align(
                                    alignment: Alignment.bottomCenter,
                                    child: Padding(
                                      padding: const EdgeInsets.only(bottom: 10.0),
                                      child: GestureDetector(
                                        onTap: _guesswords,
                                        child: Image.asset(
                                          'assets/play_button.png',
                                          width: 200,
                                          height: 200,
                                        ),
                                      ),
                                    ),
                                  )
                                else
                                  Container(),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  if (_showWinImage)
                    Center(
                      child: Padding(
                        padding: const EdgeInsets.only(top: 20.0),
                        child: Image.asset(
                          'assets/win.png',
                          width: 250,
                          height: 250,
                        ),
                      ),
                    ),
                ],
              ),
            ),
        ],
      ),
    );
  }
}
