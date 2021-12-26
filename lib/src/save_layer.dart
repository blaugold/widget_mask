import 'package:flutter/rendering.dart';
import 'package:flutter/widgets.dart';

/// A widget, which paints its [child] into a separate save layer.
///
/// The [Paint], that is used for the save layer, can be set through [paint].
///
/// Widgets that need compositing will only be partially or not at all painted
/// into the save layer. This can cause unexpected results, which is why
/// widgets that need compositing will cause an exception in debug mode, when
/// used as the [child]. To disable this check, set
/// [debugCheckChildDoesNotNeedCompositing] to `false`.
class SaveLayer extends SingleChildRenderObjectWidget {
  /// Creates a widget, which paints its [child] into a separate save layer.
  const SaveLayer({
    Key? key,
    this.paint,
    this.debugCheckChildDoesNotNeedCompositing = true,
    this.child,
  }) : super(key: key, child: child);

  /// The [Paint] to use for the save layer.
  ///
  /// If this is `null`, `Paint()` will be used.
  final Paint? paint;

  /// Whether to check that [child] does not need compositing.
  // ignore: diagnostic_describe_all_properties
  final bool debugCheckChildDoesNotNeedCompositing;

  /// The widget which will be painted into it's own save layer.
  ///
  /// {@macro flutter.widgets.ProxyWidget.child}
  @override
  final Widget? child;

  @override
  RenderObject createRenderObject(BuildContext context) => RenderSaveLayer(
        saveLayerPaint: paint,
        debugCheckChildDoesNotNeedCompositing:
            debugCheckChildDoesNotNeedCompositing,
      );

  @override
  void updateRenderObject(
    BuildContext context,
    covariant RenderSaveLayer renderObject,
  ) {
    super.updateRenderObject(context, renderObject);
    renderObject
      ..saveLayerPaint = paint
      ..debugCheckChildDoesNotNeedCompositing =
          debugCheckChildDoesNotNeedCompositing;
  }

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties.add(DiagnosticsProperty<Paint?>('paint', paint));
  }
}

/// A [RenderProxyBox], that paints its child into a separate save layer.
class RenderSaveLayer extends RenderProxyBox {
  /// Creates a [RenderProxyBox], that paints its child into a separate save
  /// layer.
  RenderSaveLayer({
    required Paint? saveLayerPaint,
    required bool debugCheckChildDoesNotNeedCompositing,
  })  : _saveLayerPaint = saveLayerPaint,
        _debugCheckChildDoesNotNeedCompositing =
            debugCheckChildDoesNotNeedCompositing,
        super();

  /// The [Paint] to use for the save layer.
  ///
  /// If this is `null`, `Paint()` will be used.
  Paint? get saveLayerPaint => _saveLayerPaint;
  Paint? _saveLayerPaint;

  set saveLayerPaint(Paint? saveLayerPaint) {
    if (_saveLayerPaint == saveLayerPaint) return;
    markNeedsPaint();
    _saveLayerPaint = saveLayerPaint;
  }

  /// Whether to check that [child] does not need compositing.
  // ignore: diagnostic_describe_all_properties
  bool get debugCheckChildDoesNotNeedCompositing =>
      _debugCheckChildDoesNotNeedCompositing;
  bool _debugCheckChildDoesNotNeedCompositing;

  set debugCheckChildDoesNotNeedCompositing(
      bool debugCheckChildDoesNotNeedCompositing) {
    if (_debugCheckChildDoesNotNeedCompositing ==
        debugCheckChildDoesNotNeedCompositing) return;
    markNeedsCompositingBitsUpdate();
    _debugCheckChildDoesNotNeedCompositing =
        debugCheckChildDoesNotNeedCompositing;
  }

  @override
  bool get needsCompositing {
    assert(() {
      if (_debugCheckChildDoesNotNeedCompositing) {
        _debugChildDoesNotNeedCompositing();
      }
      return true;
    }());
    return super.needsCompositing;
  }

  @override
  void paint(PaintingContext context, Offset offset) {
    final child = this.child;
    if (child == null) {
      return;
    }

    context.canvas.saveLayer(offset & size, _saveLayerPaint ?? Paint());
    context.paintChild(child, offset);
    context.canvas.restore();
  }

  void _debugChildDoesNotNeedCompositing() {
    final child = this.child;
    if (child == null) {
      return;
    }

    if (child.needsCompositing) {
      throw FlutterError.fromParts([
        ErrorSummary('`SaveLayer.child` cannot contain compositing layers.'),
        ErrorDescription(
          'The save layer, into which SaveLayer.child is painted, cannot '
          'encompass compositing layers.',
        ),
        ErrorHint(
          'Ensure `SaveLayer.child` contains no widgets which need '
          'compositing, such as `RepaintBoundary`.',
        ),
        _leafCompositingRenderObjects(child).first.describeForError('')
      ]);
    }
  }

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties.add(DiagnosticsProperty<Paint?>(
      'saveLayerPaint',
      saveLayerPaint,
    ));
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
