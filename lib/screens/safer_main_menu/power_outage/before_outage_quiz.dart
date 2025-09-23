import 'package:flutter/material.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:confetti/confetti.dart';

class QuizQuestion {
  final String text;
  final bool isTrue;
  final String explain;
  const QuizQuestion(this.text, this.isTrue, this.explain);
}

class BeforeOutageQuizPage extends StatefulWidget {
  const BeforeOutageQuizPage({super.key});

  @override
  State<BeforeOutageQuizPage> createState() => _BeforeOutageQuizPageState();
}

class _BeforeOutageQuizPageState extends State<BeforeOutageQuizPage> {
  final List<QuizQuestion> _questions = const [
    // Alerts & outage map
    QuizQuestion(
      'You should enroll in outage alerts and bookmark your utility’s outage map.',
      true,
      'Alerts + maps help you track restoration progress and stay informed.',
    ),
    QuizQuestion(
      'Bookmarking your utility’s outage map is unnecessary before a storm.',
      false,
      'Having the map handy helps you monitor outages and repair estimates quickly.',
    ),

    // Generator: never indoors, fresh fuel, distance
    QuizQuestion(
      'It\'s fine to run a generator in the garage if the door is cracked open.',
      false,
      'Never run generators indoors or in garages – carbon monoxide risk.',
    ),
    QuizQuestion(
      'A safe practice is to run a generator at least 20 feet away from doors and windows.',
      true,
      'Distance reduces carbon monoxide dangers from exhaust.',
    ),
    QuizQuestion(
      'Keeping fresh fuel on hand for your generator is part of storm prep.',
      true,
      'Fresh fuel ensures the generator starts and runs reliably when needed.',
    ),

    // Charge phones & backups
    QuizQuestion(
      'Charging phones and backup batteries before a storm is recommended.',
      true,
      'Full batteries keep you connected to updates and emergency contacts.',
    ),
    QuizQuestion(
      'You should wait until after the power goes out to charge phones and power banks.',
      false,
      'Charge everything beforehand so you’re ready for an extended outage.',
    ),

    // Garage door manual release
    QuizQuestion(
      'Disengaging your garage door opener so you can open it manually is smart prep.',
      true,
      'Knowing the manual release lets you get your car out if power is lost.',
    ),
    QuizQuestion(
      'There’s no need to learn the manual release for your garage door before a storm.',
      false,
      'Locate and test the manual release in advance so you’re not stuck.',
    ),

    // Fridge / Freezer to coldest
    QuizQuestion(
      'It\'s best to set the fridge and freezer to their coldest settings before an outage.',
      true,
      'Colder temps help food stay safe longer during a power loss.',
    ),
    QuizQuestion(
      'Warming your fridge/freezer before a storm helps save energy and protect food.',
      false,
      'Colder settings extend safe food temperatures during an outage.',
    ),

    // Cash on hand
    QuizQuestion(
      'Keeping some cash on hand is recommended because cards/ATMs may fail.',
      true,
      'Networks and ATMs can be down; cash ensures you can still make purchases.',
    ),
    QuizQuestion(
      'Relying only on credit/debit is fine because payment networks always stay up.',
      false,
      'Connectivity can fail in storms, so carry some cash as a backup.',
    ),

    // Unplug non-essentials, surge protection, leave 1 light on
    QuizQuestion(
      'Unplug non-essential electronics and use surge protectors before the storm.',
      true,
      'This reduces damage risk from power surges when electricity returns.',
    ),
    QuizQuestion(
      'You should plug in as many devices as possible during the storm to “use the power while you can.”',
      false,
      'Unplug non-essentials to avoid surge damage; only keep what you need.',
    ),
    QuizQuestion(
      'Leaving one light on helps you notice when power is restored.',
      true,
      'A single indicator light prevents you from constantly checking breakers.',
    ),

    // Preparedness kit: flashlights, batteries, radio
    QuizQuestion(
      'Your kit should include flashlights, extra batteries, and a radio.',
      true,
      'These essentials provide safe light and updates when the power is out.',
    ),
    QuizQuestion(
      'A storm kit doesn’t need a radio if you have flashlights and phone chargers.',
      false,
      'A radio helps you get updates if cell service or data is unreliable.',
    ),
  ];

  int _index = 0;
  int _score = 0;
  int _lives = 3;
  bool _completed = false;
  bool _lost = false;

  // Intro modal once
  bool _needsIntro = true;

  // SFX (same files as during_outage_sort)
  late final AudioPlayer _sfxPlayer;
  bool _muted = false; // optional future toggle

  // Confetti on win
  late final ConfettiController _confettiCtl;

