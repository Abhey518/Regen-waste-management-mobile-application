# ReGen – Rethink, Reduce, Recycle
### Waste Management & Recycling Application
**Subject:** Academic Project (2nd Year)

---

## 👥 Group Members & Contributions

| Name | Student ID | Implemented Module / Responsibilities |
| :--- | :--- | :--- |
| **Abeywardhana A. A. / Arunoda Abeywardhana** | `CT/2021/072` | **Project Lead**<br>• Guided & developed the frontend<br>• Developed the backend<br>• Guided & developed the admin dashboard<br>• Trained and developed the [garbage classification & proportion analyser model](https://github.com/Abhey518/Regen-object-detection-analyser) |
| **Mohan D. / Divyaloshini Mohan** | `CT/2021/085` | **Frontend Layouts & Documentation Lead**<br>• Developed initial layouts for all application screens<br>• Led the project documentation |
| **Pahalawaththa P. R. / Pasindu Randima** | `CT/2021/056` | **Backend & Database Lead**<br>• Guided and implemented backend integration<br>• Database management |
| **Jayamal B. M. / Bhanuka Malitha** | `CT/2021/058` | **Design & Admin Frontend Layout**<br>• UI design<br>• Guided and developed poster design<br>• Developed initial layout for the Admin dashboard |
| **Wijewardhana P. P. A. / Piyumi Wijewardhana** | `CT/2021/015` | **Design & Documentation Support**<br>• Guided and developed UI design<br>• Poster design<br>• Project documentation support |

---

## 📝 System Description
**ReGen** is an innovative, mobile-based waste management and recycling application combined with a web-based administration dashboard. It is designed to transform everyday disposal habits, encourage recycling, and bridge the gap between waste management policies and community involvement in Sri Lanka.

The application allows residents to track garbage truck collections in real-time, receive customized schedules based on local councils, report illegal dumping with AI-assisted object detection and GPS geotargeting, and learn sustainable practices. A gamified "Eco Kids Corner" introduces environmental topics to children through interactive quizzes, while a rewards point system encourages community engagement. The web-based administrator dashboard provides local municipal councils with visual modules to manage schedules, view public reports, analyze analytics, and handle community feedback.

---

## 🛠️ Technology Stack

* **Frontend Framework:** Flutter (Dart)
* **Backend Services:** Supabase Authentication, Supabase Storage (for dumping report photos)
* **Database Engine:** PostgreSQL (Supabase)
* **Image Recognition:** YOLOv8 Object Detection / Custom ML Model ([Regen-object-detection-analyser](https://github.com/Abhey518/Regen-object-detection-analyser))
* **UI/UX Design:** Figma
* **Collaboration & Tools:** Git, GitHub, VS Code

---

## 🗄️ Database Architecture
The platform runs on a PostgreSQL database hosted on Supabase. A complete combined schema file containing table declarations, indices, triggers, and views is located under:
📂 **[database/schema.sql](database/schema.sql)**

### Key Database Tables
* `users`: Profiles linked with Supabase Authentication, tracking locations, contact info, and roles.
* `garbage_pickup_schedule` & `area_schedule_templates`: Store local pickup schedules and recurrence rules.
* `dumping_reports`: Keep records of photo uploads, GPS coordinates, object count, and status.
* `kids_posts` & `kids_quiz_completions`: Track gamified educational quiz states.
* `notifications`: Store system alerts and status details.
* `feedback`: User suggestions and admin review comments.
* `provinces`, `districts`, `local_authorities`: Geolocation lookups for location targeting.

---

## 🎯 Main Features & Responsibilities

### 1. Garbage Pickup Schedule & Tracking
* **Dynamic Pickup Schedules:** Displays location-specific garbage collection dates, times, and status details.
* **Real-time Map Visuals:** Live tracking of garbage trucks on maps alongside nearby recycling locations using `flutter_map`.
* **Schedule Template Manager:** Web admin interface to register and modify recurring location-based pickup templates.
* **Database Procedures:** Automated scheduling runs generating collection routines from regional templates.

### 2. AI-Assisted Dumping Reports
* **Image Capture Pipeline:** Native camera and gallery integration for capturing illegal dumping sites.
* **AI Analysis:** Image recognition and object-detection model scoring to count and classify waste objects (detecting waste proportions).
* **GPS Geolocation:** Automatic extraction of device coordinate metadata (latitude/longitude) during photo submission.
* **Report Console:** Admin module showing all reports, status details (pending, investigating, resolved), and coordinates.

### 3. Eco Kids Corner
* **Gamified Interface:** Child-friendly cards showing interactive educational snippets.
* **Interactive Quizzes:** Quiz taking console checking multiple-choice answers dynamically.
* **Progress Logging:** Saves kids' quiz scores and keeps track of completed quiz states in the database.
* **Kids Corner Manager:** Web console allowing administrators to upload new quiz items and cards.

### 4. User Registration & Location Hierarchy
* **Hierarchical Signup Flow:** Step-by-step registration requesting Province ➔ District ➔ Local Municipal Council.
* **User Profile Backend:** Direct link between registration credentials, regional database references, and account profiles.
* **Feedback Portal:** Interactive channel enabling users to report bugs, request features, or send suggestions.

### 5. Educational Resources, Notifications & Rewards
* **Educational Article Feed:** Feed displaying categorization filters, saving options, and likes on sustainability articles.
* **Broadcast Alerts:** Live notification center containing announcements, urgent schedules, and pickup reminders.
* **Rewards Integration:** Points accumulation model rewarding users for logging recycling tasks.
* **Admin Publishing Tools:** Dashboard module to draft educational articles and broadcast notification alerts.

---

## ⚙️ Installation & Setup

### Prerequisites
* **Flutter SDK** (v3.7.0 or higher)
* **Dart SDK** (v2.19.0 to <3.0.0)
* **Android Studio** or **VS Code**

---

### Step 1: Set up the Database (Supabase / PostgreSQL)

1. Open your **Supabase SQL Editor**.
2. Run the database configuration script located in:
   * **[database/schema.sql](file:///d:/PROJECTS/Regen/database/schema.sql)**
   
This script establishes all tables, constraints, trigger functions, indices, and view structures required for the application.

---

### Step 2: Set up the Mobile Client (Flutter)

1. Get local package dependencies:
   ```bash
   flutter pub get
   ```

2. Create a `.env` file in your root project directory:
   ```env
   SUPABASE_URL=https://your-project.supabase.co
   SUPABASE_ANON_KEY=your-anon-key
   ```

3. Enable runtime environment access (passed at build time):
   * Add the credentials when launching or building the Flutter application:
     ```bash
     flutter run --dart-define=SUPABASE_URL=your-project-url --dart-define=SUPABASE_ANON_KEY=your-anon-key
     ```

---

## 🚀 How to Run the Application

To launch the mobile application client:

1. Connect your physical testing device (Android/iOS) or start an emulator.
2. Execute the following command from the root directory:
   ```bash
   flutter run
   ```

---

## 📄 Project Resources
- **Web Administration Dashboard:** [Regen-waste-management-admin-dashboard](https://github.com/Abhey518/Regen-waste-management-admin-dashboard)
- **Garbage Classification Model:** [Regen-object-detection-analyser](https://github.com/Abhey518/Regen-object-detection-analyser)
- **Abstract:** View our [Project Abstract](docs/Regen-Abstract.jpg)
- **Project Poster:** View our [Project Poster](docs/Regen%20-%20Project%20Poster.jpg)

---

## 📄 License
This project is licensed under the GNU General Public License v3.0 - see the [LICENSE](LICENSE) file for details.

---

Last Updated: July 2025


