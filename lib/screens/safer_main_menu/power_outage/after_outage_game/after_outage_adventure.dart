import 'dart:async';
import 'dart:convert' as convert;
import 'dart:math' as math;
import 'dart:ui' as ui;
import 'package:flame/components.dart';
import 'package:flame/game.dart';
import 'package:flame/sprite.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flame/input.dart';
import 'package:flame/events.dart';
import 'package:audioplayers/audioplayers.dart';
import 'fridge_mini_game.dart';


enum Room { living, basement, frontLawn, sidewalk, neighbor, kitchen }

class ChecklistModel {
  bool powerRestored = false;
  bool basementResolved = false;
  bool fridgeChecked = false;
  bool frontYardVideo = false;
  bool sidewalkResolved = false;
  bool neighborChecked = false;
  bool livingGlassCleared = false;
  bool leakyHydrantReported = false;

  bool get isComplete =>
      powerRestored &&
      basementResolved &&
      fridgeChecked &&
      frontYardVideo &&
      sidewalkResolved &&
      neighborChecked &&
      livingGlassCleared &&
      leakyHydrantReported;

  List<MapEntry<String, bool>> get items => [
        MapEntry('Power restored', powerRestored),
        MapEntry('Broken glass swept', livingGlassCleared),
        MapEntry('Basement flooding', basementResolved),
        MapEntry('Checked fridge', fridgeChecked),
        MapEntry('Video of front yard taken', frontYardVideo),
        MapEntry('Downed line handled', sidewalkResolved),
        MapEntry('Leaky hydrant reported', leakyHydrantReported),
        MapEntry('Checked on neighbor', neighborChecked),
      ];
}

class ChecklistOverlay extends PositionComponent
    with HasGameRef<SaferAdventureGame> {
  bool open = false;

  ChecklistOverlay() {
    priority = 2500;
  }

  @override
  void render(Canvas canvas) {
    if (!open) return;
    final s = gameRef.size;
    final w = (s.x * 0.54).clamp(260, 420).toDouble();
    final h = (s.y * 0.60).clamp(240, 420).toDouble();
    final r = RRect.fromRectAndRadius(
      Rect.fromLTWH(s.x - w - 16, s.y - h - 16, w, h),
      const Radius.circular(16),
    );
    canvas.drawRRect(r, Paint()..color = Colors.black.withOpacity(0.85));

    final title = TextPainter(
      text: const TextSpan(
        text: 'Storm Recovery Checklist',
        style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w700),
      ),
      textDirection: TextDirection.ltr,
    )..layout(maxWidth: w - 24);
    title.paint(canvas, Offset(s.x - w - 16 + 12, s.y - h - 16 + 12));

    final model = gameRef.checklist;
    double y = s.y - h - 16 + 44;
    for (final item in model.items) {
      final checked = item.value;

      final box = RRect.fromRectAndRadius(
        Rect.fromLTWH(s.x - w - 16 + 12, y, 18, 18),
        const Radius.circular(4),
      );
      canvas.drawRRect(
        box,
        Paint()..color = checked ? const Color(0xFF2E7D32) : Colors.white12,
      );
      if (checked) {
        final checkTP = TextPainter(
          text: const TextSpan(
              text: '✓',
              style: TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.bold)),
          textDirection: TextDirection.ltr,
        )..layout();
        checkTP.paint(
          canvas,
          Offset(box.outerRect.center.dx - checkTP.width / 2,
                box.outerRect.center.dy - checkTP.height / 2),
        );
      }

      final labelTP = TextPainter(
        text: TextSpan(
          text: item.key,
          style: TextStyle(color: checked ? Colors.white70 : Colors.white, fontSize: 14),
        ),
        textDirection: TextDirection.ltr,
      )..layout(maxWidth: w - 52);
      labelTP.paint(canvas, Offset(s.x - w - 16 + 12 + 26, y - 1));

      y += 28;
    }

    if (model.isComplete) {
      final win = TextPainter(
        text: const TextSpan(
          text: 'All tasks complete — You win!',
          style: TextStyle(color: Color(0xFF80E27E), fontSize: 15, fontWeight: FontWeight.w800),
        ),
        textDirection: TextDirection.ltr,
      )..layout(maxWidth: w - 24);
      win.paint(canvas, Offset(s.x - w - 16 + 12, s.y - 16 - win.height - 12));
    }
  }
}

/// Intro overlay shown at the start with instructions and Start/Exit buttons
class HowToPlayOverlay extends PositionComponent
    with HasGameRef<SaferAdventureGame>, TapCallbacks {
  HowToPlayOverlay() {
    priority = 3000; // above HUD and world
  }

  @override
  Future<void> onLoad() async {
    anchor = Anchor.topLeft;
    position = Vector2.zero();
    size = gameRef.size;
  }

  @override
  void onGameResize(Vector2 canvasSize) {
    super.onGameResize(canvasSize);
    size = canvasSize;
    position = Vector2.zero();
  }

  @override
  void render(Canvas canvas) {
    final s = gameRef.size;
    final w = (s.x * 0.88).clamp(300, 560).toDouble();
    final h = (s.y * 0.60).clamp(260, 420).toDouble();

    // Global dim so it’s obvious the game is paused & to catch taps visually
    canvas.drawRect(
      Rect.fromLTWH(0, 0, s.x, s.y),
      Paint()..color = Colors.black.withOpacity(0.65),
    );

    final panel = RRect.fromRectAndRadius(
      Rect.fromLTWH((s.x - w) / 2, (s.y - h) / 2, w, h),
      const Radius.circular(16),
    );
    canvas.drawRRect(panel, Paint()..color = Colors.black.withOpacity(0.85));

    const instructions = '''
Welcome to the After Outage Adventure!

• Move with the joystick
• Tap doors to change rooms
• Step into hotspots to complete tasks
• Complete all tasks to win
• Open checklist to see tasks

Good luck — stay safe!
''';

    final tp = TextPainter(
      text: const TextSpan(
        text: instructions,
        style: TextStyle(color: Colors.white, fontSize: 15, height: 1.35),
      ),
      textDirection: TextDirection.ltr,
      textAlign: TextAlign.left,
    )..layout(maxWidth: w - 28);
    tp.paint(canvas, Offset((s.x - w) / 2 + 14, (s.y - h) / 2 + 18));

    // Buttons
    const btnW = 120.0, btnH = 44.0, gap = 12.0;
    final buttonsTop = (s.y + h) / 2 - 56;
    final startRect = Rect.fromLTWH((s.x / 2) - btnW - gap, buttonsTop, btnW, btnH);
    final exitRect  = Rect.fromLTWH((s.x / 2) + gap,         buttonsTop, btnW, btnH);

    // Start
    canvas.drawRRect(
      RRect.fromRectAndRadius(startRect, const Radius.circular(8)),
      Paint()..color = const Color(0xFF2E7D32),
    );
    final startTP = TextPainter(
      text: const TextSpan(
        text: 'Start',
        style: TextStyle(color: Colors.white, fontSize: 15, fontWeight: FontWeight.bold),
      ),
      textDirection: TextDirection.ltr,
    )..layout();
    startTP.paint(
      canvas,
      Offset(startRect.center.dx - startTP.width / 2, startRect.center.dy - startTP.height / 2),
    );

    // Exit
    canvas.drawRRect(
      RRect.fromRectAndRadius(exitRect, const Radius.circular(8)),
      Paint()..color = const Color(0xFFC62828),
    );
    final exitTP = TextPainter(
      text: const TextSpan(
        text: 'Exit',
        style: TextStyle(color: Colors.white, fontSize: 15, fontWeight: FontWeight.bold),
      ),
      textDirection: TextDirection.ltr,
    )..layout();
    exitTP.paint(
      canvas,
      Offset(exitRect.center.dx - exitTP.width / 2, exitRect.center.dy - exitTP.height / 2),
    );
  }

  // Swallow all taps so nothing underneath receives them.
  @override
  void onTapDown(TapDownEvent event) { event.handled = true; }
  @override
  void onTapCancel(TapCancelEvent event) { event.handled = true; }

  @override
  void onTapUp(TapUpEvent event) {
    event.handled = true;

    final p = event.localPosition;
    final s = gameRef.size;
    final w = (s.x * 0.88).clamp(300, 560).toDouble();
    final h = (s.y * 0.60).clamp(260, 420).toDouble();

    const btnW = 120.0, btnH = 44.0, gap = 12.0;
    final buttonsTop = (s.y + h) / 2 - 56;
    final startRect = Rect.fromLTWH((s.x / 2) - btnW - gap, buttonsTop, btnW, btnH);
    final exitRect  = Rect.fromLTWH((s.x / 2) + gap,         buttonsTop, btnW, btnH);

    final pos = Offset(p.x, p.y);

    if (startRect.contains(pos)) {
      (gameRef).lockInput(false);        // unlock controls
      (gameRef).showCharacterSelectDialog();
      removeFromParent();                // close how-to overlay
      return;
    }
    if (exitRect.contains(pos)) {
      (gameRef).onExitToMenu?.call();
      return;
    }
  }
}


class SaferAdventureGame extends FlameGame {
  final VoidCallback? onExitToMenu;
  late BuildContext context;
  SaferAdventureGame({this.onExitToMenu});

  // Checklist notification
  final ValueNotifier<int> checklistBadgeCount = ValueNotifier<int>(0);

  // audio
  late final AudioPlayer _sfxPlayer;
  bool _muted = false;

  // game-over flags
  bool _gameOver = false;
  bool _winDialogShown = false;


  late final Player _player;
  late final HudToast _hud;
  late final FadeCurtain _fade;
  final ValueNotifier<String> roomLabel = ValueNotifier<String>('Living Room');

  // Shows the last solid object you walked into
  final ValueNotifier<String> bumpLabel = ValueNotifier<String>('');
  double _bumpTimer = 0.0;
  static const double _bumpHoldSeconds = 0.8; // how long the label lingers
  String? _lastBumpName;


  // Named zones
  List<({Rect rect, String name})> _namedSolids = [];
  List<({Rect rect, String name})> _namedKills  = [];

  // Setters used by RoomBox each frame
  void setNamedSolids(List<({Rect rect, String name})> items) {
    _namedSolids = items;
    // keep raw rects for legacy collision
    setSolids(items.map((e) => e.rect).toList());
  }
  void setNamedKills(List<({Rect rect, String name})> items) {
    _namedKills = items;
    // keep raw rects for legacy kill logic
    setKillZones(items.map((e) => e.rect).toList());
  }

  // Called by Player when bumping into a solid
  void _notifyBump(String? name) {
    final trimmed = (name ?? '').trim();

    // If we’re not currently bumping anything, just let the timer wind down
    if (trimmed.isEmpty) {
      return;
    }

    // If it’s the same object, just refresh the timer
    if (_lastBumpName == trimmed && _bumpTimer > 0) {
      _bumpTimer = _bumpHoldSeconds;
      return;
    }

    // update label + reset timer
    _lastBumpName = trimmed;
    bumpLabel.value = trimmed;
    _bumpTimer = _bumpHoldSeconds;
  }

  // Which avatar the player picked in the character-select dialog
  String selectedAvatar = 'Bradley';
  
  // Living room broken glass state & guard 
  bool _livingGlassPresent = true;   // start broken by default
  bool _livingGlassIgnored = false;  // player said "No" to sweeping

  RoomBox? _roomBox() {
    final it = children.whereType<RoomBox>();
    return it.isEmpty ? null : it.first;
  }

  // Handles so we can remove them after sweeping
  Doorway? _sweepDoorBottom;
  Doorway? _sweepDoorRight; 


  // global kill-zone registry
  final List<Rect> _killZones = [];
  void setKillZones(List<Rect> r) {
    _killZones
      ..clear()
      ..addAll(r);
  }
  List<Rect> get killZones => _killZones;

  // toggleable debug outlines
  bool debugZones = false; // turn off for release


  // Checklist & overlay
  final ChecklistModel checklist = ChecklistModel();
  late final ChecklistOverlay _checklist;

  // Task ordering: power -> all indoor tasks -> outdoor tasks
  bool get _indoorTasksDone =>
      checklist.livingGlassCleared &&
      checklist.basementResolved &&
      checklist.fridgeChecked;

  bool get _canGoOutside => checklist.powerRestored && _indoorTasksDone;


  void toggleChecklist() {
    _checklist.open = !_checklist.open;
    if (_checklist.open) {
      checklistBadgeCount.value = 0;
    }
  }

  void startFridgeMiniGame() {
    if (_fridgeMiniRunning || isTransitioning) return;
    _fridgeMiniRunning = true;
    lockInput(true);

    add(
      FridgeMiniGame(
        onFinished: ({required int tossedBad, required int savedGood, required bool perfect}) async {
          // Parent owns the comeback transition
          await _fade.fadeToBlack(duration: 0.18);

            if (tossedBad + savedGood > 0 && perfect) {
            _markTaskDone(checklist.fridgeChecked, () {
              checklist.fridgeChecked = true;
            });
            _hud.show('Fridge checked — food sorted!');

            // Rebuild room interactives so the fridge hotspot disappears
            _clearInteractives();
            _buildInteractivesFor(_room);
          } else {
            _hud.show('Fridge check incomplete — try again later.');
          }

          _fridgeMiniRunning = false;
          lockInput(false);

          // tiny yield to ensure mini-game removed itself
          await Future<void>.delayed(const Duration(milliseconds: 1));
          await _fade.fadeInFromBlack(duration: 0.18);

        },
        onCancel: () async {
          await _fade.fadeToBlack(duration: 0.12);
          _hud.show('Fridge check canceled.');
          _fridgeMiniRunning = false;
          lockInput(false);
          await Future<void>.delayed(const Duration(milliseconds: 1));
          await _fade.fadeInFromBlack(duration: 0.12);
        },
      )..size = size,
    );
  }

  // Input lock used by the how-to overlay
  bool _inputLocked = false;
  bool get isInputLocked => _inputLocked;
  void lockInput([bool v = true]) => _inputLocked = v;


  Room _room = Room.living;
  bool _initialized = false;
  bool _transitioning = false;

  // First-visit random events
  bool _visitedSidewalk = false;
  bool _sidewalkDownedLine = false;
  bool _visitedBasement = false;
  bool _basementFlooded = false;

  // Sidewalk leaky hydrant
  bool _hydrantLeaking = true;
  bool get hydrantLeaking => _hydrantLeaking;


  bool _fridgeMiniRunning = false; // controls fridge mini-game state

  // Player can ignore the hazard, but then stepping in it should kill them
  bool _basementIgnored = false;
  bool _sidewalkIgnored = false;

  // Front-lawn debris (for the video task)
  bool _frontLawnHasDebris = true;

  // Expose for drawing
  bool get sidewalkDownedLine => _sidewalkDownedLine;
  bool get basementFlooded => _basementFlooded;

  // Solids for collision
  final List<Rect> _solids = [];
  List<Rect> get solids => _solids;
  void setSolids(List<Rect> r) {
    _solids
      ..clear()
      ..addAll(r);
  }

  // Door rectangles per room so we can spawn right at doors
  Map<String, Rect> _doorRectsFor(Room room) {
    Rect bottomDoor()   => Rect.fromLTWH(size.x / 2 - 24, size.y - 50, 48, 30);
    Rect topDoor()      => Rect.fromLTWH(size.x / 2 - 20, 20, 40, 28);
    Rect rightDoor()    => Rect.fromLTWH(size.x - 60,    size.y / 2 + 4, 42, 70);
    Rect leftDoor()     => Rect.fromLTWH(16, size.y / 2 + 4, 40, 40);
    Rect topRightDoor() => Rect.fromLTWH(size.x - 80, 60, 60, 24);

    switch (room) {
      case Room.living:
        return {
          'toBasement': bottomDoor(),
          'toFrontLawn': topDoor(),
          'toKitchen': rightDoor(),
        };
      case Room.basement:
        return {'toLiving': topDoor()};
      case Room.frontLawn:
        return {'toLiving': Rect.fromLTWH(
          size.x / 2 - 24,
          size.y - 210,
          48,
          30,
        ), 'toSidewalk': topRightDoor()};
      case Room.sidewalk:
        // custom door positions 
        return {
          'toFrontLawn': Rect.fromLTWH(
            16,
            size.y * 0.33,
            40,
            40,
          ),
          'toNeighbor': Rect.fromLTWH(
            size.x - 56,
            size.y * 0.33,
            40,
            40,
          ),
        };
      case Room.neighbor:
        return {
          'toSidewalk': Rect.fromLTWH(16, size.y * 0.10, 40, 40),
        };
      case Room.kitchen:
        return {'toLiving': leftDoor()};
    }
  }

