import 'package:flutter/material.dart';
import 'colors.dart';

getRoundCornerWithShadow({Color color = white}) {
  return BoxDecoration(
    color: color,
    borderRadius: const BorderRadius.all(Radius.circular(7)),
    boxShadow: [
      BoxShadow(
          color: Colors.grey.withOpacity(0.2),
          spreadRadius: 0,
          blurRadius: 1,
          offset: const Offset(1, 1)
          ),
    ],
  );
}
