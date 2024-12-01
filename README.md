# 🍈 **DurioDex - Durian Classification App** 🍈

DurioDex is a fun and interactive app that allows users to collect different varieties of durians by capturing pictures of them. This classification app uses machine learning to predict the type of durian based on the image. The app is powered by Firebase for user authentication, data storage, and file management, and integrates ngrok to host the machine learning model.

---

## 🚀 **Project Setup**

Follow these steps to set up **DurioDex** in your Flutter project.

### 🔑 **Prerequisites**

Before you begin, make sure you have the following installed:

- Flutter SDK
- Firebase Project setup on the [Firebase Console](https://console.firebase.google.com/)
- ngrok for hosting the machine learning prediction model
- Google Firebase dependencies for Flutter

---

### 📱 **Setting Up Firebase for Your Flutter Project**

1. **Create a Firebase Project**:
   - Go to the [Firebase Console](https://console.firebase.google.com/).
   - Create a new Firebase project for **DurioDex** if you don’t have one already.

2. **Add Firebase to Your Flutter Project**:

   - **For Android**:
     1. In the Firebase console, navigate to your project settings and select **Add App** for Android.
     2. Download the `google-services.json` file and place it in your Flutter project under `android/app/`.
     3. Add the necessary Firebase dependencies to your `android/build.gradle` and `android/app/build.gradle` files as per Firebase documentation.

   - **For iOS**:
     1. In the Firebase console, navigate to your project settings and select **Add App** for iOS.
     2. Download the `GoogleService-Info.plist` file and place it in your Flutter project under `ios/Runner/`.
     3. Update the `ios/Runner/Info.plist` file to configure Firebase as specified in the Firebase setup documentation.

