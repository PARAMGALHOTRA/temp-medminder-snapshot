import 'dart:math';

class AppTexts {
  static final _tips = [
    'Drink a full glass of water with your morning pills.',
    'Set a daily reminder to check your medication schedule.',
    'Keep your medicines in a cool, dry place.',
    'Don\'t skip a dose, even if you feel better.',
    'Talk to your doctor about any side effects.',
    'Store your medications in their original containers.',
    'Keep a list of all medications you are taking.',
    'Check the expiration date on your medications regularly.',
    'Don\'t take medication in the dark to avoid mistakes.',
    'Take your medication at the same time every day.',
  ];

  static String getRandomTip() {
    final random = Random();
    return _tips[random.nextInt(_tips.length)];
  }
}
