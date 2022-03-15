import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

void main() {
  runApp(const ProviderScope(child: MyApp()));
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'White Day App',
      theme: ThemeData(primarySwatch: Colors.cyan, canvasColor: Colors.white),
      home: const MyHomePage(title: 'Happy White Day !'),
    );
  }
}

class MyHomePage extends HookConsumerWidget {
  const MyHomePage({Key? key, required this.title}) : super(key: key);
  final String title;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isTapped = useState<bool>(false);
    final isOpened = useState<bool>(false);
    final isMessageShown = useState<bool>(false);
    final isUndoButtonShown = useState<bool>(false);

    return Scaffold(
      appBar: AppBar(
        title: Text(
          title,
          style:
              const TextStyle(color: Colors.white, fontStyle: FontStyle.italic),
        ),
      ),
      floatingActionButton: isUndoButtonShown.value
          ? _undoButton(
              context, isTapped, isOpened, isMessageShown, isUndoButtonShown)
          : const SizedBox.shrink(),
      body: Center(
        child: !isOpened.value
            ? Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  isTapped.value
                      ? Column(
                          children: [
                            ShakenBox(
                              child: Image.asset(
                                'assets/images/box.png',
                                width: MediaQuery.of(context).size.width * 0.3,
                              ),
                              onAnimationFinished: () {
                                isOpened.value = true;
                                //delay showing message until Image.asset is ready
                                Future.delayed(const Duration(seconds: 1)).then(
                                    (value) => isMessageShown.value = true);
                                Future.delayed(const Duration(seconds: 5)).then(
                                    (value) => isUndoButtonShown.value = true);
                              },
                            ),
                            const SizedBox(
                              height: 24,
                            ),
                            Text(
                              '',
                              style: Theme.of(context)
                                  .textTheme
                                  .headline3!
                                  .copyWith(fontSize: 24),
                            ),
                          ],
                        )
                      : Column(
                          children: [
                            Image.asset(
                              'assets/images/box.png',
                              width: MediaQuery.of(context).size.width * 0.3,
                            ),
                            const SizedBox(
                              height: 24,
                            ),
                            ElevatedButton(
                              onPressed: () {
                                isTapped.value = true;
                              },
                              child: const Text(
                                '開けてね',
                                style: TextStyle(color: Colors.white),
                              ),
                            ),
                          ],
                        ),
                ],
              )
            : Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      isMessageShown.value ? 'Cookies for minnちゃん' : '',
                      style: Theme.of(context)
                          .textTheme
                          .headline3!
                          .copyWith(fontSize: 28),
                    ),
                    Image.asset(
                      'assets/images/cookies.png',
                      width: MediaQuery.of(context).size.width * 0.8,
                    ),
                  ],
                ),
              ),
      ),
    );
  }

  Widget _undoButton(
    BuildContext context,
    ValueNotifier<bool> isTapped,
    ValueNotifier<bool> isOpened,
    ValueNotifier<bool> isMessageShown,
    ValueNotifier<bool> isUndoButtonShown,
  ) {
    return SizedBox(
      height: MediaQuery.of(context).size.height,
      width: MediaQuery.of(context).size.width,
      child: Column(
        //locate the button on the bottom end
        mainAxisAlignment: MainAxisAlignment.end,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text('もう一度アニメーションが見たいので'),
              const Text('開けてないことにする'),
              const SizedBox(
                height: 12,
              ),
              FloatingActionButton(
                onPressed: () {
                  isOpened.value = false;
                  isMessageShown.value = false;
                  isUndoButtonShown.value = false;
                  isTapped.value = false;
                },
                child: const Icon(
                  Icons.refresh_rounded,
                  color: Colors.white,
                ),
              )
            ],
          ),
        ],
      ),
    );
  }
}

class ShakenBox extends StatefulWidget {
  const ShakenBox(
      {Key? key, required this.child, required this.onAnimationFinished})
      : super(key: key);
  final Widget child;
  final void Function() onAnimationFinished;

  @override
  _ShakenBoxState createState() => _ShakenBoxState();
}

class _ShakenBoxState extends State<ShakenBox> with TickerProviderStateMixin {
  late AnimationController controller;
  int shakeCount = 0;

  @override
  void initState() {
    controller = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    )..forward();
    super.initState();
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final offsetAnimation = Tween(
      begin: 0,
      end: 24,
    )
        .chain(
          CurveTween(curve: Curves.elasticIn),
        )
        .animate(controller)
      ..addStatusListener((status) {
        if (shakeCount >= 3) {
          if (shakeCount == 3) {
            controller.forward().then((value) => widget.onAnimationFinished());
          }
          return;
        }
        if (status == AnimationStatus.dismissed) {
          shakeCount++;
          controller.forward();
        }
        if (status == AnimationStatus.completed) {
          controller.reverse();
        }
      });

    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Stack(
          alignment: AlignmentDirectional.center,
          children: [
            AnimatedBuilder(
                animation: offsetAnimation,
                builder: (_, child) {
                  if (shakeCount == 1) {
                    return Transform.rotate(
                      angle: math.sin(controller.value * 10 * math.pi) / 60,
                      child: widget.child,
                    );
                  } else if (shakeCount == 2) {
                    return Transform.rotate(
                      angle: math.sin(controller.value * 5 * math.pi) / 10,
                      child: widget.child,
                    );
                  } else {
                    shakeCount++;
                    return widget.child;
                  }
                }),
            AnimatedBuilder(
                animation: offsetAnimation,
                builder: (_, child) {
                  if (shakeCount >= 3) {
                    return Transform.scale(
                      scale: controller.value * 10,
                      child: Container(
                        decoration: const BoxDecoration(
                            shape: BoxShape.circle,
                            color: Colors.white,
                            boxShadow: [
                              BoxShadow(
                                color: Colors.white,
                                spreadRadius: 50,
                                blurRadius: 10,
                              ),
                            ]),
                      ),
                    );
                  } else {
                    return const SizedBox.shrink();
                  }
                })
          ],
        )
      ],
    );
  }
}
