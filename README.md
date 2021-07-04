[![pub.dev](https://badgen.net/pub/v/widget_mask)](https://pub.dev/packages/widget_mask)
[![LICENSE](https://badgen.net/pub/license/widget_mask)](./LICENSE)
[![CI](https://github.com/blaugold/widget_mask/actions/workflows/CI.yaml/badge.svg)](https://github.com/blaugold/widget_mask/actions/workflows/CI.yaml)

<p align="center">
    <img width="400" src="https://raw.githubusercontent.com/blaugold/widget_mask/main/docs/images/example_screenshot.jpg?v=1">
</p>

# widget_mask

Use a widget to mask and blend another widget, for example to imprint text onto surfaces.

A mask is an image, which is positioned in front of another image and affects this images in some way, where it is not empty.

Blending is a process which takes two images and produces a new image by applying a mathematical function to each pair of pixels from the input images. For some of these functions, the order of the arguments matters. That's why the input images are labled with `src` and `dst`. A mask is usually the image labled with `src`.

## Usage

The example below paints some text onto an image. The text is filled with the negative of the image.

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

> :warning:: The `mask` widget must not contain widgets which need compositing, such as `RepaintBoundary`.

`WidgetMask` delegates to `child` to lay itself out. It always has the same size as `child`. `mask` is forced to adopt the same size as `child` and positioned on top it.

During hit testing `mask` is positioned over `child`.

The different `BlendMode`s use `src` and `dst` to describe how the colors of two images are blended with each other. In the context of `WidgetMask` `mask` is the `src` and `child` the `dst`.
