import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class AfterOutageChoicesPage extends StatefulWidget {
  const AfterOutageChoicesPage({super.key});

  @override
  State<AfterOutageChoicesPage> createState() => _AfterOutageChoicesPageState();
}

class _AfterOutageChoicesPageState extends State<AfterOutageChoicesPage>
    with TickerProviderStateMixin {
  // Shake animation for wrong choice feedback
  late final AnimationController _shakeCtl;
  late final Animation<double> _shake;

  // Routing / state
  String _current = 'q1_emergency';
  bool _isGameOver = false;
  bool _isVictory = false;
  bool _isSafeWait = false;

  // Track completed common modules to skip when merging ON path
  final Set<String> _commonCompleted = <String>{}; // 'downed', 'survey', 'flooding'
  bool _cameFromOff = false;

  final Random _rng = Random();
  final Map<String, List<_Option>> _shuffled = {};

  @override
  void initState() {
    super.initState();
    _shakeCtl =
        AnimationController(vsync: this, duration: const Duration(milliseconds: 350));
    _shake = TweenSequence<double>([
      TweenSequenceItem(tween: Tween(begin: 0, end: -10), weight: 1),
      TweenSequenceItem(tween: Tween(begin: -10, end: 10), weight: 2),
      TweenSequenceItem(tween: Tween(begin: 10, end: -8), weight: 1),
      TweenSequenceItem(tween: Tween(begin: -8, end: 6), weight: 1),
      TweenSequenceItem(tween: Tween(begin: 6, end: 0), weight: 1),
    ]).animate(CurvedAnimation(parent: _shakeCtl, curve: Curves.easeOut));

    _prepareShuffled(_current);
  }

  @override
  void dispose() {
    _shakeCtl.dispose();
    super.dispose();
  }

  // ---------------------- NODE DATA ----------------------

  late final Map<String, _Node> _nodes = {
    // Q1: Emergency?
    'q1_emergency': _Node(
      id: 'q1_emergency',
      title: 'After the Storm',
      prompt: 'Is there an emergency?',
      options: [
        _Option(
          label: 'Yes',
          explanation: 'Handle emergencies first to keep everyone safe.',
          correct: true,
          nextId: 'q2_emergency_action',
        ),
        _Option(
          label: 'No',
          explanation: 'Proceed to confirm your power status.',
          correct: true,
          nextId: 'q3_test_power',
        ),
      ],
    ),

    // Q2 (only if Q1: Yes)
    'q2_emergency_action': _Node(
      id: 'q2_emergency_action',
      title: 'Emergency Response',
      prompt: 'If there is an emergency, what should you do?',
      options: [
        _Option(
          label: 'Call 911 if there’s injury, fire, gas, or sparking',
          explanation: 'Emergencies first—call 911 immediately.',
          correct: true,
          nextId: 'q3_test_power',
        ),
        _Option(
          label: 'Flip every breaker to ON right away',
          explanation: 'Unsafe—electrical panels can wait until it’s safe.',
          correct: false,
          nextId: 'fail',
        ),
        _Option(
          label: 'Light candles and start inspecting the attic',
          explanation: 'Avoid open flames after storms—use battery lights.',
          correct: false,
          nextId: 'fail',
        ),
      ],
    ),

    // Q3: How to test power?
    'q3_test_power': _Node(
      id: 'q3_test_power',
      title: 'Confirm Power Safely',
      prompt: 'What’s the safest way to confirm the power is truly restored?',
      options: [
        _Option(
          label: 'Turn on a single light or plug in a small lamp',
          explanation: 'Use a small load to test—safe and simple.',
          correct: true,
          nextId: 'q4_power_back',
        ),
        _Option(
          label: 'Turn on all appliances at once to “stress test”',
          explanation: 'Large sudden loads can cause surges or damage.',
          correct: false,
          nextId: 'fail',
        ),
        _Option(
          label: 'Reset the main breaker repeatedly until lights stay on',
          explanation: 'Never “pump” breakers—this is unsafe.',
          correct: false,
          nextId: 'fail',
        ),
      ],
    ),

    // Q4: Is power back on?
    'q4_power_back': _Node(
      id: 'q4_power_back',
      title: 'Power Status',
      prompt: 'Is the power back on?',
      options: [
        _Option(
          label: 'Yes',
          explanation: 'Proceed with post-restoration steps.',
          correct: true,
          nextId: 'on_router', // dynamic router for ON path
        ),
        _Option(
          label: 'No',
          explanation: 'Follow safe steps while power is still out.',
          correct: true,
          nextId: 'off1_lighting',
        ),
      ],
    ),

    // -------------------- POWER OFF PATH --------------------

    // OFF1: Lighting
    'off1_lighting': _Node(
      id: 'off1_lighting',
      title: 'Power Still Out',
      prompt: 'Power is still out. What should you use as a lighting source?',
      options: [
        _Option(
          label: 'Flashlights or battery lanterns',
          explanation: 'Battery lights reduce fire risk.',
          correct: true,
          nextId: 'off2_downed',
        ),
        _Option(
          label: 'Candles or open flames',
          explanation: 'Candles raise fire risk during outages.',
          correct: false,
          nextId: 'fail',
        ),
      ],
    ),

    // OFF2: Downed lines (common)
    'off2_downed': _Node(
      id: 'off2_downed',
      title: 'Downed Lines',
      prompt: 'Outside you see a line on the ground. What should you do?',
      options: [
        _Option(
          label: 'Assume it’s live, stay away, and report it to the utility',
          explanation: 'Treat all downed lines as energized.',
          correct: true,
          nextId: 'off3_survey',
          onChoose: () => _markCommonDone('downed'),
        ),
        _Option(
          label: 'Move it with a dry stick so cars can pass',
          explanation: 'Never touch or move a downed line.',
          correct: false,
          nextId: 'fail',
        ),
        _Option(
          label: 'Drive over it carefully; tires are rubber',
          explanation: 'Avoid the area completely—extremely dangerous.',
          correct: false,
          nextId: 'fail',
        ),
      ],
    ),

    // OFF3: Survey damage (common)
    'off3_survey': _Node(
      id: 'off3_survey',
      title: 'Survey Damage',
      prompt: 'What kind of damage should you check your property for?',
      options: [
        _Option(
          label: 'Fallen trees/branches, broken windows, leaks, water inside',
          explanation: 'Spot hazards early so you can keep clear.',
          correct: true,
          nextId: 'off4_flooding',
          onChoose: () => _markCommonDone('survey'),
        ),
      ],
    ),

    // OFF4: Flooding + basement (common)
    'off4_flooding': _Node(
      id: 'off4_flooding',
      title: 'Flooding & Electrical',
      prompt:
          'If your basement is flooded and the circuit breaker is there, what should you do?',
      options: [
        _Option(
          label: 'Stay out of the water and call the utility or an electrician',
          explanation: 'Water + electricity is deadly—get a pro.',
          correct: true,
          nextId: 'off5_fridge',
          onChoose: () => _markCommonDone('flooding'),
        ),
        _Option(
          label: 'Enter the water to reset the breaker',
          explanation: 'Never enter water around electrical equipment.',
          correct: false,
          nextId: 'fail',
        ),
      ],
    ),

    // OFF5: Fridge/Freezer closed
    'off5_fridge': _Node(
      id: 'off5_fridge',
      title: 'Refrigeration',
      prompt:
          'How should you handle your fridge and freezer while power is still out?',
      options: [
        _Option(
          label: 'Keep the doors shut to preserve cold',
          explanation: 'Keeps food safe longer.',
          correct: true,
          nextId: 'off6_generator',
        ),
        _Option(
          label: 'Open them often to check food',
          explanation: 'Opening warms food quickly—avoid.',
          correct: false,
          nextId: 'fail',
        ),
      ],
    ),

    // OFF6: Generator safety
    'off6_generator': _Node(
      id: 'off6_generator',
      title: 'Generator Safety',
      prompt: 'What’s the safe way to run a generator?',
      options: [
        _Option(
          label: 'Outside, at least 20 ft from doors and windows',
          explanation: 'Distance reduces carbon monoxide risk.',
          correct: true,
          nextId: 'off7_battery',
        ),
        _Option(
          label: 'Inside the garage with the door cracked',
          explanation: 'CO can build up quickly—never indoors.',
          correct: false,
          nextId: 'fail',
        ),
        _Option(
          label: 'Right next to a window for convenience',
          explanation: 'Exhaust can enter the home—keep it far away.',
          correct: false,
          nextId: 'fail',
        ),
      ],
    ),

    // OFF7: Battery conservation
    'off7_battery': _Node(
      id: 'off7_battery',
      title: 'Battery Conservation',
      prompt:
          'How should you manage phones and batteries during an extended outage?',
      options: [
        _Option(
          label:
              'Conserve power, use low-power mode, keep one phone off as backup',
          explanation: 'Stretch limited power for updates and calls.',
          correct: true,
          nextId: 'off8_report',
        ),
        _Option(
          label: 'Stream nonstop or run all devices',
          explanation: 'Wastes power you may need later.',
          correct: false,
          nextId: 'fail',
        ),
      ],
    ),

    // OFF8: Report once
    'off8_report': _Node(
      id: 'off8_report',
      title: 'Outage Reporting',
      prompt: 'How often should you report your outage?',
      options: [
        _Option(
          label: 'Report once via the utility app/site or phone',
          explanation: 'Multiple reports don’t speed repairs.',
          correct: true,
          nextId: 'off_recheck',
        ),
        _Option(
          label: 'Report repeatedly to get priority',
          explanation: 'Spam adds noise—report once.',
          correct: false,
          nextId: 'fail',
        ),
      ],
    ),

    // OFF Recheck power
    'off_recheck': _Node(
      id: 'off_recheck',
      title: 'Power Recheck',
      prompt: 'Is the power back on now?',
      options: [
        _Option(
          label: 'Yes',
          explanation: 'Great—proceed safely with restoration steps.',
          correct: true,
          nextId: 'on_router_from_off', // will skip common modules already done
        ),
        _Option(
          label: 'No',
          explanation:
              'Hang tight. Stay alert, conserve battery, and review outage tips.',
          correct: true,
          nextId: 'safe',
        ),
      ],
    ),

    // -------------------- POWER ON PATH --------------------

    // ON1: Downed lines (common, may skip)
    'on1_downed': _Node(
      id: 'on1_downed',
      title: 'Downed Lines',
      prompt: 'You see a line on the ground outside. What should you do?',
      options: [
        _Option(
          label: 'Assume it’s live, stay away, and report it',
          explanation: 'Treat all downed lines as energized.',
          correct: true,
          nextId: 'on_router',
          onChoose: () => _markCommonDone('downed'),
        ),
        _Option(
          label: 'Move it with a dry stick',
          explanation: 'Never touch or move a downed line.',
          correct: false,
          nextId: 'fail',
        ),
        _Option(
          label: 'Drive over it carefully',
          explanation: 'Extremely dangerous—avoid the area.',
          correct: false,
          nextId: 'fail',
        ),
      ],
    ),

    // ON2: Survey damage (common, may skip)
    'on2_survey': _Node(
      id: 'on2_survey',
      title: 'Survey Damage',
      prompt: 'What damage should you look for after a storm?',
      options: [
        _Option(
          label: 'Trees, branches, broken windows, leaks, flooding',
          explanation: 'Identify hazards so you can keep clear.',
          correct: true,
          nextId: 'on_router',
          onChoose: () => _markCommonDone('survey'),
        ),
      ],
    ),

    // ON3: Flooding + basement (common, may skip)
    'on3_flooding': _Node(
      id: 'on3_flooding',
      title: 'Flooding & Electrical',
      prompt:
          'If your basement is flooded and the breaker is located there, what should you do?',
      options: [
        _Option(
          label: 'Stay out of water and call the utility/electrician',
          explanation: 'Water + electricity is deadly—get a pro.',
          correct: true,
          nextId: 'on_router',
          onChoose: () => _markCommonDone('flooding'),
        ),
        _Option(
          label: 'Enter water to reset the breaker',
          explanation: 'Never enter water around electrical equipment.',
          correct: false,
          nextId: 'fail',
        ),
      ],
    ),

    // ON4: Electrical check (post-restoration)
    'on4_electrical': _Node(
      id: 'on4_electrical',
      title: 'Electrical Check',
      prompt: 'Indoors, how should you handle electrical safety after restoration?',
      options: [
        _Option(
          label:
              'If a breaker trips, reset it once. If it trips again or you smell smoke, call an electrician',
          explanation: 'One safe reset is OK—repeated trips need a pro.',
          correct: true,
          nextId: 'on5_powerup',
        ),
        _Option(
          label: 'Hold the breaker ON with tape',
          explanation: 'Breakers protect against fire—never bypass them.',
          correct: false,
          nextId: 'fail',
        ),
        _Option(
          label: 'Ignore a faint burning smell',
          explanation: 'Investigate and call an electrician if in doubt.',
          correct: false,
          nextId: 'fail',
        ),
      ],
    ),

    // ON5: Powering back up safely
    'on5_powerup': _Node(
      id: 'on5_powerup',
      title: 'Powering Back Up',
      prompt:
          'How should you bring your home back online and protect electronics?',
      options: [
        _Option(
          label:
              'Reset outlets/clocks; power devices on gradually with surge protection',
          explanation: 'Bring loads up slowly and protect sensitive gear.',
          correct: true,
          nextId: 'on6_food',
        ),
        _Option(
          label: 'Turn everything on at once',
          explanation: 'Sudden load spikes can cause surges and trips.',
          correct: false,
          nextId: 'fail',
        ),
        _Option(
          label: 'Skip surge protection',
          explanation: 'Post-restoration surges are common—use protection.',
          correct: false,
          nextId: 'fail',
        ),
      ],
    ),

    // ON6: Food safety
    'on6_food': _Node(
      id: 'on6_food',
      title: 'Food Safety',
      prompt: 'What’s the safe rule for food after an outage?',
      options: [
        _Option(
          label: 'Discard perishable food above 40°F for 2+ hours or if spoiled',
          explanation: 'When in doubt, throw it out.',
          correct: true,
          nextId: 'on7_document',
        ),
        _Option(
          label: 'Taste to check if it’s safe',
          explanation: 'You can’t taste safety—this is risky.',
          correct: false,
          nextId: 'fail',
        ),
        _Option(
          label: 'Refreeze to “kill bacteria”',
          explanation: 'Refreezing doesn’t make unsafe food safe.',
          correct: false,
          nextId: 'fail',
        ),
      ],
    ),

    // ON7: Document & claims
    'on7_document': _Node(
      id: 'on7_document',
      title: 'Document & Claims',
      prompt: 'Before cleanup, what’s the best step for claims and follow-up?',
      options: [
        _Option(
          label:
              'Photograph/video any damage first; contact utility/insurance as needed',
          explanation: 'Documentation helps with repairs and claims.',
          correct: true,
          nextId: 'on8_prepare',
        ),
        _Option(
          label: 'Start cleaning immediately; documentation can wait',
          explanation: 'Evidence may be lost—document first.',
          correct: false,
          nextId: 'fail',
        ),
      ],
    ),

    // ON8: Prepare
    'on8_prepare': _Node(
      id: 'on8_prepare',
      title: 'Prepare for Next Time',
      prompt: 'Once everything is safe, what’s a smart final step?',
      options: [
        _Option(
          label: 'Restock supplies & fuel; review what worked and what didn’t',
          explanation: 'Close the loop so you’re better prepared.',
          correct: true,
          nextId: 'victory',
        ),
        _Option(
          label: 'Do nothing—another outage is unlikely soon',
          explanation: 'Preparedness matters—don’t skip this step.',
          correct: false,
          nextId: 'fail',
        ),
      ],
    ),

    // Terminals
    'victory': _Node.victory(
      id: 'victory',
      title: 'All Set',
      message:
          'Great job! You handled the post-outage sequence safely and smartly.',
    ),
    'safe': _Node.safe(
      id: 'safe',
      title: 'Safe While You Wait',
      message:
          'Hang tight. Stay alert, conserve battery, and review outage tips until power is restored.',
    ),
    'fail': _Node.fail(
      id: 'fail',
      title: 'Game Over',
      message:
          'That choice isn’t recommended after an outage. Review the tips and try again.',
    ),
  };

  // ---------------------- HELPERS ----------------------

  void _markCommonDone(String key) => _commonCompleted.add(key);

  void _prepareShuffled(String nodeId) {
    final node = _nodes[nodeId]!;
    if (node.type != _NodeType.normal) return;
    _shuffled[nodeId] = [...node.options]..shuffle(_rng);
  }

  List<_Option> _optionsFor(String nodeId) {
    return _shuffled[nodeId] ?? const <_Option>[];
  }

  void _restart() {
    setState(() {
      _current = 'q1_emergency';
      _isGameOver = false;
      _isVictory = false;
      _isSafeWait = false;
      _commonCompleted.clear();
      _cameFromOff = false;
      _shuffled.clear();
      _prepareShuffled(_current);
    });
  }

  // Router logic when entering ON path
  String _resolveOnRoute() {
    if (!_commonCompleted.contains('downed')) return 'on1_downed';
    if (!_commonCompleted.contains('survey')) return 'on2_survey';
    if (!_commonCompleted.contains('flooding')) return 'on3_flooding';
    return 'on4_electrical';
  }

  void _goTo(String nextId) {
    // Handle transparent router nodes
    if (nextId == 'on_router') {
      final target = _resolveOnRoute();
      setState(() {
        _current = target;
        _prepareShuffled(_current);
      });
      return;
    }
    if (nextId == 'on_router_from_off') {
      final target = _resolveOnRoute();
      setState(() {
        _cameFromOff = true; // informational only
        _current = target;
        _prepareShuffled(_current);
      });
      return;
    }

    final isTerminal = _nodes[nextId]!.type != _NodeType.normal;
    setState(() {
      _current = nextId;
      if (!isTerminal) _prepareShuffled(_current);
      _isVictory = nextId == 'victory';
      _isSafeWait = nextId == 'safe';
      _isGameOver = nextId == 'fail';
    });
  }

  Future<void> _handleChoice(_Option opt) async {
    opt.onChoose?.call();
    if (!opt.correct) {
      HapticFeedback.mediumImpact();
      await _shakeCtl.forward();
      _shakeCtl.reverse();
      _goTo(opt.nextId);
      return;
    }
    HapticFeedback.selectionClick();
    _goTo(opt.nextId);
  }

  // ---------------------- UI ----------------------

  @override
  Widget build(BuildContext context) {
    final node = _nodes[_current]!;
    final isTerminal = node.type != _NodeType.normal;
    final options = isTerminal ? const <_Option>[] : _optionsFor(_current);

    return Scaffold(
      appBar: AppBar(
        title: const Text('After the Storm — Choices'),
        centerTitle: true,
      ),
      body: AnimatedBuilder(
        animation: _shake,
        builder: (context, child) {
          return Transform.translate(offset: Offset(_shake.value, 0), child: child);
        },
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                _HeaderCard(
                  title: node.title,
                  terminal: isTerminal,
                ),
                const SizedBox(height: 12),
                Expanded(
                  child: _PromptCard(
                    prompt: node.type == _NodeType.normal ? node.prompt : (node.message ?? ''),
                    options: options,
                    isTerminal: isTerminal,
                    onSelect: _handleChoice,
                    onRestart: _restart,
                    onClose: () => Navigator.of(context).maybePop(),
                    victory: _isVictory,
                    safe: _isSafeWait,
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

// ---------------------- UI PIECES ----------------------

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
            Icon(
              terminal
                  ? Icons.emoji_events
                  : Icons.bolt,
              size: 24,
            ),
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
  final VoidCallback onClose;
  final bool victory;
  final bool safe;

  const _PromptCard({
    required this.prompt,
    required this.options,
    required this.isTerminal,
    required this.onSelect,
    required this.onRestart,
    required this.onClose,
    required this.victory,
    required this.safe,
  });

  @override
  Widget build(BuildContext context) {
    if (isTerminal) {
      final icon = victory
          ? Icons.emoji_events
          : (safe ? Icons.info_outline : Icons.warning_amber_rounded);
      final color = victory
          ? Colors.green
          : (safe ? Colors.blue : Colors.red);

      return Card(
        elevation: 2,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        child: Padding(
          padding: const EdgeInsets.all(18),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, size: 64, color: color),
              const SizedBox(height: 12),
              Text(
                prompt,
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.titleMedium,
              ),
              const SizedBox(height: 20),
              Wrap(
                spacing: 12,
                runSpacing: 8,
                alignment: WrapAlignment.center,
                children: [
                  FilledButton(onPressed: onRestart, child: const Text('Play Again')),
                  OutlinedButton(onPressed: onClose, child: const Text('Close')),
                ],
              ),
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
            ),
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

// ---------------------- MODELS ----------------------

enum _NodeType { normal, victory, fail, safe }

class _Node {
  final String id;
  final String title;
  final String prompt; // used for normal nodes
  final List<_Option> options;
  final _NodeType type;
  final String? message; // used for terminal nodes

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

  const _Node.safe({
    required this.id,
    required this.title,
    required this.message,
  })  : prompt = '',
        options = const [],
        type = _NodeType.safe;
}

class _Option {
  final String label;
  final String explanation;
  final bool correct;
  final String nextId;
  final VoidCallback? onChoose;

  const _Option({
    required this.label,
    required this.explanation,
    required this.correct,
    required this.nextId,
    this.onChoose,
  });
}
