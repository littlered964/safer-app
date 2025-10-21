import 'dart:async';
import 'dart:convert' as convert;
import 'dart:math' as math;
import 'dart:ui' as ui;
import 'package:flame/components.dart';
import 'package:flame/game.dart';
import 'package:flame/sprite.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

enum Room { living, basement, frontLawn, sidewalk, neighbor, kitchen }

class SaferAdventureGame extends FlameGame {
  late final Player _player;
  late final HudToast _hud;
  late final FadeCurtain _fade;

  Room _room = Room.living;
  bool _initialized = false;
  bool _transitioning = false;

  // First-visit random events
  bool _visitedSidewalk = false;
  bool _sidewalkDownedLine = false; // 50/50 on first enter
  bool _visitedBasement = false;
  bool _basementFlooded = false;    // 50/50 on first enter

  // Expose for drawing
  bool get sidewalkDownedLine => _sidewalkDownedLine;
  bool get basementFlooded => _basementFlooded;

  // Solids for collision (furniture etc.)
  final List<Rect> _solids = [];
  List<Rect> get solids => _solids;
  void setSolids(List<Rect> r) {
    _solids
      ..clear()
      ..addAll(r);
  }

  // Door rectangles per room so we can spawn right at doors
  Map<String, Rect> _doorRectsFor(Room room) {
    // Keep door geometry centralized & consistent with rendering.
    Rect bottomDoor()   => Rect.fromLTWH(size.x / 2 - 20, size.y - 48, 40, 28);
    Rect topDoor()      => Rect.fromLTWH(size.x / 2 - 20, 20,               40, 28);
    Rect rightDoor()    => Rect.fromLTWH(size.x - 56,    size.y / 2 - 20,   40, 40);
    Rect leftDoor()     => Rect.fromLTWH(16,             size.y / 2 - 20,   40, 40);
    Rect topRightDoor() => Rect.fromLTWH(size.x - 80,    20,                60, 28);

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
        // Sidewalk door is top-right now (to suggest neighbor’s direction)
        return {'toLiving': bottomDoor(), 'toSidewalk': topRightDoor()};
      case Room.sidewalk:
        return {'toFrontLawn': leftDoor(), 'toNeighbor': rightDoor()};
      case Room.neighbor:
        return {'toSidewalk': leftDoor()};
      case Room.kitchen:
        return {'toLiving': leftDoor()};
    }
  }

  bool get isTransitioning => _transitioning;

  @override
  Color backgroundColor() => const Color(0xFF0B1220);

  @override
  Future<void> onLoad() async {
    images.prefix = ''; // use full asset keys

    // (Optional) proof the sprite is present
    try {
      final manifest = await rootBundle.loadString('AssetManifest.json');
      final hasSprite = manifest.contains('"assets/images/sprites/main_guy_3x4_32.png"');
      debugPrint('[AssetCheck] Has main_guy_3x4_32.png? $hasSprite');
    } catch (_) {}

    final roomBox = RoomBox(room: _room)..priority = 0;
    add(roomBox);

    _hud = HudToast()..priority = 1000;
    add(_hud);

    _player = Player()
      ..position = Vector2(size.x * 0.45, size.y * 0.55) // start somewhere in Living Room
      ..priority = 50;
    add(_player);

    _fade = FadeCurtain(size: size)..priority = 2000;
    add(_fade);

    _buildInteractivesFor(_room);
    roomBox.recomputeSolids();
    _initialized = true;

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
    children.whereType<RoomBox>().firstOrNull?.recomputeSolids();
  }

  // Public hook for D-pad
  void setMobileDir(double dx, double dy) {
    final v = Vector2(dx, dy);
    _player.dir = v.length2 == 0 ? Vector2.zero() : v.normalized();
  }

  // --- Room building ---

  void _clearInteractives() {
    children.whereType<Doorway>().toList().forEach((d) => d.removeFromParent());
    children.whereType<Hotspot>().toList().forEach((h) => h.removeFromParent());
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
          await _goTo(Room.basement, spawnFrom: 'toLiving');
        },
      ));
      add(Doorway(
        rect: livingDoors['toFrontLawn']!,
        label: '↑ Front Lawn',
        onEnter: () async {
          HapticFeedback.selectionClick();
          await _goTo(Room.frontLawn, spawnFrom: 'toLiving');
        },
      ));
      add(Doorway(
        rect: livingDoors['toKitchen']!,
        label: '→ Kitchen',
        onEnter: () async {
          HapticFeedback.selectionClick();
          await _goTo(Room.kitchen, spawnFrom: 'toLiving');
        },
      ));

      // LAMP HOTSPOT (near where we draw the lamp) — invisible UI
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
            _hud.show('The lamp turns on — power is back!');
          } else {
            _hud.show('Lamp is already on.');
          }
        },
      ));
    } else if (room == Room.basement) {
      add(Doorway(
        rect: basementDoors['toLiving']!,
        label: '↑ Living (Stairs)',
        onEnter: () async {
          HapticFeedback.selectionClick();
          await _goTo(Room.living, spawnFrom: 'toBasement');
        },
      ));
    } else if (room == Room.frontLawn) {
      add(Doorway(
        rect: lawnDoors['toLiving']!,
        label: '↓ Living',
        onEnter: () async {
          HapticFeedback.selectionClick();
          await _goTo(Room.living, spawnFrom: 'toFrontLawn');
        },
      ));
      add(Doorway(
        rect: lawnDoors['toSidewalk']!,
        label: '↗ Sidewalk',
        onEnter: () async {
          HapticFeedback.selectionClick();
          await _goTo(Room.sidewalk, spawnFrom: 'toFrontLawn');
        },
      ));
    } else if (room == Room.sidewalk) {
      add(Doorway(
        rect: sidewalkDoors['toFrontLawn']!,
        label: '← Front Lawn',
        onEnter: () async {
          HapticFeedback.selectionClick();
          await _goTo(Room.frontLawn, spawnFrom: 'toSidewalk');
        },
      ));
      add(Doorway(
        rect: sidewalkDoors['toNeighbor']!,
        label: '→ Neighbor',
        onEnter: () async {
          HapticFeedback.selectionClick();
          await _goTo(Room.neighbor, spawnFrom: 'toSidewalk');
        },
      ));
    } else if (room == Room.neighbor) {
      add(Doorway(
        rect: neighborDoors['toSidewalk']!,
        label: '← Sidewalk',
        onEnter: () async {
          HapticFeedback.selectionClick();
          await _goTo(Room.sidewalk, spawnFrom: 'toNeighbor');
        },
      ));
    } else if (room == Room.kitchen) {
      add(Doorway(
        rect: kitchenDoors['toLiving']!,
        label: '← Living',
        onEnter: () async {
          HapticFeedback.selectionClick();
          await _goTo(Room.living, spawnFrom: 'toKitchen');
        },
      ));
      // Food Safety hotspot stays in kitchen
      final cx = (size.x * 0.70).clamp(80, size.x - 80).toDouble();
      final cy = (size.y * 0.28).clamp(80, size.y - 80).toDouble();
      add(Hotspot(
        center: Vector2(cx, cy),
        radius: 36,
        title: 'Food Safety',
        onTrigger: () {
          HapticFeedback.lightImpact();
          _hud.show('Discard perishables kept > 40°F for 2+ hours.');
        },
      ));
    }

    // Update background + solids
    children.whereType<RoomBox>().firstOrNull
      ?..room = room
      ..recomputeSolids();
  }

  // Spawn just inside the destination room’s door you came through
  Vector2 _spawnPoint(Room dest, String? spawnFromKey) {
    final doors = _doorRectsFor(dest);
    // Fallback: center
    Vector2 center() => Vector2(size.x / 2, size.y / 2);

    if (spawnFromKey == null || !doors.containsKey(spawnFromKey)) {
      return center();
    }
    final r = doors[spawnFromKey]!;
    const inside = 24.0; // how far inside the room we appear

    switch (dest) {
      case Room.living:
        if (spawnFromKey == 'toBasement') {
          return Vector2(r.center.dx, r.top - inside); // coming up -> above bottom door
        } else if (spawnFromKey == 'toFrontLawn') {
          return Vector2(r.center.dx, r.bottom + inside); // came in from lawn -> below top door
        } else if (spawnFromKey == 'toKitchen') {
          return Vector2(r.left - inside, r.center.dy); // from kitchen -> left of right door
        }
        break;
      case Room.basement:
        if (spawnFromKey == 'toLiving') {
          return Vector2(r.center.dx, r.bottom + inside); // appeared at top door -> below it
        }
        break;
      case Room.frontLawn:
        if (spawnFromKey == 'toLiving') {
          return Vector2(r.center.dx, r.top - inside); // stepping out the front door
        } else if (spawnFromKey == 'toSidewalk') {
          return Vector2(r.center.dx + 40, r.bottom + inside); // from sidewalk -> below top-right
        }
        break;
      case Room.sidewalk:
        if (spawnFromKey == 'toFrontLawn') {
          return Vector2(r.right + inside, r.center.dy); // from lawn -> right of left door
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
          return Vector2(r.right + inside, r.center.dy); // from living -> right of left door
        }
        break;
    }
    return center();
  }

  Future<void> _goTo(Room dest, {String? spawnFrom}) async {
    if (_transitioning) return;
    _transitioning = true;

    await _fade.fadeToBlack();

    // First-visit randomization
    if (dest == Room.sidewalk && !_visitedSidewalk) {
      _visitedSidewalk = true;
      _sidewalkDownedLine = math.Random().nextBool();
      if (_sidewalkDownedLine) {
        _hud.show('Caution: downed power line on the grass.');
      }
    }
    if (dest == Room.basement && !_visitedBasement) {
      _visitedBasement = true;
      _basementFlooded = math.Random().nextBool();
      if (_basementFlooded) {
        _hud.show('Basement is flooded.');
      }
    }

    _room = dest;

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

  // Keep the same math as RoomBox for lamp center so the hotspot lines up.
  Vector2 _livingLampCenter() {
    // Mirror RoomBox._drawLivingRoom calculations
    const inset = 14.0;
    final rect = Rect.fromLTWH(0, 0, size.x, size.y);
    final inner = rect.deflate(inset);
    final rug = Rect.fromCenter(
      center: Offset(inner.center.dx + 10.0, inner.center.dy + 18.0),
      width: inner.width * 0.46,
      height: inner.height * 0.34,
    );
    final baseCenter = Offset(rug.right + 26.0, rug.top - 10.0);
    return Vector2(baseCenter.dx, baseCenter.dy);
  }
}