  @override
  void update(double dt) {
    super.update(dt);

    if (_bumpTimer > 0) {
      _bumpTimer -= dt;
      if (_bumpTimer <= 0) {
        _bumpTimer = 0;
        _lastBumpName = null;
        bumpLabel.value = '';
      }
    }
  }

  bool get isTransitioning => _transitioning;

  @override
  Color backgroundColor() => const Color(0xFF0B1220);


    @override
    Future<void> onLoad() async {
      images.prefix = '';
      _sfxPlayer = AudioPlayer(playerId: 'after_outage_sfx')
        ..setReleaseMode(ReleaseMode.stop);

      // Build the room background
      final roomBox = RoomBox(room: _room)..priority = 0;
      add(roomBox);

      // HUD
      _hud = HudToast()..priority = 1000;
      add(_hud);

      // Player
      _player = Player()
        ..priority = 50;
      add(_player);

      // *** NEW: spawn in open floor on the right side, not inside the couch ***
      _player.position = Vector2(size.x * 0.60, size.y * 0.70);

      // Fade curtain + debug overlay
      _fade = FadeCurtain(size: size)..priority = 2000;
      add(_fade);
      add(_ZoneDebugOverlay()..priority = 1200);

      // Show intro overlay and lock input until "Start"
      lockInput(true);
      add(HowToPlayOverlay());

      // Checklist overlay
      _checklist = ChecklistOverlay()..priority = 1300;
      add(_checklist);

      // Build doorways/hotspots and solids for the initial room
      _buildInteractivesFor(_room);
      roomBox.recomputeSolids();

      // SAFETY NUDGE: if initial spawn overlaps a solid, move to a secondary clear spot
      {
        const double hb = 16.0;
        Rect hitboxAt(Vector2 p) =>
            Rect.fromCenter(center: Offset(p.x, p.y), width: hb, height: hb);
        final solidRects = solids;
        Vector2 p = _player.position.clone();
        bool collides(Rect r) => solidRects.any((s) => r.overlaps(s));

        if (collides(hitboxAt(p))) {
          // Try a few backup positions in the living room
          final candidates = <Vector2>[
            // primary safe spot on the right side
            Vector2(size.x * 0.60, size.y * 0.70),
            // slight variations around it
            Vector2(size.x * 0.55, size.y * 0.68),
            Vector2(size.x * 0.65, size.y * 0.68),
            Vector2(size.x * 0.58, size.y * 0.62),
          ];
          for (final c in candidates) {
            if (!collides(hitboxAt(c))) {
              _player.position = c;
              break;
            }
          }
        }

      _initialized = true;

      // Ensure the room label is set before the UI builds
      roomLabel.value = _roomLabel(_room);

      // Initial hint
      _hud.show('Check a lamp to see if power is back on.');
    }


    _initialized = true;

    roomLabel.value = _roomLabel(_room);
    // Nudge the player to check the lamp first
    _hud.show('Check a lamp to see if power is back on.');
  }

  @override
  void onGameResize(Vector2 canvasSize) {
    super.onGameResize(canvasSize);
    if (!_initialized) return;
    _fade.size = canvasSize;

    _clearInteractives();
    _buildInteractivesFor(_room);
    _roomBox()?.recomputeSolids();
  }

  // Public hook for D-pad
  void setMobileDir(double dx, double dy) {
    if (isInputLocked) {
      _player.dir = Vector2.zero();
      return;
    }
    final v = Vector2(dx, dy);
    _player.dir = v.length2 == 0 ? Vector2.zero() : v.normalized();
  }


  // Room building

  void _clearInteractives() {
    children.whereType<Doorway>().toList().forEach((d) => d.removeFromParent());
    children.whereType<Hotspot>().toList().forEach((h) => h.removeFromParent());
  }

  void _markTaskDone(bool alreadyDone, void Function() setTrue) {
    if (alreadyDone) return;
    setTrue();
    if (!_checklist.open) {
      checklistBadgeCount.value = (checklistBadgeCount.value + 1).clamp(0, 99);
    }
    _playSfx('correct.mp3');
    if (checklist.isComplete) {
      winGame();
    }
  }

  void _buildInteractivesFor(Room room) {
    final livingDoors   = _doorRectsFor(Room.living);
    final basementDoors = _doorRectsFor(Room.basement);
    final lawnDoors     = _doorRectsFor(Room.frontLawn);
    final sidewalkDoors = _doorRectsFor(Room.sidewalk);
    final neighborDoors = _doorRectsFor(Room.neighbor);
    final kitchenDoors  = _doorRectsFor(Room.kitchen);

    if (room == Room.living) {
      add(Doorway(
        rect: livingDoors['toBasement']!,
        label: '↓ Basement',
        onEnter: () async {
          HapticFeedback.selectionClick();

          // Must restore power before leaving the living room
          if (!checklist.powerRestored) {
            add(
              NeighborDialog(
                message: 'Before going downstairs, check a lamp to see if the power is back on.',
                onComplete: () {},
              ),
            );
            return;
          }

          await _goTo(Room.basement, spawnFrom: 'toLiving');
        },
      ));

      add(Doorway(
        rect: Rect.fromLTWH(size.x / 2 + 66, 18, 58, 32),
        label: '↑ Front Lawn',
        onEnter: () async {
          HapticFeedback.selectionClick();

          // Must restore power first
          if (!checklist.powerRestored) {
            add(
              NeighborDialog(
                message: 'Before going outside, check a lamp to see if the power came back on.',
                onComplete: () {},
              ),
            );
            return;
          }

          // Must finish all indoor tasks before leaving the house
          if (!_indoorTasksDone) {
            add(
              NeighborDialog(
                message: 'Finish all the tasks inside your house before going outside.',
                onComplete: () {},
              ),
            );
            return;
          }

          await _goTo(Room.frontLawn, spawnFrom: 'toLiving');
        },
      ));
      add(Doorway(
        rect: livingDoors['toKitchen']!,
        label: '→ Kitchen',
        onEnter: () async {
          HapticFeedback.selectionClick();

          // Must restore power before leaving the living room
          if (!checklist.powerRestored) {
            add(
              NeighborDialog(
                message: 'First, check a lamp in the living room to make sure the power is back on before going to the kitchen.',
                onComplete: () {},
              ),
            );
            return;
          }

          await _goTo(Room.kitchen, spawnFrom: 'toLiving');
        },
      ));


      Rect _livingGlassRect() {
        const double inset = 14.0;
        final Rect screen = Rect.fromLTWH(0, 0, size.x, size.y);
        final Rect inner  = screen.deflate(inset);

        // You set pixel mode:
        const bool   L_GLASS_USE_PERCENT = false;

        // Pixel mode (your new placement)
        const double L_GLASS_LEFT_PX   = 8.0;
        const double L_GLASS_TOP_PX    = 8.0;
        const double L_GLASS_WIDTH_PX  = 50.0;
        const double L_GLASS_HEIGHT_PX = 35.0;

        if (!L_GLASS_USE_PERCENT) {
          return Rect.fromLTWH(
            inner.left + L_GLASS_LEFT_PX,
            inner.top  + L_GLASS_TOP_PX,
            L_GLASS_WIDTH_PX,
            L_GLASS_HEIGHT_PX,
          );
        }
      }

      // LAMP HOTSPOT
      final lampCenter = _livingLampCenter();
      add(Hotspot(
        center: lampCenter,
        radius: 24,
        title: 'Lamp',
        showUI: false,
        onTrigger: () {
          HapticFeedback.lightImpact();
          final rb = children.whereType<RoomBox>().first;
          if (!rb.lampOn) {
            rb.lampOn = true;
            _markTaskDone(checklist.powerRestored, () {
              checklist.powerRestored = true;
            });
            _hud.show('The lamp turns on — power is back!');
          } else {
            _hud.show('Lamp is already on.');
          }
        },
      ));
      // Sweep glass hot spots
      _sweepDoorBottom?.removeFromParent();
      _sweepDoorRight?.removeFromParent();
      _sweepDoorBottom = null;
      _sweepDoorRight  = null;

      if (_livingGlassPresent) {
        final Rect glass = _roomBox()?.currentLivingGlassRect ?? _livingGlassRect();

        // thin bar along the bottom edge
        final bottomBar = Rect.fromLTWH(
          glass.left,
          glass.bottom + 4,
          glass.width,
          18,
        );

        // thin bar along the right edge
        final rightBar = Rect.fromLTWH(
          glass.right + 4,
          glass.top,
          18,
          glass.height,
        );

        Future<void> _doSweep() async {
          if (!_livingGlassPresent) {
            _hud.show('Window area already cleared.');
            return;
          }

          // Must restore power before starting indoor cleanup tasks
          if (!checklist.powerRestored) {
            add(
              NeighborDialog(
                message: 'First, check a lamp to see if the power is back on. Then you can clean up the broken glass.',
                onComplete: () {},
              ),
            );
            return;
          }

          final yes = await _showYesNoDialog(
            'Broken Glass',
            'Sweep up the broken glass now?',
          );
          if (yes) {
            await _fade.fadeToBlack(duration: 0.18);
            _livingGlassPresent = false;
            _livingGlassIgnored = false;

            // checklist tick + badge
            _markTaskDone(checklist.livingGlassCleared, () {
              checklist.livingGlassCleared = true;
            });

            // remove the two sweep hotspots so they stop showing
            _sweepDoorBottom?..removeFromParent();
            _sweepDoorRight?..removeFromParent();
            _sweepDoorBottom = null;
            _sweepDoorRight  = null;

            // refresh room art
            _roomBox()?.room = Room.living;
            await _fade.fadeInFromBlack(duration: 0.18);
            _hud.show('Glass cleared.');
          } else {
            _livingGlassIgnored = true;
            _hud.show('Be careful — glass is still on the floor.');
          }
        }

        _sweepDoorBottom = Doorway(
          rect: bottomBar,
          label: '',
          onEnter: () async { HapticFeedback.selectionClick(); await _doSweep(); },
        )..priority = 6;
        add(_sweepDoorBottom!);

        _sweepDoorRight = Doorway(
          rect: rightBar,
          label: '',
          onEnter: () async { HapticFeedback.selectionClick(); await _doSweep(); },
        )..priority = 6;
        add(_sweepDoorRight!);
      }

    } else if (room == Room.basement) {
      add(Doorway(
        rect: basementDoors['toLiving']!,
        label: '↑ Living Room',
        onEnter: () async {
          HapticFeedback.selectionClick();
          await _goTo(Room.living, spawnFrom: 'toBasement');
        },
      ));
    } else if (room == Room.frontLawn) {
      add(Doorway(
        rect: lawnDoors['toLiving']!,
        label: '↓ Living Room',
        color: Colors.transparent,
        textColor: Colors.black.withValues(alpha: 0.82),
        onEnter: () async {
          HapticFeedback.selectionClick();
          await _goTo(Room.living, spawnFrom: 'toFrontLawn');
        },
      ));
      add(Doorway(
        rect: lawnDoors['toSidewalk']!,
        label: '↗ Sidewalk',
        color: Colors.black.withOpacity(0.35),
        textColor: Colors.white,
        onEnter: () async {
          HapticFeedback.selectionClick();

          if (!_canGoOutside) {
            add(
              NeighborDialog(
                message: 'Complete all your indoor tasks before heading farther down the street.',
                onComplete: () {},
              ),
            );
            return;
          }

          await _goTo(Room.sidewalk, spawnFrom: 'toFrontLawn');
        },
      ));

      // front yard video interaction
      final Rect recordRect = Rect.fromCenter(
        center: Offset(size.x * 0.76, size.y * 0.58),
        width: 64,
        height: 36,
      );

      if (!checklist.frontYardVideo) {
        late Doorway recordDoor;
        recordDoor = Doorway(
          rect: recordRect,
          label: 'Record Damage',
          color: Colors.black.withOpacity(0.35),
          textColor: Colors.black.withOpacity(0.90),
          onEnter: () async {
            if (checklist.frontYardVideo) {
              _hud.show('Front yard already documented.');
              recordDoor.removeFromParent();
              return;
            }

            final yes = await _showYesNoDialog(
              'Front Yard',
              'Take a quick video of the storm debris for insurance?',
            );
            if (yes) {
              await _fade.fadeToBlack(duration: 0.18);
              _frontLawnHasDebris = false;
              _markTaskDone(checklist.frontYardVideo, () {
                checklist.frontYardVideo = true;
              });
              _roomBox()?.room = Room.frontLawn;
              await _fade.fadeInFromBlack(duration: 0.18);
              _hud.show('Video taken — debris cleared.');

              // remove hotspot once complete
              recordDoor.removeFromParent();
            } else {
              _hud.show('You can record it later.');
            }
          },
        );
        add(recordDoor);
      }

      } else if (room == Room.sidewalk) {
        // Doors to other rooms
        add(Doorway(
          rect: sidewalkDoors['toFrontLawn']!,
          label: '← Front Lawn',
          color: Colors.black.withOpacity(0.35),
          textColor: Colors.black,
          onEnter: () async {
            HapticFeedback.selectionClick();
            await _goTo(Room.frontLawn, spawnFrom: 'toSidewalk');
          },
        ));

        add(Doorway(
          rect: sidewalkDoors['toNeighbor']!,
          label: '→ Neighbor',
          color: Colors.black.withOpacity(0.35),
          textColor: Colors.black,
          onEnter: () async {
            HapticFeedback.selectionClick();

            if (!_canGoOutside) {
              add(
                NeighborDialog(
                  message: 'Take care of all the tasks inside your own home before checking on your neighbor.',
                  onComplete: () {},
                ),
              );
              return;
            }

            await _goTo(Room.neighbor, spawnFrom: 'toSidewalk');
          },
        ));

      // sidewalk geometry for hotspots
      const double inset = 14.0;
      final Rect screen = Rect.fromLTWH(0, 0, size.x, size.y);
      final Rect inner  = screen.deflate(inset);

      final double streetH = (inner.height * 0.24).clamp(56.0, 120.0);
      final double grassH  = (inner.height * 0.30).clamp(70.0, 160.0);
      final double pathH   = inner.height - streetH - grassH;

      final Rect streetRect = Rect.fromLTWH(inner.left, inner.top, inner.width, streetH);
      final Rect pathRect   = Rect.fromLTWH(inner.left, streetRect.bottom, inner.width, pathH);
      final Rect grassRect  = Rect.fromLTWH(inner.left, pathRect.bottom, inner.width, grassH);

      final double hydrantHotspotY = grassRect.top - 130.0; // higher
      final double lineHotspotY    = grassRect.top - 26.0; // original

      // Hydrant hotspot
      const double hydrantHotW = 40.0;
      const double hydrantHotH = 30.0;
      final Offset hydrantCenter = Offset(
        pathRect.left + pathRect.width * 0.58,
        hydrantHotspotY,
      );
      final Rect hydrantHotRect = Rect.fromCenter(
        center: hydrantCenter,
        width: hydrantHotW,
        height: hydrantHotH,
      );

      // downed-line hotspot (stays where it was)
      const double powerHotW = 40.0;
      const double powerHotH = 30.0;
      const double powerGap  = 42.0;

      final Offset powerCenter = Offset(
        hydrantCenter.dx - (hydrantHotW / 2 + powerGap + powerHotW / 2),
        lineHotspotY,
      );
      final Rect powerHotRect = Rect.fromCenter(
        center: powerCenter,
        width: powerHotW,
        height: powerHotH,
      );

      //Downed power line
      if (!checklist.sidewalkResolved) {
        late Doorway lineDoor;
        lineDoor = Doorway(
          rect: powerHotRect,
          label: 'Downed Line',
          color: Colors.black.withOpacity(0.35),
          textColor: Colors.black.withOpacity(0.90),
          onEnter: () async {
            final checklist = this.checklist;

            // No downed line visible, just verify sidewalk and clear task
            if (!_sidewalkDownedLine) {
              if (checklist.sidewalkResolved) {
                _hud.show('Sidewalk already safe.');
                lineDoor.removeFromParent();
              } else {
                _markTaskDone(checklist.sidewalkResolved, () {
                  checklist.sidewalkResolved = true;
                });
                _hud.show('Sidewalk checked — area is safe.');
                lineDoor.removeFromParent();
              }
              return;
            }

            // Active downed line hazard
            final yes = await _showYesNoDialog(
              'Downed Power Line',
              'A live wire is on the grass.\nCall the utility company to secure the area?',
            );
            if (yes) {
              await _fade.fadeToBlack(duration: 0.22);
              _sidewalkDownedLine = false;
              _markTaskDone(checklist.sidewalkResolved, () {
                checklist.sidewalkResolved = true;
              });
              children.whereType<RoomBox>().firstOrNull?.room = Room.sidewalk;
              await _fade.fadeInFromBlack(duration: 0.22);
              _hud.show('Utility notified — area safe.');

              // remove hotspot once complete
              lineDoor.removeFromParent();
            } else {
              _hud.show('Stay clear of the line!');
              _sidewalkIgnored = true;
            }
          },
        );
        add(lineDoor);
      }

      // leaky fire hydrant
      if (!checklist.leakyHydrantReported) {
        late Doorway hydrantDoor;
        hydrantDoor = Doorway(
          rect: hydrantHotRect,
          label: 'Leaky Hydrant',
          color: Colors.black.withOpacity(0.35),
          textColor: Colors.black,
          onEnter: () async {
            HapticFeedback.selectionClick();
            if (checklist.leakyHydrantReported) {
              _hud.show('Hydrant leak already reported.');
              hydrantDoor.removeFromParent();
              return;
            }

            final yes = await _showYesNoDialog(
              'Leaky Hydrant',
              'Water is leaking from the hydrant.\nCall the water department?',
            );

            if (!yes) {
              _hud.show('You can report it later.');
              return;
            }

            // fade, stop leak, tick checklist
            await _fade.fadeToBlack(duration: 0.22);

            _hydrantLeaking = false;

            _markTaskDone(checklist.leakyHydrantReported, () {
              checklist.leakyHydrantReported = true;
            });

            // force sidewalk art to refresh
            children.whereType<RoomBox>().firstOrNull?.room = Room.sidewalk;

            await _fade.fadeInFromBlack(duration: 0.22);
            _hud.show('Water department notified — leak stopped.');

            // remove hotspot once complete
            hydrantDoor.removeFromParent();
          },
        );
        add(hydrantDoor);
      }

    } else if (room == Room.neighbor) {
      add(Doorway(
        rect: neighborDoors['toSidewalk']!,
        label: '← Sidewalk',
        color: Colors.black.withOpacity(0.28), 
        textColor: Colors.white,
        onEnter: () async {
          HapticFeedback.selectionClick();
          await _goTo(Room.sidewalk, spawnFrom: 'toSidewalk');
        },
      ));

      // check on neighbor
      final Rect neighborDoorRect = Rect.fromLTWH(
        size.x / 2 - 20,
        size.y - 210,
        40,
        28,
      );

      if (!checklist.neighborChecked) {
        late Doorway neighborDoor;
        neighborDoor = Doorway(
          rect: neighborDoorRect,
          label: 'Check Neighbor',
          color: Colors.black.withOpacity(0.35),
          textColor: Colors.black.withOpacity(0.90),
          onEnter: () async {
            await _playSfx('openDoor.wav', volume: 0.9);
            if (checklist.neighborChecked) {
              _hud.show('Neighbor is okay.');
              neighborDoor.removeFromParent();
              return;
            }
            // dialog with neighbor
            add(
              NeighborDialog(
                message: 'Thank you for checking on me.\n'
                        'I\'m okay, just a bit shaken after the storm.\n\n'
                        'It really helps to have neighbors looking out for me.',
                onComplete: () {
                  _markTaskDone(checklist.neighborChecked, () {
                    checklist.neighborChecked = true;
                  });
                  _hud.show('Neighbor checked on.');
                  neighborDoor.removeFromParent();
                },
              ),
            );
          },
        );
        add(neighborDoor);
      }

    } else if (room == Room.kitchen) {
      add(Doorway(
        rect: kitchenDoors['toLiving']!,
        label: '← Living Room',
        // darker background so it stands out on the white floor
        color: Colors.black.withOpacity(0.28),
        // darker text so it’s readable against the light floor
        textColor: Colors.black.withOpacity(0.95),
        onEnter: () async {
          HapticFeedback.selectionClick();
          await _goTo(Room.living, spawnFrom: 'toKitchen');
        },
      ));

      // Fridge hotspot
      const double inset = 14.0;
      final Rect screen = Rect.fromLTWH(0, 0, size.x, size.y);
      final Rect inner  = screen.deflate(inset);

      final double rightPad   = 8.0;
      final double ovenH      = inner.height * 0.18;
      final double sinkH      = inner.height * 0.22;
      final double counterH   = inner.height * 0.24;

      final double baseFridgeH = inner.height - (ovenH + sinkH + counterH);

      const double FRIDGE_HEIGHT_SCALE = 0.50;
      const double FRIDGE_PROTRUDE_PX  = 22.0;
      final double fridgeWBase = 72.0;
      final double fridgeW     = fridgeWBase + FRIDGE_PROTRUDE_PX;
      final double fridgeH     = baseFridgeH * FRIDGE_HEIGHT_SCALE;

      final double fridgeRight = inner.right - rightPad;
      final double fridgeX     = fridgeRight - fridgeW;
      final double fridgeY     = inner.bottom - fridgeH;
      final Rect   fridgeRect  = Rect.fromLTWH(fridgeX, fridgeY, fridgeW, fridgeH);

      // vertical interaction bar to left of fridge
      final double doorBarW   = 22.0;
      final double doorBarH   = (fridgeH * 0.90).clamp(70, 160);
      final double doorBarGap = 6.0;

      final Rect fridgeDoorRect = Rect.fromCenter(
        center: Offset(fridgeRect.left - doorBarGap - doorBarW / 2, fridgeRect.center.dy),
        width: doorBarW,
        height: doorBarH,
      );

      if (!checklist.fridgeChecked) {
        add(Doorway(
          rect: fridgeDoorRect,
          label: '',
          color: Colors.black.withOpacity(0.35),
          onEnter: () async {
            HapticFeedback.selectionClick();

            if (!checklist.powerRestored) {
              add(
                NeighborDialog(
                  message: 'Before checking the fridge, turn on a lamp to make sure the power is back.',
                  onComplete: () {},
                ),
              );
              return;
            }

            if (checklist.fridgeChecked) {
              _hud.show('Fridge already checked.');
              return;
            }

            startFridgeMiniGame();
          },
        ));
      }


    }
    // Update background + solids
    children.whereType<RoomBox>().firstOrNull
      ?..room = room
      ..recomputeSolids();
  }

