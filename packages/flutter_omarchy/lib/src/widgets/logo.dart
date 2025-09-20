import 'package:flutter/widgets.dart';
import 'package:flutter_omarchy/src/theme/theme.dart';

enum _LogoType { icon, text }

class OmarchyLogo extends StatelessWidget {
  const OmarchyLogo({super.key, this.color, this.width})
    : _type = _LogoType.text;

  const OmarchyLogo.icon({super.key, this.color, this.width})
    : _type = _LogoType.icon;

  final _LogoType _type;
  final Color? color;
  final double? width;

  @override
  Widget build(BuildContext context) {
    Widget result = FittedBox(
      child: switch (_type) {
        _LogoType.text => CustomPaint(
          size: Size(1215, 285),
          painter: _TextPainter(),
        ),
        _LogoType.icon => CustomPaint(
          size: Size(353, 353),
          painter: _IconPainter(),
        ),
      },
    );
    final color = this.color ?? OmarchyTheme.of(context).colors.foreground;
    result = ColorFiltered(
      colorFilter: ColorFilter.mode(color, BlendMode.srcIn),
      child: result,
    );
    if (width != null) {
      return SizedBox(width: width, child: result);
    }
    return result;
  }
}

class _IconPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    Path path_0 = Path();
    path_0.moveTo(237, 353);
    path_0.lineTo(353, 353);
    path_0.lineTo(353, 13);
    path_0.lineTo(183, 13);
    path_0.moveTo(183, 299);
    path_0.lineTo(183, 353);
    path_0.lineTo(13, 353);
    path_0.lineTo(13, 183);
    path_0.moveTo(183, 299);
    path_0.lineTo(299, 299);
    path_0.lineTo(299, 67);
    path_0.lineTo(263, 67);
    path_0.moveTo(183, 299);
    path_0.lineTo(67, 299);
    path_0.lineTo(67, 183);
    path_0.moveTo(183, 13);
    path_0.lineTo(13, 13);
    path_0.lineTo(13, 183);
    path_0.moveTo(183, 13);
    path_0.lineTo(183, 67);
    path_0.lineTo(67, 67);
    path_0.lineTo(67, 183);
    path_0.moveTo(13, 183);
    path_0.lineTo(67, 183);

    final paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 26;
    paint.color = Color(0xff000000);
    canvas.drawPath(path_0, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return true;
  }
}

