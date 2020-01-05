import 'dart:math';

import 'package:flutter/material.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Mastermind',
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
  static const double _POSSIBLE_SYMBOL_DIMENSION = 60.0;
  static const int _INITIAL_VALUE = -1;
  static const int _CORRECT_VALUE = 1;
  static const int _WRONG_VALUE = 0;

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
    return Scaffold(
      backgroundColor: Colors.grey.shade200,
      appBar: AppBar(
        title: Text('Mastermind'),
      ),
      body: Center(
        child: _buildGameScreen(),
      ),
    );
  }

  Column _buildGameOverPanel() {
    var gameOverPanelContent = <Widget>[];
    gameOverPanelContent.add(_buildGameOverText());
    gameOverPanelContent.add(_buildGameOverCorrectCombination());
    gameOverPanelContent.add(_buildGameOverRestartButton());
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: gameOverPanelContent,
    );
  }

  Text _buildGameOverText() {
    return Text(
      _gameEndSuccess ? "YOU WON!" : "YOU LOST!",
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
          child: Image.asset(
            'images/value${_actualValues[i]}.png',
            height: _SYMBOL_DIMENSION,
            width: _SYMBOL_DIMENSION,
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
        "NEW GAME",
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

  Column _buildGameScreen() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      children: <Widget>[
        _buildPossibleColorsRow(),
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
//        _buildActualCombinationRow(),
        (_gameEndFail || _gameEndSuccess) ? _buildGameOverPanel() : Container(),
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
        String imagePath = _guessedValues[i][j] == -1
            ? 'emptyField.png'
            : 'value${_guessedValues[i][j]}.png';
        leftColumnRows[i].children.add(
              Image(
                  image: AssetImage('images/' + imagePath),
                  height: _SYMBOL_DIMENSION,
                  width: _SYMBOL_DIMENSION),
            );
      }
    }
    return leftColumnRows;
  }

  List<Widget> _buildRightColumnContent() {
    var leftColumnRows = new List<Row>(_NUMBER_OF_ROWS);
    for (int i = 0; i < _NUMBER_OF_ROWS; i++) {
      leftColumnRows[i] = new Row(
        children: <Widget>[],
      );
      for (int j = 0; j < _NUMBER_OF_SYMBOLS_IN_COMBINATION; j++) {
        String imagePath = _results[i][j] == _INITIAL_VALUE
            ? 'emptyGuess.png'
            : _results[i][j] == _CORRECT_VALUE
                ? 'goodGuess.png'
                : 'badGuess.png';
        leftColumnRows[i].children.add(
              Image(
                  image: AssetImage('images/' + imagePath),
                  height: _SYMBOL_DIMENSION,
                  width: _SYMBOL_DIMENSION),
            );
      }
    }
    return leftColumnRows;
  }

  Row _buildPossibleColorsRow() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: <Widget>[
        _buildPossibleColorsButtons(),
      ],
    );
  }

  // Build buttons for all possible symbols
  Row _buildPossibleColorsButtons() {
    var possibleColors = <Widget>[];
    for (int i = 0; i < _NUMBER_OF_POSSIBLE_VALUES; i++) {
      possibleColors.add(SizedBox(
        width: _POSSIBLE_SYMBOL_DIMENSION,
        height: _POSSIBLE_SYMBOL_DIMENSION,
        child: RaisedButton(
          elevation: 10.0,
          animationDuration: Duration(milliseconds: 100),
          highlightElevation: 30.0,
          highlightColor: Colors.blueGrey,
          padding: EdgeInsets.all(2),
          onPressed: () {
            setState(() {
              if (_symbolCounter < _NUMBER_OF_SYMBOLS_IN_COMBINATION) {
                _guessedValues[_rowCounter][_symbolCounter++] = i;
              }
            });
          },
          child: Image.asset('images/value$i.png',
              height: _POSSIBLE_SYMBOL_DIMENSION,
              width: _POSSIBLE_SYMBOL_DIMENSION),
        ),
      ));
    }
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: possibleColors,
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
          } else if (_rowCounter == _NUMBER_OF_ROWS) {
            _gameEndFail = true;
          }
        });
      };
    }
  }

  RaisedButton _buildDeleteButton() {
    return RaisedButton(
      disabledColor: Colors.grey.shade400,
      color: Colors.red,
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
