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
  Widget build(BuildContext context) => Scaffold(
        backgroundColor: Colors.grey.shade900,
        body: Center(
          child: SizedBox.fromSize(
            size: const Size.square(500),
            child: const ImageWithTextMask(
              text: 'WIDGET\nMASK',
              textScale: 5.8,
              textOffset: Offset(2, 2),
              image: AssetImage('assets/road_from_drone.jpg'),
            ),
          ),
        ),
      );
}

class ImageWithTextMask extends StatelessWidget {
  const ImageWithTextMask({
    Key? key,
    required this.text,
    required this.textScale,
    required this.textOffset,
    required this.image,
  }) : super(key: key);

  final String text;

  final double textScale;

  final Offset textOffset;

  final ImageProvider image;

  @override
  Widget build(BuildContext context) => AspectRatio(
        aspectRatio: 1,
        child: ClipRRect(
          borderRadius: BorderRadius.circular(6),
          child: WidgetMask(
            blendMode: BlendMode.difference,
            mask: LayoutBuilder(
              builder: (context, constraints) => Stack(
                children: [
                  Center(
                    child: Transform.translate(
                      offset: textOffset * -1,
                      child: Text(
                        text,
                        style: GoogleFonts.rubikMonoOne(
                          fontSize: constraints.maxWidth / textScale,
                          color: Colors.red.withOpacity(.8),
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ),
                  Center(
                    child: Transform.translate(
                      offset: textOffset,
                      child: Text(
                        text,
                        style: GoogleFonts.rubikMonoOne(
                          fontSize: constraints.maxWidth / textScale,
                          color: Colors.green.withOpacity(.8),
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ),
                  Center(
                    child: Text(
                      text,
                      style: GoogleFonts.rubikMonoOne(
                        fontSize: constraints.maxWidth / textScale,
                        color: Colors.white.withOpacity(.8),
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ],
              ),
            ),
            child: Image(
              image: image,
              fit: BoxFit.cover,
            ),
          ),
        ),
      );
}