  // Spawn just inside the destination room’s door you came through
  Vector2 _spawnPoint(Room dest, String? spawnFromKey) {
    final doors = _doorRectsFor(dest);
    Vector2 center() => Vector2(size.x / 2, size.y / 2);

    if (spawnFromKey == null || !doors.containsKey(spawnFromKey)) {
      if (dest == Room.living) {
        return Vector2(size.x * 0.60, size.y * 0.70);
      }
      return center();
    }

    final r = doors[spawnFromKey]!;
    const inside = 24.0;

    switch (dest) {
      case Room.living:
        if (spawnFromKey == 'toBasement') {
          return Vector2(r.center.dx, r.top - inside);
        } else if (spawnFromKey == 'toFrontLawn') {
          return Vector2(r.center.dx, r.bottom + inside);
        } else if (spawnFromKey == 'toKitchen') {
          return Vector2(r.left - inside, r.center.dy);
        }
        break;
      case Room.basement:
        if (spawnFromKey == 'toLiving') {
          return Vector2(r.center.dx, r.bottom + inside);
        }
        break;
      case Room.frontLawn:
        if (spawnFromKey == 'toLiving') {
          return Vector2(r.center.dx, r.top - inside);
        } else if (spawnFromKey == 'toSidewalk') {
          return Vector2(r.center.dx + 40, r.bottom + inside); 
        }
        break;
      case Room.sidewalk:
        if (spawnFromKey == 'toFrontLawn') {
          return Vector2(r.right + inside, r.center.dy);
        } else if (spawnFromKey == 'toNeighbor') {
          return Vector2(r.left - inside, r.center.dy);
        }
        break;
      case Room.neighbor:
        if (spawnFromKey == 'toSidewalk') {
          return Vector2(r.right + inside, r.center.dy);
        }
        break;
      case Room.kitchen:
        if (spawnFromKey == 'toLiving') {
          return Vector2(r.right + inside, r.center.dy);
        }
        break;
    }
    return center();
  }

  Future<void> _goTo(Room dest, {String? spawnFrom}) async {
    if (_transitioning) return;
    _transitioning = true;

    await _fade.fadeToBlack();

    if (dest == Room.sidewalk && !_visitedSidewalk) {
      _visitedSidewalk = true;
      _sidewalkDownedLine = true;
      _hud.show('Caution: downed power line on the grass.');
    }
    if (dest == Room.basement && !_visitedBasement) {
      _visitedBasement = true;
      _basementFlooded = true;
      _hud.show('Basement is flooded.');
    }

    // If we checked the room and there was no hazard, count it as resolved
    if (dest == Room.basement && !_basementFlooded && !checklist.basementResolved) {
      _markTaskDone(checklist.basementResolved, () {
        checklist.basementResolved = true;
      });
      _hud.show('Basement checked — no water found.');
    }

    // First-visit hazard prompts
    if (dest == Room.basement && _basementFlooded && !checklist.basementResolved) {
      Future.delayed(const Duration(milliseconds: 400), () async {
        // Must restore power before dealing with the flooded basement
        if (!checklist.powerRestored) {
          add(
            NeighborDialog(
              message: 'Check a lamp upstairs to make sure the power is back on before dealing with the flooded basement.',
              onComplete: () {},
            ),
          );
          return;
        }

        final yes = await _showYesNoDialog(
          'Flooded Basement',
          'Basement appears flooded.\nCall an electrician to inspect?',
        );
        if (yes) {
          await _fade.fadeToBlack(duration: 0.22);
          _basementFlooded = false;
          _markTaskDone(checklist.basementResolved, () {
            checklist.basementResolved = true;
          });
          // force room redraw
          children.whereType<RoomBox>().firstOrNull?.room = Room.basement;
          await _fade.fadeInFromBlack(duration: 0.22);
          _hud.show('Electrician contacted — basement safe.');
        } else {
          _hud.show('Basement remains unsafe.');
          _basementIgnored = true;
        }
      });
    }

    _room = dest;
    roomLabel.value = _roomLabel(_room);

    _clearInteractives();
    _buildInteractivesFor(dest);

    _player.position = _spawnPoint(dest, spawnFrom);

    await _fade.fadeInFromBlack();
    _transitioning = false;
  }

  // Keep the UI label short & in the fade text
  String _roomLabel(Room r) {
    switch (r) {
      case Room.living:    return 'Living Room';
      case Room.basement:  return 'Basement';
      case Room.frontLawn: return 'Front Lawn';
      case Room.sidewalk:  return 'Sidewalk';
      case Room.neighbor:  return 'Neighbor’s House';
      case Room.kitchen:   return 'Kitchen';
    }
  }

  // Keep the same math as RoomBox for lamp center so the hotspot lines up
  Vector2 _livingLampCenter() {
    const inset = 14.0;
    final rect = Rect.fromLTWH(0, 0, size.x, size.y);
    final inner = rect.deflate(inset);
    final rug = Rect.fromCenter(
      center: Offset(inner.center.dx + 10.0, inner.center.dy + 18.0),
      width: inner.width * 0.46,
      height: inner.height * 0.34,
    );
    final baseCenter = Offset(
      rug.right + 52.0,
      rug.top - 90.0
    );
    return Vector2(baseCenter.dx, baseCenter.dy);
  }

  // Gives Flame access to current BuildContext from GameWidget
  Future<bool> _showYesNoDialog(String title, String question) async {
    final ctx = context;
    final result = await showDialog<bool>(
      context: ctx,
      barrierDismissible: false,
      builder: (ctx2) => AlertDialog(
        title: Text(title),
        content: Text(question),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx2, false), child: const Text('No')),
          ElevatedButton(onPressed: () => Navigator.pop(ctx2, true), child: const Text('Yes')),
        ],
      ),
    );
    return result ?? false;
  }

  // Character select overlay shown after "How to Play" and before the game starts
  Future<void> showCharacterSelectDialog() async {
    add(CharacterSelectDialog());
  }


  Future<void> _playSfx(String filename, {double volume = 0.9}) async {
    if (_muted) return;
    try {
      await _sfxPlayer.stop();
      await _sfxPlayer.play(AssetSource('audio/$filename'), volume: volume);
    } catch (_) {}
  }

  // called by player hazard check
  Future<void> loseGame(String reason) async {
    if (_gameOver) return;
    _gameOver = true;
    await _playSfx('incorrect.aiff');

    // unlock input so dialog can be tapped
    lockInput(false);

    await showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => AlertDialog(
        title: const Text('Ouch!'),
        content: Text(reason),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(ctx).pop();
              _resetGame();
            },
            child: const Text('Play again'),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(ctx).pop();
              onExitToMenu?.call();
            },
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

    Future<void> winGame() async {
    if (_winDialogShown) return;
    _winDialogShown = true;

    // short ding
    await _playSfx('correct.mp3');
    // bigger win sound
    await _playSfx('win.wav');

    // confetti overlay
    add(WinConfetti());

    // unlock input so dialog is tap-able
    lockInput(false);

    await showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => AlertDialog(
        title: const Text('Great job!'),
        content: const Text('You completed all the after-outage tasks.'),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(ctx).pop();
              _resetGame();
            },
            child: const Text('Play again'),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(ctx).pop();
              onExitToMenu?.call();
            },
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  void _resetGame() {
    // reset checklist
    checklist.powerRestored = false;
    checklist.basementResolved = false;
    checklist.fridgeChecked = false;
    checklist.frontYardVideo = false;
    checklist.sidewalkResolved = false;
    checklist.neighborChecked = false;
    checklist.livingGlassCleared = false;
    checklist.leakyHydrantReported = false;

    // reset game-over / win flags
    _gameOver = false;
    _winDialogShown = false;

    // reset random states + “ignored” flags
    _visitedSidewalk = false;
    _sidewalkDownedLine = false;
    _sidewalkIgnored = false;
    _hydrantLeaking = true;
    _visitedBasement = false;
    _basementFlooded = false;
    _basementIgnored = false;
    _livingGlassPresent = true;
    _livingGlassIgnored = false;

    // reset front-lawn debris so video task is fresh
    _frontLawnHasDebris = true;

    // go back to living room
    _room = Room.living;
    roomLabel.value = _roomLabel(_room);

    // rebuild room + force living-room lamp OFF
    _clearInteractives();
    _buildInteractivesFor(_room);
    final rb = _roomBox();
    if (rb != null) {
      rb.room = _room;
      rb.lampOn = false;
      rb.recomputeSolids();
    }

    // put player in the same open spot as first time
    _player.position = Vector2(size.x * 0.60, size.y * 0.70);

    // make sure input is unlocked
    lockInput(false);

    // clear fades
    _fade.fadeInFromBlack(duration: 0.15);

    // tell user
    _hud.show('Game reset — start by checking the lamp.');

    // safety: if we somehow spawned on a solid, try a few backups
    {
      const double hb = 16.0;
      Rect hitboxAt(Vector2 p) =>
          Rect.fromCenter(center: Offset(p.x, p.y), width: hb, height: hb);
      final solidRects = solids;
      Vector2 p = _player.position.clone();
      bool collides(Rect r) => solidRects.any((s) => r.overlaps(s));

      if (collides(hitboxAt(p))) {
        final candidates = <Vector2>[
          // main intended spawn
          Vector2(size.x * 0.50, size.y * 0.68),
          // slightly left
          Vector2(size.x * 0.45, size.y * 0.70),
          // slightly right
          Vector2(size.x * 0.55, size.y * 0.70),
        ];
        for (final c in candidates) {
          if (!collides(hitboxAt(c))) {
            _player.position = c;
            break;
          }
        }
      }
    }
  }
}

// Components

enum PlayerAvatar { bradley, hannah }
enum _Facing { up, left, down, right }

