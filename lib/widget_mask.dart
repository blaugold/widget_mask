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
    required Widget mask,
    required Widget child,
  }) : super(key: key, children: [child, mask]);

  /// The [BlendMode] to use when blending the [mask] save layer with [child].
  ///
  /// In the context of this widget [mask] is the `src` and [child] the `dst`.
  final BlendMode blendMode;

  @override
  RenderObject createRenderObject(BuildContext context) =>
      _RenderWidgetMask(blendMode: blendMode);

  @override
  void updateRenderObject(
    BuildContext context,
    covariant _RenderWidgetMask renderObject,
  ) {
    renderObject.blendMode = blendMode;
  }

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties.add(EnumProperty('blendMode', blendMode));
  }
}

class _WidgetMaskParentData extends ContainerBoxParentData<RenderBox> {}

class _RenderWidgetMask extends RenderBox
    with
        ContainerRenderObjectMixin<RenderBox, _WidgetMaskParentData>,
        RenderBoxContainerDefaultsMixin<RenderBox, _WidgetMaskParentData> {
  _RenderWidgetMask({required BlendMode blendMode}) : _blendMode = blendMode;

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
    context.paintChild(_child, offset);

    context.canvas.saveLayer(offset & size, Paint()..blendMode = blendMode);
    context.paintChild(_mask, offset);
    context.canvas.restore();
  }

  @override
  void applyPaintTransform(covariant RenderObject child, Matrix4 transform) {}

  @override
  bool hitTestChildren(BoxHitTestResult result, {required Offset position}) =>
      defaultHitTestChildren(result, position: position);

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties.add(EnumProperty<BlendMode>('blendMode', blendMode));
  }

  void _debugMaskDoesNotNeedCompositing() {
    if (_mask.needsCompositing) {
      throw FlutterError.fromParts([
        ErrorSummary('`WidgetMask.mask` cannot contain compositing layers.'),
        ErrorDescription(
          'The save layer into which `mask` is painted cannot encompass '
          'compositing layers.',
        ),
        ErrorHint(
          'Ensure `WidgetMask.mask` contains no widgets which need '
          'compositing, such as `RepaintBoundary`.',
        ),
        _leafCompositingRenderObjects(_mask).first.describeForError('')
      ]);
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
