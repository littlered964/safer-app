import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class AfterOutageGame extends StatefulWidget {
  const AfterOutageGame({super.key});

  @override
  State<AfterOutageGame> createState() => _AfterOutageGameState();
}

class _AfterOutageGameState extends State<AfterOutageGame>
    with TickerProviderStateMixin {
  late final AnimationController _shake;
  late final Animation<double> _shakeAnim;

  final Random _rand = Random(); // for shuffling
  String _currentNodeId = 'start';
  bool _isGameOver = false;
  bool _isVictory = false;
  final List<String> _trail = [];

  final Map<String, List<_Option>> _shuffledOptions = {};

  final Map<String, _Node> _nodes = {
    // 1) Emergencies / 911
    'start': _Node(
      id: 'start',
      title: 'After the Storm',
      prompt:
          'First step after a storm-related outage: what should you do before anything else?',
      options: [
        _Option(
          label:
              'Check for emergencies; call 911 if there’s injury, fire, gas, or sparking',
          explanation:
              'Emergencies come first. Make the call and keep everyone safe.',
          nextId: 'testLight',
          correct: true,
        ),
        _Option(
          label: 'Flip every breaker to ON right away',
          explanation:
              'Bad order—safety checks must come first, not panel flipping.',
          nextId: 'fail',
          correct: false,
        ),
        _Option(
          label: 'Light candles and start inspecting the attic',
          explanation: 'Avoid open flames. Use flashlights/battery lanterns.',
          nextId: 'fail',
          correct: false,
        ),
      ],
    ),

    // 2) Verify power is really back
    'testLight': _Node(
      id: 'testLight',
      title: 'Is Power Actually Back?',
      prompt: 'What’s the safest way to confirm the power is truly restored?',
      options: [
        _Option(
          label: 'Turn on a single light or plug in a small lamp to test',
          explanation:
              'Use a small, simple load to verify service before doing more.',
          nextId: 'downedLines',
          correct: true,
        ),
        _Option(
          label: 'Turn on all appliances at once to “stress test”',
          explanation:
              'Demand spikes and surges can damage electronics and circuits.',
          nextId: 'fail',
          correct: false,
        ),
        _Option(
          label: 'Reset the main breaker repeatedly until lights stay on',
          explanation: 'Never force or “pump” breakers.',
          nextId: 'fail',
          correct: false,
        ),
      ],
    ),

    // 3) Assume all wires live -> report downed lines
    'downedLines': _Node(
      id: 'downedLines',
      title: 'Downed Lines',
      prompt:
          'Outside you spot a line on the ground across the street. What’s the correct move?',
      options: [
        _Option(
          label: 'Assume it’s live. Stay away and report it to the utility',
          explanation:
              'Treat all downed lines as energized. Keep others back and report.',
          nextId: 'electricalDamage',
          correct: true,
        ),
        _Option(
          label: 'Move it with a dry stick so cars can pass',
          explanation: 'Never touch or move a downed line—ever.',
          nextId: 'fail',
          correct: false,
        ),
        _Option(
          label: 'Drive over it carefully; tires are rubber',
          explanation: 'Extremely dangerous; avoid the area completely.',
          nextId: 'fail',
          correct: false,
        ),
      ],
    ),

    // 4) Electrical damage / smoke; breakers
    'electricalDamage': _Node(
      id: 'electricalDamage',
      title: 'Electrical Check',
      prompt:
          'Indoors, what’s the right approach to electrical safety after restoration?',
      options: [
        _Option(
          label:
              'Check for damage or smoke smells; reset a tripped breaker once—if it trips again, call an electrician',
          explanation:
              'One safe reset is OK. Repeated trips or burning smells = stop and call a pro.',
          nextId: 'foodSafety',
          correct: true,
        ),
        _Option(
          label: 'Hold a breaker ON with tape if it keeps tripping',
          explanation: 'Breakers protect against fire—never bypass them.',
          nextId: 'fail',
          correct: false,
        ),
        _Option(
          label: 'Ignore a faint burning smell; it will clear up',
          explanation: 'Investigate and call an electrician if in doubt.',
          nextId: 'fail',
          correct: false,
        ),
      ],
    ),

    // 5) Food safety
    'foodSafety': _Node(
      id: 'foodSafety',
      title: 'Food Safety',
      prompt:
          'The outage lasted a while. What’s the safest way to handle perishable food?',
      options: [
        _Option(
          label:
              'Discard perishable food above 40°F for 2+ hours, or if it smells/looks bad',
          explanation:
              'When in doubt, throw it out. Don’t risk foodborne illness.',
          nextId: 'powerUp',
          correct: true,
        ),
        _Option(
          label: 'Taste it to check if it’s still good',
          explanation: 'You can’t taste safety—this is risky.',
          nextId: 'fail',
          correct: false,
        ),
        _Option(
          label: 'Refreeze everything; cold will kill bacteria',
          explanation:
              'Refreezing doesn’t make unsafe food safe again.',
          nextId: 'fail',
          correct: false,
        ),
      ],
    ),

    // 6) Power electronics carefully + surge protection; reset outlets/clocks
    'powerUp': _Node(
      id: 'powerUp',
      title: 'Powering Back Up',
      prompt:
          'How should you bring the home back online and protect electronics?',
      options: [
        _Option(
          label:
              'Reset outlets/clocks; power devices back on gradually using surge protection',
          explanation:
              'Bring loads up slowly and protect sensitive gear from surges.',
          nextId: 'document',
          correct: true,
        ),
        _Option(
          label: 'Turn on everything at once to get back to normal faster',
          explanation: 'Big, sudden loads can cause surges or new trips.',
          nextId: 'fail',
          correct: false,
        ),
        _Option(
          label: 'Skip surge protection; the danger ends when power returns',
          explanation:
              'Post-restoration flickers/surges are common—use protection.',
          nextId: 'fail',
          correct: false,
        ),
      ],
    ),

    // 7) Document damage before cleanup -> insurance
    'document': _Node(
      id: 'document',
      title: 'Document & Claims',
      prompt:
          'Before cleanup, what’s the most helpful step for claims and follow-up?',
      options: [
        _Option(
          label:
              'Photograph/video any damage first; contact utility/insurance as needed',
          explanation:
              'Documentation helps with repairs and claims.',
          nextId: 'restock',
          correct: true,
        ),
        _Option(
          label: 'Start cleaning immediately; documentation can wait',
          explanation: 'Evidence may be lost—document before cleanup.',
          nextId: 'fail',
          correct: false,
        ),
      ],
    ),

    // 8) Restock, review, fuel → victory
    'restock': _Node(
      id: 'restock',
      title: 'Prepare for Next Time',
      prompt:
          'What’s a smart final step once everything is safe and stable?',
      options: [
        _Option(
          label: 'Restock supplies & fuel; review what worked and what didn’t',
          explanation: 'Close the loop so you’re better prepared next time.',
          nextId: 'victory',
          correct: true,
        ),
        _Option(
          label: 'Do nothing—another outage is unlikely soon',
          explanation: 'Preparedness matters—don’t skip this step.',
          nextId: 'fail',
          correct: false,
        ),
      ],
    ),

    // Terminals
    'victory': _Node.victory(
      id: 'victory',
      title: 'All Set',
      message:
          'Great job! You followed the correct post-outage sequence safely and smartly.',
    ),
    'fail': _Node.fail(
      id: 'fail',
      title: 'Game Over',
      message:
          'That choice isn’t recommended after an outage. Review the tips and try again.',
    ),
  };

  @override
  void initState() {
    super.initState();
    _shake = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );
    _shakeAnim = Tween<double>(begin: 0, end: 12)
        .chain(CurveTween(curve: Curves.easeOut))
        .animate(_shake);

    // Prepare shuffled options for the starting node
    _prepareShuffled('start');
  }

  @override
  void dispose() {
    _shake.dispose();
    super.dispose();
  }

  void _prepareShuffled(String nodeId) {
    final node = _nodes[nodeId]!;
    if (node.type != _NodeType.normal) return;
    _shuffledOptions[nodeId] = [...node.options]..shuffle(_rand);
  }

  List<_Option> _optionsFor(String nodeId) {
    return _shuffledOptions[nodeId] ?? const <_Option>[];
  }

  void _reset() {
    setState(() {
      _currentNodeId = 'start';
      _isGameOver = false;
      _isVictory = false;
      _trail.clear();
      _shuffledOptions.clear(); 
      _prepareShuffled('start'); 
    });
  }

  void _fail() async {
    HapticFeedback.heavyImpact();
    await _shake.forward();
    _shake.reverse();
    setState(() {
      _currentNodeId = 'fail';
      _isGameOver = true;
      _isVictory = false;
    });
  }

  void _victory() {
    HapticFeedback.mediumImpact();
    setState(() {
      _currentNodeId = 'victory';
      _isVictory = true;
      _isGameOver = false;
    });
  }

  void _handleChoice(_Option option) {
    final node = _nodes[_currentNodeId]!;
    if (!option.correct) {
      _fail();
      return;
    }

    final nextId = option.nextId;
    if (nextId == 'fail') {
      _fail();
      return;
    }
    if (nextId == 'victory') {
      _trail.add(node.id);
      _victory();
      return;
    }

    setState(() {
      _trail.add(node.id);
      _currentNodeId = nextId;
      _prepareShuffled(_currentNodeId); 
    });
  }

  @override
  Widget build(BuildContext context) {
    final node = _nodes[_currentNodeId]!;
    final isTerminal = node.type != _NodeType.normal;
    final options =
        isTerminal ? const <_Option>[] : _optionsFor(_currentNodeId);

    return Scaffold(
      appBar: AppBar(
        title: const Text('After Outage'),
        centerTitle: true,
      ),
      body: AnimatedBuilder(
        animation: _shakeAnim,
        builder: (context, child) {
          final dx = _isGameOver
              ? 0.0
              : (_shakeAnim.value *
                  (_shake.status == AnimationStatus.forward ? 1 : 0));
          return Transform.translate(offset: Offset(dx, 0), child: child);
        },
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                // 7 steps before victory
                _ProgressDots(total: 7, done: _trail.length),
                const SizedBox(height: 12),
                _HeaderCard(
                  title: node.title,
                  terminal: isTerminal,
                ),
                const SizedBox(height: 12),
                Expanded(
                  child: _PromptCard(
                    prompt: node.type == _NodeType.normal
                        ? node.prompt
                        : (node.message ?? ''),
                    options: options,
                    isTerminal: isTerminal,
                    onSelect: _handleChoice,
                    onRestart: _reset,
                    victory: _isVictory,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// UI

class _HeaderCard extends StatelessWidget {
  final String title;
  final bool terminal;
  const _HeaderCard({required this.title, this.terminal = false});

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        child: Row(
          children: [
            Icon(terminal ? Icons.emoji_events : Icons.bolt, size: 24),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                title,
                style: Theme.of(context)
                    .textTheme
                    .titleMedium
                    ?.copyWith(fontWeight: FontWeight.w700),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _PromptCard extends StatelessWidget {
  final String prompt;
  final List<_Option> options;
  final bool isTerminal;
  final void Function(_Option) onSelect;
  final VoidCallback onRestart;
  final bool victory;

  const _PromptCard({
    required this.prompt,
    required this.options,
    required this.isTerminal,
    required this.onSelect,
    required this.onRestart,
    required this.victory,
  });

  @override
  Widget build(BuildContext context) {
    if (isTerminal) {
      return Card(
        elevation: 2,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        child: Padding(
          padding: const EdgeInsets.all(18),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                victory ? Icons.emoji_events : Icons.warning_amber_rounded,
                size: 64,
              ),
              const SizedBox(height: 12),
              Text(
                prompt,
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.titleMedium,
              ),
              const SizedBox(height: 20),
              FilledButton(onPressed: onRestart, child: const Text('Play Again')),
            ],
          ),
        ),
      );
    }

    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(prompt, style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 16),
            ...options.map(
              (opt) => Padding(
                padding: const EdgeInsets.only(bottom: 10),
                child: _ChoiceTile(
                  label: opt.label,
                  explanation: opt.explanation,
                  onTap: () => onSelect(opt),
                ),
              ),
            ),
            const Spacer(),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Choose carefully.',
                  style: Theme.of(context)
                      .textTheme
                      .labelMedium
                      ?.copyWith(fontStyle: FontStyle.italic),
                ),
                const Icon(Icons.route),
              ],
            )
          ],
        ),
      ),
    );
  }
}

