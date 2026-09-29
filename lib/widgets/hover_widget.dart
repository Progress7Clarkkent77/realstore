import 'package:flutter/material.dart';

class HoverWidget extends StatefulWidget {
  final Widget child;
  final Color hoverColor;
  final Color defaultColor;
  final Function()? onTap;

  HoverWidget({
    required this.child,
    this.hoverColor = Colors.grey,
    this.defaultColor = Colors.white,
    this.onTap,
  });

  @override
  _HoverWidgetState createState() => _HoverWidgetState();
}

class _HoverWidgetState extends State<HoverWidget> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) {
        setState(() {
          _isHovered = true;
        });
      },
      onExit: (_) {
        setState(() {
          _isHovered = false;
        });
      },
      child: InkWell(
        onTap: widget.onTap,
        child: Container(
          decoration: BoxDecoration(
            color: _isHovered ? widget.hoverColor : widget.defaultColor,
            borderRadius: BorderRadius.all(Radius.circular(15.0)),
          ),
          child: widget.child,
        ),
      ),
    );
  }
}
