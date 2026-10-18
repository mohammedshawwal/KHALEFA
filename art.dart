import 'dart:math';
import 'package:flutter/material.dart';
import 'data.dart';

/// رسم المنتج بالكود (طبق خشب فيه كومة بهار، برطمان عسل، زجاجة زيت)
class ProductArt extends StatelessWidget {
  final Product p;
  const ProductArt(this.p, {super.key});
  @override
  Widget build(BuildContext context) => AspectRatio(aspectRatio: 160 / 130, child: CustomPaint(painter: _Art(p)));
}

class _Art extends CustomPainter {
  final Product p;
  _Art(this.p);
  @override
  bool shouldRepaint(covariant CustomPainter old) => false;

  @override
  void paint(Canvas c, Size s) {
    c.scale(s.width / 160, s.height / 130);
    final col = Color(p.color);
    c.drawOval(Rect.fromCenter(center: const Offset(80, 118), width: 116, height: 14), Paint()..color = Colors.black.withOpacity(.18));
    if (p.kind == 'o') {
      _bottle(c, col);
    } else if (p.kind == 'h') {
      _honey(c, col);
    } else {
      _bowl(c, col);
    }
  }

  void _bowl(Canvas c, Color col) {
    final wood = Paint()
      ..shader = const LinearGradient(colors: [Color(0xFF8A5A30), Color(0xFFC08A50), Color(0xFF6B4220)]).createShader(const Rect.fromLTWH(18, 70, 124, 46));
    c.drawPath(Path()..moveTo(18, 72)..quadraticBezierTo(22, 114, 80, 116)..quadraticBezierTo(138, 114, 142, 72)..close(), wood);
    c.drawOval(Rect.fromCenter(center: const Offset(80, 72), width: 124, height: 32), Paint()..color = const Color(0xFF4A2E14));
    final m = Path()
      ..moveTo(26, 74)..quadraticBezierTo(40, 44, 62, 46)..quadraticBezierTo(72, 24, 94, 40)
      ..quadraticBezierTo(120, 38, 134, 74)..quadraticBezierTo(80, 98, 26, 74);
    c.drawPath(m, Paint()..color = col);
    c.save();
    c.clipPath(m);
    final r = Random(p.id);
    for (var i = 0; i < 170; i++) {
      c.drawCircle(Offset(26 + r.nextDouble() * 108, 28 + r.nextDouble() * 62), .6 + r.nextDouble() * 1.2,
          Paint()..color = i.isEven ? Colors.black.withOpacity(.25) : Colors.white.withOpacity(.32));
    }
    c.drawPath(
        m,
        Paint()
          ..shader = const RadialGradient(center: Alignment(-.2, -.5), radius: .9, colors: [Color(0x61FFFFFF), Color(0x00FFFFFF), Color(0x66000000)], stops: [0, .55, 1])
              .createShader(const Rect.fromLTWH(26, 24, 108, 74)));
    c.restore();
    c.drawPath(Path()..moveTo(18, 72)..quadraticBezierTo(80, 100, 142, 72), Paint()..style = PaintingStyle.stroke..strokeWidth = 3..color = const Color(0xFFDCAE72));
    _acc(c);
  }

