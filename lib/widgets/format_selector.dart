import 'package:flutter/material.dart';
import '../models/download_model.dart';

class FormatSelector extends StatelessWidget {
  final Format selected;
  final ValueChanged<Format> onChanged;

  const FormatSelector({
    super.key,
    required this.selected,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        _buildCard(Format.mp4, '🎬', 'MP4', 'فيديو بجودة عالية'),
        const SizedBox(width: 12),
        _buildCard(Format.mp3, '🎵', 'MP3', 'صوت فقط'),
      ],
    );
  }

  Widget _buildCard(Format f, String emoji, String title, String sub) {
    final isSelected = f == selected;
    return Expanded(
      child: GestureDetector(
        onTap: () => onChanged(f),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 250),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: const Color(0xFF111118),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: isSelected
                  ? const Color(0xFF7C6AF0)
                  : const Color(0xFF2A2840),
              width: isSelected ? 2 : 1,
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(emoji, style: const TextStyle(fontSize: 24)),
                  AnimatedContainer(
                    duration: const Duration(milliseconds: 250),
                    width: 20,
                    height: 20,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: isSelected
                          ? const Color(0xFF7C6AF0)
                          : Colors.transparent,
                      border: Border.all(
                        color: isSelected
                            ? const Color(0xFF7C6AF0)
                            : const Color(0xFF3D3A60),
                        width: 2,
                      ),
                    ),
                    child: isSelected
                        ? const Icon(Icons.check, size: 12, color: Colors.white)
                        : null,
                  ),
                ],
              ),
              const SizedBox(height: 10),
              Text(
                title,
                style: const TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.w800,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                sub,
                style: const TextStyle(
                  fontSize: 12,
                  color: Color(0xFF9B96C8),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
