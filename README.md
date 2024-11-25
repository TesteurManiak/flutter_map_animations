# Flutter Map Animations

[![Pub Version (including pre-releases)](https://img.shields.io/pub/v/flutter_map_animations?include_prereleases)][pub-package]

Animation utility for the [flutter_map][pub-flutter-map] package.

[Try the example app][example]

# Table of Contents

- [Documentation](#documentation)
    - [AnimatedMapController](#animatedmapcontroller)
        - [Animated Movement](#animated-movement)
    - [AnimatedMarkerLayer & AnimatedMarker](#animatedmarkerlayer--animatedmarker)
- [Migration Guide](#migration-guide)
    - [v0.5.0](#v050)
    - [v0.4.0](#v040)
- [Contributors](#contributors)

# Documentation

## AnimatedMapController

Just create an `AnimatedMapController` and you're good to go:

```dart
class _MyWidgetState extends State<MyWidget> with TickerProviderStateMixin {
    late final _animatedMapController = AnimatedMapController(vsync: this);

    // ...
}
```

You can specify globally the animation's `duration`, `curve` and if previous animations should be stopped with `cancelPreviousAnimations`:

```dart
AnimatedMapController(
    vsync: this,
    duration: const Duration(milliseconds: 500),
    curve: Curves.easeInOut,
    cancelPreviousAnimations: true, // Default to false
);
```

And add it to your `FlutterMap` widget:

```dart
FlutterMap(
    mapController: _animatedMapController.mapController,
    // ...
)
```

### Animated Movement

| Rotation | Zoom | Center on point |
| ----- | ----- | ----- |
| <img src="https://github.com/TesteurManiak/flutter_map_animations/blob/main/gifs/rotate.gif?raw=true" height="400"> | <img src="https://github.com/TesteurManiak/flutter_map_animations/blob/main/gifs/zoom.gif?raw=true" height="400"> | <img src="https://github.com/TesteurManiak/flutter_map_animations/blob/main/gifs/center-on-point.gif?raw=true" height="400"> |

Check the [`AnimatedMapController` API][animated-map-controller] for more!

## AnimatedMarkerLayer & AnimatedMarker

| AnimatedMarker |
| ----- |
| <img src="https://raw.githubusercontent.com/TesteurManiak/flutter_map_animations/main/gifs/animated-marker.gif" height="400"> |

```dart
FlutterMap(
    mapController: _animatedMapController.mapController,
    children: [
        TileLayer(
            urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
            userAgentPackageName: 'com.example.app',
        ),
        AnimatedMarkerLayer(
            markers: [
                AnimatedMarker(
                    point: LatLng(51.509364, -0.128928),
                    builder: (_, animation) {
                        final size = 50.0 * animation.value;
                        return Icon(
                            Icons.location_on,
                            size: size,
                        );
                    },
                ),
            ],
        ),
    ],
)
```

# Migration Guide

## v0.5.0

With [flutter_map v6][flutter-map-v6] some parameters have been removed or renamed:

* `AnimatedMarker.rotateOrigin`, `AnimatedMarker.anchorPos` have been removed
* `AnimatedMarker.rotateAlignment` has been renamed to `AnimatedMarker.alignment`
* `AnimatedMarkerLayer.rotateOrigin`, `AnimatedMarkerLayer.anchorPos` have been removed
* `AnimatedMarkerLayer.rotateAlignment` has been renamed to `AnimatedMarkerLayer.alignment`

## v0.4.0

* With [flutter_map v5][flutter-map-v5] it's not possible anymore to extend `MapControllerImpl` which was used to use the `AnimatedMapController` directly as a `MapController` in the `FlutterMap` widget. Now an instance of `MapController` is created internally or can be passed as a parameter to the `AnimatedMapController` constructor. You can access it with the `mapController` getter:

```dart
late final _animatedMapController = AnimatedMapController(vsync: this);

@override
Widget build(BuildContext context) {
    return FlutterMap(
        mapController: _animatedMapController.mapController,
        // ...
    );
}
```

# Contributors

<!-- readme: contributors -start -->
<table>
<tr>
    <td align="center">
        <a href="https://github.com/TesteurManiak">
            <img src="https://avatars.githubusercontent.com/u/14369698?v=4" width="100;" alt="TesteurManiak"/>
            <br />
            <sub><b>Guillaume Roux</b></sub>
        </a>
    </td>
    <td align="center">
        <a href="https://github.com/JaffaKetchup">
            <img src="https://avatars.githubusercontent.com/u/58115698?v=4" width="100;" alt="JaffaKetchup"/>
            <br />
            <sub><b>Luka S</b></sub>
        </a>
    </td>
    <td align="center">
        <a href="https://github.com/rorystephenson">
            <img src="https://avatars.githubusercontent.com/u/3683599?v=4" width="100;" alt="rorystephenson"/>
            <br />
            <sub><b>Rory Stephenson</b></sub>
        </a>
    </td>
    <td align="center">
        <a href="https://github.com/ReinisSprogis">
            <img src="https://avatars.githubusercontent.com/u/69913791?v=4" width="100;" alt="ReinisSprogis"/>
            <br />
            <sub><b>Reinis Sprogis</b></sub>
        </a>
    </td></tr>
</table>
<!-- readme: contributors -end -->

[pub-package]: https://pub.dev/packages/flutter_map_animations
[pub-flutter-map]: https://pub.dev/packages/flutter_map
[example]: https://testeurmaniak.github.io/flutter_map_animations/#/
[animated-map-controller]: https://pub.dev/documentation/flutter_map_animations/latest/flutter_map_animations/AnimatedMapController-class.html
[flutter-map-v6]: https://pub.dev/packages/flutter_map/changelog#600---20231009
[flutter-map-v5]: https://pub.dev/packages/flutter_map/changelog#500---20230604