import 'dart:math';

import 'package:flutter/material.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Mastermind Light',
      theme: ThemeData(
        primarySwatch: Colors.blueGrey,
      ),
      home: MyHomePage(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  MyHomePage({Key key}) : super(key: key);

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  static const int _NUMBER_OF_ROWS = 6;
  static const int _NUMBER_OF_POSSIBLE_VALUES = 6;
  static const int _NUMBER_OF_SYMBOLS_IN_COMBINATION = 4;
  static const double _SYMBOL_DIMENSION = 40.0;
  static const int _INITIAL_VALUE = -1;
  static const int _CORRECT_VALUE = 1;
  static const int _WRONG_VALUE = 0;
  static const List<Color> COLORS = [
    Colors.purple,
    Colors.green,
    Colors.blue,
    Colors.red,
    Colors.orange,
    Colors.yellow
  ];

  static int _gamesTotal = 0;
  static int _gamesWon = 0;
  static int _gamesLost = 0;
  static List<int> _winningMoves = List.generate(6, (index) {
    return 0;
  });

  List<int> _actualValues = initializeActualValues();
  List<List<int>> _guessedValues = initializeGuessedValues();
  List<List<int>> _results = initializeGuessedValues();
  int _rowCounter = 0;
  int _symbolCounter = 0;
  int _correctPlaces = 0;
  int _wrongPlaces = 0;
  bool _gameEndSuccess = false;
  bool _gameEndFail = false;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          stops: [0.1, 0.3, 0.5, 0.7, 0.9],
          colors: [
            Colors.blueGrey[200],
            Colors.blueGrey[100],
            Colors.blueGrey[50],
            Colors.blueGrey[100],
            Colors.blueGrey[200],
          ],
        ),
      ),
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(
          title: Text('Mastermind Light'),
        ),
        body: SafeArea(
          child: LayoutBuilder(
            builder: (builder, constraints) {
              double maxWidth = constraints.maxWidth;
              return Center(
                child: _buildGameScreen(maxWidth),
              );
            },
          ),
        ),
      ),
    );
  }

  Column _buildGameOverPanel() {
    var gameOverPanelContent = <Widget>[];
    gameOverPanelContent.add(_buildGameOverText());
    gameOverPanelContent.add(_buildGameOverCorrectCombination());
    gameOverPanelContent.add(
      Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: <Widget>[
          _buildGameOverRestartButton(),
        ],
      ),
    );
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: gameOverPanelContent,
    );
  }

  Text _buildGameOverText() {
    return Text(
      _gameEndSuccess ? 'YOU WON!' : 'YOU LOST!',
      style: TextStyle(fontSize: 30.0, fontWeight: FontWeight.bold),
    );
  }

  Row _buildGameOverCorrectCombination() {
    var correctCombination = <Widget>[];
    for (int i = 0; i < _NUMBER_OF_SYMBOLS_IN_COMBINATION; i++) {
      correctCombination.add(
        SizedBox(
          width: _SYMBOL_DIMENSION,
          height: _SYMBOL_DIMENSION,
          child: Container(
            decoration: BoxDecoration(
              color: COLORS[_actualValues[i]],
              border: Border.all(
                color: Colors.white,
              ),
              borderRadius: BorderRadius.all(
                  Radius.circular(10.0) //         <--- border radius here
                  ),
            ),
          ),
        ),
      );
    }
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: correctCombination,
    );
  }

  RaisedButton _buildGameOverRestartButton() {
    return RaisedButton(
      color: Colors.blueGrey,
      child: Text(
        'NEW GAME',
        style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
      ),
      onPressed: () {
        setState(() {
          _actualValues = initializeActualValues();
          _guessedValues = initializeGuessedValues();
          _results = initializeResults();
          _rowCounter = 0;
          _symbolCounter = 0;
          _correctPlaces = 0;
          _wrongPlaces = 0;
          _gameEndSuccess = false;
          _gameEndFail = false;
        });
      },
    );
  }

  Column _buildGameScreen(double maxWidth) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      children: <Widget>[
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: Row(
            children: _buildPossibleColorsRow(),
          ),
        ),
        _buildCommandButtonsRow(),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: <Widget>[
            Column(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: _buildLeftColumnContent(),
            ),
            Column(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: _buildRightColumnContent(),
            )
          ],
        ),
        (_gameEndFail || _gameEndSuccess) ? _buildGameOverPanel() : Container()
      ],
    );
  }

  List<Widget> _buildLeftColumnContent() {
    var leftColumnRows = new List<Row>(_NUMBER_OF_ROWS);
    for (int i = 0; i < _NUMBER_OF_ROWS; i++) {
      leftColumnRows[i] = new Row(
        children: <Widget>[],
      );
      for (int j = 0; j < _NUMBER_OF_SYMBOLS_IN_COMBINATION; j++) {
        leftColumnRows[i].children.add(
              SizedBox(
                child: Container(
                  decoration: BoxDecoration(
                    border: Border.all(
                      color: Colors.white,
                    ),
                    color: _guessedValues[i][j] == _INITIAL_VALUE
                        ? Colors.grey
                        : COLORS[_guessedValues[i][j]],
                  ),
                ),
                height: _SYMBOL_DIMENSION,
                width: _SYMBOL_DIMENSION,
              ),
            );
      }
    }
    return leftColumnRows;
  }

  List<Widget> _buildRightColumnContent() {
    var rightColumnRows = new List<Row>(_NUMBER_OF_ROWS);
    for (int i = 0; i < _NUMBER_OF_ROWS; i++) {
      rightColumnRows[i] = new Row(
        children: <Widget>[],
      );
      for (int j = 0; j < _NUMBER_OF_SYMBOLS_IN_COMBINATION; j++) {
        String imagePath = _results[i][j] == _INITIAL_VALUE
            ? 'emptyGuess.png'
            : _results[i][j] == _CORRECT_VALUE
                ? 'goodGuess.png'
                : 'badGuess.png';
        rightColumnRows[i].children.add(
              Container(
                child: Image(
                    image: AssetImage('images/' + imagePath),
                    height: _SYMBOL_DIMENSION,
                    width: _SYMBOL_DIMENSION),
              ),
            );
      }
    }
    return rightColumnRows;
  }

  List<Widget> _buildPossibleColorsRow() {
    return <Widget>[
      _buildPossibleColorsButtons(0),
      _buildPossibleColorsButtons(1),
      _buildPossibleColorsButtons(2),
      _buildPossibleColorsButtons(3),
      _buildPossibleColorsButtons(4),
      _buildPossibleColorsButtons(5),
    ];
  }

  // Build buttons for all possible symbols
  Expanded _buildPossibleColorsButtons(int i) {
    var fieldWidth = MediaQuery.of(context).size.width / 6;
    return Expanded(
      child: GestureDetector(
        child: Container(
          decoration: BoxDecoration(
            border: Border.all(
              color: Colors.white,
            ),
            borderRadius: BorderRadius.all(
                Radius.circular(10.0) //         <--- border radius here
                ),
            color: COLORS[i],
          ),
          height: fieldWidth,
        ),
        onTap: () {
          setState(() {
            if (_symbolCounter < _NUMBER_OF_SYMBOLS_IN_COMBINATION) {
              _guessedValues[_rowCounter][_symbolCounter++] = i;
            }
          });
        },
      ),
    );
  }

  Row _buildCommandButtonsRow() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: <Widget>[
        _buildOkButton(),
        _buildDeleteButton(),
      ],
    );
  }

  RaisedButton _buildOkButton() {
    return RaisedButton(
      disabledColor: Colors.grey.shade400,
      color: Colors.green,
      shape: RoundedRectangleBorder(
        borderRadius: new BorderRadius.circular(5.0),
        side: BorderSide(color: Colors.grey),
      ),
      child: Text(
        'OK',
        style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
      ),
      onPressed: _checkCurrentGuess(),
    );
  }

  Function _checkCurrentGuess() {
    if (_symbolCounter < _NUMBER_OF_SYMBOLS_IN_COMBINATION) {
      return null;
    } else {
      return () {
        setState(() {
          // Initially, none of the guessed symbols or actual symbols are checked
          List<bool> _checkedA =
              List.generate(_NUMBER_OF_SYMBOLS_IN_COMBINATION, (index) {
            return false;
          });
          List<bool> _checkedG =
              List.generate(_NUMBER_OF_SYMBOLS_IN_COMBINATION, (index) {
            return false;
          });
          _correctPlaces = 0;
          _wrongPlaces = 0;
          _gameEndSuccess = false;
          _gameEndFail = false;

          // First check if any of the unchecked symbols has correct place...
          for (int i = 0; i < _NUMBER_OF_SYMBOLS_IN_COMBINATION; i++) {
            if (!_checkedA[i] &&
                !_checkedG[i] &&
                _guessedValues[_rowCounter][i] == _actualValues[i]) {
              _correctPlaces++;
              // ...and in that case set the 'checked' flag to avoid checking them again
              _checkedA[i] = true;
              _checkedG[i] = true;
            }
          }

          // Then check if there are unchecked guessed symbols with wrong places
          for (int i = 0; i < _NUMBER_OF_SYMBOLS_IN_COMBINATION; i++) {
            for (int j = 0; j < _NUMBER_OF_SYMBOLS_IN_COMBINATION; j++) {
              if (!_checkedG[i] &&
                  !_checkedA[j] &&
                  _guessedValues[_rowCounter][i] == _actualValues[j]) {
                _wrongPlaces++;
                _checkedG[i] = true;
                _checkedA[j] = true;
              }
            }
          }

          // Set the results accordingly
          int _tempCorrectPlaces = _correctPlaces;
          int _tempWrongPlaces = _wrongPlaces;
          for (int i = 0; i < _NUMBER_OF_SYMBOLS_IN_COMBINATION; i++) {
            // For each correct result set the value to 1 and decrement the counter
            // For each incorrect result set the value to -1 and decrement the counter
            if (_tempCorrectPlaces > 0) {
              _results[_rowCounter][i] = _CORRECT_VALUE;
              _tempCorrectPlaces--;
            } else if (_tempWrongPlaces > 0) {
              _results[_rowCounter][i] = _WRONG_VALUE;
              _tempWrongPlaces--;
            }
          }

          if (_rowCounter < _NUMBER_OF_ROWS) {
            _rowCounter++;
            _symbolCounter = 0;
          }

          if (_correctPlaces == _NUMBER_OF_SYMBOLS_IN_COMBINATION) {
            _gameEndSuccess = true;
            _gamesTotal++;
            _gamesWon++;
            _winningMoves[_rowCounter - 1]++;
          } else if (_rowCounter == _NUMBER_OF_ROWS) {
            _gameEndFail = true;
            _gamesTotal++;
            _gamesLost++;
          }
        });
      };
    }
  }

  RaisedButton _buildDeleteButton() {
    return RaisedButton(
      disabledColor: Colors.grey.shade400,
      color: Colors.red,
      shape: RoundedRectangleBorder(
        borderRadius: new BorderRadius.circular(5.0),
        side: BorderSide(color: Colors.grey),
      ),
      child: Text(
        '<<',
        style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
      ),
      onPressed: _deleteLastSymbol(),
    );
  }

