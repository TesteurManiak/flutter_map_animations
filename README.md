# Flutter Map Animations

[![Pub Version (including pre-releases)](https://img.shields.io/pub/v/flutter_map_animations?include_prereleases)](https://pub.dev/packages/flutter_map_animations)

Animation utility for the [flutter_map](https://pub.dev/packages/flutter_map) package.

You can try the example app [here](https://testeurmaniak.github.io/flutter_map_animations/#/).

# Table of Contents

- [Documentation](#documentation)
    - [AnimatedMapController](#animatedmapcontroller)
        - [Animated Movement](#animated-movement)
    - [AnimatedMarkerLayer & AnimatedMarker](#animatedmarkerlayer--animatedmarker)
- [Migration Guide](#migration-guide)
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

You can specify the animation `duration` and `curve`:

```dart
AnimatedMapController(
    vsync: this,
    duration: const Duration(milliseconds: 500),
    curve: Curves.easeInOut,
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

All those methods are accessible from the `AnimatedMapController`:

* `animateTo({LatLng? dest, double? zoom, double? rotation, Curve? curve})`
* `animatedRotateFrom(double degree, {Curve? curve})`
* `animatedRotateTo(double degree, {Curve? curve})`
* `animatedRotateReset({Curve? curve})`
* `animatedZoomTo(double newZoom, {Curve? curve})`
* `animatedZoomIn({Curve? curve})`
* `animatedZoomOut({Curve? curve})`
* `centerOnPoint(LatLng point, {double? zoom, Curve? curve})`
* `centerOnPoints(List<LatLng> points, {FitBoundsOptions? options, Curve? curve})`
* `animatedFitBounds(LatLngBounds bounds, {FitBoundsOptions? options, Curve? curve})`

## AnimatedMarkerLayer & AnimatedMarker

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
                    builder: (_, __) => Icon(Icons.location_on),
                ),
            ],
        ),
    ],
)
```

# Migration Guide

## v0.4.0

* With flutter_map v5 it's not possible anymore to extend `MapControllerImpl` which was used to use the `AnimatedMapController` directly as a `MapController` in the `FlutterMap` widget. Now an instance of `MapController` is created internally or can be passed as a parameter to the `AnimatedMapController` constructor. You can access it with the `mapController` getter:

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
        <a href="https://github.com/rorystephenson">
            <img src="https://avatars.githubusercontent.com/u/3683599?v=4" width="100;" alt="rorystephenson"/>
            <br />
            <sub><b>Rory Stephenson</b></sub>
        </a>
    </td></tr>
</table>
<!-- readme: contributors -end -->
