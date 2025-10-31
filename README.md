# 📚 Reading List App - Collaborative Edition

Aplikasi reading list yang modern, responsif, dan **collaborative** dengan Firebase backend! Cocok untuk tim yang ingin track buku-buku secara bersama-sama dengan real-time sync.

## ✨ Features

- ✅ **Collaborative Real-time** - Semua anggota tim lihat data yang sama secara real-time
- 📱 **Responsive Design** - Support mobile, tablet, dan desktop
- 🎨 **Modern UI** - Dark theme dengan library-style interface
- 🖼️ **Book Covers** - Support gambar cover buku dari URL
- 🏷️ **Tags System** - Organize buku dengan kategori/tags
- 🔍 **Search & Filter** - Cari dan filter buku dengan mudah
- 📊 **Statistics** - Track progress reading
- 💾 **Offline Support** - Tetap bisa baca data offline (backup local)
- 🔄 **Auto Sync** - Perubahan langsung sync ke semua device

## 🚀 Quick Start

### Prerequisites
- Flutter SDK (3.0+)
- Firebase account
- Node.js (untuk Firebase CLI)

### Setup Firebase Backend

**Langkah cepat (5 menit):**

1. Install tools:
```bash
npm install -g firebase-tools
dart pub global activate flutterfire_cli
```

2. Login & configure:
```bash
firebase login
flutterfire configure
```

3. Install dependencies:
```bash
flutter pub get
```

4. Run:
```bash
flutter run
```

📖 **Panduan lengkap**: Lihat [FIREBASE_SETUP.md](FIREBASE_SETUP.md) atau [QUICK_START.md](QUICK_START.md)

## 🏗️ Tech Stack

- **Framework**: Flutter
- **State Management**: GetX
- **Backend**: Firebase Firestore
- **Local Storage**: GetStorage (backup)
- **UI**: Material Design 3 (Dark Theme)

## 📱 Screenshots

> Modern library-style interface with dark theme
> Support mobile, tablet, dan desktop layouts
> Real-time collaborative features

## 🎯 Cara Kerja Collaborative

1. **Setup sekali** di Firebase Console
2. **Share project** ke semua anggota tim
3. **Install app** di masing-masing device
4. **Semua perubahan** otomatis sync real-time!

### Example Flow:
- User A tambah buku → Langsung muncul di device User B, C, D, ...
- User B edit buku → Update otomatis di semua device
- User C delete buku → Hilang dari semua device

## 📁 Project Structure

```
lib/
├── controllers/
│   └── reading_controller.dart    # State management + Firebase sync
├── models/
│   └── reading_item.dart          # Data model
├── services/
│   └── firebase_service.dart      # Firebase Firestore operations
├── views/
│   ├── home_view.dart            # Main dashboard
│   ├── all_books_view.dart       # Grid view semua buku
│   ├── add_view.dart             # Form tambah buku
│   ├── edit_view.dart            # Form edit buku
│   └── tags_view.dart            # Manage tags/categories
└── main.dart                      # Entry point + Firebase init
```

## 🔐 Security

**Development Mode** (default):
- Semua user bisa read/write
- Tidak perlu login

**Production Mode** (recommended):
- Update Firestore Security Rules
- Implement Firebase Authentication
- User-specific permissions

Lihat [FIREBASE_SETUP.md](FIREBASE_SETUP.md) untuk setup security rules.

## 🐛 Troubleshooting

**Build error?**
```bash
flutter clean
flutter pub get
```

**Data tidak sync?**
- Cek koneksi internet
- Verify Firestore rules di Firebase Console
- Lihat console log untuk error messages

**Butuh bantuan?**
Lihat dokumentasi lengkap di [FIREBASE_SETUP.md](FIREBASE_SETUP.md)

## 🤝 Contributing

Ini project tim! Silakan:
- Report bugs
- Suggest features
- Submit pull requests

## 📝 License

Private project untuk tim internal.

## 👥 Team

Dibuat untuk collaborative reading tracking antar anggota tim.

---

**Happy Reading! 📖✨**