class _ChoiceTile extends StatefulWidget {
  final String label;
  final String explanation;
  final VoidCallback onTap;
  const _ChoiceTile({
    required this.label,
    required this.explanation,
    required this.onTap,
  });

  @override
  State<_ChoiceTile> createState() => _ChoiceTileState();
}

class _ChoiceTileState extends State<_ChoiceTile> {
  bool _expanded = false;
  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(14),
      onTap: () {
        HapticFeedback.selectionClick();
        widget.onTap();
      },
      onLongPress: () => setState(() => _expanded = !_expanded),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: Theme.of(context).colorScheme.outlineVariant,
          ),
        ),
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(widget.label,
                style: Theme.of(context)
                    .textTheme
                    .bodyLarge
                    ?.copyWith(fontWeight: FontWeight.w600)),
            if (_expanded) ...[
              const SizedBox(height: 6),
              Text(widget.explanation,
                  style: Theme.of(context).textTheme.bodyMedium),
            ]
          ],
        ),
      ),
    );
  }
}

class _ProgressDots extends StatelessWidget {
  final int total;
  final int done;
  const _ProgressDots({required this.total, required this.done});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context).colorScheme;
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(total, (i) {
        final active = i < done;
        return AnimatedContainer(
          duration: const Duration(milliseconds: 250),
          margin: const EdgeInsets.symmetric(horizontal: 4),
          width: active ? 12 : 8,
          height: active ? 12 : 8,
          decoration: BoxDecoration(
            color: active ? theme.primary : theme.outlineVariant,
            shape: BoxShape.circle,
          ),
        );
      }),
    );
  }
}


enum _NodeType { normal, victory, fail }

class _Node {
  final String id;
  final String title;
  final String prompt;
  final List<_Option> options;
  final _NodeType type;
  final String? message;

  const _Node({
    required this.id,
    required this.title,
    required this.prompt,
    required this.options,
  })  : type = _NodeType.normal,
        message = null;

  const _Node.victory({
    required this.id,
    required this.title,
    required this.message,
  })  : prompt = '',
        options = const [],
        type = _NodeType.victory;

  const _Node.fail({
    required this.id,
    required this.title,
    required this.message,
  })  : prompt = '',
        options = const [],
        type = _NodeType.fail;
}

class _Option {
  final String label;
  final String nextId;
  final String explanation;
  final bool correct;

  const _Option({
    required this.label,
    required this.nextId,
    required this.explanation,
    required this.correct,
  });
}
