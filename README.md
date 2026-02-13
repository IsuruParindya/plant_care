# Plant Care Log – Mobile Application

Plant Care Log is a Flutter-based mobile application designed to help users manage plant information and basic user account data. The app focuses on simplicity, offline usage, and clean UI design for plant enthusiasts and home gardeners.

## Features

- User account management (Sign Up, Sign In, Edit Profile)
- View a curated list of plants with images and care details
- View detailed plant care information
- Edit user profile information
- Offline data persistence
- Clean and user-friendly interface

## Data Storage & Persistence

The application uses **SharedPreferences** for local data persistence.  
User and plant-related data are stored as **JSON-encoded objects** under specific keys within the device’s local storage. This approach is suitable for lightweight data storage and allows the application to function offline without requiring a backend connection.

## Technologies Used

- **Flutter**
- **Dart**
- **SharedPreferences** (local data persistence)
- **Material Design** UI components

## Supported Platforms

- Android
- iOS
- Web (limited local storage support)

## Getting Started,

To run this project locally:

1. Clone the repository:
```bash
git clone https://github.com/IsuruParindya/plant_care.git
