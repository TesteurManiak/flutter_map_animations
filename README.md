# flutter_map_animations

Animation utility for flutter_map.

## Usage

Just create an `AnimatedMapController` and you're good to go.

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

You can specify the animation duration and curve.

```dart
AnimatedMapController({
    required this.vsync,
    this.duration = const Duration(milliseconds: 500),
    this.curve = Curves.fastOutSlowIn,
});
```

## Methods

* `animatedTo({LatLng? dest, double? zoom, double? rotation})`
* `animatedRotateFrom(double degree)`
* `animatedRotateTo(double degree)`
* `animatedRotateReset()`
* `animatedZoomTo(double newZoom)`
* `animatedZoomIn()`
* `animatedZoomOut()`
