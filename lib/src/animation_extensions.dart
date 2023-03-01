import 'package:flutter/material.dart';

extension AnimationExtensions on Animation<double> {
  /// Calls [onAnimationEnd] when the animation is completed or dismissed.
  void onEnd(VoidCallback onAnimationEnd) {
    void statusListener(AnimationStatus status) {
      if (status == AnimationStatus.completed ||
          status == AnimationStatus.dismissed) {
        removeStatusListener(statusListener);
        onAnimationEnd();
      }
    }

    addStatusListener(statusListener);
  }
}
