import 'package:flutter/material.dart';
import '../models/download_model.dart';

class QualitySelector extends StatelessWidget {
  final Quality selected;
  final ValueChanged<Quality> onChanged;

  const QualitySelector({
    super.key,
    required this.selected,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const Text(
              'الجودة',
              style: TextStyle(
                fontSize: 13,
                color: Color(0xFF9B96C8),
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(width: 6),
            Text(
              '— اختر ما يناسبك',
              style: const TextStyle(
                fontSize: 11,
                color: Color(0xFF5A5580),
              ),
            ),
          ],
        ),
        const SizedBox(height: 10),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: Quality.values.map((q) => _buildPill(q)).toList(),
        ),
      ],
    );
  }

  Widget _buildPill(Quality q) {
    final isSelected = q == selected;
    return GestureDetector(
      onTap: () => onChanged(q),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 9),
        decoration: BoxDecoration(
          color: isSelected
              ? const Color(0xFF7C6AF0).withOpacity(0.15)
              : const Color(0xFF111118),
          borderRadius: BorderRadius.circular(30),
          border: Border.all(
            color: isSelected
                ? const Color(0xFF7C6AF0)
                : const Color(0xFF2A2840),
          ),
        ),
        child: Text(
          q.label,
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: isSelected ? const Color(0xFFA594F7) : const Color(0xFF9B96C8),
          ),
        ),
      ),
    );
  }
}
