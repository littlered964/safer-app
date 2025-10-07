import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter/services.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:confetti/confetti.dart';

class DuringOutageSortingPage extends StatefulWidget {
  const DuringOutageSortingPage({super.key});

  @override
  State<DuringOutageSortingPage> createState() => _DuringOutageSortingPageState();
}

// 4 speed tiers
enum _Difficulty { slowest, slow, fast, fastest }

class _DuringOutageSortingPageState extends State<DuringOutageSortingPage>
    with TickerProviderStateMixin {
  late Ticker _ticker;
  Duration? _prevElapsed;

  final Random _rng = Random();

  final double _spawnEverySec = 1.8;
  double _fallSpeed = 140; // now used as "rise" speed after inversion
  final int _targetSorted = 15;
  final int _maxMistakes = 3;

  // default tier ~"fast" comparable to prior medium
  _Difficulty _difficulty = _Difficulty.fast;

  // tuned speeds (px/s). "slowest" is very gentle.
  double _speedFor(_Difficulty d) {
    switch (d) {
      case _Difficulty.slowest:
        return 55;   // very easy (elder-friendly)
      case _Difficulty.slow:
        return 95;   // easy
      case _Difficulty.fast:
        return 140;  // medium-ish
      case _Difficulty.fastest:
        return 220;  // hard
    }
  }

  double _timeSinceSpawn = 0;
  int _score = 0;
  int _mistakes = 0;
  int _sorted = 0;

  bool _running = true;
  bool _needsIntro = true;
  final bool _iconOnly = false;

  final List<_Faller> _fallers = [];
  late List<_CardData> _deck;

  // Audio + Haptics
  late final AudioPlayer _sfxPlayer;
  bool _muted = false;

  Future<void> _playSfx(String filename, {double volume = 0.9}) async {
    if (_muted) return;
    try {
      await _sfxPlayer.stop();
      await _sfxPlayer.play(AssetSource('audio/$filename'), volume: volume);
    } catch (_) {}
  }

  void _hapticGood() => HapticFeedback.lightImpact();
  void _hapticBad() => HapticFeedback.mediumImpact();
  void _hapticWin() => HapticFeedback.heavyImpact();

  // Shake animation (wrong items)
  late final AnimationController _shakeCtl;
  late final Animation<double> _shake;
  final Set<_CardData> _shaking = {}; // which items are currently shaking

  // Confetti (on win)
  late final ConfettiController _confettiCtl;

  // Bins at TOP (inverted)
  static const double _binAreaHeight = 120;

  @override
  void initState() {
    super.initState();
    _deck = _makeDeck();
    _ticker = createTicker(_onTick)..start();

    _sfxPlayer = AudioPlayer(playerId: 'sfx')..setReleaseMode(ReleaseMode.stop);

    _shakeCtl = AnimationController(vsync: this, duration: const Duration(milliseconds: 350));
    _shake = TweenSequence<double>([
      TweenSequenceItem(tween: Tween(begin: 0, end: -10), weight: 1),
      TweenSequenceItem(tween: Tween(begin: -10, end: 10), weight: 2),
      TweenSequenceItem(tween: Tween(begin: 10, end: -8), weight: 1),
      TweenSequenceItem(tween: Tween(begin: -8, end: 6), weight: 1),
      TweenSequenceItem(tween: Tween(begin: 6, end: 0), weight: 1),
    ]).animate(CurvedAnimation(parent: _shakeCtl, curve: Curves.easeOut));

    _confettiCtl = ConfettiController(duration: const Duration(seconds: 2));

    // Show the intro on first open only.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      if (_needsIntro) {
        setState(() {
          _running = false;      // pause game until user taps Play now!
          _prevElapsed = null;   // clean delta when starting
        });
        _showIntroModal();
      }
    });
  }

  @override
  void dispose() {
    _ticker.dispose();
    _sfxPlayer.dispose();
    _shakeCtl.dispose();
    _confettiCtl.dispose();
    super.dispose();
  }

  List<_CardData> _makeDeck() {
    return [
      // Helpful
      _CardData(icon: Icons.report, label: "Report outage once", helpful: true, tip: "Report the outage once via your utility app/site or phone."),
      _CardData(icon: Icons.phone_iphone, label: "Use utility app", helpful: true, tip: "Use the official utility app/site to report."),
      _CardData(icon: Icons.flashlight_on, label: "Use flashlights", helpful: true, tip: "Use flashlights or battery lanterns; avoid candles."),
      _CardData(icon: Icons.light_mode, label: "Battery lanterns", helpful: true, tip: "Battery lights cut fire risk."),
      _CardData(icon: Icons.propane_tank, label: "Keep generator outside", helpful: true, tip: "Run outside, 20+ ft from openings; exhaust away."),
      _CardData(icon: Icons.safety_check, label: "Use transfer switch", helpful: true, tip: "Power the home safely via a transfer switch."),
      _CardData(icon: Icons.battery_saver, label: "Conserve battery", helpful: true, tip: "Low-power mode, limit streaming, batch check-ins."),
      _CardData(icon: Icons.power_settings_new, label: "Keep one phone off", helpful: true, tip: "Keep a device off as backup."),
      _CardData(icon: Icons.kitchen, label: "Keep fridge shut", helpful: true, tip: "Fridge ~4h; full freezer ~48h if unopened."),
      _CardData(icon: Icons.ac_unit, label: "Freezer stays cold", helpful: true, tip: "A full freezer can hold temp for ~48h."),
      _CardData(icon: Icons.warning_amber, label: "Avoid downed lines", helpful: true, tip: "Treat all downed lines as energized; stay far away."),
      _CardData(icon: Icons.phone_in_talk, label: "Call 9-1-1", helpful: true, tip: "Report sparking/downed lines to 9-1-1/utility."),

      // Not Helpful (variants)
      _CardData(icon: Icons.report_gmailerrorred, label: "Spam reports", helpful: false, tip: "Report once—multiple reports don’t speed repairs."),
      _CardData(icon: Icons.candlestick_chart, label: "Use candles", helpful: false, tip: "Candles raise fire risk—use battery lights."),
      _CardData(icon: Icons.local_fire_department, label: "Many candles", helpful: false, tip: "Open flames are hazardous in outages."),
      _CardData(icon: Icons.power, label: "Backfeed outlet", helpful: false, tip: "Never back-feed a home via an outlet."),
      _CardData(icon: Icons.garage, label: "Run in garage", helpful: false, tip: "CO kills—operate generators outdoors only."),
      _CardData(icon: Icons.window, label: "Near window", helpful: false, tip: "Keep generators 20+ ft from doors/windows."),
      _CardData(icon: Icons.play_circle_fill, label: "Stream nonstop", helpful: false, tip: "Streaming drains battery—save power."),
      _CardData(icon: Icons.update, label: "Auto updates on", helpful: false, tip: "Limit background activity to save battery."),
      _CardData(icon: Icons.door_back_door, label: "Open fridge", helpful: false, tip: "Opening warms food—keep doors closed."),
      _CardData(icon: Icons.fastfood, label: "Fridge taste test", helpful: false, tip: "Don’t taste to test—when in doubt, toss."),
      _CardData(icon: Icons.brush, label: "Move live wires", helpful: false, tip: "Never touch downed lines; stay back and call."),
      _CardData(icon: Icons.near_me, label: "Stand near sparks", helpful: false, tip: "Stay far away from sparking equipment."),
    ];
  }

  void _onTick(Duration elapsed) {
    if (!_running) return;

    double dtSec;
    if (_prevElapsed == null) {
      dtSec = 0;
    } else {
      dtSec = (elapsed - _prevElapsed!).inMilliseconds / 1000.0;
      dtSec = dtSec.clamp(0.0, 0.050); // cap at ~50ms/tick
    }
    _prevElapsed = elapsed;

    // rise upward (y decreases in playfield-local coordinates)
    for (final f in _fallers) {
      f.y -= _fallSpeed * dtSec;
    }

    // missed only when TOP hits the finish boundary (instant remove)
    _fallers.removeWhere((f) {
      if (f.y <= f.groundY) { // groundY == 0 (top edge of playfield)
        _playSfx('incorrect.aiff');
        _hapticBad();
        _registerMistake("Missed: ${f.data.label}\n${f.data.tip}");
        return true;
      }
      return false;
    });

    _timeSinceSpawn += dtSec;
    if (_timeSinceSpawn >= _spawnEverySec) {
      _timeSinceSpawn = 0;
      _spawnOne();
    }

    setState(() {});
  }

  void _spawnOne() {
    final data = _deck[_rng.nextInt(_deck.length)];
    final lane = _rng.nextInt(3);
    final x = 0.15 + lane * 0.35; // 15%, 50%, 85%
    _fallers.add(_Faller(data: data, fracX: x));
  }

  // Show tip + (+100) on correct; tip on incorrect (with shake)
  void _registerHit(_CardData data, bool droppedToHelpfulBin) async {
    final correct = data.helpful == droppedToHelpfulBin;
    if (correct) {
      _score += 100;
      _sorted += 1;
      _playSfx('correct.mp3');
      _hapticGood();
      _showSnack("${data.tip}  (+100)", Colors.green, milliseconds: 2200);
      _removeOne(data);
    } else {
      _playSfx('incorrect.aiff');
      _hapticBad();
      setState(() => _shaking.add(data));
      _shakeCtl.forward(from: 0);
      await Future.delayed(_shakeCtl.duration ?? const Duration(milliseconds: 350));
      setState(() => _shaking.remove(data));
      _registerMistake(data.tip);
      _removeOne(data);
    }
    _checkEnd();
  }

  void _registerMistake(String msg) {
    _mistakes += 1;
    _showSnack(msg, Colors.orange, milliseconds: 2200);
    _checkEnd();
  }

  void _checkEnd() {
    if (_mistakes >= _maxMistakes) {
      _running = false;
      _endDialog(
        title: "Storm got rough!",
        body: "You made $_mistakes mistakes. Score: $_score\n\nWant to try again and keep those safety instincts sharp?",
      );
    } else if (_sorted >= _targetSorted) {
      _running = false;
      _playSfx('win.wav');
      _hapticWin();
      _confettiCtl.play();
      _endDialog(
        title: "Great job!",
        body: "You sorted $_sorted items.\nScore: $_score\n\nYou kept it safe during the storm!",
      );
    }
  }

  void _endDialog({required String title, required String body}) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => AlertDialog(
        title: Text(title),
        content: Text(body),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              _restart();
            },
            child: const Text("Play again"),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              Navigator.of(context).maybePop();
            },
            child: const Text("Close"),
          ),
        ],
      ),
    );
  }

  void _restart() {
    setState(() {
      _fallers.clear();
      _score = 0;
      _mistakes = 0;
      _sorted = 0;
      _timeSinceSpawn = 0;
      _prevElapsed = null;
      _running = true;
      _needsIntro = false;
      _shaking.clear();
      _fallSpeed = _speedFor(_difficulty);
    });
  }

  void _showSnack(String msg, Color color, {int milliseconds = 1200}) {
    final messenger = ScaffoldMessenger.of(context);
    messenger.hideCurrentSnackBar();
    messenger.showSnackBar(
      SnackBar(
        content: Text(msg),
        backgroundColor: color,
        duration: Duration(milliseconds: milliseconds),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  // intro chips reflect new 4-tier speeds
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
        child: StatefulBuilder(
          builder: (ctx, setLocal) {
            return AlertDialog(
              title: const Text("How to play:"),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const _RuleRow(text: "Drag falling items into the correct bin"),
                  const _RuleRow(text: "Helpful vs Not Helpful during an outage"),
                  const _RuleRow(text: "+100 for correct. 3 mistakes ends the round"),
                  const _RuleRow(text: "Sort 15 items to win"),
                  const SizedBox(height: 12),
                  Text("Difficulty", style: Theme.of(context).textTheme.titleSmall),
                  const SizedBox(height: 6),
                  Wrap(
                    spacing: 8,
                    children: [
                      ChoiceChip(
                        label: const Text("Slowest"),
                        selected: _difficulty == _Difficulty.slowest,
                        onSelected: (v) {
                          if (!v) return;
                          setLocal(() => _difficulty = _Difficulty.slowest);
                        },
                      ),
                      ChoiceChip(
                        label: const Text("Slow"),
                        selected: _difficulty == _Difficulty.slow,
                        onSelected: (v) {
                          if (!v) return;
                          setLocal(() => _difficulty = _Difficulty.slow);
                        },
                      ),
                      ChoiceChip(
                        label: const Text("Fast"),
                        selected: _difficulty == _Difficulty.fast,
                        onSelected: (v) {
                          if (!v) return;
                          setLocal(() => _difficulty = _Difficulty.fast);
                        },
                      ),
                      ChoiceChip(
                        label: const Text("Fastest"),
                        selected: _difficulty == _Difficulty.fastest,
                        onSelected: (v) {
                          if (!v) return;
                          setLocal(() => _difficulty = _Difficulty.fastest);
                        },
                      ),
                    ],
                  ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.of(dialogCtx).pop();
                    Navigator.of(context).maybePop();
                  },
                  child: const Text("Back"),
                ),
                FilledButton.icon(
                  icon: const Icon(Icons.play_arrow),
                  label: const Text("Play now!"),
                  onPressed: () {
                    setState(() {
                      _fallSpeed = _speedFor(_difficulty);
                    });
                    Navigator.of(dialogCtx).pop();
                    setState(() {
                      _running = true;
                      _needsIntro = false;
                      _prevElapsed = null;
                    });
                  },
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    const itemHeight = 68.0;

    return Scaffold(
      appBar: AppBar(
        title: const Text("During the Storm — Sort Game"),
        actions: [
          IconButton(
            tooltip: _muted ? "Unmute sounds" : "Mute sounds",
            icon: Icon(_muted ? Icons.volume_off : Icons.volume_up),
            onPressed: () => setState(() => _muted = !_muted),
          ),
          IconButton(
            tooltip: _running ? "Pause" : "Resume",
            onPressed: () {
              setState(() {
                _running = !_running;
                _prevElapsed = null;
                _needsIntro = false;
              });
            },
            icon: Icon(_running ? Icons.pause_circle_filled : Icons.play_circle_fill),
          ),
          IconButton(
            tooltip: "Restart",
            onPressed: _restart,
            icon: const Icon(Icons.refresh),
          ),
        ],
      ),
      body: Container(
        // Subtle gradient background
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Color(0xFF0F172A),
              Color(0xFF1E293B),
            ],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              // Playfield first, HUD at bottom
              Expanded(
                child: LayoutBuilder(
                  builder: (context, constraints) {
                    final w = constraints.maxWidth;

                    // card size
                    final cardWidth = min(w * 0.75, 260.0);
                    const cardHeight = itemHeight;

                    // Visual finish line just under bins (outer coords)
                    final finishLineY = _binAreaHeight;

                    // ----- PLAYFIELD (inner stack) -----
                    final innerHeight = constraints.maxHeight - _binAreaHeight;
                    // In playfield-local coords: top edge (finish boundary) is y=0.
                    // Items should be visible until top hits 0, then removed instantly.

                    // Prepare per-item thresholds in PLAYFIELD coordinates
                    for (final f in _fallers) {
                      f.groundY = 0; // top edge of playfield
                      // lazy init start position at bottom of playfield
                      if (f.y < 0) {
                        f.y = innerHeight - cardHeight;
                      }
                    }

                    return Stack(
                      clipBehavior: Clip.hardEdge,
                      children: [
                        // Confetti overlay (top)
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

                        // RISING items limited to area BELOW bins
                        Positioned.fill(
                          top: _binAreaHeight,
                          bottom: 0,
                          child: Stack(
                            children: [
                              for (final f in _fallers)
                                Positioned(
                                  left: (f.fracX * w - cardWidth / 2).clamp(0.0, w - cardWidth),
                                  // clamp top between 0 (finish boundary) and bottom of playfield
                                  top: f.y.clamp(
                                    0.0,
                                    innerHeight - cardHeight,
                                  ),
                                  child: _DraggableCard(
                                    data: f.data,
                                    width: cardWidth,
                                    height: cardHeight,
                                    iconOnly: _iconOnly,
                                    // apply shake offset only to flagged item(s)
                                    shakeOffset: _shaking.contains(f.data) ? _shake.value : 0,
                                    onDragStarted: () => setState(() {}),
                                    onDragEnd: (_) => setState(() {}),
                                  ),
                                ),
                            ],
                          ),
                        ),

                        // FINISH LINE just under bins (outer coords)
                        Positioned(
                          left: 0,
                          right: 0,
                          top: finishLineY - 1,
                          child: IgnorePointer(
                            child: Container(
                              height: 2,
                              color: Colors.white24,
                            ),
                          ),
                        ),

                        // Bins row TOP-anchored
                        Align(
                          alignment: Alignment.topCenter,
                          child: Padding(
                            padding: const EdgeInsets.fromLTRB(12, 12, 12, 0),
                            child: SizedBox(
                              height: _binAreaHeight - 24,
                              child: Row(
                                children: [
                                  Expanded(
                                    child: _SortBin(
                                      label: "Helpful",
                                      color: Colors.greenAccent.shade400,
                                      icon: Icons.thumb_up_alt,
                                      onAccept: (data) {
                                        _registerHit(data, true);
                                      },
                                      binHeight: 80,
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: _SortBin(
                                      label: "Not Helpful",
                                      color: Colors.redAccent.shade200,
                                      icon: Icons.thumb_down_alt,
                                      onAccept: (data) {
                                        _registerHit(data, false);
                                      },
                                      binHeight: 80,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ],
                    );
                  },
                ),
              ),

              // HUD at bottom
              const SizedBox(height: 4),
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
                child: Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  crossAxisAlignment: WrapCrossAlignment.center,
                  children: [
                    _StatChip(icon: Icons.star, label: "Score", value: "$_score"),
                    _StatChip(icon: Icons.done_all, label: "Sorted", value: "$_sorted/$_targetSorted"),
                    _StatChip(icon: Icons.warning, label: "Mistakes", value: "$_mistakes/$_maxMistakes"),
                  ],
                ),
              ),

              // Quick legend tip
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
                child: Text(
                  "Drag falling items into the correct bin. Items align with official safety guidance.",
                  style: Theme.of(context).textTheme.labelMedium?.copyWith(color: Colors.white70),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _removeOne(_CardData data) {
    final idx = _fallers.indexWhere((e) => e.data == data);
    if (idx != -1) {
      _fallers.removeAt(idx);
    }
  }
}

// Models / Widgets

class _CardData {
  final IconData icon;
  final String label;
  final bool helpful;
  final String tip; // reserved for future on-hover/help text
  const _CardData({
    required this.icon,
    required this.label,
    required this.helpful,
    required this.tip,
  });
}

class _Faller {
  final _CardData data;
  final double fracX; // 0..1 of width
  double y = -80; // lazy-initialized to playfield bottom in build()
  double groundY = 0; // threshold in PLAYFIELD coords (top edge)
  _Faller({required this.data, required this.fracX});
}

class _DraggableCard extends StatelessWidget {
  final _CardData data;
  final double width;
  final double height;
  final bool iconOnly;
  final double shakeOffset;
  final VoidCallback? onDragStarted;
  final void Function(DraggableDetails)? onDragEnd;

  const _DraggableCard({
    required this.data,
    required this.width,
    required this.height,
    required this.iconOnly,
    required this.shakeOffset,
    this.onDragStarted,
    this.onDragEnd,
  });

  @override
  Widget build(BuildContext context) {
    final child = Transform.translate(
      offset: Offset(shakeOffset, 0),
      child: _ItemChip(
        data: data,
        width: width,
        height: height,
        iconOnly: iconOnly,
      ),
    );
    return Draggable<_CardData>(
      data: data,
      feedback: Material(
        color: Colors.transparent,
        child: Opacity(opacity: 0.9, child: child),
      ),
      childWhenDragging: Opacity(opacity: 0.25, child: child),
      onDragStarted: onDragStarted,
      onDragEnd: onDragEnd,
      child: child,
    );
  }
}

class _ItemChip extends StatelessWidget {
  final _CardData data;
  final double width;
  final double height;
  final bool iconOnly;

  const _ItemChip({
    required this.data,
    required this.width,
    required this.height,
    required this.iconOnly,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: width,
      height: height,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: Colors.black12, width: 1.2),
          boxShadow: const [
            BoxShadow(blurRadius: 6, offset: Offset(0, 3), color: Colors.black26),
          ],
        ),
        child: Row(
          children: [
            Icon(data.icon, size: 26),
            if (!iconOnly) ...[
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  data.label,
                  style: Theme.of(context).textTheme.labelLarge,
                  overflow: TextOverflow.ellipsis,
                  maxLines: 1,
                  softWrap: false,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _SortBin extends StatefulWidget {
  final String label;
  final Color color;
  final IconData icon;
  final void Function(_CardData data) onAccept;
  final double binHeight; // control bin visual height

  const _SortBin({
    required this.label,
    required this.color,
    required this.icon,
    required this.onAccept,
    required this.binHeight,
  });

  @override
  State<_SortBin> createState() => _SortBinState();
}

class _SortBinState extends State<_SortBin> {
  bool _hovered = false;

  @override
  Widget build(BuildContext context) {
    return DragTarget<_CardData>(
      onWillAccept: (data) {
        setState(() => _hovered = true);
        return true;
      },
      onLeave: (_) => setState(() => _hovered = false),
      onAccept: (data) {
        setState(() => _hovered = false);
        widget.onAccept(data);
      },
      builder: (context, candidates, rejects) {
        return AnimatedContainer(
          duration: const Duration(milliseconds: 120),
          padding: const EdgeInsets.all(8),
          height: widget.binHeight,
          decoration: BoxDecoration(
            color: _hovered ? widget.color.withOpacity(0.12) : Colors.white.withOpacity(0.06),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: _hovered ? widget.color : Colors.white24,
              width: 2,
            ),
          ),
          child: LayoutBuilder(
            builder: (ctx, c) {
              return FittedBox(
                fit: BoxFit.scaleDown,
                alignment: Alignment.center,
                child: ConstrainedBox(
                  constraints: BoxConstraints(
                    maxWidth: c.maxWidth,
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(widget.icon, color: widget.color, size: 22),
                      const SizedBox(height: 4),
                      Text(
                        widget.label,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        textAlign: TextAlign.center,
                        style: Theme.of(context)
                            .textTheme
                            .labelLarge
                            ?.copyWith(color: widget.color, fontWeight: FontWeight.w600),
                      ),
                      const SizedBox(height: 3),
                      Text(
                        "Drop here",
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: Theme.of(context).textTheme.labelSmall?.copyWith(color: Colors.white70),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        );
      },
    );
  }
}

class _StatChip extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  const _StatChip({
    required this.icon,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.12),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: Colors.white24, width: 1),
        boxShadow: const [
          BoxShadow(blurRadius: 6, offset: Offset(0, 3), color: Colors.black26),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 18, color: Colors.white),
          const SizedBox(width: 6),
          Text(
            '$label: ',
            style: Theme.of(context)
                .textTheme
                .labelMedium
                ?.copyWith(color: Colors.white70),
          ),
          Text(
            value,
            style: Theme.of(context).textTheme.labelMedium?.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.w700,
                ),
          ),
        ],
      ),
    );
  }
}

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
          Expanded(child: Text(text)),
        ],
      ),
    );
  }
}