class _TextPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    Path path_0 = Path();
    path_0.moveTo(720, 120);
    path_0.lineTo(705, 120);
    path_0.lineTo(705, 135);
    path_0.lineTo(690.002, 135);
    path_0.lineTo(690.002, 149.999);
    path_0.lineTo(630, 150);
    path_0.lineTo(630, 165.002);
    path_0.lineTo(720, 165);
    path_0.lineTo(720, 165.002);
    path_0.lineTo(720.002, 165.002);
    path_0.lineTo(720, 255);
    path_0.lineTo(705, 255);
    path_0.lineTo(705, 270);
    path_0.lineTo(692, 270);
    path_0.lineTo(692, 285);
    path_0.lineTo(675, 285);
    path_0.lineTo(675, 195.002);
    path_0.lineTo(630, 195.002);
    path_0.lineTo(630, 285.002);
    path_0.lineTo(585, 285);
    path_0.lineTo(585, 195.002);
    path_0.lineTo(570.002, 195.002);
    path_0.lineTo(570.002, 165.002);
    path_0.lineTo(585, 165.002);
    path_0.lineTo(585, 150);
    path_0.lineTo(570.002, 150);
    path_0.lineTo(570.002, 119.999);
    path_0.lineTo(585, 119.999);
    path_0.lineTo(585, 44.998999999999995);
    path_0.lineTo(600, 44.998999999999995);
    path_0.lineTo(600, 30.001999999999995);
    path_0.lineTo(615, 30.001999999999995);
    path_0.lineTo(615, 14.999999999999995);
    path_0.lineTo(720.002, 14.999999999999995);
    path_0.close();
    path_0.moveTo(630, 119.999);
    path_0.lineTo(675, 119.999);
    path_0.lineTo(675, 45.001999999999995);
    path_0.lineTo(630, 45.001999999999995);
    path_0.close();

    Paint paint0Fill = Paint()..style = PaintingStyle.fill;
    paint0Fill.color = Color(0xff000000);
    canvas.drawPath(path_0, paint0Fill);

    Path path_1 = Path();
    path_1.moveTo(105, 30.002);
    path_1.lineTo(120, 30.002);
    path_1.lineTo(120, 44.998999999999995);
    path_1.lineTo(135, 44.998999999999995);
    path_1.lineTo(135, 225);
    path_1.lineTo(120, 225);
    path_1.lineTo(120, 240);
    path_1.lineTo(105, 240);
    path_1.lineTo(105, 255.002);
    path_1.lineTo(30, 255.002);
    path_1.lineTo(30, 240);
    path_1.lineTo(15, 240);
    path_1.lineTo(15, 225);
    path_1.lineTo(0, 225);
    path_1.lineTo(0, 44.998999999999995);
    path_1.lineTo(15, 44.998999999999995);
    path_1.lineTo(15, 30.001999999999995);
    path_1.lineTo(30, 30.001999999999995);
    path_1.lineTo(30, 14.999999999999995);
    path_1.lineTo(105, 14.999999999999995);
    path_1.close();
    path_1.moveTo(45, 225);
    path_1.lineTo(90, 225);
    path_1.lineTo(90, 45.00200000000001);
    path_1.lineTo(45, 45.00200000000001);
    path_1.close();

    Paint paint1Fill = Paint()..style = PaintingStyle.fill;
    paint1Fill.color = Color(0xff000000);
    canvas.drawPath(path_1, paint1Fill);

    Path path_2 = Path();
    path_2.moveTo(300, 15);
    path_2.lineTo(360, 15);
    path_2.lineTo(360, 30);
    path_2.lineTo(375, 30);
    path_2.lineTo(375, 44.999);
    path_2.lineTo(390, 44.999);
    path_2.lineTo(390, 225);
    path_2.lineTo(375, 225);
    path_2.lineTo(375, 240);
    path_2.lineTo(360, 240);
    path_2.lineTo(360, 255);
    path_2.lineTo(345, 255);
    path_2.lineTo(344.996, 45.00200000000001);
    path_2.lineTo(300.00199999999995, 45.00200000000001);
    path_2.lineTo(300.00199999999995, 45.00000000000001);
    path_2.lineTo(299.99999999999994, 45.00000000000001);
    path_2.lineTo(299.99999999999994, 255.002);
    path_2.lineTo(254.99999999999994, 255.002);
    path_2.lineTo(254.99999999999994, 45.00200000000001);
    path_2.lineTo(210.00199999999995, 45.00200000000001);
    path_2.lineTo(210.00199999999995, 224.99900000000002);
    path_2.lineTo(209.99999999999994, 224.99900000000002);
    path_2.lineTo(209.99999999999994, 255.002);
    path_2.lineTo(194.99999999999994, 255.002);
    path_2.lineTo(194.99999999999994, 240);
    path_2.lineTo(179.99999999999994, 240);
    path_2.lineTo(179.99999999999994, 225);
    path_2.lineTo(165.00199999999995, 225);
    path_2.lineTo(165.00199999999995, 44.998999999999995);
    path_2.lineTo(179.99999999999994, 44.998999999999995);
    path_2.lineTo(179.99999999999994, 29.999999999999993);
    path_2.lineTo(194.99999999999994, 29.999999999999993);
    path_2.lineTo(194.99999999999994, 14.999999999999993);
    path_2.lineTo(254.99999999999994, 14.999999999999993);
    path_2.lineTo(254.99999999999994, -7.105427357601002e-15);
    path_2.lineTo(299.99999999999994, -7.105427357601002e-15);
    path_2.close();

    Paint paint2Fill = Paint()..style = PaintingStyle.fill;
    paint2Fill.color = Color(0xff000000);
    canvas.drawPath(path_2, paint2Fill);

    Path path_3 = Path();
    path_3.moveTo(555, 225);
    path_3.lineTo(540, 225);
    path_3.lineTo(540, 240);
    path_3.lineTo(525, 240);
    path_3.lineTo(525, 255);
    path_3.lineTo(510, 255);
    path_3.lineTo(510, 149.999);
    path_3.lineTo(465.002, 150);
    path_3.lineTo(465.002, 255.002);
    path_3.lineTo(420, 255.002);
    path_3.lineTo(420, 150);
    path_3.lineTo(405, 150);
    path_3.lineTo(405, 119.999);
    path_3.lineTo(420, 119.999);
    path_3.lineTo(420, 44.998999999999995);
    path_3.lineTo(435.002, 44.998999999999995);
    path_3.lineTo(435.002, 30.001999999999995);
    path_3.lineTo(450.002, 30.001999999999995);
    path_3.lineTo(450.002, 14.999999999999995);
    path_3.lineTo(555.002, 14.999999999999995);
    path_3.close();
    path_3.moveTo(465.002, 119.999);
    path_3.lineTo(510, 119.999);
    path_3.lineTo(510, 45.001999999999995);
    path_3.lineTo(465.002, 45.001999999999995);
    path_3.close();

    Paint paint3Fill = Paint()..style = PaintingStyle.fill;
    paint3Fill.color = Color(0xff000000);
    canvas.drawPath(path_3, paint3Fill);

    Path path_4 = Path();
    path_4.moveTo(885, 75);
    path_4.lineTo(870, 75);
    path_4.lineTo(870, 90);
    path_4.lineTo(855, 90);
    path_4.lineTo(855, 105);
    path_4.lineTo(840, 105);
    path_4.lineTo(840, 45.002);
    path_4.lineTo(795, 45.002);
    path_4.lineTo(795, 225);
    path_4.lineTo(840, 225);
    path_4.lineTo(840, 165.002);
    path_4.lineTo(855, 165.002);
    path_4.lineTo(855, 179.99900000000002);
    path_4.lineTo(870, 179.99900000000002);
    path_4.lineTo(870, 195.00000000000003);
    path_4.lineTo(885, 195.00000000000003);
    path_4.lineTo(885, 225.00000000000003);
    path_4.lineTo(870, 225.00000000000003);
    path_4.lineTo(870, 240.00000000000003);
    path_4.lineTo(855, 240.00000000000003);
    path_4.lineTo(855, 255.00200000000004);
    path_4.lineTo(750, 255.00000000000003);
    path_4.lineTo(750, 44.999000000000024);
    path_4.lineTo(764.998, 44.999000000000024);
    path_4.lineTo(764.998, 30.002000000000024);
    path_4.lineTo(780, 30.002000000000024);
    path_4.lineTo(780, 15.000000000000023);
    path_4.lineTo(885, 15.000000000000023);
    path_4.close();

    Paint paint4Fill = Paint()..style = PaintingStyle.fill;
    paint4Fill.color = Color(0xff000000);
    canvas.drawPath(path_4, paint4Fill);

    Path path_5 = Path();
    path_5.moveTo(960, 119.999);
    path_5.lineTo(1005, 119.999);
    path_5.lineTo(1005, 15);
    path_5.lineTo(1020, 15);
    path_5.lineTo(1020, 30);
    path_5.lineTo(1035, 30);
    path_5.lineTo(1035, 44.999);
    path_5.lineTo(1050, 44.999);
    path_5.lineTo(1050, 120);
    path_5.lineTo(1065, 120);
    path_5.lineTo(1065, 135);
    path_5.lineTo(1050, 135);
    path_5.lineTo(1050, 225);
    path_5.lineTo(1035, 225);
    path_5.lineTo(1035, 240);
    path_5.lineTo(1020, 240);
    path_5.lineTo(1020, 255);
    path_5.lineTo(1005, 255);
    path_5.lineTo(1005, 150);
    path_5.lineTo(960, 150);
    path_5.lineTo(960, 255.002);
    path_5.lineTo(915, 255);
    path_5.lineTo(915, 150);
    path_5.lineTo(885, 150);
    path_5.lineTo(885, 135);
    path_5.lineTo(900, 135);
    path_5.lineTo(900, 119.999);
    path_5.lineTo(915, 119.999);
    path_5.lineTo(915, 44.998999999999995);
    path_5.lineTo(930, 44.998999999999995);
    path_5.lineTo(930, 30.001999999999995);
    path_5.lineTo(945, 30.001999999999995);
    path_5.lineTo(945, 14.999999999999995);
    path_5.lineTo(960, 14.999999999999995);
    path_5.close();

    Paint paint5Fill = Paint()..style = PaintingStyle.fill;
    paint5Fill.color = Color(0xff000000);
    canvas.drawPath(path_5, paint5Fill);

    Path path_6 = Path();
    path_6.moveTo(1125, 119.999);
    path_6.lineTo(1170, 119.999);
    path_6.lineTo(1170, 15);
    path_6.lineTo(1185, 15);
    path_6.lineTo(1185, 30);
    path_6.lineTo(1200, 30);
    path_6.lineTo(1200, 45);
    path_6.lineTo(1215, 45);
    path_6.lineTo(1215, 225);
    path_6.lineTo(1200, 225);
    path_6.lineTo(1200, 240);
    path_6.lineTo(1185, 240);
    path_6.lineTo(1185, 255.002);
    path_6.lineTo(1110, 255);
    path_6.lineTo(1110, 240);
    path_6.lineTo(1095, 240);
    path_6.lineTo(1095, 225);
    path_6.lineTo(1080, 225);
    path_6.lineTo(1080, 179.999);
    path_6.lineTo(1095, 179.999);
    path_6.lineTo(1095, 165.002);
    path_6.lineTo(1095, 165);
    path_6.lineTo(1125, 165);
    path_6.lineTo(1125, 225);
    path_6.lineTo(1170, 225);
    path_6.lineTo(1170, 150);
    path_6.lineTo(1080, 150);
    path_6.lineTo(1080, 44.998999999999995);
    path_6.lineTo(1095, 44.998999999999995);
    path_6.lineTo(1095, 30.001999999999995);
    path_6.lineTo(1110, 30.001999999999995);
    path_6.lineTo(1110, 14.999999999999995);
    path_6.lineTo(1125, 14.999999999999995);
    path_6.close();

    Paint paint6Fill = Paint()..style = PaintingStyle.fill;
    paint6Fill.color = Color(0xff000000);
    canvas.drawPath(path_6, paint6Fill);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return true;
  }
}