  @override
  void initState() {
    super.initState();
    _sfxPlayer = AudioPlayer(playerId: 'quiz_sfx')..setReleaseMode(ReleaseMode.stop);
    _confettiCtl = ConfettiController(duration: const Duration(seconds: 2));

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      if (_needsIntro) {
        _showIntroModal();
      }
    });
  }

  @override
  void dispose() {
    _sfxPlayer.dispose();
    _confettiCtl.dispose();
    super.dispose();
  }

  Future<void> _playSfx(String filename, {double volume = 0.9}) async {
    if (_muted) return;
    try {
      await _sfxPlayer.stop();
      await _sfxPlayer.play(AssetSource('audio/$filename'), volume: volume);
    } catch (_) {}
  }

  void _showSnack(String message) {
    ScaffoldMessenger.of(context).hideCurrentSnackBar();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        duration: const Duration(seconds: 2),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  void _answer(bool userSaysTrue) async {
    if (_completed) return;

    final q = _questions[_index];
    final correct = (userSaysTrue == q.isTrue);

    if (correct) {
      _score++;
      _playSfx('correct.mp3');
      _showSnack('Correct! ✅\n${q.explain}');
      setState(() {
        if (_index < _questions.length - 1) {
          _index++;
        } else {
          _completed = true;
          _lost = false;
        }
      });
    } else {
      _playSfx('incorrect.aiff');
      setState(() {
        _lives = (_lives - 1).clamp(0, 3);
      });
      _showSnack('Not quite. ❌\n${q.explain}');
      setState(() {
        if (_lives == 0) {
          _completed = true;
          _lost = true;
        } else {
          if (_index < _questions.length - 1) {
            _index++;
          } else {
            _completed = true;
            _lost = false;
          }
        }
      });
    }

    // Show end dialog (and confetti + win sound if win)
    if (_completed) {
      if (!_lost) {
        _playSfx('win.wav'); // <-- added win sound
        _confettiCtl.play();
      }
      _showEndDialog();
    }
  }

  void _reset() {
    setState(() {
      _index = 0;
      _score = 0;
      _lives = 3;
      _completed = false;
      _lost = false;
    });
  }

  void _showIntroModal() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (dialogCtx) => WillPopScope(
        onWillPop: () async {
          Navigator.of(dialogCtx).pop();
          Navigator.of(context).maybePop();
          return false;
        },
        child: AlertDialog(
          title: const Text('How to play'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const _RuleRow(text: 'Answer each statement: True or False'),
              const _RuleRow(text: 'You have 3 lives'),
              _RuleRow(text: 'Answer all ${_questions.length} questions to win'),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(dialogCtx).pop();    // close intro
                Navigator.of(context).maybePop(); // back to previous page
              },
              child: const Text('Back'),
            ),
            FilledButton.icon(
              icon: const Icon(Icons.play_arrow),
              label: const Text('Play now!'),
              onPressed: () {
                Navigator.of(dialogCtx).pop();
                setState(() => _needsIntro = false);
              },
            ),
          ],
        ),
      ),
    );
  }

  void _showEndDialog() {
    final won = !_lost;
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => AlertDialog(
        title: Text(won ? 'Great job!' : 'Out of lives'),
        content: Text(
          won
              ? 'Final score: $_score / ${_questions.length}'
              : 'You\'re out of lives.\nFinal score: $_score',
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop(); // close dialog
              _reset();
            },
            child: const Text('Play Again'),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();  // close dialog
              Navigator.of(context).maybePop(); // leave quiz page
            },
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  Widget _buildLives() {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(3, (i) {
        final filled = i < _lives;
        return Padding(
          padding: const EdgeInsets.only(left: 2),
          child: Icon(
            filled ? Icons.favorite : Icons.favorite_border,
            color: filled ? Colors.red : Colors.red.withOpacity(0.5),
            size: 20,
          ),
        );
      }),
    );
  }

  @override
  Widget build(BuildContext context) {
    final q = _questions[_index];

    return Scaffold(
      appBar: AppBar(title: const Text('Before: Preparedness Quiz')),
      body: Stack(
        children: [
          // Main content
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Top bar: progress + score + lives
                Row(
                  children: [
                    Expanded(
                      child: LinearProgressIndicator(
                        value: (_index + 1) / _questions.length,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Text('Score: $_score',
                        style: const TextStyle(fontWeight: FontWeight.w600)),
                    const SizedBox(width: 12),
                    _buildLives(),
                  ],
                ),

                // Centered content: question, prompt, and buttons together
                Expanded(
                  child: Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 8.0),
                          child: Text(
                            q.text,
                            textAlign: TextAlign.center,
                            style: const TextStyle(
                              fontSize: 22,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                        const SizedBox(height: 16),
                        const Text(
                          'True or False?',
                          style: TextStyle(color: Colors.black54),
                        ),
                        const SizedBox(height: 24),

                        // Buttons directly under the prompt
                        if (!_completed) ...[
                          ElevatedButton.icon(
                            onPressed: () => _answer(true),
                            icon: const Icon(Icons.check_circle_outline),
                            label: const Text('True'),
                          ),
                          const SizedBox(height: 12),
                          OutlinedButton.icon(
                            onPressed: () => _answer(false),
                            icon: const Icon(Icons.cancel_outlined),
                            label: const Text('False'),
                          ),
                        ] else ...[
                          // Keeping your existing end-state content;
                          // the win/lose dialog will also appear.
                          Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                _lost
                                    ? Icons.sentiment_dissatisfied
                                    : Icons.verified,
                                size: 40,
                                color: _lost ? Colors.red : Colors.green,
                              ),
                              const SizedBox(height: 8),
                              Text(
                                _lost
                                    ? 'You\'re out of lives! Final score: $_score'
                                    : 'Great job! Final score: $_score / ${_questions.length}',
                                textAlign: TextAlign.center,
                                style: const TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 12),
                              ElevatedButton(
                                onPressed: _reset,
                                child: const Text('Play Again'),
                              ),
                            ],
                          ),
                        ],
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Confetti overlay (plays on win)
          Align(
            alignment: Alignment.topCenter,
            child: IgnorePointer(
              child: ConfettiWidget(
                confettiController: _confettiCtl,
                blastDirectionality: BlastDirectionality.explosive,
                numberOfParticles: 20,
                maxBlastForce: 14,
                minBlastForce: 6,
                emissionFrequency: 0.02,
                shouldLoop: false,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Small rule row used in the intro dialog
class _RuleRow extends StatelessWidget {
  final String text;
  const _RuleRow({required this.text});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Padding(
            padding: EdgeInsets.only(top: 2),
            child: Icon(Icons.check_circle, size: 16),
          ),
          const SizedBox(width: 8),
          Expanded(child: Text(text)), // <-- ensure the legend text is visible
        ],
      ),
    );
  }
}
