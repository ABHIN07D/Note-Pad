Note Pad App
A simple Note Pad application built with Flutter that allows users to create, update, delete, and view notes.
The app uses SQLite for local storage and Shared Preferences for dark mode theme persistence. 
This app demonstrates basic CRUD operations and state management.

Features
Create, update, and delete notes.
Save and view notes in a list.
Supports dark and light mode with theme persistence.
Local storage using SQLite to store notes.
Shared Preferences used to persist the theme setting.
Technologies Used
Flutter: Framework used to build the app.
SQLite: Used to store notes locally.
Shared Preferences: For theme state (dark/light mode).
Dart: Language used for development.
Flutter Material Design: For UI components.
Installation
Follow the steps below to run the Note Pad app on your local machine:

1. Clone the Repository
bash
Copy
Edit
git clone https://github.com/ABHIN07D/notepad-app.git
cd notepad-app
2. Install Dependencies
Make sure you have Flutter installed on your system. You can follow the instructions on the official Flutter website to set up Flutter if you haven't already.

After cloning the repository, run the following command to install the dependencies:

bash
Copy
Edit
flutter pub get
3. Run the App
You can run the app on your emulator or physical device:

bash
Copy
Edit
flutter run
Usage
Launch the app, and you will see the main screen with options to add, edit, and delete notes.
You can toggle between dark mode and light mode by using the switch in the top right corner.
The notes are saved locally, and you can view or edit them anytime.
Screenshots
Home Screen:

Edit Note:

Future Enhancements
Implement search functionality for notes.
Add categories or labels for organizing notes.
Sync notes to the cloud using Firebase or another cloud service.
License
This project is licensed under the MIT License - see the LICENSE file for details.
