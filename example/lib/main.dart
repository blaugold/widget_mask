import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:widget_mask/widget_mask.dart';

void main() {
  runApp(const App());
}

class App extends StatelessWidget {
  const App({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) => MaterialApp(
        debugShowCheckedModeBanner: false,
        theme: ThemeData.from(colorScheme: const ColorScheme.light()),
        home: const Home(),
      );
}

class Home extends StatelessWidget {
  const Home({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    const padding = EdgeInsets.all(20);

    return Scaffold(
      backgroundColor: Colors.grey.shade900,
      body: ListView(
        padding: padding / 2,
        children: const [
          NegativeMaskedImageDemo(),
          ImageFiledTextDemo(),
        ]
            .map((e) => Container(
                  alignment: Alignment.center,
                  padding: padding / 2,
                  child: e,
                ))
            .toList(),
      ),
    );
  }
}

class NegativeMaskedImageDemo extends StatelessWidget {
  const NegativeMaskedImageDemo({
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    const textOffset = Offset(.05, .05);
    return DemoCard(
      child: NegativeMaskedImage(
        mask: ScaledLayeredText(
          textScale: 1.8,
          variants: [
            TextVariant(
              offset: textOffset * -1,
              style: TextStyle(
                color: Colors.red.withOpacity(.8),
              ),
            ),
            TextVariant(
              style: TextStyle(
                color: Colors.green.withOpacity(.8),
              ),
            ),
            TextVariant(
              offset: textOffset * 1,
              style: TextStyle(
                color: Colors.white.withOpacity(.8),
              ),
            ),
          ],
          child: Text(
            'WIDGET\nMASK',
            style: GoogleFonts.rubikMonoOne(),
            textAlign: TextAlign.center,
          ),
        ),
        image: const AssetImage('assets/road_from_drone.jpg'),
      ),
    );
  }
}

class ImageFiledTextDemo extends StatelessWidget {
  const ImageFiledTextDemo({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) => DemoCard(
        child: Container(
          decoration: BoxDecoration(
            gradient: RadialGradient(
              colors: [
                Colors.white,
                Colors.grey.shade300,
              ],
            ),
          ),
          child: Center(
            child: ImageFilledText(
              text: ScaledLayeredText(
                textScale: 1.8,
                child: const Text(
                  'WIDGET\nMASK',
                  style: TextStyle(
                    fontWeight: FontWeight.w900,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
              image: const AssetImage('assets/road_from_drone.jpg'),
            ),
          ),
        ),
      );
}

class NegativeMaskedImage extends StatelessWidget {
  const NegativeMaskedImage({
    Key? key,
    required this.mask,
    required this.image,
  }) : super(key: key);

  final Widget mask;

  final ImageProvider image;

  @override
  Widget build(BuildContext context) => WidgetMask(
        blendMode: BlendMode.difference,
        mask: mask,
        child: Image(
          image: image,
          fit: BoxFit.cover,
        ),
      );
}

class ImageFilledText extends StatelessWidget {
  const ImageFilledText({
    Key? key,
    required this.image,
    required this.text,
  }) : super(key: key);

  final ImageProvider image;

  final Widget text;

  @override
  Widget build(BuildContext context) => WidgetMask(
        blendMode: BlendMode.srcIn,
        childSaveLayer: true,
        mask: Image(
          image: image,
          fit: BoxFit.cover,
        ),
        child: DefaultTextStyle.merge(
          style: const TextStyle(
            color: Colors.white,
          ),
          child: text,
        ),
      );
}

class DemoCard extends StatelessWidget {
  const DemoCard({Key? key, required this.child}) : super(key: key);

  final Widget child;

  @override
  Widget build(BuildContext context) => ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 500),
        child: AspectRatio(
          aspectRatio: 1,
          child: ClipRRect(
            borderRadius: BorderRadius.circular(6),
            child: child,
          ),
        ),
      );
}

class TextVariant {
  const TextVariant({
    this.offset,
    this.style,
    this.textScale,
  });

  final Offset? offset;
  final TextStyle? style;
  final double? textScale;
}

class ScaledLayeredText extends StatelessWidget {
  ScaledLayeredText({
    Key? key,
    this.variants = const [TextVariant()],
    this.textScale = 1,
    required this.child,
  })  : assert(variants.isNotEmpty),
        super(key: key);

  final List<TextVariant> variants;

  final double textScale;

  final Widget child;

  static const _baseScale = 0.1;

  @override
  Widget build(BuildContext context) => LayoutBuilder(
        builder: (context, constraints) => Stack(
          children: [
            for (final variant in variants)
              Center(
                child: Transform.translate(
                  offset: (variant.offset ?? Offset.zero) *
                      constraints.maxWidth *
                      _baseScale,
                  child: DefaultTextStyle.merge(
                    style: TextStyle(
                      fontSize: (variant.textScale ?? textScale) *
                          constraints.maxWidth *
                          _baseScale,
                    ),
                    child: DefaultTextStyle.merge(
                      style: variant.style,
                      child: child,
                    ),
                  ),
                ),
              ),
          ],
        ),
      );
}