class Player extends SpriteAnimationGroupComponent<_Facing>
    with HasGameRef<SaferAdventureGame> {
  static const double speed = 140;

  Vector2 _dir = Vector2.zero();

  // Active maps (current avatar)
  late Map<_Facing, SpriteAnimation> _idleMap;
  late Map<_Facing, SpriteAnimation> _walkMap;

  // Per-avatar animation maps
  late final Map<_Facing, SpriteAnimation> _idleBradley;
  late final Map<_Facing, SpriteAnimation> _walkBradley;
  late final Map<_Facing, SpriteAnimation> _idleHannah;
  late final Map<_Facing, SpriteAnimation> _walkHannah;

  bool _fallback = false;
  PlayerAvatar _avatar = PlayerAvatar.hannah; // default for now

  // Base size used for both avatars
  static const double _baseSize = 32.0;

  // Per-avatar visual scale (Bradley = normal, Hannah slightly bigger)
  static const double _bradScale   = 1.0;
  static const double _hannahScale = 1.20;
  
  Player()
      : super(
          priority: 50,
          anchor: Anchor.center,
          size: Vector2(_baseSize, _baseSize),
        );


  set dir(Vector2 v) => _dir = v;

  // Asset keys for both sprites
  static const String _assetBradley = 'assets/images/sprites/main_guy_3x4_32.png';
  static const String _assetHannah  = 'assets/images/sprites/main_girl_4x8_64.png';

  Future<ui.Image?> _loadSprite(String key) async {
    try {
      debugPrint('[Player] Flame load: $key');
      return await gameRef.images.load(key);
    } catch (e) {
      debugPrint('[Player] Flame load failed for $key: $e');
      // Fallback: try via rootBundle / AssetManifest
      try {
        final manifestJson = await rootBundle.loadString('AssetManifest.json');
        final Map<String, dynamic> manifest = convert.json.decode(manifestJson);
        if (!manifest.containsKey(key)) {
          debugPrint('[Player] Manifest does not list $key');
          return null;
        }
        final data = await rootBundle.load(key);
        final bytes = data.buffer.asUint8List();
        final codec = await ui.instantiateImageCodec(bytes);
        final frame = await codec.getNextFrame();
        debugPrint('[Player] Loaded via rootBundle: $key');
        return frame.image;
      } catch (e2) {
        debugPrint('[Player] Manifest/direct load failed for $key: $e2');
        return null;
      }
    }
  }

  void _buildBradley(ui.Image image) {
    // Bradley: 4 rows x 3 columns, 32x32 tiles
    const double tile = 32;
    final sheet = SpriteSheet(image: image, srcSize: Vector2(tile, tile));
    const step = 0.12;

    final walkDown  = sheet.createAnimation(row: 0, from: 0, to: 2, stepTime: step);
    final walkRight = sheet.createAnimation(row: 1, from: 0, to: 2, stepTime: step);
    final walkUp    = sheet.createAnimation(row: 2, from: 0, to: 2, stepTime: step);
    final walkLeft  = sheet.createAnimation(row: 3, from: 0, to: 2, stepTime: step);

    final idleDown  = SpriteAnimation.spriteList(
      [sheet.getSprite(0, 1)],
      stepTime: 1,
    );
    final idleRight = SpriteAnimation.spriteList(
      [sheet.getSprite(1, 1)],
      stepTime: 1,
    );
    final idleUp    = SpriteAnimation.spriteList(
      [sheet.getSprite(2, 1)],
      stepTime: 1,
    );
    final idleLeft  = SpriteAnimation.spriteList(
      [sheet.getSprite(3, 1)],
      stepTime: 1,
    );

    _idleBradley = {
      _Facing.up: idleUp,
      _Facing.left: idleLeft,
      _Facing.down: idleDown,
      _Facing.right: idleRight,
    };
    _walkBradley = {
      _Facing.up: walkUp,
      _Facing.left: walkLeft,
      _Facing.down: walkDown,
      _Facing.right: walkRight,
    };
  }


  void _buildHannah(ui.Image image) {
    // Hannah: 4 rows x 8 columns, girl is on right half (cols 4–6)
    const double tile = 64;
    final sheet = SpriteSheet(image: image, srcSize: Vector2(tile, tile));
    const step = 0.12;

    const int girlColStart = 4;
    const int girlColMid   = girlColStart + 1;
    const int girlColEnd   = girlColStart + 2;

    // Row mapping:
    // 0: facing forward (down)
    // 1: facing left
    // 2: facing right
    // 3: facing back (up)

    final walkDown  = sheet.createAnimation(
      row: 0,
      from: girlColStart,
      to: girlColEnd,
      stepTime: step,
    );
    final walkLeft  = sheet.createAnimation(
      row: 1,
      from: girlColStart,
      to: girlColEnd,
      stepTime: step,
    );
    final walkRight = sheet.createAnimation(
      row: 2,
      from: girlColStart,
      to: girlColEnd,
      stepTime: step,
    );
    final walkUp    = sheet.createAnimation(
      row: 3,
      from: girlColStart,
      to: girlColEnd,
      stepTime: step,
    );

    final idleDown  = SpriteAnimation.spriteList(
      [sheet.getSprite(0, girlColMid)],
      stepTime: 1,
    );
    // use a non-walking frame for horizontal idle
    final idleLeft  = SpriteAnimation.spriteList(
      [sheet.getSprite(1, girlColStart)],
      stepTime: 1,
    );
    final idleRight = SpriteAnimation.spriteList(
      [sheet.getSprite(2, girlColStart)],
      stepTime: 1,
    );
    final idleUp    = SpriteAnimation.spriteList(
      [sheet.getSprite(3, girlColMid)],
      stepTime: 1,
    );


    _idleHannah = {
      _Facing.up: idleUp,
      _Facing.left: idleLeft,
      _Facing.down: idleDown,
      _Facing.right: idleRight,
    };
    _walkHannah = {
      _Facing.up: walkUp,
      _Facing.left: walkLeft,
      _Facing.down: walkDown,
      _Facing.right: walkRight,
    };
  }

  void _applyAvatar(PlayerAvatar avatar) {
    _avatar = avatar;

    switch (avatar) {
      case PlayerAvatar.bradley:
        _idleMap = _idleBradley;
        _walkMap = _walkBradley;
        break;
      case PlayerAvatar.hannah:
        _idleMap = _idleHannah;
        _walkMap = _walkHannah;
        break;
    }

    // Apply per-avatar size
    final double scale =
        (avatar == PlayerAvatar.bradley) ? _bradScale : _hannahScale;
    final double s = _baseSize * scale;
    size.setValues(s, s);

    animations = _idleMap;
    current = _Facing.down;
  }

  // Public API so overlays can switch character
  void setAvatar(PlayerAvatar avatar) {
    if (_fallback) return;
    _applyAvatar(avatar);
  }

  @override
  Future<void> onLoad() async {
    try {
      final bradImg = await _loadSprite(_assetBradley);
      final hanImg  = await _loadSprite(_assetHannah);

      if (bradImg == null || hanImg == null) {
        throw Exception('One or both player sprite sheets not found.');
      }

      _buildBradley(bradImg);
      _buildHannah(hanImg);

      // Start as Hannah by default; dialog will call setAvatar(...)
      _applyAvatar(_avatar);

      paint.filterQuality = FilterQuality.none;
      debugPrint('[Player] Both avatars initialized.');
    } catch (e) {
      _fallback = true;
      animations = null;
      debugPrint('[Player] Sprite load FAILED -> using fallback. Error: $e');
    }
  }

  @override
  void update(double dt) {
    super.update(dt);

    final moving = _dir.length2 > 0;
    final old = position.clone();

    if (moving) {
      final v = _dir.normalized();
      position += v * speed * dt;

      if (!_fallback && animations != null) {
        // vertical vs horizontal
        if (v.y.abs() >= v.x.abs()) {
          // v.y > 0 → moving down (front)  | v.y < 0 → moving up (back)
          current = (v.y > 0) ? _Facing.down : _Facing.up;
        } else {
          current = (v.x > 0) ? _Facing.right : _Facing.left;
        }
        if (!identical(animations, _walkMap)) {
          animations = _walkMap;
        }
      }
    } else {
      // Not moving → idle animations, keep direction
      if (!_fallback && animations != null && !identical(animations, _idleMap)) {
        animations = _idleMap;
      }
    }

    // revert if overlapping any solid
    if (_collidesWithSolids()) {
      position.setFrom(old);
    }

    // Keep on screen
    final maxX = gameRef.size.x - 16;
    final maxY = gameRef.size.y - 16;
    position.x = position.x.clamp(16, maxX);
    position.y = position.y.clamp(16, maxY);

    // rectangle-based hazard checks
    final game = gameRef;
    final zones = game.killZones;
    if (zones.isNotEmpty) {
      const double hb = 16.0;
      final me = Rect.fromCenter(
        center: Offset(position.x, position.y),
        width: hb,
        height: hb,
      );
      for (final z in zones) {
        if (me.overlaps(z)) {
          // Basement water
          if (game._room == Room.basement &&
              game.basementFlooded &&
              !game.checklist.basementResolved) {
            game.loseGame('You walked into a flooded basement with live power.');
            return;
          }
          // Sidewalk downed line
          if (game._room == Room.sidewalk &&
              game.sidewalkDownedLine &&
              !game.checklist.sidewalkResolved) {
            game.loseGame('You touched a downed power line.');
            return;
          }
          // Living room broken glass
          if (game._room == Room.living &&
              game._livingGlassPresent &&
              game._livingGlassIgnored) {
            game.loseGame('Ouch! You stepped on broken glass.');
            return;
          }
        }
      }
    }
  }

  bool _collidesWithSolids() {
    final game = gameRef;
    if (game._namedSolids.isEmpty) {
      game._notifyBump(null);
      return false;
    }
    const double hb = 16.0;
    final r = Rect.fromCenter(
      center: Offset(position.x, position.y),
      width: hb,
      height: hb,
    );
    for (final z in game._namedSolids) {
      if (r.overlaps(z.rect)) {
        game._notifyBump(z.name);
        return true;
      }
    }
    game._notifyBump(null);
    return false;
  }

  @override
  void render(Canvas canvas) {
    if (_fallback || animations == null || current == null) {
      final paint = Paint()..color = const Color(0xFFFF8A00);
      final r = Rect.fromCenter(center: Offset.zero, width: 26, height: 26);
      canvas.drawRRect(RRect.fromRectAndRadius(r, const Radius.circular(6)), paint);
      return;
    }
    super.render(canvas);
  }
}

class RoomBox extends PositionComponent with HasGameRef<SaferAdventureGame> {
  Room room;

  Rect? currentLivingGlassRect;

  // Lamp state
  bool lampOn = false;

  // For hazard placement
  Rect? _sidewalkGrassRectForHazard;

  // Room background images
  ui.Image? _livingBgBroken;
  ui.Image? _livingBgClean;

  ui.Image? _frontLawnBgDebris;
  ui.Image? _frontLawnBgClean;

  ui.Image? _sidewalkBg;
  ui.Image? _neighborBg;
  ui.Image? _kitchenBg;
  ui.Image? _basementBg;


  RoomBox({required this.room}) {
    priority = 0;
  }

  List<Rect> _solids = const [];

  @override
  Future<void> onLoad() async {
    size = gameRef.size;
    position = Vector2.zero();
    recomputeSolids();

    void _drawImageIntoInner(Canvas canvas, ui.Image img, Rect inner) {
      final src = Rect.fromLTWH(0, 0, img.width.toDouble(), img.height.toDouble());
      final clip = RRect.fromRectAndRadius(inner, const Radius.circular(10));
      final paint = Paint()
        ..isAntiAlias = false
        ..filterQuality = FilterQuality.none;
      canvas.save();
      canvas.clipRRect(clip);
      canvas.drawImageRect(img, src, inner, paint);
      canvas.restore();
    }
    try {
      _livingBgBroken    = await gameRef.images.load('assets/images/livingRoomBrokenWindow.png');
      _livingBgClean     = await gameRef.images.load('assets/images/livingRoomClean.png');

      _frontLawnBgDebris = await gameRef.images.load('assets/images/frontLawnDebris.png');
      _frontLawnBgClean  = await gameRef.images.load('assets/images/frontLawnClean.png');

      _sidewalkBg        = await gameRef.images.load('assets/images/sidewalk.png');
      _neighborBg        = await gameRef.images.load('assets/images/neighborsHouse.png');
      _kitchenBg         = await gameRef.images.load('assets/images/kitchen.png');
      _basementBg        = await gameRef.images.load('assets/images/basement.png');
    } catch (_) {
    }
  }

  @override
  void onGameResize(Vector2 canvasSize) {
    super.onGameResize(canvasSize);
    size = canvasSize;
    position = Vector2.zero();
    recomputeSolids();
  }

  void recomputeSolids() {
    _solids = _solidsForRoom(room, size);
    (gameRef as SaferAdventureGame).setSolids(_solids);
  }

  @override
  void render(Canvas canvas) {
    final rect = Rect.fromLTWH(0, 0, size.x, size.y);

    // clear per-frame kill-zones; rooms will repopulate as needed
    (gameRef).setKillZones(const []);

    // also clear named solids/kills so they don't leak across rooms
    (gameRef).setNamedSolids(const []);
    (gameRef).setNamedKills(const []);

    switch (room) {
      case Room.living:
        _drawLivingRoom(canvas, rect);
        break;
      case Room.frontLawn:
        _drawFrontLawn(canvas, rect);
        break;
      case Room.sidewalk:
        _drawSidewalk(canvas, rect);
        break;
      case Room.neighbor:
        _drawNeighborLawn(canvas, rect);
        break;
      case Room.kitchen:
        _drawKitchen(canvas, rect);
        break;
      case Room.basement:
        _drawBasement(canvas, rect);
        break;
    }
  }

  // Drawing helpers

  Color _paletteFor(Room r) => switch (r) {
        Room.living    => const Color(0xFF1F2A44),
        Room.basement  => const Color(0xFF161B24),
        Room.frontLawn => const Color(0xFF1F3A1F),
        Room.sidewalk  => const Color(0xFF243240),
        Room.neighbor  => const Color(0xFF1F3A1F),
        Room.kitchen   => const Color(0xFF20314A),
      };

  void _drawBorder(Canvas canvas, Rect rect, Color c) {
    canvas.drawRRect(RRect.fromRectAndRadius(rect, const Radius.circular(12)), Paint()..color = c);
    canvas.drawRRect(RRect.fromRectAndRadius(rect, const Radius.circular(12)), Paint()..color = Colors.white24);
  }

