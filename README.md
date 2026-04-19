# BloodSync: Connecting Donors, Saving Lives.🩸


BloodSync is a mobile application developed to streamline the blood donation process within our community. Our platform serves as a vital bridge between individuals in urgent need of blood and local donors, ensuring that emergency requests are handled efficiently, reliably, and with transparency. By leveraging modern mobile technology, we aim to eliminate the delays often associated with finding blood during critical medical situations.








## 🚀 Deployment & Installation

### Binary Packages
To begin your journey as a donor or requester, navigate to the Releases section and select the package for your device:

* **Android:** [📥 Download BloodSync_v1.2.apk](https://github.com/Screwen/BloodSync_Blood-Donation-App/releases/download/v1.2/BloodSync.apk) 📱


### Execution Steps
1. Download the latest stable APK from the release link.
2. Authorize "Install from Unknown Sources" on your Android device.
3. Launch the application and initialize your biometric/email credentials.
4. Connect—The network is now live. Prepare to save lives.

## ✨ Key Features
* Authentication: Users login/resgister with Email and Password for secure privacy.
* Real-time Request and Feedback: Users can post requestes and all the other usrs can see it in real-time and inform the user if they are willing to donate.
* Dashboard feature: The requester can easily contact the donors from their post itself.
* Profile Customization: Users can customize their profile to update their information.
* Search and Filter: Users can search and look for all users by blood group and location.



## 🗡️ System Architecture

### Real-Time Infrastructure
*Between guest and user states.

### Human-Centric UI
* Tactical Request Interface: A streamlined submission flow utilizing SliverAppBar for high-speed data entry during emergency scenarios.
* Visual Blood-Type Matrix: An interactive, grid-based selection system with AnimatedContainer feedback for error-free group identification.

### Backend Intelligence
* NoSQL Schema Optimization: A distributed data structure (Users <-> Emergency Posts) designed for rapid indexing and minimal read/write overhead.
* Secure Credentialing: Industry-standard Firebase Authentication to protect user privacy and sensitive medical metadata.



## 🛠️ Technical Specifications

* Framework: Flutter 3.29.0 (Stable)
* Engine: Dart 3.x
* Cloud Infrastructure: Firebase (Firestore, Auth)
* Architecture Pattern: State-Driven UI / MVC-Hybrid
* Primary OS Target: Android 11+ (API 30+)



## 📂 System Topology

```text
BloodSync/
├── lib/
│   ├── auth/                  # Security Gateways & Stream Logic
│   ├── components/            # Atomic UI Units (Buttons, Inputs, Cards)
│   ├── pages/                 # High-Level Feature Modules (Feed, Request, Profile)
│   ├── services/              # Firebase API Integrations
│   └── main.dart              # System Entry Point & Theme Engine
├── firebase_options.dart      # Cloud Configuration Mapping
├── pubspec.yaml               # Dependency Manifest
└── build_configurations/      # Split-ABI Export Presets
```



## 👥 The Engineering Team

Meet the minds behind the Network:

* **Md. Nura Nafiz Rahman:** System Architect, Lead Backend Developer, and Firebase Integration Specialist.
* **Liven Rahman:** Lead UI/UX Architect, Frontend Systems Developer, and State Management Specialist.



## 📜 Legal Status

This repository is currently under Proprietary Academic Use. No public license is defined. All rights reserved.






<p align="center">
  <b>Developed to bridge the gap between emergency needs and life-saving action.</b>
</p>