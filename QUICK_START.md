# ⚡ Quick Start - Firebase Setup

Setup Firebase dalam 5 menit! Follow langkah ini secara berurutan.

## 🎯 Langkah Cepat

### 1. Install Firebase CLI
```bash
npm install -g firebase-tools
dart pub global activate flutterfire_cli
```

### 2. Login & Setup
```bash
firebase login
```

### 3. Create Firebase Project
- Buka https://console.firebase.google.com/
- Create new project
- Enable Firestore Database (test mode)

### 4. Configure App
```bash
# Di root project folder
flutterfire configure
```
Pilih project yang baru dibuat dan platform yang diinginkan.

### 5. Install Dependencies
```bash
flutter pub get
```

### 6. Run!
```bash
flutter run
```

## ✅ Test Real-time Sync

1. Buka app di 2 device berbeda (atau emulator + physical device)
2. Tambah buku di device 1
3. Lihat muncul otomatis di device 2! 🎉

---

## 🔥 Firestore Rules (Development)

Di Firebase Console > Firestore > Rules:
```javascript
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    match /{document=**} {
      allow read, write: if true;
    }
  }
}
```

---

## 🆘 Troubleshooting

**Error saat build?**
```bash
flutter clean
flutter pub get
```

**Data tidak sync?**
- Pastikan internet connected
- Cek Firestore rules (harus allow read/write)

**Butuh detail lebih?**
Lihat file `FIREBASE_SETUP.md` untuk panduan lengkap.

---

**Selesai! App sekarang collaborative! 🚀**
