import 'package:flutter/material.dart';


class DefaultButton extends StatelessWidget {
  //final Icon icon;
  final String labelText;
  final TextStyle textStyle;
  final void Function()? onPressed;
  final Color backgroundColor;
  const DefaultButton(
      {super.key,
      required this.labelText,
      required this.textStyle,
      required this.onPressed,
      required this.backgroundColor});

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
        onPressed: onPressed,
        style: ButtonStyle(
            backgroundColor: WidgetStateProperty.all(backgroundColor),
            padding: WidgetStateProperty.all(
                const EdgeInsets.symmetric(vertical: 4, horizontal: 14)),
            minimumSize: WidgetStateProperty.all<Size>(
                Size(MediaQuery.of(context).size.width, 50)),
            maximumSize: WidgetStateProperty.all<Size>(
                Size(MediaQuery.of(context).size.width, 50))),
        child: Text(
          labelText,
          style: textStyle,
        ));
  }
}

class OutlineButton extends StatelessWidget {
  //final Icon icon;
  final String labelText;
  final TextStyle textStyle;
  final void Function()? onPressed;
  final Color borderColor;
  const OutlineButton(
      {super.key,
        required this.labelText,
        required this.textStyle,
        required this.onPressed,
        required this.borderColor});

  @override
  Widget build(BuildContext context) {
    return OutlinedButton(
        onPressed: onPressed,
        style: ButtonStyle(
          side: WidgetStateProperty.all<BorderSide>(
              BorderSide(color: borderColor, width: 1.4, style: BorderStyle.solid)),
            padding: WidgetStateProperty.all(
                const EdgeInsets.symmetric(vertical: 4, horizontal: 14)),
            minimumSize: WidgetStateProperty.all<Size>(
                Size(MediaQuery.of(context).size.width, 50)),
            maximumSize: WidgetStateProperty.all<Size>(
                Size(MediaQuery.of(context).size.width, 50))),
        child: Text(
          labelText,
          style: textStyle,
        ));
  }
}
