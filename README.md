🎬 Flutter Show App

📌 Description

This is a Flutter mobile application that allows users to manage a list of movies, series, and anime. Users can add, update, and delete shows, as well as authenticate through a login system. The app interacts with a Node.js backend via a RESTful API.

🚀 Features

Login Page: Authenticate users with email and password.

Update Show Page: Modify existing show details.

Auto-Refresh Homepage: Dynamically update the show list after adding or editing a show.

REST API Integration: Communicates with a Node.js backend for data management.

🛠️ Installation & Setup

Prerequisites

Flutter installed (Installation Guide)

Node.js installed (Download Node.js)

A running backend server (configured in lib/config.dart)

Steps

Clone the repository:

git clone <repository_url>

Navigate to the project directory:

cd flutter_show_app

Install dependencies:

flutter pub get

Run the app:

flutter run

🔑 Login Credentials

Use the following credentials to test the login functionality:

Email: admin@example.com
Password: admin123

📂 API Endpoints

Ensure your backend API follows these endpoints:

POST /login → Authenticate users

GET /shows → Retrieve all shows

PUT /shows/:id → Update a show

DELETE /shows/:id → Delete a show

📜 License

This project is for educational purposes only.

🤝 Contributing

Feel free to fork and improve the project! Submit a pull request if you have enhancements.

📧 Contact

For any inquiries, reach out at your_email@example.com.

📝 Note

Ensure your backend server is running before testing the app!
