import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';

class DuringOutageSortingPage extends StatefulWidget {
  const DuringOutageSortingPage({super.key});

  @override
  State<DuringOutageSortingPage> createState() => _DuringOutageSortingPageState();
}

class _DuringOutageSortingPageState extends State<DuringOutageSortingPage>
    with SingleTickerProviderStateMixin {
  late Ticker _ticker;
  Duration? _prevElapsed; // for delta timing

  final Random _rng = Random();

  final double _spawnEverySec = 1.8; // spawn cadence
  final double _fallSpeed = 140; // logical px/sec
  final int _targetSorted = 15; // win condition
  final int _maxMistakes = 3; // lose condition

  double _timeSinceSpawn = 0;
  int _score = 0;
  int _mistakes = 0;
  int _sorted = 0;

  bool _running = true;

  // Show the “how to play” modal only on first open (not on Restart)
  bool _needsIntro = true;

  // Toggle to hide labels if you want pure icon-only gameplay
  final bool _iconOnly = false;

  // Active falling pieces
  final List<_Faller> _fallers = [];

  late List<_CardData> _deck;

  @override
  void initState() {
    super.initState();
    _deck = _makeDeck();
    _ticker = createTicker(_onTick)..start();

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
    super.dispose();
  }

  // Build the deck from your tips — short labels (<= 4 words) + variants
  List<_CardData> _makeDeck() {
    return [
      // --- Helpful (variants) ---
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

      // --- Not Helpful (variants) ---
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

  // Fixed ticker delta
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

    for (final f in _fallers) {
      f.y += _fallSpeed * dtSec;
    }

    _fallers.removeWhere((f) {
      if (f.y > f.groundY) {
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

  // Show tip + (+100) on correct; tip on incorrect
  void _registerHit(_CardData data, bool droppedToHelpfulBin) {
    final correct = data.helpful == droppedToHelpfulBin;
    if (correct) {
      _score += 100;
      _sorted += 1;
      _showSnack("${data.tip}  (+100)", Colors.green, milliseconds: 2200);
    } else {
      _registerMistake(data.tip);
    }
    _checkEnd();
  }

  // longer duration for readability
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
              Navigator.of(context).pop(); // close results dialog
              _restart();                   // restart stays on game page
            },
            child: const Text("Play again"),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();  // close results dialog
              // leave the game page (return to Power Outage main)
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
      _prevElapsed = null; // reset delta timing
      _running = true;     // Restart should NOT show intro again
      _needsIntro = false;
    });
  }

  // allow custom duration + floating behavior for multi-line tips
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

  // Intro modal shown only once per page load
  void _showIntroModal() {
    showDialog(
      context: context,
      barrierDismissible: false, // tap outside won't dismiss
      builder: (dialogCtx) => WillPopScope(
        // Hardware back should leave the game if intro is up
        onWillPop: () async {
          Navigator.of(dialogCtx).pop();      // close intro
          Navigator.of(context).maybePop();   // go back to main page
          return false;                       // we've handled it
        },
        child: AlertDialog(
          title: const Text("How to play:"),
          content: const Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _RuleRow(text: "Drag falling items into the correct bin"),
              _RuleRow(text: "Helpful vs Not Helpful during an outage"),
              _RuleRow(text: "+100 for correct. 3 mistakes ends the round"),
              _RuleRow(text: "Sort 15 items to win"),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(dialogCtx).pop();    // close intro
                Navigator.of(context).maybePop(); // back to main page
              },
              child: const Text("Back"),
            ),
            FilledButton.icon(
              icon: const Icon(Icons.play_arrow),
              label: const Text("Play now!"),
              onPressed: () {
                Navigator.of(dialogCtx).pop(); // close intro
                setState(() {
                  _running = true;
                  _needsIntro = false;
                  _prevElapsed = null;
                });
              },
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final groundY = size.height - 220; // where bins start
    const itemHeight = 68.0;

    // Update groundY now that we know size
    for (final f in _fallers) {
      f.groundY = groundY;
    }

    return Scaffold(
      appBar: AppBar(title: const Text("During the Storm — Sort Game")),
      body: SafeArea(
        child: Column(
          children: [
            // TOP HUD (Wrap to avoid overflow)
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
                  IconButton(
                    tooltip: _running ? "Pause" : "Resume",
                    onPressed: () {
                      setState(() {
                        _running = !_running;
                        _prevElapsed = null; // avoid big dt on resume
                        _needsIntro = false; // shouldn't show intro later
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
            ),
            const SizedBox(height: 4),

            // Playfield + bins
            Expanded(
              child: LayoutBuilder(
                builder: (context, constraints) {
                  final w = constraints.maxWidth;

                  // fixed card width, clamped to screen so it won't overflow
                  final cardWidth = min(w * 0.75, 260.0);
                  const cardHeight = itemHeight;

                  return Stack(
                    children: [
                      for (final f in _fallers)
                        Positioned(
                          left: (f.fracX * w - cardWidth / 2).clamp(0.0, w - cardWidth),
                          top: f.y.clamp(0, groundY - cardHeight),
                          child: _DraggableCard(
                            data: f.data,
                            width: cardWidth,
                            height: cardHeight,
                            iconOnly: _iconOnly,
                            onDragStarted: () => setState(() {}),
                            onDragEnd: (_) => setState(() {}),
                          ),
                        ),

                      // Bins row
                      Align(
                        alignment: Alignment.bottomCenter,
                        child: Padding(
                          padding: const EdgeInsets.fromLTRB(12, 0, 12, 12),
                          child: Row(
                            children: [
                              Expanded(
                                child: _SortBin(
                                  label: "Helpful",
                                  color: Colors.green,
                                  icon: Icons.thumb_up_alt,
                                  onAccept: (data) {
                                    _registerHit(data, true);
                                    _removeOne(data);
                                  },
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: _SortBin(
                                  label: "Not Helpful",
                                  color: Colors.red,
                                  icon: Icons.thumb_down_alt,
                                  onAccept: (data) {
                                    _registerHit(data, false);
                                    _removeOne(data);
                                  },
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  );
                },
              ),
            ),

            // Quick legend tip
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
              child: Text(
                "Drag falling items into the correct bin. Items align with official safety guidance.",
                style: Theme.of(context).textTheme.labelMedium,
              ),
            ),
          ],
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

// ===== Models / Widgets =====

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
  double y = -80; // starts above screen
  double groundY = 600; // set from layout
  _Faller({required this.data, required this.fracX});
}

class _DraggableCard extends StatelessWidget {
  final _CardData data;
  final double width;
  final double height;
  final bool iconOnly;
  final VoidCallback? onDragStarted;
  final void Function(DraggableDetails)? onDragEnd;

  const _DraggableCard({
    required this.data,
    required this.width,
    required this.height,
    required this.iconOnly,
    this.onDragStarted,
    this.onDragEnd,
  });

  @override
  Widget build(BuildContext context) {
    final child = _ItemChip(
      data: data,
      width: width,
      height: height,
      iconOnly: iconOnly,
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
            BoxShadow(blurRadius: 6, offset: Offset(0, 3), color: Colors.black12),
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

  const _SortBin({
    required this.label,
    required this.color,
    required this.icon,
    required this.onAccept,
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
          padding: const EdgeInsets.all(12),
          height: 160,
          decoration: BoxDecoration(
            color: _hovered ? widget.color.withOpacity(0.1) : Colors.grey.shade50,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: _hovered ? widget.color : Colors.black12,
              width: 2,
            ),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(widget.icon, color: widget.color, size: 28),
              const SizedBox(height: 8),
              Text(
                widget.label,
                style: Theme.of(context)
                    .textTheme
                    .titleMedium
                    ?.copyWith(color: widget.color, fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 6),
              Text("Drop here", style: Theme.of(context).textTheme.labelSmall),
            ],
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
    return Chip(
      avatar: Icon(icon, size: 18),
      label: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text("$label: ", style: Theme.of(context).textTheme.labelMedium),
          Text(
            value,
            style: Theme.of(context).textTheme.labelMedium?.copyWith(fontWeight: FontWeight.w700),
          ),
        ],
      ),
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 0),
    );
  }
}

/// Small rule row for the intro dialog
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
