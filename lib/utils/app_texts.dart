import 'dart:math';

class AppTexts {
  // General
  static const String appName = 'MedMinder';
  static const String featureNotImplemented =
      'This feature is not yet implemented.';
  static const String notSet = 'Not Set';

  // Auth Screen
  static const String welcomeMessage = 'Welcome to MedMinder';
  static const String loginToContinue = 'Login or Sign Up to continue';
  static const String emailLabel = 'Email';
  static const String passwordLabel = 'Password';
  static const String loginButtonLabel = 'Login';
  static const String signupPrompt = 'Don\'t have an account?';
  static const String signupButtonLabel = 'Sign Up';
  static const String authFailedError = 'Authentication Failed';
  static const String invalidEmailError = 'Please enter a valid email';
  static const String passwordLengthError =
      'Password must be at least 6 characters';

  // User Details Screen
  static const String userDetailsTitle = 'Complete Your Profile';
  static const String nameLabel = 'Full Name';
  static const String dobLabel = 'Date of Birth';
  static const String selectDateHint = 'Select Date';
  static const String saveButtonLabel = 'Save and Continue';

  // Home Screen
  static const String homeScreenTitle = 'Your Medication Schedule';
  static const String noMedicationsMessage =
      'You have no medications scheduled.';
  static const String addMedicationPrompt = 'Add a new one below!';
  static const String dailyTip = 'Daily Tip';
  static const String markAsTakenButton = 'Mark as Taken';
  static const String takenPillMessage = 'Pill taken!';

  // Medication Form
  static const String addMedicationTitle = 'Add New Medication';
  static const String editMedicationTitle = 'Edit Medication';
  static const String medicineNameLabel = 'Medicine Name';
  static const String dosageLabel = 'Dosage (e.g., 50mg, 1 tablet)';
  static const String scheduleLabel = 'Schedule';
  static const String frequencyLabel = 'Frequency';
  static const String reminderTimeLabel = 'Reminder Time';
  static const String selectTimeButton = 'Select Time';
  static const String saveMedicationButton = 'Save Medication';

  // History Screen
  static const String historyScreenTitle = 'Medication History';
  static const String noHistoryMessage = 'No medication history found.';
  static const String takenStatus = 'Taken';
  static const String skippedStatus = 'Skipped';

  // Profile Screen
  static const String profileScreenTitle = 'Profile';
  static const String noUserLoggedInError = 'No user logged in.';
  static const String profileDataError = 'Error loading profile data';
  static const String noProfileData = 'No profile data found.';
  static const String editProfileButton = 'Edit Profile';
  static const String logoutButtonLabel = 'Log Out';

  // Tips
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
