import 'dart:async';
import 'dart:math' as math;
import 'dart:ui' as ui;

import 'package:flame/components.dart';
import 'package:flame/events.dart';
import 'package:flame/game.dart' show FlameGame;
import 'package:flutter/painting.dart' show TextPainter, TextSpan, TextStyle;
import 'package:flutter/services.dart';

typedef FridgeMiniGameResult = void Function({
  required int tossedBad,
  required int savedGood,
  required bool perfect,
});

class FridgeMiniGame extends PositionComponent
    with DragCallbacks, TapCallbacks, HasGameRef<FlameGame> {
  FridgeMiniGame({
    required this.onFinished,
    this.onCancel,
  }) {
    priority = 3000;
    anchor = Anchor.topLeft;
    position = Vector2.zero();
  }

  final FridgeMiniGameResult onFinished;
  final VoidCallback? onCancel;

  // overlays/state
  bool _showHowTo = true;
  bool _showCongrats = false;

  // local fade
  late final _MiniFade _fade;

  // background + item images
  ui.Image? _bg;
  final Map<String, ui.Image> _images = {};

  // queue of items: appears exactly once, one at a time
  late final List<_FoodItemSpec> _queueSpecs = [
    _FoodItemSpec('burgerBad',  'assets/images/burgerBad.png',  true),
    _FoodItemSpec('burgerGood', 'assets/images/burgerGood.png', false),
    _FoodItemSpec('cheeseBad',  'assets/images/cheeseBad.png',  true),
    _FoodItemSpec('eggsGood',   'assets/images/eggsGood.png',   false),
    _FoodItemSpec('milkBad',    'assets/images/milkBad.png',    true),
    _FoodItemSpec('yogurtGood', 'assets/images/yogurtGood.png', false),
  ];

  // current item and index
  _FoodCard? _current;
  int _queueIndex = 0;

  // zones
  ui.Rect? _trashZone;
  ui.Rect? _fridgeZone;

  // results
  int _tossedBad = 0;
  int _savedGood = 0;

  // drag
  _FoodCard? _dragging;

  // finish guard to ensure overlay closes exactly once
  bool _closing = false;

  // high-contrast amber for headings/counters
  static const ui.Color _uiAccent = ui.Color(0xFFFFD54F);

  @override
  Future<void> onLoad() async {
    size = gameRef.size;

    // create the fade overlay but DO NOT await any animations here
    _fade = _MiniFade(size: size)..priority = 9999;
    add(_fade);

    _bg = await gameRef.images.load('assets/images/fridgeGameBackground.png');
    for (final spec in _queueSpecs) {
      _images[spec.asset] = await gameRef.images.load(spec.asset);
    }

    _buildLayout();
    _spawnCurrent();
  }

  @override
  void onMount() {
    super.onMount();
    // safe to run fades now
    _runIntroFade();
  }

  Future<void> _runIntroFade() async {
    await _fade.fadeToBlack(duration: 0.001);
    await _fade.fadeIn(duration: 0.22);
  }

  @override
  void onGameResize(Vector2 canvasSize) {
    super.onGameResize(canvasSize);
    size = canvasSize;
    _buildLayout();
    _placeOnShelf(_current);

    // keep fade sized correctly
    _fade.size = size;
    _fade.position = Vector2.zero();
  }

  // layout

  ui.Rect _innerRect() => ui.Rect.fromLTWH(12, 12, size.x - 24, size.y - 24);

  void _buildLayout() {
    final inner = _innerRect();
    final h = size.y;

    final zonesTop = inner.bottom - math.max(120.0, h * 0.22);
    final zonePad = 12.0;
    final zoneW = (inner.width - zonePad) / 2;

    _trashZone  = ui.Rect.fromLTWH(inner.left, zonesTop, zoneW, inner.bottom - zonesTop);
    _fridgeZone = ui.Rect.fromLTWH(inner.left + zoneW + zonePad, zonesTop, zoneW, inner.bottom - zonesTop);
  }

  void _placeOnShelf(_FoodCard? it) {
    if (it == null) return;
    final shelfY = size.y * 0.5 + size.y * 0.08; // a tad below center
    it.pos
      ..x = size.x * 0.5
      ..y = shelfY;
    it.home.setFrom(it.pos);
  }

  void _spawnCurrent() {
    if (_closing) return; // if we’re finishing, don’t spawn again
    if (_queueIndex >= _queueSpecs.length) {
      // show congrats instead of exiting immediately
      _showCongrats = true;
      return;
    }
    final spec = _queueSpecs[_queueIndex];
    final img  = _images[spec.asset]!;
    _current = _FoodCard(image: img, sizePx: Vector2(160, 160), isBad: spec.isBad);
    _placeOnShelf(_current);
  }

  // input

  @override
  void onTapUp(TapUpEvent e) {
    // handle overlay buttons first; gameplay taps otherwise
    final p = e.localPosition;

    if (_showHowTo) {
      _handleHowToTap(p);
      e.handled = true;
      return;
    }
    if (_showCongrats) {
      _handleCongratsTap(p);
      e.handled = true;
      return;
    }

    _dragging = null;
  }

  void _handleHowToTap(Vector2 p) {
    final s = gameRef.size;
    const btnW = 130.0, btnH = 44.0, gap = 14.0;
    final cy = (s.y * 0.62).clamp(220.0, s.y - 80.0).toDouble();

    final playRect = _btnRectCenter(s.x / 2 - (btnW + gap) / 2, cy, btnW, btnH);
    final exitRect = _btnRectCenter(s.x / 2 + (btnW + gap) / 2, cy, btnW, btnH);
    final pos = ui.Offset(p.x, p.y);

    if (playRect.contains(pos)) {
      () async {
        await _fade.fadeToBlack(duration: 0.18);
        _showHowTo = false;
        await _fade.fadeIn(duration: 0.18);
      }();
      return;
    }
    if (exitRect.contains(pos)) {
      () async {
        await _fade.fadeToBlack(duration: 0.18);
        onCancel?.call();
        removeFromParent();
      }();
      return;
    }
  }

  void _handleCongratsTap(Vector2 p) {
    final s = gameRef.size;
    const btnW = 130.0, btnH = 44.0;
    final cy = (s.y * 0.64).clamp(220.0, s.y - 80.0).toDouble();
    final closeRect = _btnRectCenter(s.x / 2, cy, btnW, btnH);
    final pos = ui.Offset(p.x, p.y);

    if (closeRect.contains(pos)) {
      // No local fade here — parent will do the transition
      _finishNow(); // calls onFinished and removes self
    }
  }

  @override
  void onDragStart(DragStartEvent e) {
    if (_closing || _showHowTo || _showCongrats) return;
    final p = e.canvasPosition;
    final it = _current;
    if (it != null && it.rect.contains(ui.Offset(p.x, p.y))) {
      _dragging = it;
      HapticFeedback.selectionClick();
    }
  }

  @override
  void onDragUpdate(DragUpdateEvent e) {
    if (_closing || _showHowTo || _showCongrats || _dragging == null) return;
    final d = e.canvasDelta;
    _dragging!.pos.x += d.x;
    _dragging!.pos.y += d.y;
  }

  @override
  void onDragEnd(DragEndEvent e) {
    if (_closing || _showHowTo || _showCongrats || _dragging == null) return;
    final it = _dragging!;
    _dragging = null;

    final center = it.rect.center;
    final inTrash  = _trashZone!.contains(center);
    final inFridge = _fridgeZone!.contains(center);

    if (inTrash) {
      if (it.isBad) {
        _tossedBad++;
        HapticFeedback.lightImpact();
        _advanceQueue();
      } else {
        it.pos.setFrom(it.home);
        HapticFeedback.vibrate();
      }
    } else if (inFridge) {
      if (!it.isBad) {
        _savedGood++;
        HapticFeedback.lightImpact();
        _advanceQueue();
      } else {
        it.pos.setFrom(it.home);
        HapticFeedback.vibrate();
      }
    } else {
      it.pos.setFrom(it.home);
    }
  }

  @override
  void onDragCancel(DragCancelEvent e) {
    _dragging = null;
  }

  void _advanceQueue() {
    _queueIndex++;
    _spawnCurrent();
  }

  Future<void> _finishNow() async {
    if (_closing) return;    // hard guard
    _closing = true;

    final total   = _queueSpecs.length;
    final perfect = (_tossedBad + _savedGood) == total;

    onFinished(tossedBad: _tossedBad, savedGood: _savedGood, perfect: perfect);

    // small delay to ensure we don't process further input
    await Future<void>.delayed(const Duration(milliseconds: 1));
    removeFromParent();
  }

  // render

  @override
  void render(ui.Canvas c) {
    final inner = _innerRect();

    // background
    if (_bg != null) {
      final clip = ui.RRect.fromRectAndRadius(inner, const ui.Radius.circular(14));
      c.save();
      c.clipRRect(clip);
      final src = ui.Rect.fromLTWH(0, 0, _bg!.width.toDouble(), _bg!.height.toDouble());
      c.drawImageRect(_bg!, src, inner, ui.Paint()..filterQuality = ui.FilterQuality.none);
      c.restore();
    } else {
      _fillRRect(
        c,
        ui.RRect.fromRectAndRadius(inner, const ui.Radius.circular(14)),
        const ui.Color(0xFFE7EDF4),
      );
    }

    // headings/counters
    _drawText(
      c,
      'Fridge Check',
      at: ui.Offset(inner.left + 16, inner.top + 14),
      style: const TextStyle(
        color: _uiAccent,
        fontSize: 18,
        fontWeight: ui.FontWeight.w700,
      ),
    );
    _drawText(
      c,
      'Drag spoiled food ➜ TRASH   |   Safe food ➜ FRIDGE',
      at: ui.Offset(inner.left + 16, inner.top + 40),
      style: const TextStyle(
        color: _uiAccent,
        fontSize: 12,
        fontWeight: ui.FontWeight.w500,
      ),
    );
    _drawText(
      c,
      'Tossed bad: $_tossedBad   |   Saved good: $_savedGood',
      at: ui.Offset(inner.left + 16, inner.top + 64),
      style: const TextStyle(
        color: _uiAccent,
        fontSize: 12,
        fontWeight: ui.FontWeight.w600,
      ),
    );

    // Zones
    final trash  = _trashZone!;
    final fridge = _fridgeZone!;

    _fillRRect(
      c,
      ui.RRect.fromRectAndRadius(trash, const ui.Radius.circular(12)),
      const ui.Color(0x33FF0000),
    );
    _strokeRRect(
      c,
      ui.RRect.fromRectAndRadius(trash, const ui.Radius.circular(12)),
      const ui.Color(0x66FF0000),
      2,
    );
    _drawCenteredText(
      c,
      'TRASH 🗑️',
      rect: trash,
      style: const TextStyle(
        color: _uiAccent,
        fontSize: 16,
        fontWeight: ui.FontWeight.w700,
      ),
      dy: -18,
    );

    _fillRRect(
      c,
      ui.RRect.fromRectAndRadius(fridge, const ui.Radius.circular(12)),
      const ui.Color(0x3300AA66),
    );
    _strokeRRect(
      c,
      ui.RRect.fromRectAndRadius(fridge, const ui.Radius.circular(12)),
      const ui.Color(0x6600AA66),
      2,
    );
    _drawCenteredText(
      c,
      'FRIDGE 🧊',
      rect: fridge,
      style: const TextStyle(
        color: _uiAccent,
        fontSize: 16,
        fontWeight: ui.FontWeight.w700,
      ),
      dy: -18,
    );

    // current item
    if (_current != null) {
      _drawItem(c, _current!);
    }

    // overlays last
    if (_showHowTo) {
      _renderHowTo(c);
    } else if (_showCongrats) {
      _renderCongrats(c);
    }
  }

  void _drawItem(ui.Canvas c, _FoodCard it) {
    final dst = it.rect;

    // subtle shadow
    c.drawRRect(
      ui.RRect.fromRectAndRadius(dst.inflate(6), const ui.Radius.circular(14)),
      ui.Paint()..color = const ui.Color(0x22000000),
    );

    final clip = ui.RRect.fromRectAndRadius(dst, const ui.Radius.circular(12));
    c.save();
    c.clipRRect(clip);

    final src = ui.Rect.fromLTWH(0, 0, it.image.width.toDouble(), it.image.height.toDouble());
    c.drawImageRect(it.image, src, dst, ui.Paint()..filterQuality = ui.FilterQuality.none);

    c.restore();
  }

  // overlay rendering

  void _renderPanel(
    ui.Canvas canvas,
    String title,
    String body, {
    List<({String label, ui.Rect rect, ui.Color color})>? buttons,
  }) {
    final s = gameRef.size;
    final w = (s.x * 0.84).clamp(300, 540).toDouble();
    final h = (s.y * 0.56).clamp(240, 400).toDouble();
    final panelRect = ui.Rect.fromLTWH((s.x - w) / 2, (s.y - h) / 2, w, h);

    // darkened backdrop
    canvas.drawRect(
      ui.Rect.fromLTWH(0, 0, s.x, s.y),
      ui.Paint()..color = const ui.Color(0x8C000000),
    );

    // panel
    final panel = ui.RRect.fromRectAndRadius(panelRect, const ui.Radius.circular(16));
    canvas.drawRRect(panel, ui.Paint()..color = const ui.Color(0xE6000000));

    // title
    _drawText(
      canvas,
      title,
      at: ui.Offset(panelRect.left + 14, panelRect.top + 14),
      style: const TextStyle(color: ui.Color(0xFFFFFFFF), fontSize: 18, fontWeight: ui.FontWeight.w800),
      maxWidth: w - 28,
    );

    // body
    _drawText(
      canvas,
      body,
      at: ui.Offset(panelRect.left + 14, panelRect.top + 44),
      style: const TextStyle(color: ui.Color(0xCCFFFFFF), fontSize: 14, height: 1.35),
      maxWidth: w - 28,
    );

    if (buttons != null) {
      for (final b in buttons) {
        final rr = ui.RRect.fromRectAndRadius(b.rect, const ui.Radius.circular(8));
        canvas.drawRRect(rr, ui.Paint()..color = b.color);
        final tp = TextPainter(
          text: TextSpan(
            text: b.label,
            style: const TextStyle(color: ui.Color(0xFFFFFFFF), fontSize: 15, fontWeight: ui.FontWeight.w700),
          ),
          textDirection: ui.TextDirection.ltr,
        )..layout();
        tp.paint(canvas, ui.Offset(b.rect.center.dx - tp.width / 2, b.rect.center.dy - tp.height / 2));
      }
    }
  }

  ui.Rect _btnRectCenter(double cx, double cy, double w, double h) =>
      ui.Rect.fromCenter(center: ui.Offset(cx, cy), width: w, height: h);

  void _renderHowTo(ui.Canvas canvas) {
    final s = gameRef.size;
    const btnW = 130.0, btnH = 44.0, gap = 14.0;
    final cy = (s.y * 0.62).clamp(220.0, s.y - 80.0).toDouble();

    final playRect = _btnRectCenter(s.x / 2 - (btnW + gap) / 2, cy, btnW, btnH);
    final exitRect = _btnRectCenter(s.x / 2 + (btnW + gap) / 2, cy, btnW, btnH);

    _renderPanel(
      canvas,
      'Fridge Mini-Game',
      'Drag each food item into the correct bin:\n'
      '• Toss spoiled items\n'
      '• Save good items\n\n'
      'Finish all items to complete the task.',
      buttons: [
        (label: 'Play',  rect: playRect, color: const ui.Color(0xFF2E7D32)),
        (label: 'Exit',  rect: exitRect, color: const ui.Color(0xFFC62828)),
      ],
    );
  }

  void _renderCongrats(ui.Canvas canvas) {
    final s = gameRef.size;
    const btnW = 130.0, btnH = 44.0;
    final cy = (s.y * 0.64).clamp(220.0, s.y - 80.0).toDouble();
    final closeRect = _btnRectCenter(s.x / 2, cy, btnW, btnH);

    _renderPanel(
      canvas,
      'Nice work!',
      'All items sorted correctly.\nThis task is complete.',
      buttons: [
        (label: 'Close', rect: closeRect, color: const ui.Color(0xFF2E7D32)),
      ],
    );
  }

  // draw helpers

  void _fillRRect(ui.Canvas c, ui.RRect rr, ui.Color color) {
    final p = ui.Paint()..color = color;
    c.drawRRect(rr, p);
  }

  void _strokeRRect(ui.Canvas c, ui.RRect rr, ui.Color color, double width) {
    final p = ui.Paint()
      ..color = color
      ..style = ui.PaintingStyle.stroke
      ..strokeWidth = width;
    c.drawRRect(rr, p);
  }

  void _drawText(ui.Canvas c, String text,
      {required ui.Offset at, required TextStyle style, double maxWidth = 1000}) {
    final tp = TextPainter(
      text: TextSpan(text: text, style: style),
      textDirection: ui.TextDirection.ltr,
      textAlign: TextAlign.left,
    )..layout(minWidth: 0, maxWidth: maxWidth);
    tp.paint(c, at);
  }

  void _drawCenteredText(ui.Canvas c, String text,
      {required ui.Rect rect, required TextStyle style, double dy = 0}) {
    final tp = TextPainter(
      text: TextSpan(text: text, style: style),
      textDirection: ui.TextDirection.ltr,
      textAlign: TextAlign.center,
    )..layout(minWidth: 0, maxWidth: rect.width);
    final offset = ui.Offset(
      rect.left + (rect.width - tp.width) / 2,
      rect.top + (rect.height - tp.height) / 2 + dy,
    );
    tp.paint(c, offset);
  }
}

