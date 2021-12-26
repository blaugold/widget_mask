import 'package:flutter/rendering.dart';
import 'package:flutter/widgets.dart';

import 'save_layer.dart';

/// A widget which paints a [mask] widget into a save layer and blends that
/// layer with its [child].
///
/// [blendMode] determines how [mask] and [child] are blended with each other.
/// In the context of this widget [mask] is the `src` and [child] the `dst`.
///
/// This widget sizes itself to the dimensions of [child] and forces [mask] to
/// the same size. For the purpose of hit testing [mask] is painted over
/// [child].
///
/// Since [mask] is panted into a save layer, this widget is relatively
/// expensive. See [Canvas.saveLayer] for more on the performance implications
/// of a save layer.
///
/// [mask] must not contain [RenderObject]s which need compositing because
/// the save layer into which [mask] is painted cannot encompass compositing
/// layers. `RepaintBoundary` is a widget, whose [RenderObject] needs
/// compositing, for example.
class WidgetMask extends StatelessWidget {
  /// Creates a widget which paints a [mask] widget into a save layer and blends
  /// that layer with its [child].
  const WidgetMask({
    Key? key,
    this.blendMode = BlendMode.srcOver,
    this.childSaveLayer = false,
    required this.mask,
    required this.child,
  }) : super(key: key);

  /// The [BlendMode] to use when blending the [mask] save layer with [child].
  ///
  /// In the context of this widget [mask] is the `src` and [child] the `dst`.
  final BlendMode blendMode;

  /// Whether to paint [child] in its own save layer.
  ///
  /// This allows you to blend [child] and [mask] without the transparent
  /// areas of [child] influencing the result.
  ///
  /// Enabling this option impacts performance, since it adds another save layer
  /// and should only be done if necessary.
  final bool childSaveLayer;

  /// The widget which is painted over the [child] widget, in a save layer with
  /// [BlendMode] [blendMode].
  final Widget mask;

  /// The widget which determines the size of this widget and is painted behind
  /// the [mask] widget.
  final Widget child;

  @override
  Widget build(BuildContext context) {
    Widget child = Stack(
      textDirection: TextDirection.ltr,
      fit: StackFit.passthrough,
      children: [
        this.child,
        Positioned.fill(
          child: SaveLayer(
            paint: Paint()..blendMode = blendMode,
            child: mask,
          ),
        ),
      ],
    );

    if (childSaveLayer) {
      child = SaveLayer(
        child: child,
      );
    }

    return child;
  }

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties
      ..add(EnumProperty('blendMode', blendMode))
      ..add(FlagProperty(
        'childSaveLayer',
        value: childSaveLayer,
        ifTrue: 'CHILD-SAVE-LAYER',
        defaultValue: false,
      ));
  }
}
