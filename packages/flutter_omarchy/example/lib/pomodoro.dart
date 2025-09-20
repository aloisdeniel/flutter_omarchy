import 'dart:async';
import 'dart:math' show Random, exp, pi, pow, sin;

import 'package:flutter/foundation.dart';
import 'package:flutter_omarchy/flutter_omarchy.dart';

class PomodoroApp extends StatelessWidget {
  const PomodoroApp({super.key});

  @override
  Widget build(BuildContext context) {
    return OmarchyApp(
      debugShowCheckedModeBanner: false,
      home: const PomodoroTimer(),
    );
  }
}

class PomodoroTimer extends StatefulWidget {
  const PomodoroTimer({super.key});

  @override
  State<PomodoroTimer> createState() => _PomodoroTimerState();
}

class _PomodoroTimerState extends State<PomodoroTimer>
    with SingleTickerProviderStateMixin {
  // Timer settings
  final int workDuration = 25 * 60; // 25 minutes in seconds
  final int shortBreakDuration = 5 * 60; // 5 minutes in seconds
  final int longBreakDuration = 15 * 60; // 15 minutes in seconds

  // Timer state
  late Timer _timer;
  int _secondsRemaining = 0;
  bool _isRunning = false;
  bool _isWorkPhase = true;
  int _completedWorkPhases = 0;

  // Animation controller
  late AnimationController _animationController;

  @override
  void initState() {
    super.initState();
    _secondsRemaining = workDuration;

    // Initialize animation controller
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _timer.cancel();
    _animationController.dispose();
    super.dispose();
  }

  void _startTimer() {
    setState(() {
      _isRunning = true;
    });

    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      setState(() {
        if (_secondsRemaining > 0) {
          _secondsRemaining--;
        } else {
          _timer.cancel();
          _isRunning = false;

          // Switch between work and break phases
          if (_isWorkPhase) {
            _completedWorkPhases++;
            _isWorkPhase = false;

            // After 4 work phases, take a long break
            if (_completedWorkPhases % 4 == 0) {
              _secondsRemaining = longBreakDuration;
            } else {
              _secondsRemaining = shortBreakDuration;
            }
          } else {
            _isWorkPhase = true;
            _secondsRemaining = workDuration;
          }

          // Play notification sound or show notification here
        }
      });
    });
  }

  void _pauseTimer() {
    _timer.cancel();
    setState(() {
      _isRunning = false;
    });
  }

  void _resetTimer() {
    _timer.cancel();
    setState(() {
      _isRunning = false;
      _isWorkPhase = true;
      _secondsRemaining = workDuration;
      _completedWorkPhases = 0;
    });
  }

  String _formatTime(int seconds) {
    int minutes = seconds ~/ 60;
    int remainingSeconds = seconds % 60;
    return '$minutes:${remainingSeconds.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    final theme = OmarchyTheme.of(context);
    late final endsAt = DateTime.now().add(
      Duration(seconds: _secondsRemaining),
    );
    return OmarchyScaffold(
      status: OmarchyStatusBar(
        leading: [
          OmarchyStatus(
            accent: () {
              if (!_isRunning) {
                return AnsiColor.white;
              }
              if (_isWorkPhase) {
                return AnsiColor.red;
              }
              return AnsiColor.blue;
            }(),
            child: () {
              if (!_isRunning) {
                return Text('PAUSED');
              }
              if (_isWorkPhase) {
                return Text('WORK');
              }
              return Text('BREAK');
            }(),
          ),
          if (_isRunning)
            OmarchyStatus(
              accent: AnsiColor.white,
              child: Row(
                mainAxisSize: MainAxisSize.min,
                spacing: 4,
                children: [
                  Icon(OmarchyIcons.codArrowRight),
                  Text('${endsAt.hour}:${endsAt.minute}'),
                ],
              ),
            ),
        ],
        trailing: [
          OmarchyStatus(
            child: Text('Completed Pomodoros: $_completedWorkPhases'),
          ),
        ],
      ),
      child: AnimatedContainer(
        duration: const Duration(seconds: 1),
        color: () {
          return (_isWorkPhase
                  ? theme.colors.normal.red
                  : theme.colors.normal.blue)
              .withValues(alpha: _isRunning ? 0.1 : 0.0);
        }(),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          spacing: 40,
          children: [
            Expanded(
              flex: 2,
              child: AnimatedOpacity(
                duration: const Duration(milliseconds: 200),
                opacity: _isRunning ? 1.0 : 0.2,
                child: _AnimatedWaveLines(
                  isAnimated: _isRunning,
                  intensity: _isWorkPhase ? 1.0 : 0.0,
                ),
              ),
            ),
            Expanded(
              flex: 1,
              child: Center(
                child: Text(
                  _formatTime(_secondsRemaining),
                  style: theme.text.bold.copyWith(fontSize: 60),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(24.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  OmarchyButton(
                    onPressed: _isRunning ? _pauseTimer : _startTimer,
                    style: OmarchyButtonStyle.filled(
                      _isWorkPhase ? AnsiColor.red : AnsiColor.blue,
                    ),
                    child: Text(
                      _isRunning ? 'PAUSE' : 'START',
                      style: const TextStyle(fontSize: 20),
                    ),
                  ),
                  const SizedBox(width: 20),
                  OmarchyButton(
                    onPressed: _resetTimer,
                    style: OmarchyButtonStyle.filled(AnsiColor.white),
                    child: const Text('RESET', style: TextStyle(fontSize: 20)),
                  ),
                  if (kDebugMode) ...[
                    const SizedBox(width: 40),
                    OmarchyButton(
                      onPressed: () {
                        _secondsRemaining -= 5 * 60;
                      },
                      style: OmarchyButtonStyle.filled(AnsiColor.white),
                      child: const Text(
                        'ADD 5',
                        style: TextStyle(fontSize: 20),
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _AnimatedWaveLines extends StatefulWidget {
  const _AnimatedWaveLines({required this.isAnimated, required this.intensity});

  final bool isAnimated;
  final double intensity;

  @override
  State<_AnimatedWaveLines> createState() => _AnimatedWaveLinesState();
}

class _AnimatedWaveLinesState extends State<_AnimatedWaveLines>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late List<double> thicknesses;
  late List<double> frequencies;
  late List<double> phases;

  @override
  void initState() {
    super.initState();

    final random = Random();

    // Initialize line properties
    frequencies = List.generate(5, (_) => 0.005 + random.nextDouble() * 0.01);
    phases = List.generate(5, (_) => random.nextDouble() * 2 * pi);

    _controller = AnimationController(
      vsync: this,
      duration: Duration(seconds: 4),
    );
    if (widget.isAnimated) {
      _controller.repeat();
    }
  }

  @override
  void didUpdateWidget(covariant _AnimatedWaveLines oldWidget) {
    if (widget.isAnimated != oldWidget.isAnimated) {
      if (widget.isAnimated) {
        _controller.repeat();
      } else {
        _controller.stop();
      }
    }
    super.didUpdateWidget(oldWidget);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  List<Color> colors(BuildContext context) {
    final theme = OmarchyTheme.of(context);
    final notIntense = [
      theme.colors.bright.blue,
      theme.colors.bright.green,
      theme.colors.normal.blue,
      theme.colors.normal.green,
      theme.colors.normal.blue,
    ];
    final intense = [
      theme.colors.bright.red,
      theme.colors.bright.yellow,
      theme.colors.bright.red,
      theme.colors.normal.yellow,
      theme.colors.normal.red,
    ];
    return [
      for (var i = 0; i < notIntense.length; i++)
        Color.lerp(notIntense[i], intense[i], widget.intensity)!,
    ];
  }

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      painter: WaveLinesPainter(
        colors: colors(context),
        intensity: widget.intensity,
        animation: _controller,
        thicknesses: const [55, 70, 44, 60, 50],
        frequencies: const [0.005, 0.006, 0.007, 0.005, 0.006],
        phases: phases,
      ),
      size: Size(double.infinity, 300),
    );
  }
}

class WaveLinesPainter extends CustomPainter {
  WaveLinesPainter({
    required this.animation,
    required this.thicknesses,
    required this.frequencies,
    required this.phases,
    required this.colors,
    required this.intensity,
  }) : super(repaint: animation);

  final Animation<double> animation;
  final List<double> thicknesses;
  final List<double> frequencies;
  final List<double> phases;
  final List<Color> colors;
  final double intensity;

  @override
  void paint(Canvas canvas, Size size) {
    final centerX = 2 * size.width / 3;
    for (int i = 0; i < phases.length; i++) {
      final color = colors[i % colors.length];
      final paint = Paint()
        ..style = PaintingStyle.stroke
        ..shader =
            LinearGradient(
              begin: Alignment.centerLeft,
              end: Alignment.centerRight,
              stops: [0.0, 0.35, 0.6, 1.0],
              colors: [
                color.withValues(alpha: 0),
                color,
                color,
                color.withValues(alpha: 0),
              ],
            ).createShader(
              Offset(-size.width * 0.1, 0) &
                  Size(size.width * 1.2, size.height),
            )
        ..strokeWidth = thicknesses[i];

      final path = Path();

      for (double x = 0; x <= size.width + 20; x += 1) {
        final normalizedX = (x - centerX) / centerX;
        final envelope = exp(-pow(normalizedX * 2.4, 2));
        final wave = sin(
          x * frequencies[i] + (1 - animation.value) * 2 * pi + phases[i],
        );

        final y =
            (size.height / 2) +
            wave * (0.1 + 0.2 * intensity) * size.height / 2 * envelope;

        if (x == 0) {
          path.moveTo(x, y);
        } else {
          path.lineTo(x, y);
        }
      }

      canvas.drawPath(path, paint);
    }
  }

  @override
  bool shouldRepaint(covariant WaveLinesPainter oldDelegate) => true;
}
