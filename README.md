# Flutter Map Animations

[![Pub Version (including pre-releases)](https://img.shields.io/pub/v/flutter_map_animations?include_prereleases)](https://pub.dev/packages/flutter_map_animations)

Animation utility for the [flutter_map](https://pub.dev/packages/flutter_map) package.

You can try the example app [here](https://testeurmaniak.github.io/flutter_map_animations/#/).

## AnimatedMapController

Just create an `AnimatedMapController` and you're good to go:

```dart
class _MyWidgetState extends State<MyWidget> with TickerProviderStateMixin {
    late final _mapController = AnimatedMapController(vsync: this);

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
    mapController: _mapController,
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
    mapController: _mapController,
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
    </td></tr>
</table>
<!-- readme: contributors -end -->
