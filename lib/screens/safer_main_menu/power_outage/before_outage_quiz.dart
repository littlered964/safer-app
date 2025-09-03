import 'package:flutter/material.dart';

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
    QuizQuestion(
      'You should enroll in outage alerts and bookmark your utility’s outage map.',
      true,
      'Alerts + maps help you track restoration progress and stay informed.',
    ),
    QuizQuestion(
      'It\'s fine to run a generator in the garage if the door is cracked open.',
      false,
      'Never run generators indoors or in garages – carbon monoxide risk.',
    ),
    QuizQuestion(
      'Charging phones and backup batteries before a storm is recommended.',
      true,
      'Full batteries keep you connected to updates and emergency contacts.',
    ),
    QuizQuestion(
      'It\'s best to set the fridge/freezer to their coldest settings before an outage.',
      true,
      'Colder temps help food stay safe longer during a power loss.',
    ),
    QuizQuestion(
      'Use candles as your primary light source during outages.',
      false,
      'Avoid candles due to fire risk. Use flashlights or battery lanterns instead.',
    ),
  ];

  int _index = 0;
  int _score = 0;
  int _lives = 3;
  bool _completed = false;
  bool _lost = false;

  void _showSnack(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  void _answer(bool userSaysTrue) {
    if (_completed) return;

    final q = _questions[_index];
    final correct = (userSaysTrue == q.isTrue);

    if (correct) {
      _score++;
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
      body: Padding(
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
    );
  }
}
