// ignore_for_file: diagnostic_describe_all_properties

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:widget_mask/widget_mask.dart';

void main() {
  testWidgets('default blend mode', (tester) async {
    await tester.pumpWidget(
      const Center(
        child: WidgetMask(
          mask: Center(
            child: Square(),
          ),
          child: Square(
            size: 200,
            color: Colors.green,
          ),
        ),
      ),
    );

    await expectLater(
      find.byType(WidgetMask),
      matchesGoldenFile('goldens/default_blend_mode.png'),
    );
  });

  testWidgets('custom blend mode', (tester) async {
    await tester.pumpWidget(
      const Center(
        child: WidgetMask(
          blendMode: BlendMode.difference,
          mask: Center(
            child: Square(
              color: Colors.white,
            ),
          ),
          child: Square(
            size: 200,
            color: Colors.green,
          ),
        ),
      ),
    );

    await expectLater(
      find.byType(WidgetMask),
      matchesGoldenFile('goldens/custom_blend_mode.png'),
    );
  });

  testWidgets(
    'child save layer allows blending of child without background',
    (tester) async {
      await tester.pumpWidget(
        Container(
          color: Colors.white,
          alignment: Alignment.center,
          child: const WidgetMask(
            childSaveLayer: true,
            blendMode: BlendMode.dstOver,
            mask: Square(
              color: Colors.red,
            ),
            child: Padding(
              padding: EdgeInsets.all(50),
              child: Square(
                size: 200,
                color: Colors.green,
              ),
            ),
          ),
        ),
      );

      await expectLater(
        find.byType(WidgetMask),
        matchesGoldenFile('goldens/child_save_layer.png'),
      );
    },
  );

  testWidgets('mask which contains layer throws debug error', (tester) async {
    await tester.pumpWidget(
      const Center(
        child: WidgetMask(
          blendMode: BlendMode.difference,
          mask: Center(
            child: RepaintBoundary(
              child: Square(
                color: Colors.white,
              ),
            ),
          ),
          child: Square(
            size: 200,
            color: Colors.green,
          ),
        ),
      ),
    );

    expect(tester.takeException(), isFlutterError);
  });

  testWidgets('child which contains layer', (tester) async {
    await tester.pumpWidget(
      const Center(
        child: WidgetMask(
          blendMode: BlendMode.difference,
          mask: Center(
            child: Square(
              color: Colors.white,
            ),
          ),
          child: RepaintBoundary(
            child: Square(
              size: 200,
              color: Colors.green,
            ),
          ),
        ),
      ),
    );

    await expectLater(
      find.byType(WidgetMask),
      matchesGoldenFile('goldens/child_with_layer.png'),
    );
  });

  testWidgets(
    'child with save layer, which contains layer throws debug error',
    (tester) async {
      await tester.pumpWidget(
        const Center(
          child: WidgetMask(
            childSaveLayer: true,
            blendMode: BlendMode.difference,
            mask: Center(
              child: Square(
                color: Colors.white,
              ),
            ),
            child: RepaintBoundary(
              child: Square(
                size: 200,
                color: Colors.green,
              ),
            ),
          ),
        ),
      );

      expect(tester.takeException(), isFlutterError);
    },
  );

  testWidgets('mask is hit tested before child', (tester) async {
    var didHitMask = false;
    var didHitChild = false;

    await tester.pumpWidget(
      Align(
        alignment: Alignment.topLeft,
        child: WidgetMask(
          blendMode: BlendMode.difference,
          mask: Align(
            alignment: Alignment.topLeft,
            child: GestureDetector(
              onTap: () => didHitMask = true,
              child: const Square(
                color: Colors.white,
              ),
            ),
          ),
          child: GestureDetector(
            onTap: () => didHitChild = true,
            child: const Square(
              size: 200,
              color: Colors.green,
            ),
          ),
        ),
      ),
    );

    await tester.tapAt(const Offset(50, 50));
    expect(didHitMask, isTrue);
    expect(didHitChild, isFalse);

    await tester.tapAt(const Offset(150, 150));
    expect(didHitChild, isTrue);
  });
}

class Square extends StatelessWidget {
  const Square({Key? key, this.size = 100, this.color}) : super(key: key);

  final double size;

  final Color? color;

  @override
  Widget build(BuildContext context) => SizedBox.fromSize(
        size: Size.square(size),
        child: Container(
          color: color ?? Colors.red,
        ),
      );
}
