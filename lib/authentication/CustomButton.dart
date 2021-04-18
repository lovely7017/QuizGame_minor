import 'package:flutter/material.dart';

class CustomButton extends StatelessWidget {
  final VoidCallback callback;
  final Widget lol;
  final Color colour;
  final double Height;

  const CustomButton(
      {Key key, this.callback, this.lol, this.colour, this.Height})
      : super(key: key);
  @override
  Widget build(BuildContext context) {
    return Material(
      color: colour,
      elevation: 3.0,
      borderRadius: BorderRadius.circular(3.0),
      child: MaterialButton(
        onPressed: callback,
        minWidth: 100.0,
        height: 45.0 + Height,
        child: lol,
      ),
    );
  }
}
