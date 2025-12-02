import 'dart:async';
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
    with TapCallbacks, HasGameRef<FlameGame> {
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
    _FoodItemSpec(
      id: 'burgerBad',
      asset: 'assets/images/burgerBad.png',
      isBad: true,
      label: 'Burger',
      expiration: '3 days ago',
      note: 'Looks gray and smells funky.',
    ),
    _FoodItemSpec(
      id: 'burgerGood',
      asset: 'assets/images/burgerGood.png',
      isBad: false,
      label: 'Burger',
      expiration: 'In 2 days',
      note: 'Color looks fresh and normal.',
    ),
    _FoodItemSpec(
      id: 'cheeseBad',
      asset: 'assets/images/cheeseBad.png',
      isBad: true,
      label: 'Cheese',
      expiration: '1 week ago',
      note: 'Visible mold spots on the surface.',
    ),
    _FoodItemSpec(
      id: 'eggsGood',
      asset: 'assets/images/eggsGood.png',
      isBad: false,
      label: 'Eggs',
      expiration: '2027',
      note: 'Shells look clean and intact.',
    ),
    _FoodItemSpec(
      id: 'eggsBad',
      asset: 'assets/images/eggsBad.png',
      isBad: true,
      label: 'Eggs',
      expiration: '10 days ago',
      note: 'Shells are cracked and smell bad.',
    ),
    _FoodItemSpec(
      id: 'milkBad',
      asset: 'assets/images/milkBad.png',
      isBad: true,
      label: 'Milk',
      expiration: '4 days ago',
      note: 'Smells sour and looks chunky.',
    ),
    _FoodItemSpec(
      id: 'yogurtGood',
      asset: 'assets/images/yogurtGood.png',
      isBad: false,
      label: 'Yogurt',
      expiration: '2027',
      note: 'Sealed and looks normal.',
    ),
  ];

  // current index
  int _queueIndex = 0;

  // results
  int _tossedBad = 0;
  int _savedGood = 0;

  // finish guard to ensure overlay closes exactly once
  bool _closing = false;

  // for tap handling on decision buttons
  ui.Rect? _keepBtnRect;
  ui.Rect? _trashBtnRect;

  // high-contrast accent (used rarely now)
  static const ui.Color _uiAccent = ui.Color(0xFF8A8A8A);

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
  }

  @override
  void onMount() {
    super.onMount();
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

    // keep fade sized correctly
    _fade.size = size;
    _fade.position = Vector2.zero();
  }

  ui.Rect _innerRect() => ui.Rect.fromLTWH(12, 12, size.x - 24, size.y - 24);

  bool get _done => _queueIndex >= _queueSpecs.length;

  _FoodItemSpec? get _currentSpec =>
      _done ? null : _queueSpecs[_queueIndex];

  // input

  @override
  void onTapUp(TapUpEvent e) {
    final p = e.localPosition;
    final pos = ui.Offset(p.x, p.y);

    if (_showHowTo) {
      _handleHowToTap(pos);
      e.handled = true;
      return;
    }

    if (_showCongrats) {
      _handleCongratsTap(pos);
      e.handled = true;
      return;
    }

    // check Keep / Trash buttons
    if (_keepBtnRect != null && _keepBtnRect!.contains(pos)) {
      e.handled = true;
      _handleChoice(keep: true);
      return;
    }
    if (_trashBtnRect != null && _trashBtnRect!.contains(pos)) {
      e.handled = true;
      _handleChoice(keep: false);
      return;
    }
  }

  void _handleHowToTap(ui.Offset pos) {
    final s = gameRef.size;
    const btnW = 130.0, btnH = 44.0, gap = 14.0;
    final cy = (s.y * 0.62).clamp(220.0, s.y - 80.0).toDouble();

    final playRect = _btnRectCenter(s.x / 2 - (btnW + gap) / 2, cy, btnW, btnH);
    final exitRect = _btnRectCenter(s.x / 2 + (btnW + gap) / 2, cy, btnW, btnH);

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

  void _handleCongratsTap(ui.Offset pos) {
    final s = gameRef.size;
    const btnW = 130.0, btnH = 44.0;
    final cy = (s.y * 0.64).clamp(220.0, s.y - 80.0).toDouble();
    final closeRect = _btnRectCenter(s.x / 2, cy, btnW, btnH);

    if (closeRect.contains(pos)) {
      _finishNow();
    }
  }

  void _handleChoice({required bool keep}) {
    if (_done) return;
    final spec = _queueSpecs[_queueIndex];

    final bool isCorrect =
        keep ? !spec.isBad : spec.isBad; // keep good, trash bad

    if (isCorrect) {
      if (spec.isBad) {
        _tossedBad++;
      } else {
        _savedGood++;
      }
      HapticFeedback.lightImpact();
    } else {
      HapticFeedback.vibrate();
    }

    _queueIndex++;

    if (_queueIndex >= _queueSpecs.length) {
      _showCongrats = true;
    }
  }

  Future<void> _finishNow() async {
    if (_closing) return; // hard guard
    _closing = true;

    final total = _queueSpecs.length;
    final perfect = (_tossedBad + _savedGood) == total;

    onFinished(
      tossedBad: _tossedBad,
      savedGood: _savedGood,
      perfect: perfect,
    );

    await Future<void>.delayed(const Duration(milliseconds: 1));
    removeFromParent();
  }

  // render

  @override
  void render(ui.Canvas c) {
    final inner = _innerRect();

    // background fridge art
    if (_bg != null) {
      final clip =
          ui.RRect.fromRectAndRadius(inner, const ui.Radius.circular(14));
      c.save();
      c.clipRRect(clip);
      final src = ui.Rect.fromLTWH(
        0,
        0,
        _bg!.width.toDouble(),
        _bg!.height.toDouble(),
      );
      c.drawImageRect(
        _bg!,
        src,
        inner,
        ui.Paint()..filterQuality = ui.FilterQuality.none,
      );
      c.restore();
    } else {
      _fillRRect(
        c,
        ui.RRect.fromRectAndRadius(inner, const ui.Radius.circular(14)),
        const ui.Color(0xFFE7EDF4),
      );
    }

    // overlays last
    if (_showHowTo) {
      _renderHowTo(c);
    } else if (_showCongrats) {
      _renderCongrats(c);
    } else {
      _renderDecisionDialog(c);
    }
  }

  void _renderDecisionDialog(ui.Canvas canvas) {
    final spec = _currentSpec;
    if (spec == null) return;

    final img = _images[spec.asset];

    final s = gameRef.size;
    final double w = (s.x * 0.86).clamp(280.0, 520.0);
    final double h = (s.y * 0.63).clamp(260.0, 420.0);
    final ui.Rect panelRect =
        ui.Rect.fromLTWH((s.x - w) / 2, s.y - h - 20, w, h);

    // darkened backdrop
    canvas.drawRect(
      ui.Rect.fromLTWH(0, 0, s.x, s.y),
      ui.Paint()..color = const ui.Color(0xAA000000),
    );

    // dialog bubble
    final ui.RRect bubble =
        ui.RRect.fromRectAndRadius(panelRect, const ui.Radius.circular(16));
    canvas.drawRRect(
      bubble,
      ui.Paint()..color = const ui.Color(0xFFFAFAFA),
    );

    // Image at the top of the bubble
    if (img != null) {
      const double imgPad = 14.0;
      const double imgH = 200.0;

      final ui.Rect imgRect = ui.Rect.fromLTWH(
        panelRect.left + imgPad,
        panelRect.top + imgPad,
        panelRect.width - imgPad * 2,
        imgH,
      );

      final ui.RRect imgClip = ui.RRect.fromRectAndRadius(
        imgRect,
        const ui.Radius.circular(10),
      );
      canvas.save();
      canvas.clipRRect(imgClip);

      final ui.Rect src = ui.Rect.fromLTWH(
        0,
        0,
        img.width.toDouble(),
        img.height.toDouble(),
      );
      canvas.drawImageRect(
        img,
        src,
        imgRect,
        ui.Paint()..filterQuality = ui.FilterQuality.none,
      );
      canvas.restore();
    }

    // Text lines under the image
    const double textPadX = 16.0;
    double textY = panelRect.top + 220.0;

    void drawLine(String label, String value) {
      final tp = TextPainter(
        text: TextSpan(
          text: '$label ',
          style: const TextStyle(
            color: ui.Color(0xFF000000),
            fontSize: 14,
            fontWeight: ui.FontWeight.w700,
          ),
          children: [
            TextSpan(
              text: value,
              style: const TextStyle(
                color: ui.Color(0xFF333333),
                fontSize: 14,
                fontWeight: ui.FontWeight.w400,
              ),
            ),
          ],
        ),
        textDirection: ui.TextDirection.ltr,
      )..layout(maxWidth: panelRect.width - textPadX * 2);

      tp.paint(canvas, ui.Offset(panelRect.left + textPadX, textY));
      textY += tp.height + 6;
    }

    drawLine('Item:', spec.label);
    drawLine('Expiration:', spec.expiration);
    drawLine('Note:', spec.note);

    // Buttons at the bottom
    const double btnW = 110.0;
    const double btnH = 40.0;
    const double btnGap = 18.0;
    final double btnCy = panelRect.bottom - 20.0 - btnH / 2;

    final ui.Rect trashRect = ui.Rect.fromCenter(
      center: ui.Offset(
        panelRect.center.dx - (btnW / 2 + btnGap / 2),
        btnCy,
      ),
      width: btnW,
      height: btnH,
    );

    final ui.Rect keepRect = ui.Rect.fromCenter(
      center: ui.Offset(
        panelRect.center.dx + (btnW / 2 + btnGap / 2),
        btnCy,
      ),
      width: btnW,
      height: btnH,
    );

    // store for tap handling
    _trashBtnRect = trashRect;
    _keepBtnRect = keepRect;

    void drawButton(ui.Rect r, String label, ui.Color color) {
      final ui.RRect rr =
          ui.RRect.fromRectAndRadius(r, const ui.Radius.circular(8));
      canvas.drawRRect(rr, ui.Paint()..color = color);

      final tp = TextPainter(
        text: TextSpan(
          text: label,
          style: const TextStyle(
            color: ui.Color(0xFFFFFFFF),
            fontSize: 15,
            fontWeight: ui.FontWeight.w700,
          ),
        ),
        textDirection: ui.TextDirection.ltr,
      )..layout();

      tp.paint(
        canvas,
        ui.Offset(
          r.center.dx - tp.width / 2,
          r.center.dy - tp.height / 2,
        ),
      );
    }

    drawButton(trashRect, 'TRASH', const ui.Color(0xFFC62828));
    drawButton(keepRect, 'KEEP', const ui.Color(0xFF2E7D32));
  }

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
    final panel =
        ui.RRect.fromRectAndRadius(panelRect, const ui.Radius.circular(16));
    canvas.drawRRect(panel, ui.Paint()..color = const ui.Color(0xE6000000));

    // title
    _drawText(
      canvas,
      title,
      at: ui.Offset(panelRect.left + 14, panelRect.top + 14),
      style: const TextStyle(
        color: ui.Color(0xFFFFFFFF),
        fontSize: 18,
        fontWeight: ui.FontWeight.w800,
      ),
      maxWidth: w - 28,
    );

    // body
    _drawText(
      canvas,
      body,
      at: ui.Offset(panelRect.left + 14, panelRect.top + 44),
      style: const TextStyle(
        color: ui.Color(0xCCFFFFFF),
        fontSize: 14,
        height: 1.35,
      ),
      maxWidth: w - 28,
    );

    if (buttons != null) {
      for (final b in buttons) {
        final rr =
            ui.RRect.fromRectAndRadius(b.rect, const ui.Radius.circular(8));
        canvas.drawRRect(rr, ui.Paint()..color = b.color);
        final tp = TextPainter(
          text: TextSpan(
            text: b.label,
            style: const TextStyle(
              color: ui.Color(0xFFFFFFFF),
              fontSize: 15,
              fontWeight: ui.FontWeight.w700,
            ),
          ),
          textDirection: ui.TextDirection.ltr,
        )..layout();
        tp.paint(
          canvas,
          ui.Offset(
            b.rect.center.dx - tp.width / 2,
            b.rect.center.dy - tp.height / 2,
          ),
        );
      }
    }
  }

  ui.Rect _btnRectCenter(double cx, double cy, double w, double h) =>
      ui.Rect.fromCenter(center: ui.Offset(cx, cy), width: w, height: h);

  void _renderHowTo(ui.Canvas canvas) {
    final s = gameRef.size;
    const btnW = 130.0, btnH = 44.0, gap = 14.0;
    final cy = (s.y * 0.62).clamp(220.0, s.y - 80.0).toDouble();

    final playRect = _btnRectCenter(
      s.x / 2 - (btnW + gap) / 2,
      cy,
      btnW,
      btnH,
    );
    final exitRect = _btnRectCenter(
      s.x / 2 + (btnW + gap) / 2,
      cy,
      btnW,
      btnH,
    );

    _renderPanel(
      canvas,
      'Fridge Mini-Game',
      'Check each item carefully.\n\n'
      'At the bottom of the screen, you\'ll see:\n'
      '• Details about the food\n'
      '• Buttons to KEEP it or TRASH it\n\n'
      'Try to keep safe food and throw away spoiled food.',
      buttons: [
        (label: 'Play', rect: playRect, color: const ui.Color(0xFF2E7D32)),
        (label: 'Exit', rect: exitRect, color: const ui.Color(0xFFC62828)),
      ],
    );
  }

  void _renderCongrats(ui.Canvas canvas) {
    final s = gameRef.size;
    const btnW = 130.0, btnH = 44.0;
    final cy = (s.y * 0.64).clamp(220.0, s.y - 80.0).toDouble();
    final closeRect = _btnRectCenter(s.x / 2, cy, btnW, btnH);

    final int total = _queueSpecs.length;

    _renderPanel(
      canvas,
      'Nice work!',
      'You finished checking the fridge.\n\n'
      'Tossed spoiled: $_tossedBad\n'
      'Saved safe: $_savedGood\n'
      'Total items: $total',
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

  void _drawText(
    ui.Canvas c,
    String text, {
    required ui.Offset at,
    required TextStyle style,
    double maxWidth = 1000,
  }) {
    final tp = TextPainter(
      text: TextSpan(text: text, style: style),
      textDirection: ui.TextDirection.ltr,
      textAlign: TextAlign.left,
    )..layout(minWidth: 0, maxWidth: maxWidth);
    tp.paint(c, at);
  }
}

// models

class _FoodItemSpec {
  final String id;
  final String asset;
  final bool isBad;
  final String label;
  final String expiration;
  final String note;

  const _FoodItemSpec({
    required this.id,
    required this.asset,
    required this.isBad,
    required this.label,
    required this.expiration,
    required this.note,
  });
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
    final p =
        ui.Paint()..color = const ui.Color(0xFF000000).withOpacity(_alpha);
    canvas.drawRect(
      ui.Rect.fromLTWH(0, 0, size.x, size.y),
      p,
    );
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