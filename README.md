[![pub.dev package page](https://badgen.net/pub/v/widget_mask)](https://pub.dev/packages/widget_mask)
[![GitHub Actions CI](https://github.com/blaugold/widget_mask/actions/workflows/CI.yaml/badge.svg)](https://github.com/blaugold/widget_mask/actions/workflows/ci.yml)
[![GitHub Stars](https://badgen.net/github/stars/blaugold/widget_mask)](https://github.com/blaugold/widget_mask/stargazers)

Use a widget to mask and blend another widget, for example to imprint text onto
surfaces.

<p align="center">
    <img width="500" src="https://raw.githubusercontent.com/blaugold/widget_mask/main/docs/images/example_screenshot.jpg?v=1">
</p>

---

If you're looking for a **database solution**, check out
[`cbl`](https://pub.dev/packages/cbl), another project of mine. It brings
Couchbase Lite to **standalone Dart** and **Flutter**, with support for:

- **Full-Text Search**,
- **Expressive Queries**,
- **Data Sync**,
- **Change Notifications**

and more.

---

# Limitations

Widgets that are used as children of `WidgetMask` or `SaveLayer` must not need
compositing, or contain widgets which need compositing, such as
`RepaintBoundary`.

This is because this package makes use of save layers, which cannot encompass
compositing layers.

# Masks and blending

A mask is an image, which is positioned in front of another image and affects
this images in some way, where it is not empty.

Blending is a process which takes two images and produces a new image by
applying a mathematical function to each pair of pixels from the input images.
For some of these functions, the order of the arguments matters. That's why the
input images are labeled with `src` and `dst`. A mask is usually the image
labeled with `src`.

# Getting started

The example below paints some text onto an image. The text is filled with the
negative of the image.

```dart
WidgetMask(
  // `BlendMode.difference` results in the negative of `dst` where `src`
  // is fully white. That is why the text is white.
  blendMode: BlendMode.difference,
  mask: Center(
    child: Text(
      'Negative',
      style: TextStyle(
        fontSize: 50,
        color: Colors.white,
      ),
    ),
  ),
  child: Image.asset('images/my_image.jpg'),
);
```

`WidgetMask` delegates to `child` to lay itself out. It always has the same size
as `child`. `mask` is forced to adopt the same size as `child` and positioned on
top it.

During hit testing `mask` is positioned over `child`.

The different `BlendMode`s use `src` and `dst` to describe how the colors of two
images are blended with each other. In the context of `WidgetMask` `mask` is the
`src` and `child` the `dst`.

# Examples

The `NegativeMaskedImageDemo` widget, in the
[example app](https://pub.dev/packages/widget_mask/example), implements the
image at the top.

# `SaveLayer`

This widget paints its child into a save layer and allows you to fully specify
the `Paint` to use with the save layer. If you need to use a custom `Paint` or
require a different layout of the widgets, you can use `SaveLayer`.

`WidgetMask` is implement using two `SaveLayer`s to blend the `mask` and
`child`:

```dart
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
```

---

**Gabriel Terwesten** &bullet; **GitHub**
**[@blaugold](https://github.com/blaugold)** &bullet; **Twitter**
**[@GTerwesten](https://twitter.com/GTerwesten)** &bullet; **Medium**
**[@gabriel.terwesten](https://medium.com/@gabriel.terwesten)**
