## 0.4.1

* Fixed topics in `pubspec.yaml`

## 0.4.0

**Check the [Migration Guide](https://github.com/TesteurManiak/flutter_map_animations#v040) to learn about breaking changes in this version**

* Updated to [flutter_map](https://pub.dev/packages/flutter_map/versions/5.0.0) v5
* Updated Dart SDK constraints to `>=3.0.0 <4.0.0`
* Contributions from [Rory Stephenson](https://github.com/rorystephenson)
    * Add customId for for animated movements and don't trigger movement when it isn't necessary [#5](https://github.com/TesteurManiak/flutter_map_animations/pull/5)

## 0.3.0

* Updated to [flutter_map](https://pub.dev/packages/flutter_map/versions/4.0.0) v4

## 0.3.0-dev.2

* Added `AnimationId` class to manage a `TileUpdateTransformer`

## 0.3.0-dev.1

* Updated to [flutter_map](https://pub.dev/packages/flutter_map/versions/4.0.0-dev.1) v4

## 0.2.2

* Contribution from [MaxiStefan](https://github.com/MaxiStefan)
    * Use the shortest rotation path when animating the camera [#1](https://github.com/TesteurManiak/flutter_map_animations/pull/1)

## 0.2.1

* Updated example
* Allow to set a custom `Curve` to each of the methods of `AnimatedMapController`

## 0.2.0

* Added `animatedFitBounds` and `centerOnPoints` methods to `AnimatedMapController`
* Properly disposed the `AnimationController` when the widget is disposed
* Smoother animation when the `LatLng` is updated

## 0.1.0+1

* Updated `README.md` to add the pub.dev badge

## 0.1.0

* First release