// Delete the last entered symbol
  Function _deleteLastSymbol() {
    if (_symbolCounter == 0) {
      return null;
    } else {
      return () {
        setState(() {
          _symbolCounter--;
          _guessedValues[_rowCounter][_symbolCounter] = _INITIAL_VALUE;
        });
      };
    }
  }

  static List<int> initializeActualValues() {
    List<int> possibleValues =
        List.generate(_NUMBER_OF_POSSIBLE_VALUES, (index) {
      return index;
    });
    List<int> actualValues = new List(_NUMBER_OF_SYMBOLS_IN_COMBINATION);
    for (int i = 0; i < _NUMBER_OF_SYMBOLS_IN_COMBINATION; i++) {
      actualValues[i] =
          possibleValues[Random().nextInt(_NUMBER_OF_POSSIBLE_VALUES)];
    }
    return actualValues;
  }

  static List<List<int>> initializeGuessedValues() {
    return List.generate(_NUMBER_OF_ROWS, (index) {
      return List.generate(_NUMBER_OF_SYMBOLS_IN_COMBINATION, (index) {
        return _INITIAL_VALUE;
      });
    });
  }

  static List<List<int>> initializeResults() {
    return List.generate(_NUMBER_OF_ROWS, (index) {
      return List.generate(_NUMBER_OF_SYMBOLS_IN_COMBINATION, (index) {
        return _INITIAL_VALUE;
      });
    });
  }
}
