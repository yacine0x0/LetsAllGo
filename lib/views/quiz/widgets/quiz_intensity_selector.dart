// views/quiz/widgets/quiz_intensity_selector.dart
import 'package:flutter/material.dart';

class QuizIntensitySelector extends StatelessWidget {
  final double h;
  final double w;
  final int selectedIntensity;
  final List<int> intensities;
  final List<String> labels;
  final List<Color> colors;
  final Function(int) onIntensitySelected;

  const QuizIntensitySelector({
    super.key,
    required this.h,
    required this.w,
    required this.selectedIntensity,
    required this.intensities,
    required this.labels,
    required this.colors,
    required this.onIntensitySelected,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "Niveau de difficulté du quiz",
          style: TextStyle(
            color: Colors.white,
            fontSize: h * 0.022,
            fontWeight: FontWeight.bold,
          ),
        ),
        SizedBox(height: h * 0.02),
        Wrap(
          spacing: 16,
          children: List.generate(intensities.length, (index) {
            final intensity = intensities[index];
            final isSelected = selectedIntensity == intensity;
            final color = colors[index];
            return GestureDetector(
              onTap: () => onIntensitySelected(intensity),
              child: Container(
                padding: EdgeInsets.symmetric(
                  horizontal: w * 0.03,
                  vertical: h * 0.015,
                ),
                decoration: BoxDecoration(
                  color: isSelected ? color.withValues(alpha: 0.2) : Colors.white.withValues(alpha: 0.08),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(
                    color: isSelected ? color : Colors.white24,
                    width: isSelected ? 2 : 1,
                  ),
                ),
                child: Column(
                  children: [
                    Text(
                      labels[index],
                      style: TextStyle(
                        color: isSelected ? color : Colors.white70,
                        fontSize: h * 0.020,
                        fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                      ),
                    ),
                    Text(
                      "$intensity questions par chapitre",
                      style: TextStyle(
                        color: isSelected ? color.withValues(alpha: 0.8) : Colors.white54,
                        fontSize: h * 0.012,
                      ),
                    ),
                  ],
                ),
              ),
            );
          }),
        ),
        SizedBox(height: h * 0.03),
        Container(
          padding: EdgeInsets.all(h * 0.02),
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.05),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.white12),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "Que signifie le niveau de difficulté ?",
                style: TextStyle(
                  color: Colors.blue,
                  fontSize: h * 0.018,
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(height: h * 0.01),
              Text(
                "Le niveau de difficulté détermine le nombre de questions que tu devras répondre par chapitre sélectionné.\n\n"
                "• Facile : Bon pour apprendre\n"
                "• Moyen : Questions plus challenging\n"
                "• Difficile : Niveau avancé\n"
                "• Expert : Difficulté maximale",
                style: TextStyle(
                  color: Colors.white54,
                  fontSize: h * 0.014,
                  height: 1.5,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}