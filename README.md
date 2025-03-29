# Chat App: Nullo
This is a full-stack dating application built with NestJS for the backend and Flutter for the frontend.

## Project Structure
```sh
chat-app-Nullo/
│── api-nestjs/       # Backend (NestJS)
│── frontend-flutter/  # Frontend (Flutter)
│── README.md
```
## Tech Stack
Backend: NestJS (Nestjs, TypeScript)

Frontend: Flutter (Dart, Provider for state management)

Database: MongoDB

Message: Socket.io

Deployment: Railway (8GB RAM / 8 vCPU per service)

## Setup Instructions

### Backend (NestJS)
Prerequisites:
```sh
cd api-nestjs
npm install
```
Running the Backend:
```sh
npm run start:dev
```

### Frontend (Flutter)
Prerequisites:
Flutter SDK
Dart
Installation:
```sh
cd frontend-flutter
flutter pub get
```
Running the Frontend:
```sh
flutter run
```

## Features
User Authentication: Signup/Login with email, password, username

Profile Management: Users can edit their profile

Matching System: Swipe left/right to match with users

Messaging: Real-time chat via WebSockets

Notifications: Push notifications for new messages

## Contributing
Fork the repository

Create a new branch (feature-branch)

Commit your changes

Push to the branch and create a pull request

## License
This project is licensed under the MIT License.
