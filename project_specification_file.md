# Product Requirement Document (PRD) & Technical Specification

## 1. Project Overview & Name
* **Application Display Name:** `Go Learn`
* **Target Platforms:** Cross-platform single codebase in **Flutter** compiled for **Android** and **Web (Desktop)**.

---

## 2. Tech Stack Architecture

| Layer | Technology | Description |
| :--- | :--- | :--- |
| **Frontend Framework** | **Flutter (3.x)** | Single codebase targeting Android (`apk`/`bundle`) and Web (`canvasKit`). |
| **Authentication** | **Clerk (`clerk_flutter`)** | User auth, web hooks, multi-tenant session management, and custom user metadata roles (`student`, `instructor`, `admin`). |
| **Database & Storage** | **Firebase (Cloud Firestore + Storage)** | NoSQL real-time database and file storage for assignments, course notes, and submissions. |
| **Code Execution API** | **Piston API** | External execution engine for evaluating HTML/CSS/JS or Python snippets submitted via Desktop Code Lab. |
| **Routing** | **`go_router`** | Handles deep linking on Web (`/admin`, `/courses`, `/dashboard`) and mobile navigation stack. |

---

## 3. UI/UX Design System: Neobrutalism Style Guide

The application UI **must strictly adhere** to the Neobrutalist design language extracted from the provided reference image (`signup.png`).

```
  ┌──────────────────────────────────────────────────────────────┐
  │                 NEOBRUTALISM UI SPECIFICATION                │
  ├──────────────────────────────────────────────────────────────┤
  │  • Hard, Offset Drop Shadows (3px–5px solid #000000)        │
  │  • Thick Black Borders (2px–3px stroke #000000)             │
  │  • Pure Sharp Corners or Minimal Radius (R: 8px–12px)       │
  │  • High-Contrast Bold Typography (Heavy Sans-Serif Fonts)    │
  │  • Vibrant Solid Palette with Pale Mint Background          │
  └──────────────────────────────────────────────────────────────┘
```

### Color Palette Reference Map
* **Primary Royal Blue:** `#5346E0` (Left hero panel, main CTA button fill)
* **Accent Neon Green:** `#00FF87` (Highlight text, badge indicators, callouts)
* **Background Pale Mint:** `#E3FBEB` (Global web & mobile screen background)
* **Secondary Crimson Red:** `#9E1B22` / `#D32F2F` (Badges, tag banners, alert states)
* **Neutral Dark Charcoal / Black:** `#0C1810` / `#000000` (Thick borders, hard offset shadows, high-contrast headings)
* **Surface White:** `#FFFFFF` (Card backgrounds, input container fills)

### Theme Specification in Flutter

```dart
import 'package:flutter/material.dart';

class NeobrutalismTheme {
  static const Color primaryBlue = Color(0xFF5346E0);
  static const Color neonGreen = Color(0xFF00FF87);
  static const Color backgroundMint = Color(0xFFE3FBEB);
  static const Color crimsonRed = Color(0xFF9E1B22);
  static const Color pureBlack = Color(0xFF000000);
  static const Color cardWhite = Color(0xFFFFFFFF);

  static BoxDecoration neobrutalCardDecoration({Color color = cardWhite}) {
    return BoxDecoration(
      color: color,
      borderRadius: BorderRadius.circular(12),
      border: Border.all(color: pureBlack, width: 2.5),
      boxShadow: const [
        BoxShadow(
          color: pureBlack,
          offset: Offset(4, 4),
          blurRadius: 0, // Hard shadow, zero blur radius
        ),
      ],
    );
  }

  static TextStyle headingBold = const TextStyle(
    fontFamily: 'Lexend',
    fontWeight: FontWeight.w900,
    color: pureBlack,
    letterSpacing: -0.5,
  );
}
```

---

## 4. Multi-Device Strategy & Access Control

