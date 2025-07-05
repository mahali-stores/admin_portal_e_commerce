import 'package:flutter/material.dart';
import 'package:get/get.dart';

class StatCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String count;
  final Color color;
  final VoidCallback onTap;

  const StatCard({
    super.key,
    required this.icon,
    required this.title,
    required this.count,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 4,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(icon, size: 40, color: color),
              const SizedBox(height: 16),
              Text(
                count,
                style: Get.textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              Text(
                title,
                style: Get.textTheme.titleMedium?.copyWith(color: Colors.grey[600]),
              ),
            ],
          ),
        ),
      ),
    );
  }
}