import 'build_step.dart';

enum Difficulty { easy, medium, hard, expert, master }

enum Category {
  animals,
  buildings,
  vehicles,
  shapes,
  games,
  characters,
  nature,
  fantasy,
}

class Construction {
  final String id;
  final String name;
  final String emoji;
  final bool is3d;
  final Difficulty difficulty;
  final Category category;
  final int timeMinutes;
  final String description;
  final String tip;
  final Map<String, int> piecesNeeded; // tileId -> quantity
  final List<BuildStep> steps;
  final List<String> ageGroups; // es. ['5-7', '8+']

  const Construction({
    required this.id,
    required this.name,
    required this.emoji,
    required this.is3d,
    required this.difficulty,
    required this.category,
    required this.timeMinutes,
    required this.description,
    required this.tip,
    required this.piecesNeeded,
    required this.steps,
    this.ageGroups = const ['5-7', '8+'],
  });

  String get difficultyLabel {
    switch (difficulty) {
      case Difficulty.easy: return 'Facile';
      case Difficulty.medium: return 'Medio';
      case Difficulty.hard: return 'Difficile';
      case Difficulty.expert: return 'Esperto';
      case Difficulty.master: return 'Master';
    }
  }

  int get totalPieces => piecesNeeded.values.fold(0, (a, b) => a + b);
}