// ---------------- Components ----------------

enum _Facing { up, left, down, right }

class Player extends SpriteAnimationGroupComponent<_Facing>
    with HasGameRef<SaferAdventureGame> {
  static const double speed = 140;
  static const double _tile = 32;

  Vector2 _dir = Vector2.zero();

  late final SpriteAnimation _idleUp;
  late final SpriteAnimation _idleLeft;
  late final SpriteAnimation _idleDown;
  late final SpriteAnimation _idleRight;

  late final SpriteAnimation _walkUp;
  late final SpriteAnimation _walkLeft;
  late final SpriteAnimation _walkDown;
  late final SpriteAnimation _walkRight;

  late final Map<_Facing, SpriteAnimation> _idleMap;
  late final Map<_Facing, SpriteAnimation> _walkMap;

  bool _fallback = false;

  Player() : super(priority: 50, anchor: Anchor.center, size: Vector2(28, 28));

  set dir(Vector2 v) => _dir = v;

  static const String _assetKey = 'assets/images/sprites/main_guy_3x4_32.png';

  Future<ui.Image?> _tryFlameLoadExact() async {
    try {
      debugPrint('[Player] Flame load: $_assetKey');
      return await gameRef.images.load(_assetKey);
    } catch (e) {
      debugPrint('[Player] Flame load failed: $e');
      return null;
    }
  }

  Future<ui.Image?> _tryManifestDirect() async {
    try {
      final manifestJson = await rootBundle.loadString('AssetManifest.json');
      final Map<String, dynamic> manifest = convert.json.decode(manifestJson);
      if (!manifest.containsKey(_assetKey)) {
        debugPrint('[Player] Manifest does not list $_assetKey');
        return null;
      }
      final data = await rootBundle.load(_assetKey);
      final bytes = data.buffer.asUint8List();
      final codec = await ui.instantiateImageCodec(bytes);
      final frame = await codec.getNextFrame();
      debugPrint('[Player] Loaded via rootBundle: $_assetKey');
      return frame.image;
    } catch (e) {
      debugPrint('[Player] Manifest/direct load failed: $e');
      return null;
    }
  }

  @override
  Future<void> onLoad() async {
    try {
      ui.Image? image = await _tryFlameLoadExact();
      image ??= await _tryManifestDirect();

      if (image == null) {
        throw Exception('Sprite not found in bundle: $_assetKey');
      }

      final sheet = SpriteSheet(image: image, srcSize: Vector2(_tile, _tile));
      const step = 0.12;

      // Assuming rows: 0=up, 1=right, 2=down, 3=left
      _walkUp    = sheet.createAnimation(row: 0, from: 0, to: 2, stepTime: step);
      _walkLeft  = sheet.createAnimation(row: 3, from: 0, to: 2, stepTime: step);
      _walkDown  = sheet.createAnimation(row: 2, from: 0, to: 2, stepTime: step);
      _walkRight = sheet.createAnimation(row: 1, from: 0, to: 2, stepTime: step);

      _idleUp    = SpriteAnimation.spriteList([sheet.getSprite(0, 1)], stepTime: 1);
      _idleLeft  = SpriteAnimation.spriteList([sheet.getSprite(3, 1)], stepTime: 1);
      _idleDown  = SpriteAnimation.spriteList([sheet.getSprite(2, 1)], stepTime: 1);
      _idleRight = SpriteAnimation.spriteList([sheet.getSprite(1, 1)], stepTime: 1);

      _idleMap = {
        _Facing.up: _idleUp,
        _Facing.left: _idleLeft,
        _Facing.down: _idleDown,
        _Facing.right: _idleRight,
      };
      _walkMap = {
        _Facing.up: _walkUp,
        _Facing.left: _walkLeft,
        _Facing.down: _walkDown,
        _Facing.right: _walkRight,
      };

      animations = _idleMap;
      current = _Facing.down;

      paint.filterQuality = FilterQuality.none;
      debugPrint('[Player] Sprite sheet initialized.');
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
        if (v.y.abs() >= v.x.abs()) {
          current = (v.y > 0) ? _Facing.up : _Facing.down;
        } else {
          current = (v.x > 0) ? _Facing.right : _Facing.left;
        }
        if (!identical(animations, _walkMap)) animations = _walkMap;
      }
    } else {
      if (!_fallback && animations != null && !identical(animations, _idleMap)) {
        animations = _idleMap;
      }
    }

    // Collision: revert if overlapping any solid
    if (_collidesWithSolids()) {
      position.setFrom(old);
    }

    // Keep on screen
    final maxX = gameRef.size.x - 16;
    final maxY = gameRef.size.y - 16;
    position.x = position.x.clamp(16, maxX);
    position.y = position.y.clamp(16, maxY);
  }

  bool _collidesWithSolids() {
    final game = gameRef as SaferAdventureGame;
    if (game.solids.isEmpty) return false;
    const double hb = 16.0;
    final r = Rect.fromCenter(
      center: Offset(position.x, position.y),
      width: hb,
      height: hb,
    );
    for (final s in game.solids) {
      if (r.overlaps(s)) return true;
    }
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

  // Lamp state (for living room)
  bool lampOn = false;

  RoomBox({required this.room}) {
    priority = 0;
  }

  List<Rect> _solids = const [];

  @override
  Future<void> onLoad() async {
    size = gameRef.size;
    position = Vector2.zero();
    recomputeSolids();
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

    // Room label (top-left)
    final label = switch (room) {
      Room.living    => 'Living Room',
      Room.basement  => 'Basement',
      Room.frontLawn => 'Front Lawn',
      Room.sidewalk  => 'Sidewalk',
      Room.neighbor  => 'Neighbor’s House',
      Room.kitchen   => 'Kitchen',
    };
    final tp = TextPainter(
      text: TextSpan(text: label, style: const TextStyle(color: Colors.white70, fontSize: 14)),
      textDirection: TextDirection.ltr,
    )..layout();
    tp.paint(canvas, const Offset(12, 10));
  }

  // ---------- Drawing helpers ----------

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

  // ---------- Living Room (unchanged look; no grid) ----------
  void _drawLivingRoom(Canvas canvas, Rect rect) {
    // Walls + border
    _drawBorder(canvas, rect, const Color(0xFF222B3F));

    // Baseboard inset
    const inset = 14.0;
    final inner = rect.deflate(inset);

    // Wood floor (clean)
    final floor = RRect.fromRectAndRadius(inner, const Radius.circular(10));
    canvas.drawRRect(floor, Paint()..color = const Color(0xFF3A2E24));

    // Doors (must match Doorway rectangles)
    final topDoorRect    = Rect.fromLTWH(size.x / 2 - 20, 20, 40, 28);                // to Front Lawn
    final rightDoorRect  = Rect.fromLTWH(size.x - 56, size.y / 2 - 20, 40, 40);       // to Kitchen
    final bottomDoorRect = Rect.fromLTWH(size.x / 2 - 20, size.y - 48, 40, 28);       // to Basement
    _drawFrontDoor(canvas, topDoorRect);
    _drawInteriorDoorway(canvas, rightDoorRect);
    _drawStairsDown(canvas, bottomDoorRect);

    // Rug
    final rugRect = Rect.fromCenter(
      center: Offset(inner.center.dx + 10.0, inner.center.dy + 18.0),
      width: inner.width * 0.46,
      height: inner.height * 0.34,
    );
    final rug = RRect.fromRectAndRadius(rugRect, const Radius.circular(22));
    canvas.drawRRect(rug, Paint()..color = const Color(0xFF2C5F6B));
    canvas.drawRRect(rug, Paint()..color = const Color(0x22FFFFFF));

    // Coffee table (solid)
    final coffeeRect = Rect.fromCenter(
      center: Offset(rugRect.center.dx + 4.0, rugRect.center.dy + 2.0),
      width: rugRect.width * 0.38,
      height: rugRect.height * 0.30,
    );
    final coffee = RRect.fromRectAndRadius(coffeeRect, const Radius.circular(12));
    canvas.drawShadow(Path()..addRRect(coffee), Colors.black, 4, false);
    canvas.drawRRect(coffee, Paint()..color = const Color(0xFF6B4E32));

    // Vertical couch (solid)
    final innerRect = inner;
    final couchRect = Rect.fromCenter(
      center: Offset(innerRect.left + 72.0, rugRect.center.dy),
      width: 58.0,
      height: 150.0,
    );
    final couch = RRect.fromRectAndRadius(couchRect, const Radius.circular(12));
    canvas.drawShadow(Path()..addRRect(couch), Colors.black, 6, false);
    canvas.drawRRect(couch, Paint()..color = const Color(0xFF2C6AD4));
    final seam = Paint()..color = const Color(0x33FFFFFF);
    canvas.drawLine(
      Offset(couchRect.center.dx, couchRect.top + 10.0),
      Offset(couchRect.center.dx, couchRect.bottom - 10.0),
      seam,
    );

    // Floor lamp (on/off)
    final lampBase = Offset(rugRect.right + 26.0, rugRect.top - 10.0);
    _drawFloorLamp(canvas, baseCenter: lampBase, on: lampOn);

    // Register solids (couch + coffee)
    (gameRef as SaferAdventureGame).setSolids([
      couchRect.deflate(4.0),
      coffeeRect.deflate(6.0),
    ]);

    // LIGHT THE WHOLE ROOM WHEN LAMP IS ON
    if (lampOn) {
      final softRoomLight = Paint()
        ..blendMode = BlendMode.plus
        ..color = const Color(0x33FFF7C2); // warm additive wash
      canvas.drawRRect(RRect.fromRectAndRadius(inner, const Radius.circular(10)), softRoomLight);
    }

    // Gentle vignette
    final vignette = Paint()
      ..shader = RadialGradient(
        center: Alignment.topCenter,
        radius: 1.1,
        colors: [Colors.white.withOpacity(0.06), Colors.transparent],
        stops: const [0.0, 1.0],
      ).createShader(inner);
    canvas.drawRRect(RRect.fromRectAndRadius(inner, const Radius.circular(10)), vignette);
  }

  // ---------- Front Lawn ----------
  void _drawFrontLawn(Canvas canvas, Rect rect) {
    _drawBorder(canvas, rect, const Color(0xFF1A2A1A));
    const inset = 14.0;
    final inner = rect.deflate(inset);

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

    // Top-right "door" visual to Sidewalk (must match topRightDoor)
    final trDoorRect = Rect.fromLTWH(size.x - 80, 20, 60, 28);
    canvas.drawRRect(
      RRect.fromRectAndRadius(trDoorRect.inflate(2), const Radius.circular(6)),
      Paint()..color = Colors.white.withOpacity(0.12),
    );

    // House façade at bottom + front door (to Living)
    final houseBandH = (inner.height * 0.14).clamp(40.0, 90.0);
    final houseBand = Rect.fromLTWH(inner.left, inner.bottom - houseBandH, inner.width, houseBandH);
    canvas.drawRect(houseBand, Paint()..color = const Color(0xFF3A4458));

    final bottomDoorRect = Rect.fromLTWH(size.x / 2 - 20, size.y - 48, 40, 28);
    canvas.drawRRect(
      RRect.fromRectAndRadius(bottomDoorRect, const Radius.circular(6)),
      Paint()..color = Colors.white.withOpacity(0.10),
    );
    canvas.drawRRect(
      RRect.fromRectAndRadius(bottomDoorRect.deflate(2), const Radius.circular(5)),
      Paint()..color = const Color(0xFF252D3A),
    );

    // Stone path from door up toward sidewalk (center-ish)
    final pathPaint = Paint()..color = const Color(0xFFD8D2C8).withOpacity(0.80);
    final pathLeft  = inner.center.dx - 26;
    final pathRight = inner.center.dx + 26;
    final pathTop   = sidewalkRect.bottom + 6;
    final pathBottom= bottomDoorRect.top - 4;
    final pathRect  = RRect.fromRectAndRadius(
      Rect.fromLTRB(pathLeft, pathTop, pathRight, pathBottom),
      const Radius.circular(18),
    );
    canvas.drawRRect(pathRect, pathPaint);

    // Register solids (none here)
    (gameRef as SaferAdventureGame).setSolids(const []);

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

  // ---------- Sidewalk ----------
  void _drawSidewalk(Canvas canvas, Rect rect) {
    _drawBorder(canvas, rect, const Color(0xFF1E2B38));
    const inset = 14.0;
    final inner = rect.deflate(inset);

    // Layout bands: street (top), sidewalk path (center), grass (bottom)
    final streetH = (inner.height * 0.24).clamp(56.0, 120.0);
    final grassH  = (inner.height * 0.30).clamp(70.0, 160.0);
    final pathH   = inner.height - streetH - grassH;

    final streetRect = Rect.fromLTWH(inner.left, inner.top, inner.width, streetH);
    final pathRect   = Rect.fromLTWH(inner.left, streetRect.bottom, inner.width, pathH);
    final grassRect  = Rect.fromLTWH(inner.left, pathRect.bottom, inner.width, grassH);

    // Street
    canvas.drawRect(streetRect, Paint()..color = const Color(0xFF2E2E33));

    // Sidewalk path (concrete with joints)
    final sidewalkPaint = Paint()..color = const Color(0xFFBFC5C8);
    canvas.drawRect(pathRect, sidewalkPaint);
    final joint = Paint()
      ..color = Colors.black.withOpacity(0.12)
      ..strokeWidth = 2;
    for (double x = pathRect.left + 24; x < pathRect.right; x += 48) {
      canvas.drawLine(Offset(x, pathRect.top + 4), Offset(x, pathRect.bottom - 4), joint);
    }

    // Grass
    canvas.drawRect(grassRect, Paint()..color = const Color(0xFF2F6E2F));

    // Left & Right door overlays (must match Doorway rects)
    final leftDoorRect  = Rect.fromLTWH(16, size.y / 2 - 20, 40, 40);          // to Front Lawn
    final rightDoorRect = Rect.fromLTWH(size.x - 56, size.y / 2 - 20, 40, 40); // to Neighbor
    for (final r in [leftDoorRect, rightDoorRect]) {
      canvas.drawRRect(
        RRect.fromRectAndRadius(r, const Radius.circular(8)),
        Paint()..color = Colors.white.withOpacity(0.10),
      );
    }

    // Downed power line chance (first visit determined by gameRef)
    final game = gameRef as SaferAdventureGame;
    if (game.sidewalkDownedLine) {
      _drawDownedLine(canvas, grassRect);
    }

    // Register solids (none for now)
    game.setSolids(const []);
  }

  void _drawDownedLine(Canvas canvas, Rect grassRect) {
    // Simple zigzag cable + warning sign
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

  // ---------- Neighbor (another front lawn look) ----------
  void _drawNeighborLawn(Canvas canvas, Rect rect) {
    _drawBorder(canvas, rect, const Color(0xFF1A2A1A));
    const inset = 14.0;
    final inner = rect.deflate(inset);

    // Lawn
    canvas.drawRRect(RRect.fromRectAndRadius(inner, const Radius.circular(10)), Paint()..color = const Color(0xFF2B6A2B));

    // House band at bottom, door on left side (flavor change)
    final houseBandH = (inner.height * 0.14).clamp(40.0, 90.0);
    final house = Rect.fromLTWH(inner.left, inner.bottom - houseBandH, inner.width, houseBandH);
    canvas.drawRect(house, Paint()..color = const Color(0xFF454F63));

    // Visualize left door (from sidewalk)
    final leftDoorRect  = Rect.fromLTWH(16, size.y / 2 - 20, 40, 40);
    canvas.drawRRect(
      RRect.fromRectAndRadius(leftDoorRect, const Radius.circular(8)),
      Paint()..color = Colors.white.withOpacity(0.10),
    );

    // Simple stepping stones
    final stonesPaint = Paint()..color = const Color(0xFFD6D3CD);
    for (int i = 0; i < 5; i++) {
      final cx = inner.center.dx - 40 + i * 22;
      final cy = inner.center.dy + 18 - i * 6;
      canvas.drawRRect(
        RRect.fromRectAndRadius(Rect.fromCenter(center: Offset(cx, cy), width: 20, height: 12), const Radius.circular(6)),
        stonesPaint,
      );
    }

    (gameRef as SaferAdventureGame).setSolids(const []);
  }

  // ---------- Kitchen ----------
  void _drawKitchen(Canvas canvas, Rect rect) {
    _drawBorder(canvas, rect, const Color(0xFF223249));
    const inset = 14.0;
    final inner = rect.deflate(inset);

    // Floor tiles
    canvas.drawRRect(RRect.fromRectAndRadius(inner, const Radius.circular(10)), Paint()..color = const Color(0xFF374B63));
    final grout = Paint()
      ..color = Colors.black.withOpacity(0.18)
      ..strokeWidth = 1;
    const tile = 26.0;
    for (double x = inner.left; x <= inner.right; x += tile) {
      canvas.drawLine(Offset(x, inner.top), Offset(x, inner.bottom), grout);
    }
    for (double y = inner.top; y <= inner.bottom; y += tile) {
      canvas.drawLine(Offset(inner.left, y), Offset(inner.right, y), grout);
    }

    // Counters (top band)
    final counterH = 44.0;
    final counters = Rect.fromLTWH(inner.left, inner.top, inner.width, counterH);
    canvas.drawRect(counters, Paint()..color = const Color(0xFF8C9AA9));
    // Sink cutout
    final sink = RRect.fromRectAndRadius(Rect.fromLTWH(inner.center.dx - 26, inner.top + 6, 52, counterH - 12), const Radius.circular(8));
    canvas.drawRRect(sink, Paint()..color = const Color(0xFFB8C6D9));

    // Fridge (right side)
    final fridge = RRect.fromRectAndRadius(
      Rect.fromLTWH(inner.right - 78, inner.top + 8, 66, 110),
      const Radius.circular(8),
    );
    canvas.drawShadow(Path()..addRRect(fridge), Colors.black, 6, false);
    canvas.drawRRect(fridge, Paint()..color = const Color(0xFFE5E9EF));
    // Fridge details
    canvas.drawLine(
      Offset(fridge.outerRect.left + 4, fridge.outerRect.center.dy),
      Offset(fridge.outerRect.right - 4, fridge.outerRect.center.dy),
      Paint()..color = const Color(0xFFCBD3DB)..strokeWidth = 2,
    );
    final handle = RRect.fromRectAndRadius(Rect.fromLTWH(fridge.outerRect.right - 10, fridge.outerRect.top + 16, 4, 28), const Radius.circular(2));
    canvas.drawRRect(handle, Paint()..color = const Color(0xFFB0B8C0));

    (gameRef as SaferAdventureGame).setSolids(const []);
  }

  // ---------- Basement ----------
  void _drawBasement(Canvas canvas, Rect rect) {
    _drawBorder(canvas, rect, const Color(0xFF151C27));
    const inset = 14.0;
    final inner = rect.deflate(inset);

    // Bare floor
    canvas.drawRRect(RRect.fromRectAndRadius(inner, const Radius.circular(10)), Paint()..color = const Color(0xFF263141));

    // Top door with "stairs up" visual (matches toLiving topDoor)
    final topDoorRect = Rect.fromLTWH(size.x / 2 - 20, 20, 40, 28);
    _drawStairsUp(canvas, topDoorRect);

    // Some boxes & a shelf (flavor)
    final box = RRect.fromRectAndRadius(Rect.fromLTWH(inner.left + 28, inner.bottom - 70, 48, 32), const Radius.circular(6));
    canvas.drawRRect(box, Paint()..color = const Color(0xFF7A5A3A));
    final shelf = RRect.fromRectAndRadius(Rect.fromLTWH(inner.right - 100, inner.bottom - 120, 86, 60), const Radius.circular(6));
    canvas.drawRRect(shelf, Paint()..color = const Color(0xFF445468));

    // Flooded overlay (first-visit 50/50)
    final game = gameRef as SaferAdventureGame;
    if (game.basementFlooded) {
      final water = Paint()..color = const Color(0x6633A6FF);
      final waterRect = Rect.fromLTWH(inner.left + 8, inner.center.dy, inner.width - 16, inner.height * 0.45);
      canvas.drawRRect(RRect.fromRectAndRadius(waterRect, const Radius.circular(8)), water);

      // Ripples
      final ripple = Paint()
        ..color = const Color(0x99B4DAFF)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.5;
      for (double y = waterRect.top + 8; y < waterRect.bottom; y += 12) {
        canvas.drawArc(Rect.fromCenter(center: Offset(waterRect.center.dx, y), width: waterRect.width * 0.7, height: 12), 0, math.pi, false, ripple);
      }
    }

    (gameRef as SaferAdventureGame).setSolids(const []);
  }

  // ---------- Shared small drawing bits ----------

  List<Rect> _solidsForRoom(Room r, Vector2 size) {
    // Only living room has solids for now; others cosmetic
    if (r != Room.living) return const [];
    const inset = 14.0;
    final rect = Rect.fromLTWH(0, 0, size.x, size.y);
    final inner = rect.deflate(inset);
    final rug = Rect.fromCenter(
      center: Offset(inner.center.dx + 10.0, inner.center.dy + 18.0),
      width: inner.width * 0.46,
      height: inner.height * 0.34,
    );
    final coffee = Rect.fromCenter(
      center: Offset(rug.center.dx + 4.0, rug.center.dy + 2.0),
      width: rug.width * 0.38,
      height: rug.height * 0.30,
    );
    final couch = Rect.fromCenter(
      center: Offset(inner.left + 72.0, rug.center.dy),
      width: 58.0,
      height: 150.0,
    );
    return <Rect>[
      couch.deflate(4.0),
      coffee.deflate(6.0),
    ];
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
    // Visual cue for stairs going up (inverse of stairs down)
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

    // modest local glow when on (room-wide light handled separately)
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
}

class Doorway extends PositionComponent with HasGameRef<SaferAdventureGame> {
  final Rect rect;
  final String label;
  final Future<void> Function() onEnter;

  Doorway({required this.rect, required this.label, required this.onEnter}) {
    position = Vector2(rect.left, rect.top);
    size = Vector2(rect.width, rect.height);
    priority = 6;
  }

  @override
  void render(Canvas canvas) {
    // Subtle door overlay + label (kept for clarity)
    final p = Paint()..color = Colors.white.withOpacity(0.10);
    final r = Rect.fromLTWH(0, 0, size.x, size.y);
    canvas.drawRRect(RRect.fromRectAndRadius(r, const Radius.circular(6)), p);

    final tp = TextPainter(
      text: TextSpan(text: label, style: const TextStyle(color: Colors.white60, fontSize: 10)),
      textDirection: TextDirection.ltr,
    )..layout(maxWidth: size.x + 80);
    tp.paint(canvas, const Offset(-18, -14));
  }

  @override
  void update(double dt) {
    super.update(dt);
    position = Vector2(rect.left, rect.top);
    size = Vector2(rect.width, rect.height);

    final game = gameRef as SaferAdventureGame;
    if (game.isTransitioning) return;

    final player = game.children.whereType<Player>().firstOrNull;
    if (player == null) return;

    final center = Vector2(x + size.x / 2, y + size.y / 2);
    final dist = (player.position - center).length;
    if (dist < 26) {
      final away = (player.position - center);
      if (away.length2 > 0) player.position += away.normalized() * 10;
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
    tp.paint(canvas, Offset(-tp.width / 2, -radius - tp.height - 2));
  }

  @override
  void update(double dt) {
    super.update(dt);
    final player = gameRef.children.whereType<Player>().firstOrNull;
    if (player == null) return;

    final d = (player.position - position).length;
    if (d < radius * 0.75) {
      onTrigger();
      final push = (player.position - position);
      if (push.length2 > 0) player.position += push.normalized() * 8;
    }
  }
}

class HudToast extends Component with HasGameRef<SaferAdventureGame> {
  String? _text;
  double _timer = 0;

  void show(String text, {double seconds = 1.1}) {
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

    final w = gameRef.size.x;
    const pad = 12.0;
    final boxW = (w - 40).clamp(220, 560).toDouble();
    const boxH = 52.0;

    final left = (w - boxW) / 2.0;
    const top = 24.0;

    final paint = Paint()..color = Colors.black.withOpacity(0.72);
    final r = RRect.fromRectAndRadius(
      Rect.fromLTWH(left, top, boxW, boxH),
      const Radius.circular(10),
    );
    canvas.drawRRect(r, paint);

    final tp = TextPainter(
      text: TextSpan(text: _text!, style: const TextStyle(color: Colors.white, fontSize: 14)),
      textDirection: TextDirection.ltr,
      textAlign: TextAlign.center,
    )..layout(maxWidth: boxW - pad * 2);
    tp.paint(canvas, Offset(left + (boxW - tp.width) / 2, top + (boxH - tp.height) / 2));
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
    _target = 1.0;
    _speed = 1.0 / (duration <= 0 ? 0.0001 : duration);
    _anim ??= Completer<void>();
    return _anim!.future;
  }

  Future<void> fadeInFromBlack({double duration = 0.28}) {
    _target = 0.0;
    _speed = 1.0 / (duration <= 0 ? 0.0001 : duration);
    _anim ??= Completer<void>();
    return _anim!.future;
  }
}