  // Living Room
  void _drawLivingRoom(Canvas canvas, Rect rect) {
    // Local named zones just for this frame
    final namedSolids = <({Rect rect, String name})>[];
    final namedKills  = <({Rect rect, String name})>[];

    // Outer walls/border
    _drawBorder(canvas, rect, const Color(0xFF222B3F));

    // Baseboard inset
    const inset = 14.0;
    final inner = rect.deflate(inset);

    // Choose broken vs clean based on game state
    final game = gameRef;
    final ui.Image? livingImg =
        game._livingGlassPresent ? _livingBgBroken : _livingBgClean;

    // Background image
    if (livingImg != null) {
      final src = Rect.fromLTWH(
        0,
        0,
        livingImg.width.toDouble(),
        livingImg.height.toDouble(),
      );
      final paint = Paint()
        ..isAntiAlias = false
        ..filterQuality = FilterQuality.none;
      final clip = RRect.fromRectAndRadius(inner, const Radius.circular(10));
      canvas.save();
      canvas.clipRRect(clip);
      canvas.drawImageRect(livingImg, src, inner, paint);
      canvas.restore();
    } else {
      canvas.drawRRect(
        RRect.fromRectAndRadius(inner, const Radius.circular(10)),
        Paint()..color = const Color(0xFF3A2E24),
      );
    }

    // Doors
    final topDoorRect = Rect.fromLTWH(size.x / 2 + 66, 18, 58, 32);
    final rightDoorRect = Rect.fromLTWH(size.x - 60, size.y / 2 + 4, 42, 70);
    final bottomDoorRect = Rect.fromLTWH(size.x / 2 - 24, size.y - 50, 48, 30);
    _drawFrontDoor(canvas, topDoorRect);
    _drawInteriorDoorway(canvas, rightDoorRect);
    _drawStairsDown(canvas, bottomDoorRect);

    // Tunables for new layout
    // Broken glass
    bool   L_GLASS_USE_PERCENT = false;
    double L_GLASS_LEFT_PCT  = 0.03;
    double L_GLASS_TOP_PCT   = 0.03;
    double L_GLASS_W_PCT     = 0.22;
    double L_GLASS_H_PCT     = 0.18;
    double L_GLASS_LEFT_PX   = 8.0;
    double L_GLASS_TOP_PX    = 8.0;
    double L_GLASS_WIDTH_PX  = 50.0;
    double L_GLASS_HEIGHT_PX = 35.0;

    // Rug anchor
    double L_RUG_CX_OFFSET   = 10.0;
    double L_RUG_CY_OFFSET   = 28.0;
    double L_RUG_W_FACTOR    = 0.46;
    double L_RUG_H_FACTOR    = 0.34;

    // Lamp relative to rug
    double L_LAMP_RIGHT_PAD  = 52.0;
    double L_LAMP_UP_PAD     = 90.0;

    // rug + lamp

    final rugRect = Rect.fromCenter(
      center: Offset(
        inner.center.dx + L_RUG_CX_OFFSET,
        inner.center.dy + L_RUG_CY_OFFSET,
      ),
      width: inner.width * L_RUG_W_FACTOR,
      height: inner.height * L_RUG_H_FACTOR,
    );

    final lampBase = Offset(
      rugRect.right + L_LAMP_RIGHT_PAD,
      rugRect.top - L_LAMP_UP_PAD,
    );
    _drawFloorLamp(canvas, baseCenter: lampBase, on: lampOn);

    // Broken glass hazard

    final Rect glassRect = L_GLASS_USE_PERCENT
        ? Rect.fromLTWH(
            inner.left + inner.width * L_GLASS_LEFT_PCT,
            inner.top + inner.height * L_GLASS_TOP_PCT,
            inner.width * L_GLASS_W_PCT,
            inner.height * L_GLASS_H_PCT,
          )
        : Rect.fromLTWH(
            inner.left + L_GLASS_LEFT_PX,
            inner.top + L_GLASS_TOP_PX,
            L_GLASS_WIDTH_PX,
            L_GLASS_HEIGHT_PX,
          );

    // Expose to game so sweep hotspots can hug its edges
    currentLivingGlassRect = glassRect;

    if (game._livingGlassPresent) {
      namedKills.add((rect: glassRect, name: 'Broken Glass'));
      // use this as the living-room hazard band
      (gameRef).setKillZones([glassRect]);
    }

    // furniture layout 

    // TV on right wall
    const double TV_W_PCT   = 0.06;
    const double TV_H_PCT   = 0.14;
    const double TV_RIGHT_PX = 1.0;
    const double TV_Y_PCT    = 0.29;

    final double tvW = inner.width * TV_W_PCT;
    final double tvH = inner.height * TV_H_PCT;
    final Rect tvRect = Rect.fromLTWH(
      inner.right - TV_RIGHT_PX - tvW,
      inner.top + inner.height * TV_Y_PCT,
      tvW,
      tvH,
    );
    namedSolids.add((rect: tvRect, name: 'TV Stand'));

    // Main vertical couch on the left
    const double SOFA_W_PCT   = 0.05;
    const double SOFA_H_PCT   = 0.24;
    const double SOFA_LEFT_PCT = 0.13;
    const double SOFA_TOP_PCT  = 0.24;

    final Rect sofaRect = Rect.fromLTWH(
      inner.left + inner.width * SOFA_LEFT_PCT,
      inner.top + inner.height * SOFA_TOP_PCT,
      inner.width * SOFA_W_PCT,
      inner.height * SOFA_H_PCT,
    );
    namedSolids.add((rect: sofaRect, name: 'Couch'));

    // Two love seats (shorter, slightly up + left)
    const double LOVE_W_PCT = 0.26;   // same width
    const double LOVE_H_PCT = 0.04;   // was 0.17 → less tall

    final double loveW = inner.width * LOVE_W_PCT;
    final double loveH = inner.height * LOVE_H_PCT;

    // shift X slightly left, Y slightly up for both
    final Offset loveTopCenter = Offset(
      inner.center.dx - inner.width * 0.04,    // a bit left
      inner.top + inner.height * 0.15,         // was 0.30 → slightly up
    );
    final Offset loveBottomCenter = Offset(
      inner.center.dx - inner.width * 0.04,    // same X shift
      inner.top + inner.height * 0.55,         // was 0.63 → slightly up
    );

    // Recreate rectangles from new centers
    final Rect loveTopRect = Rect.fromCenter(
      center: loveTopCenter,
      width: loveW,
      height: loveH,
    );
    final Rect loveBottomRect = Rect.fromCenter(
      center: loveBottomCenter,
      width: loveW,
      height: loveH,
    );

    // Add to solids
    namedSolids.add((rect: loveTopRect, name: 'Loveseat'));
    namedSolids.add((rect: loveBottomRect, name: 'Loveseat'));


    // Small end tables between couch / love seats
    const double ET_W_PCT = 0.16;
    const double ET_H_PCT = 0.07;
    const double ET_DX    = 0.18; // how far from rug / center horizontally

    final double etW = inner.width * ET_W_PCT;
    final double etH = inner.height * ET_H_PCT;

    // One table just above the couch, one just below.
    // Both centered horizontally on the couch.
    // End tables above and below couch, shifted slightly right
    final Rect topEndTable = Rect.fromCenter(
      center: Offset(
        sofaRect.center.dx + inner.width * 0.05,   // shifted right
        sofaRect.top - etH / 2 - 4,                // above couch
      ),
      width: etW,
      height: etH,
    );

    final Rect bottomEndTable = Rect.fromCenter(
      center: Offset(
        sofaRect.center.dx + inner.width * 0.05,   // shifted right (same as top)
        sofaRect.bottom + etH / 2 + 4,             // below couch
      ),
      width: etW,
      height: etH,
    );

    namedSolids.add((rect: topEndTable, name: 'End Table'));
    namedSolids.add((rect: bottomEndTable, name: 'End Table'));


    // Bookshelf tunables
    const double SHELF_W_PCT      = 0.12;  // wider/narrower
    const double SHELF_H_PCT      = 0.25;  // taller/shorter
    const double SHELF_RIGHT_PAD  = 2.0;   // distance from right wall
    const double SHELF_BOTTOM_PAD = 28.0;  // distance up from bottom

    final double shelfW = inner.width * SHELF_W_PCT;
    final double shelfH = inner.height * SHELF_H_PCT;
    final Rect shelfRect = Rect.fromLTWH(
      inner.right - shelfW - SHELF_RIGHT_PAD,
      inner.bottom - shelfH - SHELF_BOTTOM_PAD,
      shelfW,
      shelfH,
    );
    namedSolids.add((rect: shelfRect, name: 'Bookshelf'));

    // Bottom-left oval table with two chairs
    const double TBL_W_PCT = 0.11;
    const double TBL_H_PCT = 0.14;

    final Offset tableCenter = Offset(
      inner.left + inner.width * 0.20,   // ← left/right
      inner.bottom - inner.height * 0.18 // ← up/down
    );
    final Rect tableRect = Rect.fromCenter(
      center: tableCenter,
      width: inner.width * TBL_W_PCT,
      height: inner.height * TBL_H_PCT,
    );
    namedSolids.add((rect: tableRect, name: 'Dining Table'));

    // Two dining chairs, one on each side of the table
    const double CH_W_PCT   = 0.08;
    const double CH_H_PCT   = 0.08;
    const double CH_DX_PCT  = 0.12; // how far left/right from table center

    final double chW = inner.width * CH_W_PCT;
    final double chH = inner.height * CH_H_PCT;

    final Rect leftChairRect = Rect.fromCenter(
      center: tableCenter.translate(-inner.width * CH_DX_PCT, 0),
      width: chW,
      height: chH,
    );
    final Rect rightChairRect = Rect.fromCenter(
      center: tableCenter.translate(inner.width * CH_DX_PCT, 0),
      width: chW,
      height: chH,
    );
    namedSolids.add((rect: leftChairRect, name: 'Chair'));
    namedSolids.add((rect: rightChairRect, name: 'Chair'));

    // Register for collisions + debug overlay + bump label
    (gameRef).setNamedSolids(namedSolids);
    (gameRef).setNamedKills(namedKills);

    // Light entire room if lamp on
    if (lampOn) {
      final softRoomLight = Paint()
        ..blendMode = BlendMode.plus
        ..color = const Color(0x33FFF7C2);
      canvas.drawRRect(
        RRect.fromRectAndRadius(inner, const Radius.circular(10)),
        softRoomLight,
      );
    }

    // Gentle vignette for depth
    final vignette = Paint()
      ..shader = RadialGradient(
        center: Alignment.topCenter,
        radius: 1.1,
        colors: [Colors.white.withOpacity(0.06), Colors.transparent],
        stops: const [0.0, 1.0],
      ).createShader(inner);
    canvas.drawRRect(
      RRect.fromRectAndRadius(inner, const Radius.circular(10)),
      vignette,
    );
  }


  // Front Lawn
  void _drawFrontLawn(Canvas canvas, Rect rect) {
    _drawBorder(canvas, rect, const Color(0xFF1A2A1A));
    const inset = 14.0;
    final inner = rect.deflate(inset);

    final game = gameRef;
    final ui.Image? lawnImg = game._frontLawnHasDebris ? _frontLawnBgDebris : _frontLawnBgClean;

    if (lawnImg != null) {
      final src = Rect.fromLTWH(0, 0, lawnImg.width.toDouble(), lawnImg.height.toDouble());
      final clip = RRect.fromRectAndRadius(inner, const Radius.circular(10));
      final paint = Paint()
        ..isAntiAlias = false
        ..filterQuality = FilterQuality.none;
      canvas.save();
      canvas.clipRRect(clip);
      canvas.drawImageRect(lawnImg, src, inner, paint);
      canvas.restore();
    } else {
      // Lawn
      final lawn = RRect.fromRectAndRadius(inner, const Radius.circular(10));
      canvas.drawRRect(lawn, Paint()..color = const Color(0xFF2F6E2F));
      // Street + sidewalk band at the top edge
      final streetH = (inner.height * 0.10).clamp(36.0, 64.0);
      final sidewalkH = (streetH * 0.38);
      final streetRect   = Rect.fromLTWH(inner.left, inner.top, inner.width, streetH);
      final sidewalkRect = Rect.fromLTWH(inner.left, inner.top, inner.width, sidewalkH);
      canvas.drawRect(streetRect, Paint()..color = const Color(0xFF2E2E33));
      canvas.drawRect(sidewalkRect, Paint()..color = const Color(0xFFBFC5C8));
      // House band + bottom door visual
      final houseBandH = (inner.height * 0.14).clamp(40.0, 90.0);
      final houseBand = Rect.fromLTWH(inner.left, inner.bottom - houseBandH, inner.width, houseBandH);
      canvas.drawRect(houseBand, Paint()..color = const Color(0xFF3A4458));
      // Stone path
      final bottomDoorRect = Rect.fromLTWH(size.x / 2 - 20, size.y - 48, 40, 28);
      final sidewalkRectForPath = Rect.fromLTWH(inner.left, inner.top, inner.width, sidewalkH);
      final pathPaint = Paint()..color = const Color(0xFFD8D2C8).withOpacity(0.80);
      final pathLeft  = inner.center.dx - 26;
      final pathRight = inner.center.dx + 26;
      final pathTop   = sidewalkRectForPath.bottom + 6;
      final pathBottom= bottomDoorRect.top - 4;
      final pathRect  = RRect.fromRectAndRadius(
        Rect.fromLTRB(pathLeft, pathTop, pathRight, pathBottom),
        const Radius.circular(18),
      );
      canvas.drawRRect(pathRect, pathPaint);
    }

    // Door overlays
    final trDoorRect = Rect.fromLTWH(size.x - 80, 60, 60, 24);
    canvas.drawRRect( 
      RRect.fromRectAndRadius(trDoorRect.inflate(2), const Radius.circular(6)),
      Paint()..color = Colors.white.withOpacity(0.12),
    );
    final bottomDoorRect = Rect.fromLTWH(size.x / 2 - 24, size.y - 210, 48, 30,);
    canvas.drawRRect(
      RRect.fromRectAndRadius(bottomDoorRect, const Radius.circular(6)),
      Paint()..color = Colors.white.withOpacity(0.10),
    );
    canvas.drawRRect(
      RRect.fromRectAndRadius(bottomDoorRect.deflate(2), const Radius.circular(5)),
      Paint()
        ..color = const Color(0xFF252D3A).withValues(
          alpha: 0.24,
        ),
    );

    // Collision solids
    final namedSolids = <({Rect rect, String name})>[];

    // Left tree 
    final leftTreeRect = Rect.fromCircle(
      center: Offset(
        inner.left + inner.width * 0.20,
        inner.top + inner.height * 0.55,
      ),
      radius: inner.width * 0.08,
    );
    namedSolids.add((rect: leftTreeRect, name: 'Tree'));

    // Right tree – higher middle
    final rightTreeRect = Rect.fromCircle(
      center: Offset(
        inner.left + inner.width * 0.77,
        inner.top + inner.height * 0.33,
      ),
      radius: inner.width * 0.08,
    );
    namedSolids.add((rect: rightTreeRect, name: 'Tree'));

    // Bottom bushes + house front
    final double bushBandHeight = inner.height * 0.13;
    final double gapHalfWidth   = inner.width * 0.26; 
    const double HOUSE_VERTICAL_OFFSET = -16.0;
    final double bushTop    = inner.bottom - bushBandHeight - 88.0;
    final double bushBottom = inner.bottom - 30.0;

    // Left bushes
    final Rect leftBushes = Rect.fromLTRB(
      inner.left,
      bushTop,
      inner.center.dx - gapHalfWidth,
      bushBottom,
    );
    namedSolids.add((rect: leftBushes, name: 'Bushes'));

    // Right bushes
    final Rect rightBushes = Rect.fromLTRB(
      inner.center.dx + gapHalfWidth,
      bushTop,
      inner.right,
      bushBottom,
    );
    namedSolids.add((rect: rightBushes, name: 'Bushes'));

    // House
    final Rect houseFront = Rect.fromLTRB(
      leftBushes.right + 4.0,
      bushTop + HOUSE_VERTICAL_OFFSET,      // move top upward
      rightBushes.left - 4.0,
      bushBottom + HOUSE_VERTICAL_OFFSET,   // move bottom upward too
    );
    namedSolids.add((rect: houseFront, name: 'House'));

    // Register so collisions + bump label work
    game.setNamedSolids(namedSolids);

    // Soft vignette
    final vignette = Paint()
      ..shader = RadialGradient(
        center: Alignment.center,
        radius: 1.2,
        colors: [Colors.white.withOpacity(0.05), Colors.transparent],
        stops: const [0.0, 1.0],
      ).createShader(inner);
    canvas.drawRRect(RRect.fromRectAndRadius(inner, const Radius.circular(10)), vignette);
  }

