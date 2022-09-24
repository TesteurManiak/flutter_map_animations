# flutter_map_animations

Animation utility for flutter_map.

## AnimatedMapController

Just create an `AnimatedMapController` and you're good to go:

```dart
class _MyWidgetState extends State<MyWidget> with TickerProviderStateMixin {
    late final AnimatedMapController _mapController;

    @override
    void initState() {
        super.initState();
        _mapController = AnimatedMapController(vsync: this);
    }
}
```

You can specify the animation `duration` and `curve`.

And add it to your `FlutterMap` widget:

```dart
FlutterMap(
    mapController: _mapController,
    // ...
)
```

### Methods

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
    options: MapOptions(
        center: _center,
        onTap: (_, point) => _addMarker(point),
    ),
    children: [
        TileLayer(
            urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
            userAgentPackageName: 'com.example.app',
        ),
        AnimatedMarkerLayer(markers: markers),
    ],
)
```
