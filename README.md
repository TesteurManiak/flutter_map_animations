# Flutter Map Animations

Animation utility for [flutter_map](https://pub.dev/packages/flutter_map).

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

* `animateTo({LatLng? dest, double? zoom, double? rotation})`
* `animatedRotateFrom(double degree)`
* `animatedRotateTo(double degree)`
* `animatedRotateReset()`
* `animatedZoomTo(double newZoom)`
* `animatedZoomIn()`
* `animatedZoomOut()`
* `centerOnPoint(LatLng point, {double? zoom})`

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
