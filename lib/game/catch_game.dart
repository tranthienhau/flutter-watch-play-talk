import 'dart:math';
import 'dart:ui';

import 'package:flame/components.dart';
import 'package:flame/events.dart';
import 'package:flame/game.dart';
import 'package:flutter/material.dart' show Colors, TextStyle, FontWeight, ValueNotifier;

import '../theme/tokens.dart';
import 'game_settings.dart';

/// "Catch" template: steer a basket left and right to catch the falling
/// target items. No fail state, no timer, gentle speed. Content (target,
/// distractors, goal, speed) comes from approved [GameSettings].
class CatchGame extends FlameGame {
  CatchGame({required this.settings, this.autoplay = false, this.onWin});

  final GameSettings settings;
  final bool autoplay;
  final VoidCallback? onWin;

  final score = ValueNotifier<int>(0);

  /// -1 left, 0 idle, 1 right (held arrow buttons).
  int steer = 0;
  late Basket basket;
  final _rng = Random(7);
  double _spawnClock = 0;
  bool _won = false;
  int _sinceTarget = 0;

  @override
  Color backgroundColor() => const Color(0x00000000);

  @override
  Future<void> onLoad() async {
    basket = Basket()..position = Vector2(size.x / 2, size.y - 70);
    add(basket);
  }

  @override
  void onGameResize(Vector2 size) {
    super.onGameResize(size);
    if (isLoaded) basket.position.y = size.y - 70;
  }

  @override
  void update(double dt) {
    super.update(dt);
    if (_won) return;

    _spawnClock += dt * 1000;
    if (_spawnClock >= settings.spawnEveryMs) {
      _spawnClock = 0;
      _spawn();
    }

    // Steering.
    var dir = steer.toDouble();
    if (autoplay) {
      final targets = children.whereType<FallingItem>().where((i) => i.isTarget && !i.caught).toList()
        ..sort((a, b) => b.position.y.compareTo(a.position.y));
      if (targets.isNotEmpty) {
        final dx = targets.first.position.x - basket.position.x;
        dir = dx.abs() < 6 ? 0 : dx.sign;
      }
    }
    basket.position.x = (basket.position.x + dir * 300 * dt).clamp(50, size.x - 50);

    // Catch check.
    for (final item in children.whereType<FallingItem>()) {
      if (item.caught) continue;
      final dy = item.position.y - (basket.position.y - 28);
      if (dy.abs() < 22 && (item.position.x - basket.position.x).abs() < 52) {
        item.caught = true;
        if (item.isTarget) {
          score.value++;
          basket.bounce();
          add(Floater('¡Muy bien! +1', basket.position + Vector2(0, -78), AppColors.accentFill));
          item.removeFromParent();
          if (score.value >= settings.goal) {
            _won = true;
            add(Floater('⭐ ¡Ganaste! ⭐', Vector2(size.x / 2, size.y / 2 - 40), AppColors.accentFill, big: true));
            Future.delayed(const Duration(milliseconds: 1400), () => onWin?.call());
          }
        } else {
          add(Floater(FallingItem.label(item.kind), basket.position + Vector2(0, -78), AppColors.textTertiary));
          item.bounceAway();
        }
      }
    }
  }

  void _spawn() {
    // Keep targets frequent: at least one in every three spawns.
    final forceTarget = _sinceTarget >= 2;
    final isTarget = forceTarget || _rng.nextDouble() < 0.5;
    _sinceTarget = isTarget ? 0 : _sinceTarget + 1;
    final kind = isTarget ? settings.target : settings.distractors[_rng.nextInt(settings.distractors.length)];
    final x = 40 + _rng.nextDouble() * (size.x - 80);
    add(FallingItem(kind: kind, isTarget: isTarget, speed: settings.fallSpeed * (0.85 + _rng.nextDouble() * 0.3))
      ..position = Vector2(x, -30));
  }
}

class Basket extends PositionComponent with DragCallbacks, HasGameReference<CatchGame> {
  Basket() : super(size: Vector2(112, 76), anchor: Anchor.center);

  double _bounce = 0;
  void bounce() => _bounce = 1;

  @override
  void onDragUpdate(DragUpdateEvent event) {
    position.x = (position.x + event.localDelta.x).clamp(50, game.size.x - 50);
  }

  @override
  void update(double dt) {
    _bounce = max(0, _bounce - dt * 4);
  }

