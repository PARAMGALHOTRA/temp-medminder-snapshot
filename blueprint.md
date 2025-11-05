
# MedMinder Application Blueprint

## Overview

MedMinder is a Flutter application designed to help users manage their medication schedules effectively. It provides features for adding, tracking, and receiving reminders for medications, a functionality that is achieved through the use of a backend service that sends notifications to the users. The application leverages Firebase for backend services, including user authentication, data storage and scheduled notifications.

## Style and Design

- **Theme:** The app uses a modern, clean design with both light and dark themes, powered by Material Design 3.
- **Fonts:** Google Fonts (Manrope, Oswald) are used for a clean and readable typography.
- **Layout:** The layout is designed to be intuitive and user-friendly, with a focus on clear navigation and information hierarchy.

## Features

- **User Authentication:** Secure user sign-up and login functionality using Firebase Authentication.
- **Medication Management:** Users can add, edit, and delete their medications, including details such as name, dosage, and frequency.
- **Smart Reminders:** The app sends timely notifications to remind users to take their medications.
- **Inventory Tracking:** Users can track their medication inventory and receive alerts when it's time to refill.
- **Profile Management:** Users can manage their profile and app settings, including notification preferences and theme selection.
- **Onboarding:** A simple onboarding flow to introduce new users to the app's features.

## Backend Services

- **Scheduled Medication Notifier:** A Cloud Function that runs every hour to check for upcoming medications and sends push notifications to users.
- **Daily Medication Completion Reset:** A daily Cloud Function that resets the completion status of all medications, ensuring users start each day with a fresh medication schedule.

## Current Plan

- **Run Application:** Launch the application to ensure all recent changes and bug fixes have been correctly implemented and that the new backend services are working as expected.
