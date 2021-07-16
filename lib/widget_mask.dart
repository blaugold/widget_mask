import 'package:flutter/rendering.dart';
import 'package:flutter/widgets.dart';

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
/// [mask] must not contain [RenderObject]s which need compositing, because
/// the save layer into which [mask] is painted cannot encompass compositing
/// layers. `RepaintBoundary` is a widget, whose [RenderObject] needs
/// compositing, for example.
class WidgetMask extends MultiChildRenderObjectWidget {
  /// Creates a widget which paints a [mask] widget into a save layer and blends
  /// that layer with its [child].
  WidgetMask({
    Key? key,
    this.blendMode = BlendMode.srcOver,
    this.childSaveLayer = false,
    required this.mask,
    required this.child,
  }) : super(key: key, children: [child, mask]);

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
  RenderObject createRenderObject(BuildContext context) => _RenderWidgetMask(
        blendMode: blendMode,
        childSaveLayer: childSaveLayer,
      );

  @override
  void updateRenderObject(
    BuildContext context,
    covariant _RenderWidgetMask renderObject,
  ) {
    renderObject
      ..blendMode = blendMode
      ..childSaveLayer = childSaveLayer;
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

class _WidgetMaskParentData extends ContainerBoxParentData<RenderBox> {}

class _RenderWidgetMask extends RenderBox
    with
        ContainerRenderObjectMixin<RenderBox, _WidgetMaskParentData>,
        RenderBoxContainerDefaultsMixin<RenderBox, _WidgetMaskParentData> {
  _RenderWidgetMask({
    required BlendMode blendMode,
    required bool childSaveLayer,
  })  : _blendMode = blendMode,
        _childSaveLayer = childSaveLayer;

  @override
  void setupParentData(covariant RenderBox child) {
    if (child.parentData is! _WidgetMaskParentData) {
      child.parentData = _WidgetMaskParentData();
    }
  }

  RenderBox get _mask => lastChild!;
  RenderBox get _child => firstChild!;

  BlendMode get blendMode => _blendMode;
  BlendMode _blendMode;

  set blendMode(BlendMode blendMode) {
    if (_blendMode != blendMode) {
      _blendMode = blendMode;
      markNeedsPaint();
    }
  }

  bool get childSaveLayer => _childSaveLayer;
  bool _childSaveLayer;

  set childSaveLayer(bool childSaveLayer) {
    if (_childSaveLayer != childSaveLayer) {
      _childSaveLayer = childSaveLayer;
      markNeedsPaint();
    }
  }

  @override
  bool get sizedByParent => _child.sizedByParent;

  @override
  double? computeDistanceToActualBaseline(TextBaseline baseline) =>
      _child.computeDistanceToActualBaseline(baseline);

  @override
  double computeMinIntrinsicHeight(double width) =>
      _child.computeMinIntrinsicHeight(width);

  @override
  double computeMaxIntrinsicHeight(double width) =>
      _child.computeMaxIntrinsicHeight(width);

  @override
  double computeMaxIntrinsicWidth(double height) =>
      _child.computeMaxIntrinsicWidth(height);

  @override
  double computeMinIntrinsicWidth(double height) =>
      _child.computeMinIntrinsicWidth(height);

  @override
  Size computeDryLayout(BoxConstraints constraints) =>
      _child.computeDryLayout(constraints);

  @override
  bool get needsCompositing {
    assert(() {
      _debugMaskDoesNotNeedCompositing();
      return true;
    }());
    return super.needsCompositing;
  }

  @override
  void performLayout() {
    _child.layout(constraints, parentUsesSize: true);
    size = _child.size;
    _mask.layout(BoxConstraints.tight(size));
  }

  @override
  void paint(PaintingContext context, Offset offset) {
    if (_childSaveLayer) {
      context.canvas.saveLayer(offset & size, Paint());
    }
    context.paintChild(_child, offset);

    context.canvas.saveLayer(offset & size, Paint()..blendMode = blendMode);
    context.paintChild(_mask, offset);
    context.canvas.restore();

    if (_childSaveLayer) {
      context.canvas.restore();
    }
  }

  @override
  void applyPaintTransform(covariant RenderObject child, Matrix4 transform) {}

  @override
  bool hitTestChildren(BoxHitTestResult result, {required Offset position}) =>
      defaultHitTestChildren(result, position: position);

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties
      ..add(EnumProperty<BlendMode>('blendMode', blendMode))
      ..add(FlagProperty(
        'childSaveLayer',
        value: childSaveLayer,
        ifTrue: 'CHILD-SAVE-LAYER',
        defaultValue: false,
      ));
  }

  void _debugMaskDoesNotNeedCompositing() {
    void _throwErrorFor(RenderObject renderObject, String name) {
      throw FlutterError.fromParts([
        ErrorSummary('`WidgetMask.$name` cannot contain compositing layers.'),
        ErrorDescription(
          'The save layer into which `$name` is painted cannot encompass '
          'compositing layers.',
        ),
        ErrorHint(
          'Ensure `WidgetMask.$name` contains no widgets which need '
          'compositing, such as `RepaintBoundary`.',
        ),
        _leafCompositingRenderObjects(renderObject).first.describeForError('')
      ]);
    }

    if (_mask.needsCompositing) {
      _throwErrorFor(_mask, 'mask');
    }

    if (_childSaveLayer) {
      if (_child.needsCompositing) {
        _throwErrorFor(_child, 'child');
      }
    }
  }
}

Iterable<RenderObject> _leafCompositingRenderObjects(
  RenderObject renderObject,
) =>
    (_renderTreeNodes(renderObject).toList()..sort((a, b) => a.depth - b.depth))
        .where(_isLeafCompositingRenderObject);

Iterable<RenderObject> _renderTreeNodes(RenderObject root) sync* {
  final children = <RenderObject>[];
  root.visitChildren((child) {
    children.add(child);
  });
  yield root;
  yield* children.expand((child) => _renderTreeNodes(child));
}

bool _isLeafCompositingRenderObject(RenderObject renderObject) {
  if (renderObject.needsCompositing) {
    var hasChildThatNeedsCompositing = false;
    renderObject.visitChildren((child) {
      if (!hasChildThatNeedsCompositing) {
        hasChildThatNeedsCompositing = child.needsCompositing;
      }
    });
    return !hasChildThatNeedsCompositing;
  } else {
    return false;
  }
}