// models
class _FoodItemSpec {
  final String name;
  final String asset;
  final bool isBad;
  _FoodItemSpec(this.name, this.asset, this.isBad);
}

class _FoodCard {
  _FoodCard({required this.image, required this.sizePx, required this.isBad})
      : pos = Vector2.zero(),
        home = Vector2.zero();

  final ui.Image image;
  final Vector2 sizePx;
  final bool isBad;
  final Vector2 pos;
  final Vector2 home;

  ui.Rect get rect => ui.Rect.fromLTWH(
        pos.x - sizePx.x / 2,
        pos.y - sizePx.y / 2,
        sizePx.x,
        sizePx.y,
      );
}

/// Local fade overlay used inside the mini-game only
class _MiniFade extends PositionComponent {
  _MiniFade({required Vector2 size}) {
    this.size = size;
    position = Vector2.zero();
  }

  double _alpha = 0.0;
  double _target = 0.0;
  double _speed = 0.0;
  Completer<void>? _anim;

  @override
  void render(ui.Canvas canvas) {
    if (_alpha <= 0) return;
    final p = ui.Paint()..color = const ui.Color(0xFF000000).withOpacity(_alpha);
    canvas.drawRect(ui.Rect.fromLTWH(0, 0, size.x, size.y), p);
  }

  @override
  void update(double dt) {
    super.update(dt);
    if ((_alpha - _target).abs() < 1e-4) return;

    final dir = _alpha < _target ? 1.0 : -1.0;
    _alpha += dir * _speed * dt;

    // clamp + finish
    if ((dir > 0 && _alpha >= _target) || (dir < 0 && _alpha <= _target)) {
      _alpha = _target;
      _anim?.complete();
      _anim = null;
    }

    if (_alpha < 0) _alpha = 0;
    if (_alpha > 1) _alpha = 1;
  }

  Future<void> fadeToBlack({double duration = 0.28}) {
    // cancel any prior waiter
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

  Future<void> fadeIn({double duration = 0.28}) {
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