  // Sidewalk
  void _drawSidewalk(Canvas canvas, Rect rect) {
    _drawBorder(canvas, rect, const Color(0xFF1E2B38));
    const inset = 14.0;
    final inner = rect.deflate(inset);

    final game = gameRef;
    final namedSolids = <({Rect rect, String name})>[];

    // Shared geometry
    final double streetH = (inner.height * 0.24).clamp(56.0, 120.0);
    final double grassH  = (inner.height * 0.30).clamp(70.0, 160.0);
    final double pathH   = inner.height - streetH - grassH;

    final Rect streetRect = Rect.fromLTWH(inner.left, inner.top, inner.width, streetH);
    final Rect pathRect   = Rect.fromLTWH(inner.left, streetRect.bottom, inner.width, pathH);
    final Rect grassRect  = Rect.fromLTWH(inner.left, pathRect.bottom, inner.width, grassH);

    _sidewalkGrassRectForHazard = grassRect;

    // Background
    if (_sidewalkBg != null) {
      final src = Rect.fromLTWH(
        0,
        0,
        _sidewalkBg!.width.toDouble(),
        _sidewalkBg!.height.toDouble(),
      );
      final clip = RRect.fromRectAndRadius(inner, const Radius.circular(10));
      final paint = Paint()
        ..isAntiAlias = false
        ..filterQuality = FilterQuality.none;
      canvas.save();
      canvas.clipRRect(clip);
      canvas.drawImageRect(_sidewalkBg!, src, inner, paint);
      canvas.restore();
    } else {
      canvas.drawRect(streetRect, Paint()..color = const Color(0xFF2E2E33));
      canvas.drawRect(pathRect,   Paint()..color = const Color(0xFFBFC5C8));
      final joint = Paint()
        ..color = Colors.black.withOpacity(0.12)
        ..strokeWidth = 2;
      for (double x = pathRect.left + 24; x < pathRect.right; x += 48) {
        canvas.drawLine(
          Offset(x, pathRect.top + 4),
          Offset(x, pathRect.bottom - 4),
          joint,
        );
      }
      canvas.drawRect(grassRect, Paint()..color = const Color(0xFF2F6E2F));
    }

    // Draw leaky fire hydrant
    {
      // Position roughly matched to hotspot band
      final Offset hydrantCenter = Offset(
        pathRect.left + pathRect.width * 0.70,
        grassRect.top - 130,
      );

      final Paint hydrantPaint = Paint()..color = const Color(0xFFB71C1C);
      final Paint metalPaint   = Paint()..color = const Color(0xFF5D4037);
      final Paint waterPaint   = Paint()..color = const Color(0xAA4FC3F7);

      // Body
      final Rect body = Rect.fromCenter(
        center: hydrantCenter.translate(0, 4),
        width: 18,
        height: 28,
      );
      canvas.drawRRect(
        RRect.fromRectAndRadius(body, const Radius.circular(4)),
        hydrantPaint,
      );

      // Top cap
      final Rect cap = Rect.fromCenter(
        center: hydrantCenter.translate(0, -10),
        width: 22,
        height: 10,
      );
      canvas.drawRRect(
        RRect.fromRectAndRadius(cap, const Radius.circular(4)),
        hydrantPaint,
      );

      // Side nozzles
      final Rect leftNozzle = Rect.fromCenter(
        center: hydrantCenter.translate(-14, 0),
        width: 10,
        height: 8,
      );
      final Rect rightNozzle = Rect.fromCenter(
        center: hydrantCenter.translate(14, 0),
        width: 10,
        height: 8,
      );
      canvas.drawRRect(
        RRect.fromRectAndRadius(leftNozzle, const Radius.circular(3)),
        hydrantPaint,
      );
      canvas.drawRRect(
        RRect.fromRectAndRadius(rightNozzle, const Radius.circular(3)),
        hydrantPaint,
      );

      // Bolts
      canvas.drawCircle(
        hydrantCenter.translate(-14, 0),
        2,
        metalPaint,
      );
      canvas.drawCircle(
        hydrantCenter.translate(14, 0),
        2,
        metalPaint,
      );

      // Water puddle only if the leak is still active
      if (game.hydrantLeaking) {
        final Rect puddle = Rect.fromCenter(
          center: hydrantCenter.translate(10, 18),
          width: 26,
          height: 10,
        );
        canvas.drawRRect(
          RRect.fromRectAndRadius(puddle, const Radius.circular(6)),
          waterPaint,
        );
      }
      // Fire Hydrant Collision Dead Zone
      final double hydrantDZ_W = 40.0;
      final double hydrantDZ_H = 40.0;

      final Rect hydrantDZ = Rect.fromCenter(
        center: hydrantCenter,
        width: hydrantDZ_W,
        height: hydrantDZ_H,
      );
      namedSolids.add((rect: hydrantDZ, name: 'Hydrant'));
    }


    // Door overlays (moved up to match functional doors)
    final leftDoorRect  = Rect.fromLTWH(16, size.y * 0.30, 40, 40);
    final rightDoorRect = Rect.fromLTWH(size.x - 56, size.y * 0.30, 40, 40);
    for (final r in [leftDoorRect, rightDoorRect]) {
      canvas.drawRRect(
        RRect.fromRectAndRadius(r, const Radius.circular(8)),
        Paint()..color = Colors.white.withOpacity(0.10),
      );
    }


    // road dead zone
    final Rect roadRect = Rect.fromLTRB(
      rect.left,
      rect.top,
      rect.right,
      leftDoorRect.top - 8,
    );
    namedSolids.add((rect: roadRect, name: 'Road'));

    // Smaller hazard kill zone + fence dead zone 
    if (game.sidewalkDownedLine) {
      _drawDownedLine(canvas, grassRect);
    }

    // Smaller kill band directly under the wire, not the whole grass
    final double lethalLeft   = grassRect.left + grassRect.width * 0.15;
    final double lethalRight  = grassRect.right - grassRect.width * 0.12;
    final double lethalTop    = grassRect.top + grassRect.height * 0.24;
    final double lethalBottom = grassRect.top + grassRect.height * 0.50;

    final Rect lethal = Rect.fromLTRB(
      lethalLeft,
      lethalTop,
      lethalRight,
      lethalBottom,
    );

    if (game.sidewalkDownedLine) {
      game.setKillZones([lethal]);

      if (game.debugZones) {
        final dbg = Paint()
          ..style = PaintingStyle.stroke
          ..strokeWidth = 2
          ..color = const Color(0xFFFFB300).withOpacity(0.95);
        canvas.drawRect(lethal, dbg);
      }
    }

    // Fence dead zone: everything directly under the kill zone
    final Rect fenceRect = Rect.fromLTRB(
      grassRect.left, 
      lethalBottom + 8.0,
      grassRect.right,
      grassRect.bottom,
    );
    namedSolids.add((rect: fenceRect, name: 'Fence'));

    // Register named solids so collision + debug overlay know about the fence & road
    game.setNamedSolids(namedSolids);
  }

  void _drawDownedLine(Canvas canvas, Rect grassRect) {
    final path = Path();
    final left = grassRect.left + grassRect.width * 0.15;
    final right = grassRect.right - grassRect.width * 0.12;
    final midY = grassRect.top + grassRect.height * 0.35;

    path.moveTo(left, midY);
    final segments = 6;
    final dx = (right - left) / segments;
    for (int i = 0; i <= segments; i++) {
      final x = left + dx * i;
      final y = midY + (i.isOdd ? 16 : -12);
      path.lineTo(x, y);
    }
    final cable = Paint()
      ..color = const Color(0xFF111111)
      ..strokeWidth = 4
      ..style = PaintingStyle.stroke;
    canvas.drawPath(path, cable);

    // Little yellow "⚠" sign
    final signRect = RRect.fromRectAndRadius(
      Rect.fromCenter(center: Offset(left + 24, midY - 26), width: 18, height: 14),
      const Radius.circular(3),
    );
    canvas.drawRRect(signRect, Paint()..color = const Color(0xFFE9C46A));
    final tp = TextPainter(
      text: const TextSpan(text: '⚠', style: TextStyle(fontSize: 12, color: Colors.black)),
      textDirection: TextDirection.ltr,
    )..layout();
    tp.paint(canvas, Offset(signRect.outerRect.center.dx - tp.width / 2, signRect.outerRect.center.dy - tp.height / 2));
  }

  // Neighbor
  void _drawNeighborLawn(Canvas canvas, Rect rect) {
    _drawBorder(canvas, rect, const Color(0xFF1A2A1A));
    const inset = 14.0;
    final inner = rect.deflate(inset);

    final game = gameRef;

    final namedSolids = <({Rect rect, String name})>[];

    // Background image
    if (_neighborBg != null) {
      final src = Rect.fromLTWH(
        0,
        0,
        _neighborBg!.width.toDouble(),
        _neighborBg!.height.toDouble(),
      );
      final clip = RRect.fromRectAndRadius(inner, const Radius.circular(10));
      final paint = Paint()
        ..isAntiAlias = false
        ..filterQuality = FilterQuality.none;
      canvas.save();
      canvas.clipRRect(clip);
      canvas.drawImageRect(_neighborBg!, src, inner, paint);
      canvas.restore();
    } else {
      canvas.drawRRect(
        RRect.fromRectAndRadius(inner, const Radius.circular(10)),
        Paint()..color = const Color(0xFF2B6A2B),
      );
      final houseBandH =
          (inner.height * 0.14).clamp(40.0, 90.0);
      final house = Rect.fromLTWH(
        inner.left,
        inner.bottom - houseBandH,
        inner.width,
        houseBandH,
      );
      canvas.drawRect(
        house,
        Paint()..color = const Color(0xFF454F63),
      );
    }

    // door to sidewalk
    final leftDoorRect = Rect.fromLTWH(
      16,
      game.size.y * 0.34,
      40,
      40,
    );
    canvas.drawRRect(
      RRect.fromRectAndRadius(leftDoorRect, const Radius.circular(8)),
      Paint()..color = Colors.white.withOpacity(0.10),
    );

    // bottom door visual
    final bottomDoorRect = Rect.fromLTWH(
      game.size.x / 2 - 20,
      game.size.y - 210,
      40,
      28,
    );
    canvas.drawRRect(
      RRect.fromRectAndRadius(bottomDoorRect, const Radius.circular(6)),
      Paint()..color = Colors.white.withOpacity(0.12),
    );

    // Bottom bushes + house front
    final double bushBandHeight = inner.height * 0.13;
    final double gapHalfWidth   = inner.width * 0.26; 
    const double HOUSE_VERTICAL_OFFSET = -16.0;

    final double bushTop    = inner.bottom - bushBandHeight - 88.0;
    final double bushBottom = inner.bottom - 30.0;

    // Left bushes
    final Rect leftBushes = Rect.fromLTRB(
      inner.left,
      bushTop,
      inner.center.dx - gapHalfWidth,
      bushBottom,
    );
    namedSolids.add((rect: leftBushes, name: 'Bushes'));

    // Right bushes
    final Rect rightBushes = Rect.fromLTRB(
      inner.center.dx + gapHalfWidth,
      bushTop,
      inner.right,
      bushBottom,
    );
    namedSolids.add((rect: rightBushes, name: 'Bushes'));

    // House
    final Rect houseFront = Rect.fromLTRB(
      leftBushes.right + 4.0,
      bushTop + HOUSE_VERTICAL_OFFSET,
      rightBushes.left - 4.0,
      bushBottom + HOUSE_VERTICAL_OFFSET,
    );
    namedSolids.add((rect: houseFront, name: 'House'));

    // tree log dead zone
    final double logW = inner.width * 0.24;
    final double logH = inner.height * 0.07;

    final double logCx = inner.left + inner.width * 0.20; 
    final double logCy = inner.top  + inner.height * 0.38;

    final Rect treeLog = Rect.fromCenter(
      center: Offset(logCx, logCy),
      width: logW,
      height: logH,
    );

    namedSolids.add((rect: treeLog, name: 'Tree Log'));

    // Register collision solids (bushes + log)
    game.setNamedSolids(namedSolids);
  }

  // Kitchen
  void _drawKitchen(Canvas canvas, Rect rect) {
    _drawBorder(canvas, rect, const Color(0xFF223249));
    const inset = 14.0;
    final inner = rect.deflate(inset);

    if (_kitchenBg != null) {
      final src = Rect.fromLTWH(0, 0, _kitchenBg!.width.toDouble(), _kitchenBg!.height.toDouble());
      final paint = Paint()..isAntiAlias = false..filterQuality = FilterQuality.none;
      final clip = RRect.fromRectAndRadius(inner, const Radius.circular(10));
      canvas.save(); canvas.clipRRect(clip);
      canvas.drawImageRect(_kitchenBg!, src, inner, paint);
      canvas.restore();
    } else {
      canvas.drawRRect(
        RRect.fromRectAndRadius(inner, const Radius.circular(10)),
        Paint()..color = const Color(0xFFCBD4DD),
      );
    }

    // Door to Living
    final doorRect = Rect.fromLTWH(16, size.y / 2 - 8, 40, 40);
    canvas.drawRRect(
      RRect.fromRectAndRadius(doorRect, const Radius.circular(10)),
      Paint()..color = Colors.white.withOpacity(0.26),
    );

    // collision solids
    final List<({Rect rect, String name})> namedSolids = [];

    const double rightPad = 8.0;
    final double rightEdge = inner.right - rightPad;

    // Heights as proportions of the inner height
    final double topCounterH = inner.height * 0.19;
    final double ovenH       = inner.height * 0.20;
    final double sinkH       = inner.height * 0.20;

    // how far they stick out from the wall
    const double topCounterDepth = 70.0;
    const double ovenDepth       = 84.0;
    const double sinkDepth       = 80.0;
    const double fridgeDepth     = 100.0;

    const double WALL_TOP_OFFSET = 16.0;
    double wallY = inner.top + WALL_TOP_OFFSET; 

    // Top built-in counter / cabinets
    const double COUNTER_VISUAL_OFFSET = -16.0;
    const double COUNTER_EXTRA_HEIGHT  = 120.0;

    final double counterY = wallY + COUNTER_VISUAL_OFFSET;

    final Rect wallCounterRect = Rect.fromLTWH(
      rightEdge - topCounterDepth,
      counterY,
      topCounterDepth,
      topCounterH + COUNTER_EXTRA_HEIGHT,
    );
    namedSolids.add((rect: wallCounterRect, name: 'Counter'));

    wallY += topCounterH;

    const double OVEN_VISUAL_OFFSET = 108.0;

    final double ovenY = wallY + OVEN_VISUAL_OFFSET;

    final Rect ovenRect = Rect.fromLTWH(
      rightEdge - ovenDepth,
      ovenY,
      ovenDepth,
      ovenH,
    );
    namedSolids.add((rect: ovenRect, name: 'Oven'));

    wallY += ovenH;

    // SINK
    const double SINK_VERTICAL_OFFSET = 120.0;

    final Rect sinkRect = Rect.fromLTWH(
      rightEdge - sinkDepth,
      wallY + SINK_VERTICAL_OFFSET,
      sinkDepth,
      sinkH,
    );
    namedSolids.add((rect: sinkRect, name: 'Sink'));

    // Fridge
    const double FRIDGE_HEIGHT = 95.0;
    const double FRIDGE_BOTTOM_PAD = 6.0;
    const double FRIDGE_DEPTH = 95.0;

    final double fridgeRight  = rightEdge;
    final double fridgeBottom = inner.bottom - FRIDGE_BOTTOM_PAD;
    final double fridgeTop    = fridgeBottom - FRIDGE_HEIGHT;

    final Rect fridgeRect = Rect.fromLTWH(
      fridgeRight - FRIDGE_DEPTH,
      fridgeTop,
      FRIDGE_DEPTH,
      FRIDGE_HEIGHT,
    );
    namedSolids.add((rect: fridgeRect, name: 'Fridge'));

    // kitchen island + 3 stools on the LEFT side
    const double BL_ISLAND_WIDTH      = 48.0;
    const double BL_ISLAND_HEIGHT     = 144.0;
    const double BL_ISLAND_BOTTOM_PAD = 0.0; 

    // Keep the same left anchor so it stays in the same column
    final double islandLeft = inner.left + inner.width * 0.14;
    final Rect blIsland = Rect.fromLTWH(
      islandLeft,
      inner.bottom - BL_ISLAND_HEIGHT - BL_ISLAND_BOTTOM_PAD,
      BL_ISLAND_WIDTH,
      BL_ISLAND_HEIGHT,
    );
    namedSolids.add((rect: blIsland, name: 'Kitchen Island'));

    // Vertical stools island
    const int    BL_STOOL_COUNT    = 3;
    const double BL_STOOL_W        = 28.0;
    const double BL_STOOL_H        = 24.0;
    const double BL_STOOL_GAP_Y    = 22.0;
    const double BL_STOOL_LEFT_DX  = 8.0;
    const double BL_STOOL_TOP_PAD  = 10.0;

    double stoolX = blIsland.left - BL_STOOL_LEFT_DX - BL_STOOL_W;
    double stoolY = blIsland.top + BL_STOOL_TOP_PAD;

    for (int i = 0; i < BL_STOOL_COUNT; i++) {
      final Rect stool = Rect.fromLTWH(
        stoolX,
        stoolY + i * (BL_STOOL_H + BL_STOOL_GAP_Y),
        BL_STOOL_W,
        BL_STOOL_H,
      );
      namedSolids.add((rect: stool, name: 'Bar Stool'));
    }

    // top left dining table + chairs
    const double TBL_ANCHOR_LEFT_PCT  = 0.27;
    const double TBL_ANCHOR_TOP_PCT   = 0.22;
    const double TBL_WIDTH_PCT        = 0.27;
    const double TBL_HEIGHT_PX        = 132.0;

    const double TBL_DX_PX            = -10.0;
    const double TBL_DY_PX            = -12.0;

    const int    SIDE_CHAIRS_PER_COL  = 3;
    const double CH_WIDTH_PX          = 24.0;
    const double CH_HEIGHT_PX         = 20.0;

    // compute table rect from inner room rect
    final Rect _kInner = inner;
    final double tblW  = _kInner.width * TBL_WIDTH_PCT;
    final double tblH  = TBL_HEIGHT_PX;

    final Offset tblCenter = Offset(
      _kInner.left + _kInner.width  * TBL_ANCHOR_LEFT_PCT + tblW * 0.5 + TBL_DX_PX,
      _kInner.top  + _kInner.height * TBL_ANCHOR_TOP_PCT  + TBL_DY_PX,
    );

    final Rect tableRect = Rect.fromCenter(center: tblCenter, width: tblW, height: tblH);
    namedSolids.add((rect: tableRect, name: 'Dining Table'));

    // Helper to build a chair rect by center
    Rect _chairAt(double cx, double cy) => Rect.fromCenter(
          center: Offset(cx, cy),
          width: CH_WIDTH_PX,
          height: CH_HEIGHT_PX,
        );

    // SIDE CHAIRS
    final double sideTopY = tableRect.top + CH_HEIGHT_PX / 2 + 12;
    final double sideBottomY = tableRect.bottom - CH_HEIGHT_PX / 2;
    final double sideStepY   =
        (sideBottomY - sideTopY) / (SIDE_CHAIRS_PER_COL - 1) * 0.75 ;

    for (int i = 0; i < SIDE_CHAIRS_PER_COL; i++) {
      final double cy = sideTopY + i * sideStepY;

      // left column chairs
      final double leftCx = tableRect.left - CH_WIDTH_PX / 2;
      namedSolids.add((rect: _chairAt(leftCx, cy), name: 'Chair'));

      // right columnm chairs
      final double rightCx = tableRect.right + CH_WIDTH_PX / 2;
      namedSolids.add((rect: _chairAt(rightCx, cy), name: 'Chair'));
    }

    // TOP center chair
    final double topCx = tableRect.center.dx;
    final double topCy = tableRect.top - CH_HEIGHT_PX / 2;
    namedSolids.add((rect: _chairAt(topCx, topCy), name: 'Chair'));

    // BOTTOM center chair
    final double bottomCx = tableRect.center.dx;
    final double bottomCy = tableRect.bottom + CH_HEIGHT_PX / 2;
    namedSolids.add((rect: _chairAt(bottomCx, bottomCy), name: 'Chair'));

    // debug outlines
    if ((gameRef).debugZones) {
      final p = Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2
        ..color = const Color(0xFFFF4081).withOpacity(0.85);
      for (final z in namedSolids) {
        canvas.drawRect(z.rect, p);
      }
    }

    // Register as named solids so the bump label shows
    (gameRef).setNamedSolids(namedSolids);


    // Soft vignette
    final vignette = Paint()
      ..shader = RadialGradient(
        center: Alignment.topCenter,
        radius: 1.25,
        colors: [Colors.white.withOpacity(0.05), Colors.transparent],
        stops: const [0.0, 1.0],
      ).createShader(inner);
    canvas.drawRRect(RRect.fromRectAndRadius(inner, const Radius.circular(10)), vignette);
  }

