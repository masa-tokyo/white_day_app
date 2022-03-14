import 'package:flutter/cupertino.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final boxStateProvider =
    ChangeNotifierProvider<BoxStateNotifier>((ref) => BoxStateNotifier());

class BoxStateNotifier extends ChangeNotifier {
  BoxStateNotifier() : super();

  bool isOpened = false;

  void open() {
    isOpened = true;
    notifyListeners();
  }
}

// final boxProvider =
//     StateNotifierProvider<BoxNotifier, BoxState>((ref) => BoxNotifier());
//
// class BoxNotifier extends StateNotifier<BoxState> {
//   BoxNotifier() : super(const BoxState(isOpened: false));
//
//   bool isOpened = false;
//
//   void open() {
//     state = const BoxState(isOpened: true);
//   }
// }
//
// @immutable
// class BoxState {
//   const BoxState({required this.isOpened});
//   final bool isOpened;
// }
