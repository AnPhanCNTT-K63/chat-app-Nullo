# Chat App: Nullo
This is a full-stack chat app built with NestJS for the backend and Flutter for the frontend.

## Project Structure
```sh
chat-app-Nullo/
│── api-nestjs/       # Backend (NestJS)
│── frontend-flutter/  # Frontend (Flutter)
│── README.md
```

## Tech Stack
- **Backend**: NestJS (TypeScript)
- **Frontend**: Flutter (Dart, Provider for state management)
- **Database**: MongoDB, Firebase
- **Messaging**: Socket.io
- **Storage**: AWS S3
- **CDN**: AWS CloudFront
- **Deployment**: Railway (8GB RAM / 8 vCPU per service)

## Setup Instructions

### **Backend (NestJS)**
#### Prerequisites:
```sh
cd api-nestjs
npm install
```
#### Running the Backend:
```sh
npm run start:dev
```

### **Frontend (Flutter)**
#### Prerequisites:
- Flutter SDK
- Dart

#### Installation:
```sh
cd frontend-flutter
flutter pub get
```
#### Running the Frontend:
```sh
flutter run
```

## Features
1. **User Authentication**: Signup/Login with email, password, username.
   
   ![image](https://github.com/user-attachments/assets/af8c77ab-1324-47aa-a376-3f8d5e443c9e)
   ![image](https://github.com/user-attachments/assets/9ca8ceee-a625-410f-b3c8-225ae12e5c55)

2. **Home**: Display all users, search bar, and receive messages.
   
   ![image](https://github.com/user-attachments/assets/4ebd3ddb-34db-40b8-934b-d0a61716837f)

3. **Messaging**: Real-time chat via WebSockets.
   
   ![image](https://github.com/user-attachments/assets/ea90fcc6-acc5-4f9e-940f-1b4fe0ee921b)

4. **Notifications**: Push notifications for new messages.
   
   ![image](https://github.com/user-attachments/assets/adfe55e1-3148-4e6a-acb9-b6249a5be6df)

5. **Profile Management**: Users can edit their profile.
   
   ![image](https://github.com/user-attachments/assets/8607eb95-a013-4d33-a2d7-8cd154910e46)

6. **Account Management**: Users can edit their account details.
   
   ![image](https://github.com/user-attachments/assets/57c90fcf-b8f2-429e-bf42-ae6573267dac)
   ![image](https://github.com/user-attachments/assets/5a426c5d-df9a-4b17-8130-a959352fb64c)

## Contributing
1. Fork the repository.
2. Create a new branch (`feature-branch`).
3. Commit your changes.
4. Push to the branch and create a pull request.

## License
This project is licensed under the MIT License.

