import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

class AnimatedStatCard extends StatefulWidget {
  final IconData icon;
  final String title;
  final double end;
  final Color color;
  final String Function(double)? formatter;

  const AnimatedStatCard({
    super.key,
    required this.icon,
    required this.title,
    required this.end,
    required this.color,
    this.formatter,
  });

  @override
  State<AnimatedStatCard> createState() => _AnimatedStatCardState();
}

class _AnimatedStatCardState extends State<AnimatedStatCard> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 1200),
      vsync: this,
    );
    _animation = Tween<double>(begin: 0, end: widget.end).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOut),
    );
    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Icon(widget.icon, size: 40, color: widget.color),
            const SizedBox(height: 16),
            AnimatedBuilder(
              animation: _animation,
              builder: (context, child) {
                return Text(
                  widget.formatter != null
                      ? widget.formatter!(_animation.value)
                      : NumberFormat.compact().format(_animation.value),
                  style: Get.textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.bold),
                );
              },
            ),
            const SizedBox(height: 8),
            Text(
              widget.title,
              style: Get.textTheme.titleMedium?.copyWith(color: Colors.grey[600]),
            ),
          ],
        ),
      ),
    );
  }
}