  // Basement
  void _drawBasement(Canvas canvas, Rect rect) {
    _drawBorder(canvas, rect, const Color(0xFF151C27));
    const inset = 14.0;
    final inner = rect.deflate(inset);

    // Local, named zones for this room
    final namedSolids = <({Rect rect, String name})>[];
    final namedKills  = <({Rect rect, String name})>[];

    // Background image
    if (_basementBg != null) {
      final src  = Rect.fromLTWH(0, 0, _basementBg!.width.toDouble(), _basementBg!.height.toDouble());
      final clip = RRect.fromRectAndRadius(inner, const Radius.circular(10));
      final paint = Paint()..isAntiAlias = false..filterQuality = FilterQuality.none;
      canvas.save();
      canvas.clipRRect(clip);
      canvas.drawImageRect(_basementBg!, src, inner, paint);
      canvas.restore();
    } else {
      canvas.drawRRect(
        RRect.fromRectAndRadius(inner, const Radius.circular(10)),
        Paint()..color = const Color(0xFF263141),
      );
    }

    // Top door
    final topDoorRect = Rect.fromLTWH(size.x / 2 + 20, 20, 40, 28);
    _drawStairsUp(canvas, topDoorRect);

    // Flooded water overlay / kill zone
    final game = gameRef;
    if (game.basementFlooded) {
      final waterRect = Rect.fromLTWH(
        inner.left + 8,
        inner.center.dy,
        inner.width - 16,
        inner.height * 0.45,
      );

      // water fill
      canvas.drawRRect(
        RRect.fromRectAndRadius(waterRect, const Radius.circular(8)),
        Paint()..color = const Color(0x6633A6FF),
      );

      // ripples
      final ripple = Paint()
        ..color = const Color(0x99B4DAFF)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.5;
      for (double y = waterRect.top + 8; y < waterRect.bottom; y += 12) {
        canvas.drawArc(
          Rect.fromCenter(center: Offset(waterRect.center.dx, y), width: waterRect.width * 0.7, height: 12),
          0, math.pi, false, ripple,
        );
      }

      // register named kill and raw kill zone
      final Rect waterKill = Rect.fromLTWH(
        waterRect.left,
        waterRect.top + 4,
        waterRect.width,
        waterRect.height - 8,
      );
      namedKills.add((rect: waterKill, name: 'Flooded Water'));
      (gameRef).setKillZones([waterKill]);
    }

    // Basement collision solids

    // Electrical panel
    final Rect electricalBoxRect = Rect.fromLTWH(
      inner.left + 10, 
      inner.bottom - 125, 
      80,
      75,
    );
    namedSolids.add((rect: electricalBoxRect, name: 'Electrical Panel'));

    // Single cardboard box
    final Rect singleBoxRect = Rect.fromLTWH(
      inner.left + 15,
      inner.top + inner.height * 0.43,
      82,
      62,
    );
    namedSolids.add((rect: singleBoxRect, name: 'Box'));

    // Stool
    final Rect stoolRect = Rect.fromCenter(
      center: Offset(inner.left + inner.width * 0.18, inner.top + inner.height * 0.18),
      width: 50,
      height: 40,
    );
    namedSolids.add((rect: stoolRect, name: 'Stool'));

    // Rolled rug
    final Rect rugRect = Rect.fromCenter(
      center: Offset(inner.right - inner.width * 0.07, inner.top + inner.height * 0.23),
      width: 35,
      height: 100,
    );
    namedSolids.add((rect: rugRect, name: 'Rolled Rug'));

    // Boxes group
    // Tunables
    double BX_ANCHOR_RIGHT = 90;
    double BX_ANCHOR_BOTTOM = 185;
    double BX_W = 70;
    double BX_H = 50; 
    double BX_GAP = 1; 

    bool H_ON_LEFT = true;

    // Compute anchor for the bottom box of the vertical column
    final double colX = inner.right - BX_ANCHOR_RIGHT;
    final double colY = inner.bottom - BX_ANCHOR_BOTTOM;

    // Vertical column: bottom and top boxes
    final Rect boxBottom = Rect.fromLTWH(colX, colY, BX_W, BX_H);
    final Rect boxTop    = Rect.fromLTWH(colX, colY - BX_H - BX_GAP, BX_W, BX_H);

    // Horizontal box at the bottom of the L
    final double horizX = H_ON_LEFT
        ? (colX - BX_GAP - BX_W) 
        : (colX + BX_W + BX_GAP); 
    final Rect boxSide  = Rect.fromLTWH(horizX, colY, BX_W, BX_H);

    // Add all three with the same display name
    namedSolids.add((rect: boxBottom, name: 'Boxes'));
    namedSolids.add((rect: boxTop,    name: 'Boxes'));
    namedSolids.add((rect: boxSide,   name: 'Boxes'));


    // debug outlines
    if ((gameRef).debugZones) {
      final solidP = Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2
        ..color = const Color(0xFF00E5FF).withOpacity(0.9);
      for (final s in namedSolids) { canvas.drawRect(s.rect, solidP); }

      final killP = Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2
        ..color = const Color(0xFFF44336);
      for (final k in namedKills) { canvas.drawRect(k.rect, killP); }
    }

    // Register for collision + labels
    (gameRef).setNamedSolids(namedSolids);
    (gameRef).setNamedKills(namedKills);

    // Vignette for mood
    final vignette = Paint()
      ..shader = RadialGradient(
        center: Alignment.bottomCenter,
        radius: 1.4,
        colors: [Colors.white.withOpacity(0.04), Colors.transparent],
        stops: const [0.0, 1.0],
      ).createShader(inner);
    canvas.drawRRect(RRect.fromRectAndRadius(inner, const Radius.circular(10)), vignette);
  }
}

  // Shared small drawing bits

  List<Rect> _solidsForRoom(Room r, Vector2 size) {
    if (r == Room.living) return const [];
    return const [];
  }

  void _drawFrontDoor(Canvas canvas, Rect doorRect) {
    final opening = RRect.fromRectAndRadius(doorRect.inflate(2.0), const Radius.circular(8));
    canvas.drawRRect(opening, Paint()..color = Colors.white.withOpacity(0.10));
    final slab = RRect.fromRectAndRadius(
      Rect.fromLTWH(doorRect.left + 2, doorRect.top + 3, doorRect.width - 4, doorRect.height - 6),
      const Radius.circular(5),
    );
    canvas.drawRRect(slab, Paint()..color = const Color(0xFF39485C));
    final panelPaint = Paint()..color = const Color(0xFF2F3B4D);
    final p1 = RRect.fromRectAndRadius(
      Rect.fromLTWH(slab.outerRect.left + 6, slab.outerRect.top + 6, 14, slab.outerRect.height - 14),
      const Radius.circular(3),
    );
    final p2 = RRect.fromRectAndRadius(
      Rect.fromLTWH(slab.outerRect.right - 20, slab.outerRect.top + 6, 14, slab.outerRect.height - 14),
      const Radius.circular(3),
    );
    canvas.drawRRect(p1, panelPaint);
    canvas.drawRRect(p2, panelPaint);
    canvas.drawCircle(
      Offset(slab.outerRect.right - 8, slab.outerRect.center.dy),
      2,
      Paint()..color = const Color(0xFFB8C6D9),
    );
  }

  void _drawInteriorDoorway(Canvas canvas, Rect doorRect) {
    final arch = RRect.fromRectAndRadius(doorRect, const Radius.circular(10));
    canvas.drawRRect(arch, Paint()..color = Colors.white.withOpacity(0.12));
    canvas.drawRRect(
      RRect.fromRectAndRadius(doorRect.deflate(3), const Radius.circular(8)),
      Paint()..color = Colors.white.withOpacity(0.18),
    );
  }

  void _drawStairsDown(Canvas canvas, Rect doorRect) {
    final opening = RRect.fromRectAndRadius(doorRect, const Radius.circular(8));
    canvas.drawRRect(opening, Paint()..color = Colors.black.withOpacity(0.25));
    const steps = 5;
    final stepH = (doorRect.height - 8.0) / steps;
    for (int i = 0; i < steps; i++) {
      final r = Rect.fromLTWH(
        doorRect.left + 5.0 + i * 2.2,
        doorRect.top + 4.0 + i * stepH,
        doorRect.width - 10.0 - i * 4.4,
        stepH - 1.2,
      );
      canvas.drawRect(r, Paint()..color = const Color(0xFF2E3B4E));
      canvas.drawLine(
        Offset(r.left, r.bottom),
        Offset(r.right, r.bottom),
        Paint()
          ..color = Colors.black26
          ..strokeWidth = 1,
      );
    }
    canvas.drawLine(
      Offset(doorRect.left + 4.0, doorRect.top + 3.0),
      Offset(doorRect.right - 4.0, doorRect.bottom - 3.0),
      Paint()
        ..color = Colors.white24
        ..strokeWidth = 1.2,
    );
  }

  void _drawStairsUp(Canvas canvas, Rect doorRect) {
    // Visual cue for stairs going up
    final opening = RRect.fromRectAndRadius(doorRect, const Radius.circular(8));
    canvas.drawRRect(opening, Paint()..color = Colors.black.withOpacity(0.18));
    const steps = 5;
    final stepH = (doorRect.height - 8.0) / steps;
    for (int i = 0; i < steps; i++) {
      final r = Rect.fromLTWH(
        doorRect.left + 5.0 + (steps - i - 1) * 2.2,
        doorRect.top + 4.0 + i * stepH,
        doorRect.width - 10.0 - (steps - i - 1) * 4.4,
        stepH - 1.2,
      );
      canvas.drawRect(r, Paint()..color = const Color(0xFF405067));
      canvas.drawLine(Offset(r.left, r.top), Offset(r.right, r.top), Paint()..color = Colors.white24..strokeWidth = 1);
    }
  }

  void _drawFloorLamp(Canvas canvas, {required Offset baseCenter, required bool on}) {
    // base
    canvas.drawCircle(baseCenter, 6.0, Paint()..color = const Color(0xFF5A5A5A));
    // pole
    canvas.drawRect(
      Rect.fromLTWH(baseCenter.dx - 1.0, baseCenter.dy - 46.0, 2.0, 40.0),
      Paint()..color = const Color(0xFF7A7A7A),
    );
    // shade
    final shade = RRect.fromRectAndRadius(
      Rect.fromCenter(center: Offset(baseCenter.dx, baseCenter.dy - 54.0), width: 26.0, height: 18.0),
      const Radius.circular(6),
    );
    canvas.drawRRect(shade, Paint()..color = on ? const Color(0xFFFFE38A) : const Color(0xFF3F3F45));

    // modest local glow when on 
    if (on) {
      final glow = Paint()
        ..shader = RadialGradient(
          colors: [const Color(0x80FFF3B0), const Color(0x00FFF3B0)],
          stops: const [0, 1],
          radius: 1.0,
        ).createShader(Rect.fromCenter(center: shade.outerRect.center, width: 120, height: 120));
      canvas.drawCircle(shade.outerRect.center, 70, glow);
    } else {
      final faint = Paint()
        ..shader = RadialGradient(
          colors: [const Color(0x00FFFFCC), const Color(0x00000000)],
          stops: const [0, 1],
          radius: 0.7,
        ).createShader(shade.outerRect);
      canvas.drawRRect(shade, faint);
    }
  }

class Doorway extends PositionComponent with HasGameRef<SaferAdventureGame> {
  final Rect rect;
  final String label;
  final Future<void> Function() onEnter;
  final Color? color;
  final Color? textColor;


  Doorway({
    required this.rect,
    required this.label,
    required this.onEnter,
    this.color,
    this.textColor,
  }) {
    position = Vector2(rect.left, rect.top);
    size = Vector2(rect.width, rect.height);
    priority = 6;
  }

  @override
  void render(Canvas canvas) {
    // Background color
    final bgColor = color ?? Colors.white.withOpacity(0.10);
    final p = Paint()..color = bgColor;

    final r = Rect.fromLTWH(0, 0, size.x, size.y);
    canvas.drawRRect(RRect.fromRectAndRadius(r, const Radius.circular(6)), p);

    final labelColor = textColor ?? Colors.white.withOpacity(0.97);

    final tp = TextPainter(
      text: TextSpan(
        text: label,
        style: TextStyle(
          color: labelColor,
          fontSize: 11,
          fontWeight: FontWeight.w700,
        ),
      ),
      textDirection: TextDirection.ltr,
    )..layout(maxWidth: size.x + 80);

    tp.paint(canvas, const Offset(-18, -14));
  }

  @override
  void update(double dt) {
    super.update(dt);

    // Keep geometry synced with the logical rect every frame
    position = Vector2(rect.left, rect.top);
    size = Vector2(rect.width, rect.height);

    final game = gameRef;

    // block doorway interactions while overlay is up or during fades
    if (game.isInputLocked || game.isTransitioning) return;

    final players = game.children.whereType<Player>();
    final player = players.isEmpty ? null : players.first;
    if (player == null) return;

    final center = Vector2(x + size.x / 2, y + size.y / 2);
    final dist = (player.position - center).length;
    if (dist < 26) {
      // Nudge player away so we don’t re-trigger instantly
      final away = (player.position - center);
      if (away.length2 > 0) {
        player.position += away.normalized() * 10;
      }
      onEnter();
    }
  }
}

class Hotspot extends PositionComponent with HasGameRef<SaferAdventureGame> {
  final Vector2 center;
  final double radius;
  final String title;
  final VoidCallback onTrigger;
  final bool showUI; // allow invisible hotspot

  Hotspot({
    required this.center,
    required this.radius,
    required this.title,
    required this.onTrigger,
    this.showUI = true,
  }) {
    position = center;
    size = Vector2.all(radius * 2);
    anchor = Anchor.center;
    priority = 6;
  }

  @override
  void render(Canvas canvas) {
    if (!showUI) return; // hide ring/label entirely
    final glow = Paint()..color = Colors.tealAccent.withOpacity(0.10);
    final ring = Paint()
      ..color = Colors.tealAccent
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2;
    canvas.drawCircle(Offset.zero, radius, glow);
    canvas.drawCircle(Offset.zero, radius, ring);

    final tp = TextPainter(
      text: TextSpan(
        text: title,
        style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.w600),
      ),
      textDirection: TextDirection.ltr,
    )..layout(maxWidth: radius * 2 + 80);
    tp.paint(canvas, Offset(-tp.width / 2, radius + 6));
  }

  @override
  void update(double dt) {
    super.update(dt);

    // block hotspot interactions while overlay is up
    if ((gameRef).isInputLocked) return;

    final players = gameRef.children.whereType<Player>();
    final player = players.isEmpty ? null : players.first;
    if (player == null) return;

    final d = (player.position - position).length;
    if (d < radius * 0.75) {
      onTrigger();

      // Small pushback so it doesn't spam-trigger
      final push = (player.position - position);
      if (push.length2 > 0) {
        player.position += push.normalized() * 8;
      }
    }
  }
}

class HudToast extends Component with HasGameRef<SaferAdventureGame> {
  String? _text;
  double _timer = 0;

  void show(String text, {double seconds = 2.6}) {
    _text = text;
    _timer = seconds;
  }

  @override
  void update(double dt) {
    super.update(dt);
    if (_timer > 0) _timer -= dt;
    if (_timer < 0) _timer = 0;
  }

