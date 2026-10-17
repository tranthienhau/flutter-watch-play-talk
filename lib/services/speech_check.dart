import '../models/models.dart';

/// On-device answer matcher for the Talk step.
///
/// The recognizer (Apple Speech on-device / Android on-device recognizer)
/// is hinted with the question's closed answer list and returns an N-best
/// list of text guesses. Only those strings reach this class; the audio
/// buffer is dropped before matching, and nothing is sent off the device.
///
/// Matching leans toward "yes": exact or toddler form = right, sound-alike
/// = close (still counts), otherwise none (gentle correction, never "wrong").
class SpeechCheck {
  const SpeechCheck();

  TalkResult check(List<String> nBest, List<String> accepted) {
    final guesses = nBest.take(5).map(_normalize).where((g) => g.isNotEmpty).toList();
    final answers = accepted.map(_normalize).toList();

    for (final g in guesses) {
      if (answers.contains(g)) return TalkResult.right;
    }
    for (final g in guesses) {
      final key = _soundKey(g);
      for (final a in answers) {
        if (_soundKey(a) == key) return TalkResult.close;
        if (_distance(g, a) <= _tolerance(a)) return TalkResult.close;
      }
    }
    return TalkResult.none;
  }

  /// Lowercase, strip accents and punctuation.
  static String _normalize(String s) {
    const from = 'áéíóúüñ';
    const to = 'aeiouun';
    final b = StringBuffer();
    for (final ch in s.toLowerCase().trim().split('')) {
      final i = from.indexOf(ch);
      b.write(i >= 0 ? to[i] : ch);
    }
    return b.toString().replaceAll(RegExp(r'[^a-z ]'), '').trim();
  }

  /// Rough bilingual sound key: merges letters toddlers and Spanish/English
  /// speakers commonly swap (r/l/w/d, b/v, s/z/c, ll/y, silent h).
  static String _soundKey(String s) {
    var k = s
        .replaceAll('ll', 'y')
        .replaceAll('h', '')
        .replaceAll(RegExp('[rlwd]'), 'r')
        .replaceAll('v', 'b')
        .replaceAll(RegExp('[zc]'), 's')
        .replaceAll(RegExp('[aeiou]+'), 'a');
    k = k.replaceAll(RegExp(r'(.)\1+'), r'$1');
    return k;
  }

  static int _tolerance(String answer) => answer.length <= 4 ? 1 : 2;

  static int _distance(String a, String b) {
    final d = List.generate(a.length + 1, (i) => List<int>.filled(b.length + 1, 0));
    for (var i = 0; i <= a.length; i++) {
      d[i][0] = i;
    }
    for (var j = 0; j <= b.length; j++) {
      d[0][j] = j;
    }
    for (var i = 1; i <= a.length; i++) {
      for (var j = 1; j <= b.length; j++) {
        final cost = a[i - 1] == b[j - 1] ? 0 : 1;
        d[i][j] = [d[i - 1][j] + 1, d[i][j - 1] + 1, d[i - 1][j - 1] + cost].reduce((x, y) => x < y ? x : y);
      }
    }
    return d[a.length][b.length];
  }
}