  @override
  void render(Canvas canvas) {
    final c = canvas;
    final squash = sin(_bounce * pi) * 6;
    final w = size.x, h = size.y - squash;
    c.save();
    c.translate(0, squash);
    // Body.
    final body = Path()
      ..moveTo(4, 14)
      ..lineTo(w - 4, 14)
      ..quadraticBezierTo(w - 10, h, w / 2, h)
      ..quadraticBezierTo(10, h, 4, 14)
      ..close();
    c.drawPath(body, Paint()..color = const Color(0xFFFF9C80));
    // Weave lines.
    final weave = Paint()
      ..color = const Color(0xFFE97A5E)
      ..strokeWidth = 2.5
      ..style = PaintingStyle.stroke;
    for (var i = 1; i < 5; i++) {
      c.drawLine(Offset(w * i / 5, 16), Offset(w * i / 5 + (i - 2.5) * -4, h - 6), weave);
    }
    c.drawLine(Offset(10, 34), Offset(w - 10, 34), weave);
    // Rim.
    c.drawRRect(RRect.fromRectAndRadius(Rect.fromLTWH(0, 6, w, 14), const Radius.circular(7)), Paint()..color = const Color(0xFFE5383B));
    // Face.
    final ink = Paint()..color = const Color(0xFF3A2A2A);
    c.drawCircle(Offset(w / 2 - 16, 44), 4, ink);
    c.drawCircle(Offset(w / 2 + 16, 44), 4, ink);
    c.drawArc(Rect.fromCenter(center: Offset(w / 2, 50), width: 18, height: 12), 0.2, pi - 0.4, false,
        ink..style = PaintingStyle.stroke..strokeWidth = 3..strokeCap = StrokeCap.round);
    c.drawCircle(Offset(w / 2 - 28, 52), 5, Paint()..color = const Color(0x66FF6B6B));
    c.drawCircle(Offset(w / 2 + 28, 52), 5, Paint()..color = const Color(0x66FF6B6B));
    c.restore();

    // Name tag.
    _tag(c, 'Canastita', Offset(w / 2, size.y + 18));
  }

  void _tag(Canvas c, String text, Offset center) {
    final tp = TextPaint(style: const TextStyle(fontFamily: AppFonts.body, fontSize: 13, fontWeight: FontWeight.w600, color: AppColors.textPrimary));
    final m = tp.getLineMetrics(text);
    final r = RRect.fromRectAndRadius(
      Rect.fromCenter(center: center, width: m.width + 24, height: 26),
      const Radius.circular(13),
    );
    c.drawRRect(r, Paint()..color = Colors.white);
    tp.render(c, text, Vector2(center.dx, center.dy), anchor: Anchor.center);
  }
}

class FallingItem extends PositionComponent with HasGameReference<CatchGame> {
  FallingItem({required this.kind, required this.isTarget, required this.speed})
      : super(size: Vector2.all(52), anchor: Anchor.center);

  final String kind;
  final bool isTarget;
  final double speed;
  bool caught = false;
  double _t = 0;
  Vector2? _away;

  static String label(String kind) => switch (kind) {
        'apple' => '¡Rojo!',
        'blueberry' => 'Azul',
        'banana' => 'Amarillo',
        'star' => 'Estrella',
        'sun' => 'Sol',
        'hand' => '¡Hola!',
        'number3' => 'Tres',
        _ => kind,
      };

  void bounceAway() => _away = Vector2(position.x < game.size.x / 2 ? -180 : 180, -260);

  @override
  void update(double dt) {
    _t += dt;
    if (_away != null) {
      _away!.y += 700 * dt;
      position += _away! * dt;
      angle += dt * 6;
    } else {
      position.y += speed * dt;
      angle = sin(_t * 3) * 0.12;
    }
    if (position.y > game.size.y + 60 || position.x < -80 || position.x > game.size.x + 80) {
      removeFromParent();
    }
  }

  @override
  void render(Canvas canvas) {
    final c = canvas;
    final ctr = Offset(size.x / 2, size.y / 2);
    switch (kind) {
      case 'apple':
        _apple(c, ctr);
      case 'blueberry':
        _blueberry(c, ctr);
      case 'banana':
        _banana(c, ctr);
      case 'star':
        _star(c, ctr, 22, AppColors.gameYellow);
      case 'sun':
        _sun(c, ctr);
      case 'hand':
        TextPaint(style: const TextStyle(fontSize: 40)).render(c, '👋', Vector2(ctr.dx, ctr.dy), anchor: Anchor.center);
      case 'number3':
        c.drawCircle(ctr, 24, Paint()..color = AppColors.accentFill);
        TextPaint(style: const TextStyle(fontFamily: AppFonts.display, fontSize: 30, fontWeight: FontWeight.w700, color: Colors.white))
            .render(c, '3', Vector2(ctr.dx, ctr.dy), anchor: Anchor.center);
    }
    if (isTarget) _labelTag(c, label(kind), Offset(ctr.dx, size.y + 14), AppColors.gameRed);
  }

  void _labelTag(Canvas c, String text, Offset center, Color color) {
    final tp = TextPaint(style: TextStyle(fontFamily: AppFonts.body, fontSize: 12, fontWeight: FontWeight.w700, color: color));
    final m = tp.getLineMetrics(text);
    c.drawRRect(
      RRect.fromRectAndRadius(Rect.fromCenter(center: center, width: m.width + 16, height: 22), const Radius.circular(11)),
      Paint()..color = const Color(0xFFFFEDE6),
    );
    tp.render(c, text, Vector2(center.dx, center.dy), anchor: Anchor.center);
  }

