import 'package:flutter/foundation.dart';

class VisibilityState extends ValueNotifier<bool> {
  VisibilityState() : super(false); // false indicates hidden

  void setVisible(bool isVisible) {
    value = isVisible;
  }
}

// Create a global instance of VisibilityState
final VisibilityState globalSlabVisibilityState = VisibilityState();
