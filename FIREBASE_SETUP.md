# 🔥 Setup Firebase untuk Reading List App (Collaborative)

Panduan lengkap untuk mengaktifkan fitur collaborative menggunakan Firebase Firestore.

## 📋 Prerequisites

- Flutter SDK terpasang
- Akun Google untuk Firebase Console
- Node.js (untuk Firebase CLI)

---

## 🚀 Langkah Setup

### 1️⃣ Install Firebase CLI

```bash
npm install -g firebase-tools
```

### 2️⃣ Login ke Firebase

```bash
firebase login
```

### 3️⃣ Buat Project di Firebase Console

1. Buka [Firebase Console](https://console.firebase.google.com/)
2. Klik **"Add project"** atau **"Tambahkan project"**
3. Beri nama project: `reading-list-app` (atau nama lain)
4. Enable/disable Google Analytics (optional)
5. Klik **Create project**

### 4️⃣ Aktifkan Firestore Database

1. Di Firebase Console, pilih project Anda
2. Buka **Firestore Database** dari menu kiri
3. Klik **Create database**
4. Pilih **Start in test mode** (untuk development)
5. Pilih location/region terdekat
6. Klik **Enable**

### 5️⃣ Install FlutterFire CLI

```bash
dart pub global activate flutterfire_cli
```

Pastikan path sudah di environment:
```bash
export PATH="$PATH":"$HOME/.pub-cache/bin"
```

### 6️⃣ Configure Firebase untuk Flutter

Jalankan di root project:

```bash
flutterfire configure
```

Pilih:
- Project yang sudah dibuat
- Platform: iOS, Android, macOS, Web (sesuai kebutuhan)
- Ini akan generate file `firebase_options.dart` otomatis

### 7️⃣ Install Dependencies

```bash
flutter pub get
```

### 8️⃣ Setup Firestore Security Rules (Opsional)

Di Firebase Console > Firestore Database > Rules:

```javascript
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    // Allow semua user read/write (untuk development)
    match /{document=**} {
      allow read, write: if true;
    }
  }
}
```

⚠️ **PENTING**: Untuk production, ganti dengan rules yang lebih secure!

```javascript
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    // Books collection
    match /books/{bookId} {
      allow read: if true;  // Semua bisa lihat
      allow write: if request.auth != null;  // Harus login
    }
    
    // Tags collection
    match /tags/{tagId} {
      allow read: if true;
      allow write: if request.auth != null;
    }
  }
}
```

### 9️⃣ Run Aplikasi

```bash
flutter run
```

---

## 📱 Platform-Specific Setup

### **Android**

File `android/app/google-services.json` sudah di-generate otomatis oleh FlutterFire.

Pastikan di `android/app/build.gradle`:
```gradle
minSdkVersion 21  // minimal SDK 21
```

### **iOS**

File `ios/Runner/GoogleService-Info.plist` sudah di-generate otomatis.

Pastikan iOS Deployment Target minimal **11.0**:
```bash
cd ios
open Runner.xcworkspace
# Set Deployment Target to 11.0+ di Xcode
```

### **macOS**

Aktifkan network entitlements di `macos/Runner/DebugProfile.entitlements`:
```xml
<key>com.apple.security.network.client</key>
<true/>
```

### **Web**

Sudah ter-configure otomatis di `web/index.html`.

---

## ✅ Verifikasi Setup

1. **Jalankan aplikasi**
2. **Tambahkan buku baru**
3. **Cek Firebase Console** > Firestore Database
4. **Lihat collection `books`** - seharusnya ada data baru
5. **Buka aplikasi di device lain** - data seharusnya sync otomatis!

---

## 🎯 Cara Kerja Collaborative

### Real-time Sync
- Setiap perubahan (add, edit, delete) langsung sync ke Firebase
- Semua device yang terhubung langsung dapat update real-time
- Stream listener otomatis update UI

### Offline Support
- Data juga di-backup ke local storage (GetStorage)
- Bisa tetap baca data offline
- Perubahan akan di-sync begitu online kembali

### Multi-User
- Semua anggota tim yang pakai app akan lihat data yang sama
- Tidak perlu login/authentication (untuk development)
- Untuk production, sebaiknya tambahkan Firebase Auth

---

## 🔐 (Opsional) Tambah Authentication

Jika ingin user harus login dulu:

### 1. Enable Authentication di Firebase Console
- Buka **Authentication**
- Pilih method (Email/Password, Google, dll)

### 2. Update Security Rules
```javascript
allow read, write: if request.auth != null;
```

### 3. Tambahkan Login Screen
(Akan require additional code - contact dev jika perlu)

---

## 🐛 Troubleshooting

### Error: "No Firebase App"
```bash
flutter clean
flutter pub get
flutterfire configure
```

### Error: "Permission Denied"
- Cek Firestore Rules di Console
- Pastikan set ke test mode atau rules yang benar

### Data tidak sync
- Cek koneksi internet
- Lihat console log untuk error
- Pastikan Firebase sudah ter-initialize di `main.dart`

### Build error Android
```bash
cd android
./gradlew clean
cd ..
flutter clean
flutter pub get
```

---

## 📊 Struktur Data di Firestore

### Collection: `books`
```json
{
  "id": "1234567890",
  "title": "Judul Buku",
  "isRead": false,
  "createdAt": "2025-10-31T08:00:00.000Z",
  "tags": ["fiction", "bestseller"],
  "imageUrl": "https://example.com/cover.jpg"
}
```

### Collection: `tags`
```json
{
  "fiction": {
    "createdAt": "2025-10-31T08:00:00.000Z"
  },
  "bestseller": {
    "createdAt": "2025-10-31T08:00:00.000Z"
  }
}
```

---

## 💡 Tips

1. **Gunakan satu Firebase project** untuk semua anggota tim
2. **Share project credentials** dengan aman (jangan commit ke public repo)
3. **Backup data** secara berkala lewat Firebase Console
4. **Monitor usage** di Firebase Console untuk avoid quota limits
5. **Test di multiple devices** untuk verify real-time sync

---

## 🚨 Catatan Keamanan

File yang **JANGAN** di-commit ke Git public:
- `firebase_options.dart` (sudah ada di .gitignore)
- `google-services.json` (Android)
- `GoogleService-Info.plist` (iOS)

Jika project private, boleh di-commit. Tapi kalau public repo, **JANGAN!**

---

## 📞 Bantuan

Jika ada masalah:
1. Cek [Firebase Documentation](https://firebase.google.com/docs/flutter/setup)
2. Cek [FlutterFire Documentation](https://firebase.flutter.dev/)
3. Contact team developer

---

**Happy Coding! 🎉**
