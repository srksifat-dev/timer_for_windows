import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'dart:async';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Timer',
      themeMode: ThemeMode.system,
      home: TimerScreen(),
    );
  }
}

class TimerScreen extends StatefulWidget {
  @override
  _TimerScreenState createState() => _TimerScreenState();
}

class _TimerScreenState extends State<TimerScreen> {
  int _minutes = 30;
  int _seconds = 0;
  Timer? _timer;
  bool _isRunning = false;
  bool _isTimeUp = false;

  void _increaseMinutes() {
    setState(() {
      _minutes++;
    });
  }

  void _decreaseMinutes() {
    setState(() {
      if (_minutes > 0) {
        _minutes--;
      }
    });
  }

  void _toggleTimer() {
    if (_isRunning) {
      _timer?.cancel();
    } else {
      _isTimeUp = false;
      _timer = Timer.periodic(Duration(seconds: 1), (timer) {
        setState(() {
          if (_seconds > 0) {
            _seconds--;
          } else if (_minutes > 0) {
            _seconds = 59;
            _minutes--;
          } else {
            _timer?.cancel();
            _isRunning = false;
            _isTimeUp = true;
          }
        });
      });
    }
    setState(() {
      _isRunning = !_isRunning;
    });
  }

  void _resetTimer() {
    _timer?.cancel();
    setState(() {
      _minutes = 0;
      _seconds = 0;
      _isRunning = false;
      _isTimeUp = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _isTimeUp ? Colors.redAccent : Colors.black12,
      body: CallbackShortcuts(
        bindings: {
          LogicalKeySet(LogicalKeyboardKey.arrowUp): _increaseMinutes,
          LogicalKeySet(LogicalKeyboardKey.arrowDown): _decreaseMinutes,
          LogicalKeySet(LogicalKeyboardKey.space): _toggleTimer,
          LogicalKeySet(LogicalKeyboardKey.delete): _resetTimer,
        },
        child: Focus(
          autofocus: true,
          child: Center(
            child: _isTimeUp
                ? AutoSizeText(
                    'Time is up!',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  )
                    .animate(
                        onPlay: (controller) =>
                            controller.repeat(reverse: true))
                    .shake(
                      duration: Duration(seconds: 1),
                    )
                : Text(
                  textHeightBehavior: TextHeightBehavior(
                    applyHeightToLastDescent: false,
                    applyHeightToFirstAscent: true,
                    leadingDistribution: TextLeadingDistribution.proportional,
                  ),
                  '$_minutes:${_seconds.toString().padLeft(2, '0')}',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    height: 0.7,
                    fontSize: 100,
                    fontWeight: FontWeight.bold,
                    color: Colors.grey,
                  ),
                ),
          ),
        ),
      ),
    );
  }
}
