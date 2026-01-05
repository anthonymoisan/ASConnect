import 'package:flutter/foundation.dart';

class ConversationEvents {
  // à chaque "bump", les listeners peuvent reload
  static final ValueNotifier<int> refreshTick = ValueNotifier<int>(0);

  static void bump() {
    refreshTick.value++;
  }
}
