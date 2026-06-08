import 'package:flutter/material.dart';

class HoverElevatedButton extends StatefulWidget {
  const HoverElevatedButton({
    super.key,
    required this.onPressed,
    required this.icon,
    required this.label,
    required this.style,
    this.enableHover = true,
    this.hoverElevation = 8,
    this.defaultElevation = 4,
  });

  final VoidCallback onPressed;
  final Icon icon;
  final String label;
  final ButtonStyle style;
  final bool enableHover;
  final double hoverElevation;
  final double defaultElevation;

  @override
  State<HoverElevatedButton> createState() => _HoverElevatedButtonState();
}

class _HoverElevatedButtonState extends State<HoverElevatedButton> {
  bool _isHovering = false;

  @override
  Widget build(BuildContext context) {
    final elevation =
        _isHovering && widget.enableHover ? widget.hoverElevation : widget.defaultElevation;

    return MouseRegion(
      onEnter: widget.enableHover
          ? (_) => setState(() => _isHovering = true)
          : null,
      onExit: widget.enableHover
          ? (_) => setState(() => _isHovering = false)
          : null,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        child: ElevatedButton.icon(
          onPressed: widget.onPressed,
          icon: widget.icon,
          label: Text(widget.label),
          style: widget.style.copyWith(
            elevation: WidgetStateProperty.all(elevation),
          ),
        ),
      ),
    );
  }
}