```
                         ┌─────────────────────────────────┐
                         │      Flutter Unified Codebase   │
                         └────────────────┬────────────────┘
                                          │
                  ┌───────────────────────┴───────────────────────┐
                  ▼                                               ▼
      ┌───────────────────────┐                       ┌───────────────────────┐
      │   Desktop Web Build   │                       │ Flutter Android Build │
      └───────────┬───────────┘                       └───────────┬───────────┘
                  │                                               │
  ┌───────────────┴───────────────┐               ┌───────────────┴───────────────┐
  │ • Admin Management Panel      │               │ • View Courses & Schemes      │
  │ • Instructor Grading Suite    │               │ • Daily Multiple-Choice Quizzes│
  │ • Full Interactive Code Lab   │               │ • Leaderboards & Progress     │
  │ • Neobrutalist UI Dashboard   │               │ • 🔒 Code Lab Locked (Prompt) │
  └───────────────────────────────┘               └───────────────────────────────┘
```

### Mobile Lockout Implementation
If the viewport width is below `800px` (or on Android native), render a locked screen state for practical assignments:

```dart
Widget buildAssignmentScreen(BuildContext context) {
  final bool isDesktop = MediaQuery.of(context).size.width >= 800;

  return Scaffold(
    backgroundColor: NeobrutalismTheme.backgroundMint,
    body: isDesktop 
      ? const DesktopCodeLabWidget() 
      : const MobileLockoutPromptWidget(),
  );
}
```

---

## 5. Database Schema (Cloud Firestore)

```text
/users/{userId}
  ├── name: string
  ├── email: string
  ├── role: "student" | "instructor" | "admin"  // Synced from Clerk Public Metadata
  ├── approved: boolean
  └── createdAt: timestamp

/courses/{courseId}
  ├── title: string
  ├── category: string
  ├── description: string
  ├── lessonsCount: number
  ├── isLocked: boolean
  └── /lessons/{lessonId} (Subcollection: Daily Scheme of Work)
        ├── dayNumber: number
        ├── title: string
        ├── contentMarkdown: string
        ├── starterCode: string
        └── /quizzes/{quizId} (Subcollection: Daily Quiz)
              ├── question: string
              ├── options: array [string]
              └── correctAnswerIndex: number

/submissions/{submissionId}
  ├── studentId: string
  ├── courseId: string
  ├── lessonId: string
  ├── codeSubmitted: string
  ├── fileUrl: string
  ├── score: number
  ├── graded: boolean
  └── submittedAt: timestamp
```

---

## 6. Detailed Feature Requirements

### A. Admin Control Panel (Desktop Web)
* **User Approvals:** Table listing unapproved registrations with quick Approve/Reject buttons styled in Neobrutalist high contrast.
* **Role Syncing:** Update Clerk metadata (`role: admin | instructor | student`) and update corresponding Firestore user documents.
* **Course Creator:** Modal form with bold black outlines to add daily schemes, lesson notes, and quizzes.

### B. Instructor Suite (Desktop Web)
* **Grading Queue:** List of student submissions with split view showing submitted code/file on left and score input box on right.

### C. Student Experience (Web & Mobile)
* **Mobile (Android):** Read course notes, take daily quizzes, view departmental rank on leaderboard, track completion percentage.
* **Desktop Web:** Access in-browser Code Lab (`flutter_code_editor`) with live output execution powered by Piston API.

---

## 7. Developer Execution Steps

1. **Setup Project:** Initialize Flutter app and ensure `android/app/src/main/AndroidManifest.xml` label is set to `"Smart LMS"`.
2. **Setup Clerk & Firebase:** Integrate `clerk_flutter` for auth and `cloud_firestore` for database operations.
3. **Build Neobrutal Design System:** Build reusable widgets (`NeobrutalCard`, `NeobrutalButton`, `NeobrutalTextField`) adhering to the `#E3FBEB` background and `#5346E0` primary accents.
4. **Build Core Views:** Construct Admin dashboard, Course Reader, Quiz engine, and Desktop Code Lab.
5. **Testing & Build:** Build Android APK (`flutter build apk`) and deploy Flutter Web (`flutter build web`) to Vercel/Firebase Hosting.