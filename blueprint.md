# MedMinder Application Blueprint

## Overview

MedMinder is a Flutter application designed to help users manage their medication schedules. The app allows users to log in, add their medications, set reminders, track their daily progress, and view their medication history.

## Style and Design

The application follows Material Design 3 principles to provide a modern and intuitive user experience. The UI is designed to be clean, with a focus on readability and ease of use.

- **Theming**: The app uses a centralized `ThemeData` object with a color scheme generated from a seed color. It supports both light and dark modes.
- **Typography**: The app uses the `google_fonts` package for a consistent and visually appealing text style.
- **Iconography**: The app uses Material Design icons to enhance usability and provide clear visual cues.
- **Navigation**: The app uses a `BottomNavigationBar` for easy navigation between the main screens.

## Features

- **User Authentication**: Users can sign in using their Google account.
- **Medication Management**: Users can add, view, and manage their medications.
- **Daily Progress Tracking**: The app displays a circular progress indicator to show the percentage of medicines taken for the day.
- **Next Dose Reminder**: The app highlights the next upcoming medication dose, with a visual indicator for overdue medicines.
- **Categorized Medicine List**: Medicines are categorized into morning, afternoon, and evening sections for better organization.
- **Medication History**:
    - The app now has a `HistoryScreen` that displays a real-time log of all "Taken" and "Skipped" medication events.
    - History is fetched from a `medication_logs` collection in Firestore.
    - The history is grouped by date for easy readability.
    - A mechanism is in place to automatically log missed doses.

## Current Plan

The `HistoryScreen` currently displays placeholder statistics for "This Week's Adherence" and "Current Streak". The next step is to replace these placeholders with real, calculated data based on the user's medication logs.

1.  **Calculate Weekly Adherence**: Implement a function to calculate the percentage of 'Taken' events over the last 7 days from the medication logs.
2.  **Calculate Current Streak**: Implement a function to determine the number of consecutive days the user has taken at least one medication.
3.  **Update UI**: Integrate these calculations into the `HistoryScreen` to display the dynamic stats in the UI cards.