  void _face(Canvas c, Offset o) {
    final ink = Paint()..color = const Color(0xFF3A2A2A);
    c.drawCircle(o + const Offset(-7, 0), 2.6, ink);
    c.drawCircle(o + const Offset(7, 0), 2.6, ink);
    c.drawArc(Rect.fromCenter(center: o + const Offset(0, 5), width: 10, height: 7), 0.3, pi - 0.6, false,
        ink..style = PaintingStyle.stroke..strokeWidth = 2..strokeCap = StrokeCap.round);
  }

  void _apple(Canvas c, Offset o) {
    c.drawCircle(o + const Offset(-8, 4), 18, Paint()..color = AppColors.gameRed);
    c.drawCircle(o + const Offset(8, 4), 18, Paint()..color = AppColors.gameRed);
    c.drawCircle(o + const Offset(-10, -2), 5, Paint()..color = const Color(0x55FFFFFF));
    c.drawLine(o + const Offset(0, -12), o + const Offset(2, -22),
        Paint()..color = const Color(0xFF7C4A2D)..strokeWidth = 3.5..strokeCap = StrokeCap.round);
    final leaf = Path()
      ..moveTo(o.dx + 3, o.dy - 18)
      ..quadraticBezierTo(o.dx + 16, o.dy - 30, o.dx + 20, o.dy - 18)
      ..quadraticBezierTo(o.dx + 10, o.dy - 14, o.dx + 3, o.dy - 18);
    c.drawPath(leaf, Paint()..color = const Color(0xFF22A06B));
    _face(c, o + const Offset(0, 6));
  }

  void _blueberry(Canvas c, Offset o) {
    final p = Paint()..color = AppColors.gameBlue;
    c.drawCircle(o + const Offset(-9, 6), 14, p);
    c.drawCircle(o + const Offset(9, -4), 15, Paint()..color = const Color(0xFF2563EB));
    c.drawCircle(o + const Offset(5, -10), 4, Paint()..color = const Color(0x55FFFFFF));
    _face(c, o + const Offset(-9, 6));
  }

  void _banana(Canvas c, Offset o) {
    final path = Path()
      ..moveTo(o.dx - 24, o.dy - 10)
      ..quadraticBezierTo(o.dx - 6, o.dy + 26, o.dx + 24, o.dy - 6)
      ..quadraticBezierTo(o.dx + 2, o.dy + 10, o.dx - 24, o.dy - 10)
      ..close();
    c.drawPath(path, Paint()..color = AppColors.gameYellow);
    c.drawPath(path, Paint()..color = const Color(0xFFCA9A04)..style = PaintingStyle.stroke..strokeWidth = 2);
    c.drawCircle(Offset(o.dx - 24, o.dy - 10), 3, Paint()..color = const Color(0xFF7C4A2D));
  }

  void _star(Canvas c, Offset o, double r, Color color) {
    final p = Path();
    for (var i = 0; i < 10; i++) {
      final rad = i.isEven ? r : r * 0.48;
      final a = -pi / 2 + i * pi / 5;
      final pt = o + Offset(cos(a) * rad, sin(a) * rad);
      i == 0 ? p.moveTo(pt.dx, pt.dy) : p.lineTo(pt.dx, pt.dy);
    }
    p.close();
    c.drawPath(p, Paint()..color = color);
  }

  void _sun(Canvas c, Offset o) {
    final ray = Paint()
      ..color = const Color(0xFFF59E0B)
      ..strokeWidth = 4
      ..strokeCap = StrokeCap.round;
    for (var i = 0; i < 8; i++) {
      final a = i * pi / 4;
      c.drawLine(o + Offset(cos(a) * 18, sin(a) * 18), o + Offset(cos(a) * 25, sin(a) * 25), ray);
    }
    c.drawCircle(o, 15, Paint()..color = AppColors.gameYellow);
    _face(c, o + const Offset(0, 1));
  }
}

/// Floating feedback text that rises and fades.
class Floater extends PositionComponent {
  Floater(this.text, Vector2 at, this.color, {this.big = false}) : super(position: at.clone(), anchor: Anchor.center);
  final String text;
  final Color color;
  final bool big;
  double _life = 0;

  @override
  void update(double dt) {
    _life += dt;
    position.y -= dt * (big ? 10 : 40);
    if (_life > (big ? 1.6 : 0.9)) removeFromParent();
  }

  @override
  void render(Canvas canvas) {
    final c = canvas;
    final fade = (1 - (_life / (big ? 1.6 : 0.9))).clamp(0.0, 1.0);
    final tp = TextPaint(
      style: TextStyle(
        fontFamily: AppFonts.display,
        fontSize: big ? 34 : 18,
        fontWeight: FontWeight.w700,
        color: color.withValues(alpha: fade),
      ),
    );
    final m = tp.getLineMetrics(text);
    c.drawRRect(
      RRect.fromRectAndRadius(Rect.fromCenter(center: Offset.zero, width: m.width + 28, height: big ? 60 : 34), const Radius.circular(30)),
      Paint()..color = Colors.white.withValues(alpha: fade * 0.95),
    );
    tp.render(c, text, Vector2.zero(), anchor: Anchor.center);
  }
}
