# MedMinder Application Blueprint

## Overview

MedMinder is a Flutter application designed to help users manage their medications. It allows users to track their medication schedules, receive reminders, and reorder their prescriptions. The app is built with Flutter and uses Firebase for backend services such as authentication and data storage.

## Project Style, Design, and Features

### Style and Design

*   **Theming**: The app uses a modern, clean design with a light and dark theme. The color scheme is based on Material Design 3 principles, with a primary color of `#4A90E2`. The typography is based on the `Manrope` and `GoogleFonts` font families.
*   **Layout**: The app uses a bottom navigation bar for main navigation and has a consistent layout across all screens.
*   **Components**: The app uses a variety of Material Design components, including cards, buttons, icons, and text fields.

### Features

*   **Authentication**: Users can sign in to the app using their email and password.
*   **Medication Tracking**: Users can add, edit, and delete their medications. Each medication has a name, dosage, and schedule.
*   **Reminders**: Users receive notifications to remind them to take their medications.
*   **Order Medicines**: Users can view their current medications and contact pharmacies to reorder them.
*   **History**: Users can view a history of their medication intake.
*   **Profile**: Users can view and edit their profile information.

## Current Change: Fix Order Screen and Refactor

### Plan and Steps

1.  **Delete redundant file**: Deleted the `lib/screens/orders_screen.dart` file to remove confusion and redundancy.
2.  **Correct navigation**: Updated `lib/screens/app_shell.dart` to point the "Orders" tab to the correct `OrderScreen`.
3.  **Refactor `OrderScreen`**: Refactored `lib/screens/order_screen.dart` to:
    *   Fetch medication data from Firestore instead of using a hardcoded list.
    *   Display an "empty cabinet" message when no medications are available.
    *   Remove hardcoded colors and use `Theme.of(context)` for a cleaner and more maintainable codebase.
4.  **Fix syntax error**: Corrected a syntax error in `lib/screens/order_screen.dart` where the entire file was wrapped in a multi-line string.
