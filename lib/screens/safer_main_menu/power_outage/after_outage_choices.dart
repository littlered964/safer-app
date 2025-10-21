import 'dart:async';
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
  // ---------- Room / movement ----------
  static const Size _roomSize = Size(1000, 620); // logical canvas size
  static const double _avatarSize = 34;
  static const double _moveSpeed = 180; // px/s while holding
  static const double _tapStep = 40; // px per tap
  static const double _interactRadius = 56; // how close to interact

  // Avatar state (room-local coordinates, origin = top-left of playfield)
  Offset _avatar = const Offset(160, 480);
  Timer? _moveTimer;
  _Dir? _heldDir;

  // Pulse animation for active hotspot
  late final AnimationController _pulseCtl =
      AnimationController(vsync: this, duration: const Duration(milliseconds: 900))
        ..repeat(reverse: true);
  late final Animation<double> _pulse = Tween(begin: 0.8, end: 1.12).animate(
    CurvedAnimation(parent: _pulseCtl, curve: Curves.easeInOut),
  );

  // Wrong-choice shake
  late final AnimationController _shakeCtl =
      AnimationController(vsync: this, duration: const Duration(milliseconds: 350));
  late final Animation<double> _shake = TweenSequence<double>([
    TweenSequenceItem(tween: Tween(begin: 0, end: -10), weight: 1),
    TweenSequenceItem(tween: Tween(begin: -10, end: 10), weight: 2),
    TweenSequenceItem(tween: Tween(begin: 10, end: -8), weight: 1),
    TweenSequenceItem(tween: Tween(begin: -8, end: 6), weight: 1),
    TweenSequenceItem(tween: Tween(begin: 6, end: 0), weight: 1),
  ]).animate(CurvedAnimation(parent: _shakeCtl, curve: Curves.easeOut));

  // Routing / state (kept from your file)
  String _current = 'q1_emergency';
  bool _isGameOver = false;
  bool _isVictory = false;
  bool _isSafeWait = false;

  // Track completed common modules to skip on ON path
  final Set<String> _commonCompleted = <String>{}; // 'downed', 'survey', 'flooding'
  bool _cameFromOff = false;

  final Random _rng = Random();
  final Map<String, List<_Option>> _shuffled = {};

  // -------------------- Hotspots (room objects) --------------------
  // Each node is mapped to a hotspot location in the room.
  // Feel free to adjust positions or icons.
  late final List<_Hotspot> _hotspots = [
    _Hotspot(id: 'q1_emergency', label: 'Emergency?', icon: Icons.phone_in_talk, pos: const Offset(100, 140)),
    _Hotspot(id: 'q2_emergency_action', label: 'Call 911?', icon: Icons.local_fire_department, pos: const Offset(210, 120)),

    _Hotspot(id: 'q3_test_power', label: 'Test Power', icon: Icons.lightbulb, pos: const Offset(360, 160)),
    _Hotspot(id: 'q4_power_back', label: 'Power Status', icon: Icons.power, pos: const Offset(520, 160)),

    // OFF path cluster (left/bottom)
    _Hotspot(id: 'off1_lighting', label: 'Lighting', icon: Icons.flashlight_on, pos: const Offset(140, 420)),
    _Hotspot(id: 'off2_downed', label: 'Downed Line', icon: Icons.warning_amber, pos: const Offset(80, 320)),
    _Hotspot(id: 'off3_survey', label: 'Survey', icon: Icons.home_repair_service, pos: const Offset(80, 260)),
    _Hotspot(id: 'off4_flooding', label: 'Flooding', icon: Icons.water_damage, pos: const Offset(80, 200)),
    _Hotspot(id: 'off5_fridge', label: 'Fridge', icon: Icons.kitchen, pos: const Offset(220, 420)),
    _Hotspot(id: 'off6_generator', label: 'Generator', icon: Icons.propane_tank, pos: const Offset(300, 520)),
    _Hotspot(id: 'off7_battery', label: 'Battery', icon: Icons.battery_saver, pos: const Offset(400, 520)),
    _Hotspot(id: 'off8_report', label: 'Report', icon: Icons.report, pos: const Offset(500, 520)),
    _Hotspot(id: 'off_recheck', label: 'Recheck Power', icon: Icons.refresh, pos: const Offset(600, 520)),

    // ON path cluster (right/top)
    _Hotspot(id: 'on1_downed', label: 'Downed Line', icon: Icons.warning, pos: const Offset(820, 150)),
    _Hotspot(id: 'on2_survey', label: 'Survey', icon: Icons.rule_folder, pos: const Offset(820, 210)),
    _Hotspot(id: 'on3_flooding', label: 'Flooding', icon: Icons.water_drop, pos: const Offset(820, 270)),
    _Hotspot(id: 'on4_electrical', label: 'Electrical', icon: Icons.electric_bolt, pos: const Offset(700, 160)),
    _Hotspot(id: 'on5_powerup', label: 'Power Up', icon: Icons.settings_power, pos: const Offset(700, 220)),
    _Hotspot(id: 'on6_food', label: 'Food Safety', icon: Icons.fastfood, pos: const Offset(700, 280)),
    _Hotspot(id: 'on7_document', label: 'Document', icon: Icons.photo_camera, pos: const Offset(700, 340)),
    _Hotspot(id: 'on8_prepare', label: 'Prepare', icon: Icons.inventory_2, pos: const Offset(700, 400)),

    // Terminals
    _Hotspot(id: 'victory', label: 'All Set', icon: Icons.emoji_events, pos: const Offset(860, 460)),
    _Hotspot(id: 'safe', label: 'Safe Wait', icon: Icons.info_outline, pos: const Offset(560, 120)),
    _Hotspot(id: 'fail', label: 'Game Over', icon: Icons.warning_amber_rounded, pos: const Offset(560, 120)),
  ];

  // ---------------------- NODE DATA (unchanged content) ----------------------
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
      _avatar = const Offset(160, 480);
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
        _cameFromOff = true;
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

  // ---------------------- Movement ----------------------

  void _startHold(_Dir dir) {
    _heldDir = dir;
    _moveTimer?.cancel();
    const tick = Duration(milliseconds: 16);
    _moveTimer = Timer.periodic(tick, (_) {
      final delta = (_moveSpeed * (tick.inMilliseconds / 1000.0));
      _nudge(dir, delta);
    });
  }

  void _stopHold() {
    _moveTimer?.cancel();
    _heldDir = null;
  }

  void _tapStepMove(_Dir dir) {
    _nudge(dir, _tapStep);
  }

  void _nudge(_Dir dir, double d) {
    // ensure doubles (0.0 instead of 0)
    final double dx = (dir == _Dir.left ? -d : (dir == _Dir.right ? d : 0.0));
    final double dy = (dir == _Dir.up   ? -d : (dir == _Dir.down  ? d : 0.0));

    var p = _avatar + Offset(dx, dy);

    // clamp to room bounds (account for avatar size)
    const double pad = 8.0;
    final double maxX = _roomSize.width  - pad - _avatarSize;
    final double maxY = _roomSize.height - pad - _avatarSize;

    p = Offset(
      p.dx.clamp(pad, maxX).toDouble(),
      p.dy.clamp(pad, maxY).toDouble(),
    );

    setState(() => _avatar = p);
  }


  // Current hotspot object
  _Hotspot? get _activeHotspot {
    // The current node determines the required hotspot.
    // If _current is a router, highlight the resolved target.
    final id = (_current == 'on_router' || _current == 'on_router_from_off')
        ? _resolveOnRoute()
        : _current;
    return _hotspots.firstWhere((h) => h.id == id, orElse: () => _hotspots.firstWhere((h) => h.id == 'safe'));
  }

  bool get _canInteract {
    final h = _activeHotspot;
    if (h == null) return false;
    final dist = (_avatar + Offset(_avatarSize / 2, _avatarSize / 2) - h.pos).distance;
    return dist <= _interactRadius;
  }

  void _onInteract() {
    final node = _nodes[_current]!;
    final isTerminal = node.type != _NodeType.normal;
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      showDragHandle: true,
      backgroundColor: Theme.of(context).colorScheme.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(18)),
      ),
      builder: (_) {
        return AnimatedBuilder(
          animation: _shake,
          builder: (context, child) => Transform.translate(offset: Offset(_shake.value, 0), child: child),
          child: Padding(
            padding: EdgeInsets.only(
              left: 16, right: 16,
              bottom: 16 + MediaQuery.of(context).viewInsets.bottom,
              top: 6,
            ),
            child: _PromptSheet(
              title: node.title,
              prompt: node.type == _NodeType.normal ? node.prompt : (node.message ?? ''),
              options: isTerminal ? const <_Option>[] : _optionsFor(_current),
              isTerminal: isTerminal,
              onSelect: (opt) async {
                Navigator.of(context).pop(); // close sheet first
                await _handleChoice(opt);
              },
              onRestart: () {
                Navigator.of(context).pop();
                _restart();
              },
              onClose: () => Navigator.of(context).maybePop(),
              victory: _isVictory,
              safe: _isSafeWait,
            ),
          ),
        );
      },
    );
  }

  @override
  void initState() {
    super.initState();
    _prepareShuffled(_current);
  }

  @override
  void dispose() {
    _moveTimer?.cancel();
    _pulseCtl.dispose();
    _shakeCtl.dispose();
    super.dispose();
  }

  // ---------------------- UI ----------------------

  @override
  Widget build(BuildContext context) {
    final active = _activeHotspot;

    return Scaffold(
      appBar: AppBar(
        title: const Text('After the Storm — Explore'),
        centerTitle: true,
        actions: [
          IconButton(
            tooltip: 'Restart',
            icon: const Icon(Icons.refresh),
            onPressed: _restart,
          ),
        ],
      ),
      body: LayoutBuilder(
        builder: (context, c) {
          // Fit the room into available space while preserving aspect
          final scale = min(c.maxWidth / _roomSize.width, (c.maxHeight - 120) / _roomSize.height);
          final roomPx = Size(_roomSize.width * scale, _roomSize.height * scale);

          return Column(
            children: [
              const SizedBox(height: 8),
              // Progress hint
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 12),
                child: Row(
                  children: [
                    Icon(Icons.place, size: 18, color: Theme.of(context).colorScheme.primary),
                    const SizedBox(width: 6),
                    Expanded(
                      child: Text(
                        'Go to: ${_nodes[(active?.id ?? _current)]?.title ?? ''}',
                        overflow: TextOverflow.ellipsis,
                        style: Theme.of(context).textTheme.labelMedium,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 8),

              // Room playfield
              Center(
                child: Container(
                  width: roomPx.width,
                  height: roomPx.height,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(18),
                    gradient: const LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [Color(0xFF0F172A), Color(0xFF1E293B)],
                    ),
                    border: Border.all(color: Colors.white24, width: 1),
                    boxShadow: const [BoxShadow(blurRadius: 10, color: Colors.black38)],
                  ),
                  clipBehavior: Clip.antiAlias,
                  child: Stack(
                    children: [
                      // Light grid / room hints
                      CustomPaint(
                        size: roomPx,
                        painter: _RoomPainter(),
                      ),

                      // Hotspots
                      for (final h in _hotspots)
                        _buildHotspot(h, scale, h.id == (active?.id ?? '')),

                      // Avatar
                      Positioned(
                        left: _avatar.dx * scale,
                        top: _avatar.dy * scale,
                        child: Semantics(
                          label: 'Player avatar',
                          child: Container(
                            width: _avatarSize * scale,
                            height: _avatarSize * scale,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: Colors.amber.shade400,
                              boxShadow: const [BoxShadow(blurRadius: 8, color: Colors.black54)],
                              border: Border.all(color: Colors.black26, width: 1),
                            ),
                            alignment: Alignment.center,
                            child: const Icon(Icons.person, size: 18, color: Colors.black87),
                          ),
                        ),
                      ),

                      // Interact button (only when near current objective)
                      Positioned(
                        right: 12,
                        bottom: 12,
                        child: AnimatedOpacity(
                          opacity: _canInteract ? 1 : 0.0,
                          duration: const Duration(milliseconds: 180),
                          child: FloatingActionButton.extended(
                            heroTag: 'interact',
                            onPressed: _canInteract ? _onInteract : null,
                            icon: const Icon(Icons.touch_app),
                            label: const Text('Interact'),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              // D-pad
              const SizedBox(height: 10),
              _Dpad(
                onTap: _tapStepMove,
                onHoldStart: _startHold,
                onHoldEnd: _stopHold,
              ),
              const SizedBox(height: 10),
            ],
          );
        },
      ),
    );
  }

  Widget _buildHotspot(_Hotspot h, double scale, bool isActive) {
    final pulse = isActive ? _pulse.value : 1.0;
    final iconSize = 28.0 * pulse;
    final color = isActive ? Colors.tealAccent : Colors.white70;

    return Positioned(
      left: (h.pos.dx - 0) * scale - 16,
      top: (h.pos.dy - 0) * scale - 16,
      child: Semantics(
        button: true,
        label: h.label,
        child: Column(
          children: [
            Transform.scale(
              scale: pulse,
              child: Container(
                decoration: BoxDecoration(
                  color: color.withOpacity(0.10),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: color.withOpacity(isActive ? 0.9 : 0.3)),
                ),
                padding: const EdgeInsets.all(6),
                child: Icon(h.icon, size: iconSize, color: color),
              ),
            ),
            const SizedBox(height: 4),
            SizedBox(
              width: 110,
              child: Text(
                h.label,
                textAlign: TextAlign.center,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  color: isActive ? Colors.white : Colors.white70,
                  fontSize: 12,
                  fontWeight: isActive ? FontWeight.w700 : FontWeight.w500,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ---------------------- UI PIECES ----------------------

class _PromptSheet extends StatelessWidget {
  final String title;
  final String prompt;
  final List<_Option> options;
  final bool isTerminal;
  final void Function(_Option) onSelect;
  final VoidCallback onRestart;
  final VoidCallback onClose;
  final bool victory;
  final bool safe;

  const _PromptSheet({
    required this.title,
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

      return Padding(
        padding: const EdgeInsets.only(bottom: 8),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(title,
                style: Theme.of(context)
                    .textTheme
                    .titleMedium
                    ?.copyWith(fontWeight: FontWeight.w700)),
            const SizedBox(height: 10),
            Icon(icon, size: 64, color: color),
            const SizedBox(height: 12),
            Text(
              prompt,
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 16),
            Wrap(
              spacing: 12,
              runSpacing: 8,
              alignment: WrapAlignment.center,
              children: [
                FilledButton(onPressed: onRestart, child: const Text('Play Again')),
                OutlinedButton(onPressed: onClose, child: const Text('Close')),
              ],
            ),
            const SizedBox(height: 12),
          ],
        ),
      );
    }

    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.only(bottom: 16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(title,
                style: Theme.of(context)
                    .textTheme
                    .titleMedium
                    ?.copyWith(fontWeight: FontWeight.w700)),
            const SizedBox(height: 8),
            Text(prompt, textAlign: TextAlign.center),
            const SizedBox(height: 14),
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

// D-pad with tap or hold
class _Dpad extends StatelessWidget {
  final void Function(_Dir dir) onTap;
  final void Function(_Dir dir) onHoldStart;
  final VoidCallback onHoldEnd;

  const _Dpad({
    required this.onTap,
    required this.onHoldStart,
    required this.onHoldEnd,
  });

  @override
  Widget build(BuildContext context) {
    final btn = (IconData icon, _Dir dir) => _HoldButton(
          onTap: () => onTap(dir),
          onHoldStart: () => onHoldStart(dir),
          onHoldEnd: onHoldEnd,
          icon: icon,
        );

    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const SizedBox(width: 12),
        Column(
          children: [
            btn(Icons.keyboard_arrow_up, _Dir.up),
            Row(
              children: [
                btn(Icons.keyboard_arrow_left, _Dir.left),
                const SizedBox(width: 12),
                btn(Icons.keyboard_arrow_right, _Dir.right),
              ],
            ),
            btn(Icons.keyboard_arrow_down, _Dir.down),
          ],
        ),
      ],
    );
  }
}

class _HoldButton extends StatefulWidget {
  final VoidCallback onTap;
  final VoidCallback onHoldStart;
  final VoidCallback onHoldEnd;
  final IconData icon;
  const _HoldButton({
    required this.onTap,
    required this.onHoldStart,
    required this.onHoldEnd,
    required this.icon,
  });

  @override
  State<_HoldButton> createState() => _HoldButtonState();
}

class _HoldButtonState extends State<_HoldButton> {
  bool _holding = false;

  @override
  Widget build(BuildContext context) {
    final bg = _holding ? Colors.white.withOpacity(0.18) : Colors.white.withOpacity(0.10);
    return GestureDetector(
      onTap: () {
        HapticFeedback.selectionClick();
        widget.onTap();
      },
      onLongPressStart: (_) {
        setState(() => _holding = true);
        HapticFeedback.lightImpact();
        widget.onHoldStart();
      },
      onLongPressEnd: (_) {
        setState(() => _holding = false);
        widget.onHoldEnd();
      },
      child: Container(
        margin: const EdgeInsets.all(6),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: bg,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.white24),
        ),
        child: Icon(widget.icon, size: 28),
      ),
    );
  }
}

// Room background painter (subtle grid + “walls”)
class _RoomPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final bg = Paint()..color = Colors.white.withOpacity(0.02);
    final grid = Paint()..color = Colors.white12..strokeWidth = 1;
    final wall = Paint()..color = Colors.white24..strokeWidth = 2;

    // light grid
    for (double x = 0; x < size.width; x += 40) {
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), grid);
    }
    for (double y = 0; y < size.height; y += 40) {
      canvas.drawLine(Offset(0, y), Offset(size.width, y), grid);
    }
    // simple “room zones”
    final rect1 = RRect.fromRectAndRadius(Rect.fromLTWH(40, 40, size.width - 80, 110), const Radius.circular(14));
    final rect2 = RRect.fromRectAndRadius(Rect.fromLTWH(40, 180, size.width - 80, size.height - 220), const Radius.circular(14));
    canvas.drawRRect(rect1, bg);
    canvas.drawRRect(rect2, bg);
    // outline walls
    canvas.drawRRect(rect1, wall);
    canvas.drawRRect(rect2, wall);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

// ---------------------- MODELS ----------------------

enum _NodeType { normal, victory, fail, safe }
enum _Dir { up, down, left, right }

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

class _Hotspot {
  final String id;
  final String label;
  final IconData icon;
  final Offset pos; // room-local center
  const _Hotspot({
    required this.id,
    required this.label,
    required this.icon,
    required this.pos,
  });
}
