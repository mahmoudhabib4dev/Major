import 'package:flutter/material.dart';
import 'package:get/get.dart';

class AnimatedDotsLoader extends StatefulWidget {
  final double fontSize;

  const AnimatedDotsLoader({Key? key, required this.fontSize})
    : super(key: key);

  @override
  State<AnimatedDotsLoader> createState() => _AnimatedDotsLoaderState();
}

class _AnimatedDotsLoaderState extends State<AnimatedDotsLoader>
    with TickerProviderStateMixin {
  late AnimationController _controller;
  late List<Animation<double>> _animations;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 1200),
      vsync: this,
    )..repeat();

    _animations = List.generate(3, (index) {
      return Tween<double>(begin: 0, end: 1).animate(
        CurvedAnimation(
          parent: _controller,
          curve: Interval(
            index * 0.2,
            0.6 + index * 0.2,
            curve: Curves.easeInOut,
          ),
        ),
      );
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          'loading'.tr,
          style: TextStyle(color: Colors.white70, fontSize: widget.fontSize),
        ),
        SizedBox(width: widget.fontSize * 0.3),
        ...List.generate(3, (index) {
          return AnimatedBuilder(
            animation: _animations[index],
            builder: (context, child) {
              return Opacity(
                opacity: 0.4 + (_animations[index].value * 0.6),
                child: Text(
                  '.',
                  style: TextStyle(
                    color: Colors.white70,
                    fontSize: widget.fontSize,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              );
            },
          );
        }),
      ],
    );
  }
}