  @override
  void render(Canvas canvas) {
    if (_timer <= 0 || _text == null) return;

    const double fadeWindow = 1.2;
    double alpha = 1.0;
    if (_timer < fadeWindow) {
      alpha = (_timer / fadeWindow).clamp(0.0, 1.0);
    }
    if (alpha <= 0) return;

    final w = gameRef.size.x;
    const pad = 12.0;
    final boxW = (w - 40).clamp(220, 560).toDouble();
    const boxH = 52.0;

    final left = (w - boxW) / 2.0;
    const top = 24.0;

    final paint = Paint()..color = Colors.black.withOpacity(0.72 * alpha);
    final r = RRect.fromRectAndRadius(
      Rect.fromLTWH(left, top, boxW, boxH),
      const Radius.circular(10),
    );
    canvas.drawRRect(r, paint);

    final tp = TextPainter(
      text: TextSpan(
        text: _text!,
        style: TextStyle(
          color: Colors.white.withOpacity(alpha),
          fontSize: 14,
        ),
      ),
      textDirection: TextDirection.ltr,
      textAlign: TextAlign.center,
    )..layout(maxWidth: boxW - pad * 2);

    tp.paint(
      canvas,
      Offset(
        left + (boxW - tp.width) / 2,
        top + (boxH - tp.height) / 2,
      ),
    );
  }
}

class NeighborDialog extends PositionComponent
    with HasGameRef<SaferAdventureGame>, TapCallbacks {
  final String message;
  final VoidCallback onComplete;

  NeighborDialog({
    required this.message,
    required this.onComplete,
  }) {
    priority = 2600; // above HUD, below how-to overlay
  }

  @override
  Future<void> onLoad() async {
    // Full-screen so we can darken everything and catch taps
    anchor = Anchor.topLeft;
    position = Vector2.zero();
    size = gameRef.size;
    // Lock player movement while dialog is up
    gameRef.lockInput(true);
  }

  @override
  void onGameResize(Vector2 canvasSize) {
    super.onGameResize(canvasSize);
    size = canvasSize;
    position = Vector2.zero();
  }

  @override
  void render(Canvas canvas) {
    final s = gameRef.size;

    // Dim background
    canvas.drawRect(
      Rect.fromLTWH(0, 0, s.x, s.y),
      Paint()..color = Colors.black.withOpacity(0.45),
    );

    // Bubble
    final double pad = 16.0;
    final double bubbleH = 140.0;
    final Rect bubbleRect = Rect.fromLTWH(
      pad,
      s.y - bubbleH - pad,
      s.x - pad * 2,
      bubbleH,
    );
    final RRect bubbleRRect =
        RRect.fromRectAndRadius(bubbleRect, const Radius.circular(12));
    canvas.drawRRect(
      bubbleRRect,
      Paint()..color = const Color(0xFFFAFAFA),
    );

    // Text inside bubble
    final textPainter = TextPainter(
      text: TextSpan(
        text: message,
        style: const TextStyle(
          color: Colors.black87,
          fontSize: 14,
          height: 1.3,
        ),
      ),
      textDirection: TextDirection.ltr,
    )..layout(maxWidth: bubbleRect.width - 24);

    textPainter.paint(
      canvas,
      Offset(
        bubbleRect.left + 12,
        bubbleRect.top + 12,
      ),
    );

    // "OK" button in bottom-right of bubble
    const double btnW = 70;
    const double btnH = 30;
    final Rect okRect = Rect.fromLTWH(
      bubbleRect.right - btnW - 14,
      bubbleRect.bottom - btnH - 12,
      btnW,
      btnH,
    );
    canvas.drawRRect(
      RRect.fromRectAndRadius(okRect, const Radius.circular(8)),
      Paint()..color = const Color(0xFF1976D2),
    );
    final okTp = TextPainter(
      text: const TextSpan(
        text: 'GREAT',
        style: TextStyle(
          color: Colors.white,
          fontSize: 14,
          fontWeight: FontWeight.bold,
        ),
      ),
      textDirection: TextDirection.ltr,
    )..layout();
    okTp.paint(
      canvas,
      Offset(
        okRect.center.dx - okTp.width / 2,
        okRect.center.dy - okTp.height / 2,
      ),
    );
  }

  @override
  void onTapUp(TapUpEvent event) {
    event.handled = true;
    final s = gameRef.size;

    // Rebuild the bubble + OK rect the same way as in render
    final double pad = 16.0;
    final double bubbleH = 140.0;
    final Rect bubbleRect = Rect.fromLTWH(
      pad,
      s.y - bubbleH - pad,
      s.x - pad * 2,
      bubbleH,
    );
    const double btnW = 70;
    const double btnH = 30;
    final Rect okRect = Rect.fromLTWH(
      bubbleRect.right - btnW - 14,
      bubbleRect.bottom - btnH - 12,
      btnW,
      btnH,
    );

    final Offset pos = event.localPosition.toOffset();

    // Tap OK or anywhere inside bubble to close
    if (okRect.contains(pos) || bubbleRect.contains(pos)) {
      // unlock movement, mark task done, remove dialog
      gameRef.lockInput(false);
      onComplete();
      removeFromParent();
    }
  }

  @override
  void onRemove() {
    // make sure input is unlocked when this goes away
    gameRef.lockInput(false);
    super.onRemove();
  }
}

class CharacterSelectDialog extends PositionComponent
    with HasGameRef<SaferAdventureGame>, TapCallbacks {
  CharacterSelectDialog() {
    priority = 2650; // above HUD, similar to NeighborDialog
  }

  Sprite? _bradPreview;
  Sprite? _hannahPreview;
  bool _spritesReady = false;

  static const String _assetBradley = 'assets/images/sprites/main_guy_3x4_32.png';
  static const String _assetHannah  = 'assets/images/sprites/main_girl_4x8_64.png';

  @override
  Future<void> onLoad() async {
    anchor = Anchor.topLeft;
    position = Vector2.zero();
    size = gameRef.size;
    gameRef.lockInput(true);

    // Load preview sprites (idle, facing forward) for both characters
    try {
      final bradImg = await gameRef.images.load(_assetBradley);
      final hanImg  = await gameRef.images.load(_assetHannah);

      // Bradley: 4x3, tile 32x32 — row 0 col 1 = idle facing down
      const double bradTile = 32;
      final bradSheet = SpriteSheet(
        image: bradImg,
        srcSize: Vector2(bradTile, bradTile),
      );
      _bradPreview = bradSheet.getSprite(0, 1);

      // Hannah: row 0, girl in columns 4–6, idle = middle (5)
      const double hanTile = 64;
      final hanSheet = SpriteSheet(
        image: hanImg,
        srcSize: Vector2(hanTile, hanTile),
      );
      const int girlColMid = 5;
      _hannahPreview = hanSheet.getSprite(0, girlColMid);

      _spritesReady = true;
    } catch (_) {
      _spritesReady = false;
    }
  }

  @override
  void onGameResize(Vector2 canvasSize) {
    super.onGameResize(canvasSize);
    size = canvasSize;
    position = Vector2.zero();
  }

  void _select(PlayerAvatar avatar) {
    // Find the Player in the game tree and switch avatar
    final players = gameRef.children.whereType<Player>();
    if (players.isNotEmpty) {
      players.first.setAvatar(avatar);
    }
    gameRef.lockInput(false);
    removeFromParent();
  }

  @override
  void render(Canvas canvas) {
    final s = gameRef.size;

    // Dim background
    canvas.drawRect(
      Rect.fromLTWH(0, 0, s.x, s.y),
      Paint()..color = Colors.black.withOpacity(0.55),
    );

    // Dialog bubble (taller, darker)
    const double pad = 16.0;
    const double bubbleH = 220.0; // ⬅️ taller than before
    final Rect bubbleRect = Rect.fromLTWH(
      pad,
      s.y - bubbleH - pad,
      s.x - pad * 2,
      bubbleH,
    );
    final RRect bubbleRRect =
        RRect.fromRectAndRadius(bubbleRect, const Radius.circular(14));

    // Dark panel similar to how-to style
    canvas.drawRRect(
      bubbleRRect,
      Paint()..color = const Color(0xFF101621),
    );

    // Title
    final titleTp = TextPainter(
      text: const TextSpan(
        text: 'Choose Your Character',
        style: TextStyle(
          color: Colors.white,
          fontSize: 16,
          fontWeight: FontWeight.w700,
        ),
      ),
      textDirection: TextDirection.ltr,
    )..layout(maxWidth: bubbleRect.width - 24);
    titleTp.paint(
      canvas,
      Offset(bubbleRect.left + 12, bubbleRect.top + 12),
    );

    // Description
    final bodyTp = TextPainter(
      text: const TextSpan(
        text: 'Who would you like to play as?\n',
        style: TextStyle(
          color: Colors.white70,
          fontSize: 13,
          height: 1.3,
        ),
      ),
      textDirection: TextDirection.ltr,
    )..layout(maxWidth: bubbleRect.width - 24);
    bodyTp.paint(
      canvas,
      Offset(bubbleRect.left + 12, bubbleRect.top + 40),
    );

    // sprites preview
    if (_spritesReady) {
      const double previewSize = 54.0;

      // push previews down so they don't cover title/description
      final double previewTop = bubbleRect.top + 100;

      // horizontal centers
      final double bradCx = bubbleRect.left + bubbleRect.width * 0.28;
      final double hanCx  = bubbleRect.left + bubbleRect.width * 0.72;

      // Bradley preview
      if (_bradPreview != null) {
        _bradPreview!.render(
          canvas,
          position: Vector2(
            bradCx - previewSize / 2,
            previewTop,
          ),
          size: Vector2.all(previewSize),
        );
      }

      // Hannah preview
      if (_hannahPreview != null) {
        _hannahPreview!.render(
          canvas,
          position: Vector2(
            hanCx - previewSize / 2,
            previewTop,
          ),
          size: Vector2.all(previewSize),
        );
      }
    }

    // === BUTTONS ===
    const double btnW = 110;
    const double btnH = 34;
    const double gap = 16;

    // move buttons down a bit
    final double btnY = bubbleRect.bottom - btnH - 8;
    final double cx = bubbleRect.center.dx;

    final Rect bradRect = Rect.fromLTWH(
      cx - btnW - gap / 2,
      btnY,
      btnW,
      btnH,
    );
    final Rect hannahRect = Rect.fromLTWH(
      cx + gap / 2,
      btnY,
      btnW,
      btnH,
    );

    // Bradley button (blue)
    canvas.drawRRect(
      RRect.fromRectAndRadius(bradRect, const Radius.circular(8)),
      Paint()..color = const Color(0xFF1976D2),
    );
    final bradTp = TextPainter(
      text: const TextSpan(
        text: 'Bradley',
        style: TextStyle(
          color: Colors.white,
          fontSize: 14,
          fontWeight: FontWeight.bold,
        ),
      ),
      textDirection: TextDirection.ltr,
    )..layout();
    bradTp.paint(
      canvas,
      Offset(
        bradRect.center.dx - bradTp.width / 2,
        bradRect.center.dy - bradTp.height / 2,
      ),
    );

    // Hannah button (purple)
    canvas.drawRRect(
      RRect.fromRectAndRadius(hannahRect, const Radius.circular(8)),
      Paint()..color = const Color(0xFF8E24AA),
    );
    final hanTp = TextPainter(
      text: const TextSpan(
        text: 'Hannah',
        style: TextStyle(
          color: Colors.white,
          fontSize: 14,
          fontWeight: FontWeight.bold,
        ),
      ),
      textDirection: TextDirection.ltr,
    )..layout();
    hanTp.paint(
      canvas,
      Offset(
        hannahRect.center.dx - hanTp.width / 2,
        hannahRect.center.dy - hanTp.height / 2,
      ),
    );
  }

  @override
  void onTapUp(TapUpEvent event) {
    event.handled = true;
    final s = gameRef.size;

    const double pad = 16.0;
    const double bubbleH = 220.0;
    final Rect bubbleRect = Rect.fromLTWH(
      pad,
      s.y - bubbleH - pad,
      s.x - pad * 2,
      bubbleH,
    );

    const double btnW = 110;
    const double btnH = 34;
    const double gap = 16;
    final double btnY = bubbleRect.bottom - btnH - 8;
    final double cx = bubbleRect.center.dx;

    final Rect bradRect = Rect.fromLTWH(
      cx - btnW - gap / 2,
      btnY,
      btnW,
      btnH,
    );
    final Rect hannahRect = Rect.fromLTWH(
      cx + gap / 2,
      btnY,
      btnW,
      btnH,
    );

    final Offset pos = event.localPosition.toOffset();

    if (bradRect.contains(pos)) {
      _select(PlayerAvatar.bradley);
    } else if (hannahRect.contains(pos)) {
      _select(PlayerAvatar.hannah);
    } else if (bubbleRect.contains(pos)) {
      // tap inside bubble but not a button -> ignore
    }
  }

  @override
  void onRemove() {
    gameRef.lockInput(false);
    super.onRemove();
  }
}


class _ZoneDebugOverlay extends Component with HasGameRef<SaferAdventureGame> {
  @override
  void render(Canvas canvas) {
    if (!gameRef.debugZones) return;

    final tp = TextPainter(textDirection: TextDirection.ltr);

    final solidPaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2
      ..color = const Color(0xFF42A5F5);
    for (final z in gameRef._namedSolids) {
      canvas.drawRect(z.rect, solidPaint);
      tp.text = TextSpan(text: z.name, style: const TextStyle(color: Colors.lightBlueAccent, fontSize: 11));
      tp.layout();
      tp.paint(canvas, Offset(z.rect.left + 4, z.rect.top - 14));
    }

    final killPaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2
      ..color = const Color(0xFFF44336);
    for (final z in gameRef._namedKills) {
      canvas.drawRect(z.rect, killPaint);
      tp.text = const TextSpan(text: 'KILL', style: TextStyle(color: Colors.redAccent, fontSize: 11));
      tp.layout();
      tp.paint(canvas, Offset(z.rect.left + 4, z.rect.top - 14));
    }
  }
}


class WinConfetti extends Component with HasGameRef<SaferAdventureGame> {
  double _time = 0;
  final double _duration = 1.5;

  @override
  int get priority => 2800; // above HUD, below how-to if it ever shows

  @override
  void render(Canvas canvas) {
    final s = gameRef.size;
    final center = Offset(s.x / 2, s.y / 3);
    final paint = Paint()..style = PaintingStyle.fill;

    for (int i = 0; i < 12; i++) {
      final t = _time + i * 0.08;
      final r = 24 + i * 4;
      final dx = math.sin(t * 6 + i) * r;
      final dy = math.cos(t * 4 + i * 0.5) * r * 0.4;
      paint.color = Colors.primaries[i % Colors.primaries.length].withOpacity(0.9);
      canvas.drawCircle(center + Offset(dx, dy), 6, paint);
    }
  }

  @override
  void update(double dt) {
    _time += dt;
    if (_time > _duration) {
      removeFromParent();
    }
  }
}

class FadeCurtain extends PositionComponent {
  FadeCurtain({required Vector2 size}) {
    this.size = size;
    position = Vector2.zero();
  }

  double _alpha = 0.0;
  double _target = 0.0;
  double _speed = 0.0;
  Completer<void>? _anim;

  @override
  void render(Canvas canvas) {
    if (_alpha <= 0) return;
    final p = Paint()..color = Colors.black.withOpacity(_alpha);
    canvas.drawRect(Rect.fromLTWH(0, 0, size.x, size.y), p);
  }

  @override
  void update(double dt) {
    super.update(dt);
    if ((_alpha - _target).abs() < 1e-4) return;

    final dir = _alpha < _target ? 1.0 : -1.0;
    _alpha += dir * _speed * dt;

    if ((dir > 0 && _alpha >= _target) || (dir < 0 && _alpha <= _target)) {
      _alpha = _target;
      _anim?.complete();
      _anim = null;
    }
    if (_alpha < 0) _alpha = 0;
    if (_alpha > 1) _alpha = 1;
  }

  Future<void> fadeToBlack({double duration = 0.28}) {
    // cancel any prior waiter and start fresh
    _anim?.complete();
    _anim = Completer<void>();

    if (duration <= 0) {
      _alpha = 1.0;
      _target = 1.0;
      final c = _anim!;
      _anim = null;
      c.complete();
      return c.future;
    }

    _target = 1.0;
    _speed = 1.0 / duration;
    return _anim!.future;
  }

  Future<void> fadeInFromBlack({double duration = 0.28}) {
    _anim?.complete();
    _anim = Completer<void>();

    if (duration <= 0) {
      _alpha = 0.0;
      _target = 0.0;
      final c = _anim!;
      _anim = null;
      c.complete();
      return c.future;
    }

    _target = 0.0;
    _speed = 1.0 / duration;
    return _anim!.future;
  }
}
