/// Settings for one game template instance.
///
/// The lesson pipeline (server side) picks a template and fills these
/// settings as JSON. The app only accepts a payload that passes [validate],
/// so a malformed or off-curriculum draft can never reach a child.
class GameSettings {
  const GameSettings({
    required this.template,
    required this.target,
    required this.distractors,
    required this.goal,
    required this.promptEs,
    required this.promptEn,
    required this.targetLabel,
    this.fallSpeed = 120,
    this.spawnEveryMs = 1100,
  });

  /// One of [templates].
  final String template;

  /// Item kind the child should catch, e.g. `apple`.
  final String target;
  final List<String> distractors;
  final int goal;
  final String promptEs;
  final String promptEn;
  final String targetLabel;

  /// Pixels per second. Kept gentle for toddler hands.
  final double fallSpeed;
  final int spawnEveryMs;

  static const templates = {'catch', 'runner', 'drive', 'pop', 'feed', 'sort'};

  /// Item kinds the art library can draw.
  static const artLibrary = {'apple', 'blueberry', 'banana', 'star', 'hand', 'number3', 'sun'};

  factory GameSettings.fromJson(Map<String, dynamic> j) {
    final s = GameSettings(
      template: j['template'] as String,
      target: j['target'] as String,
      distractors: (j['distractors'] as List).cast<String>(),
      goal: j['goal'] as int,
      promptEs: j['prompt_es'] as String,
      promptEn: j['prompt_en'] as String,
      targetLabel: j['target_label'] as String,
      fallSpeed: (j['fall_speed'] as num?)?.toDouble() ?? 120,
      spawnEveryMs: j['spawn_every_ms'] as int? ?? 1100,
    );
    final errors = s.validate();
    if (errors.isNotEmpty) {
      throw FormatException('Invalid game settings: ${errors.join('; ')}');
    }
    return s;
  }

  List<String> validate() {
    final e = <String>[];
    if (!templates.contains(template)) e.add('unknown template "$template"');
    if (!artLibrary.contains(target)) e.add('target "$target" not in art library');
    for (final d in distractors) {
      if (!artLibrary.contains(d)) e.add('distractor "$d" not in art library');
      if (d == target) e.add('distractor equals target');
    }
    if (goal < 3 || goal > 15) e.add('goal must be 3..15 for ages 2-6');
    if (fallSpeed > 220) e.add('fall speed too fast for toddlers');
    if (promptEs.isEmpty || promptEn.isEmpty) e.add('missing prompt');
    return e;
  }
}