  void _acc(Canvas c) {
    void stick(double y1, double y2, Color a, Color b) {
      c.drawLine(Offset(18, y1), Offset(76, y1 - 8), Paint()..color = a..strokeWidth = 8..strokeCap = StrokeCap.round);
      c.drawLine(Offset(20, y2), Offset(84, y2 - 10), Paint()..color = b..strokeWidth = 8..strokeCap = StrokeCap.round);
    }
    void leaf(double x, double y, double rot, Color f) {
      c.save();
      c.translate(x, y);
      c.rotate(rot);
      c.drawOval(Rect.fromCenter(center: Offset.zero, width: 24, height: 12), Paint()..color = f);
      c.restore();
    }
    void dot(double x, double y, double r, Color f) => c.drawCircle(Offset(x, y), r, Paint()..color = f);
    switch (p.id) {
      case 4: stick(106, 116, const Color(0xFF7D4220), const Color(0xFFA35F30));
      case 13: stick(106, 116, const Color(0xFF4A2F16), const Color(0xFF6B4423));
      case 10:
        leaf(68, 50, -.5, const Color(0xFF4F9A45));
        leaf(92, 48, .45, const Color(0xFF4F9A45));
        leaf(80, 60, -.1, const Color(0xFF3F8A3A));
      case 11:
        dot(118, 104, 9, Colors.white);
        dot(134, 112, 7, Colors.white);
        dot(118, 104, 4, const Color(0xFFF2B705));
        dot(134, 112, 3, const Color(0xFFF2B705));
      case 12:
        dot(118, 104, 9, const Color(0xFFB3203A));
        dot(134, 112, 7, const Color(0xFFB3203A));
        dot(118, 104, 2.6, const Color(0xFFF7C948));
      case 7:
        leaf(116, 106, -.45, const Color(0xFF8DB15A));
        leaf(132, 112, .2, const Color(0xFF8DB15A));
        leaf(124, 98, .6, const Color(0xFF8DB15A));
      case 6:
        c.drawPath(Path()..moveTo(110, 100)..quadraticBezierTo(132, 92, 146, 106)..quadraticBezierTo(130, 104, 118, 112)..close(), Paint()..color = const Color(0xFFC0261B));
    }
  }

  void _glass(Canvas c, Path b) {
    c.drawPath(b, Paint()..shader = const LinearGradient(colors: [Color(0x80FFFFFF), Color(0x1AFFFFFF), Color(0x61FFFFFF)]).createShader(const Rect.fromLTWH(38, 20, 90, 100)));
    c.drawPath(b, Paint()..style = PaintingStyle.stroke..strokeWidth = 1..color = Colors.black26);
  }

  void _honey(Canvas c, Color col) {
    final b = Path()..addRRect(RRect.fromLTRBR(38, 40, 122, 118, const Radius.circular(14)));
    c.drawPath(b, Paint()..color = col);
    _glass(c, b);
    c.drawRRect(RRect.fromLTRBR(36, 22, 124, 42, const Radius.circular(6)),
        Paint()..shader = const LinearGradient(colors: [Color(0xFFA87C1C), Color(0xFFF3D27A), Color(0xFFA87C1C)]).createShader(const Rect.fromLTWH(36, 22, 88, 20)));
    c.drawRRect(RRect.fromLTRBR(56, 68, 104, 98, const Radius.circular(4)), Paint()..color = const Color(0xFFFBF6E9));
    c.drawLine(const Offset(148, 14), const Offset(136, 88), Paint()..color = const Color(0xFF9A6A3A)..strokeWidth = 5..strokeCap = StrokeCap.round);
    c.drawOval(Rect.fromCenter(center: const Offset(135, 96), width: 16, height: 20), Paint()..color = const Color(0xFFB8844D));
  }

  void _bottle(Canvas c, Color col) {
    c.drawRRect(RRect.fromLTRBR(70, 3, 90, 14, const Radius.circular(3)), Paint()..color = const Color(0xFF2B2B2B));
    c.drawRect(const Rect.fromLTRB(72, 13, 88, 39), Paint()..color = col);
    final b = Path()
      ..moveTo(72, 38)..quadraticBezierTo(50, 46, 50, 66)..lineTo(50, 110)..quadraticBezierTo(50, 122, 62, 122)
      ..lineTo(98, 122)..quadraticBezierTo(110, 122, 110, 110)..lineTo(110, 66)..quadraticBezierTo(110, 46, 88, 38)..close();
    c.drawPath(b, Paint()..color = col);
    _glass(c, b);
    c.drawRRect(RRect.fromLTRBR(55, 66, 105, 98, const Radius.circular(4)), Paint()..color = const Color(0xFFFBF6E9));
  }
}
