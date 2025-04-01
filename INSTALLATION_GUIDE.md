# Panduan Installasi Aplikasi QCFP Report

## Persyaratan Sistem
- Flutter SDK versi 3.22.0 atau lebih baru
- Dart SDK versi 3.4.0 atau lebih baru
- Android Studio atau Visual Studio Code dengan plugin Flutter/Dart
- Android SDK untuk build Android
- XCode untuk build iOS (hanya di MacOS)

## Cara Installasi (Pengembang)

### 1. Ekstrak file qcfp_report_app_full.zip
Ekstrak file zip yang telah diunduh ke lokasi yang diinginkan di komputer Anda.

### 2. Buka Terminal atau Command Prompt
Buka terminal atau command prompt dan navigasikan ke folder yang telah diekstrak:

```bash
cd path/to/extracted/qcfp_report_app
```

### 3. Jalankan Flutter Pub Get
Jalankan perintah berikut untuk mengunduh dan menginstal semua dependencies:

```bash
flutter pub get
```

### 4. Jalankan aplikasi di emulator atau perangkat
Hubungkan perangkat Android/iOS atau jalankan emulator, kemudian jalankan aplikasi:

```bash
flutter run
```

### 5. Build aplikasi untuk distribusi

#### Untuk Android (APK)
```bash
flutter build apk --release
```
File APK akan tersedia di: `build/app/outputs/flutter-apk/app-release.apk`

#### Untuk Android (App Bundle)
```bash
flutter build appbundle --release
```
File AAB akan tersedia di: `build/app/outputs/bundle/release/app-release.aab`

#### Untuk iOS (Hanya di MacOS)
```bash
flutter build ios --release
```
Kemudian buka folder ios/ di XCode dan lakukan proses distribusi melalui XCode.

## Cara Installasi (Pengguna)

### Android
1. Download file APK dari link yang disediakan
2. Buka file APK di perangkat Android
3. Jika diminta, izinkan installasi dari "sumber tidak dikenal" di pengaturan keamanan
4. Ikuti instruksi di layar untuk menyelesaikan installasi

### iOS
Aplikasi iOS harus didistribusikan melalui App Store atau TestFlight. Hubungi pengembang untuk mendapatkan akses ke aplikasi versi iOS.

## Informasi Login
### Admin
- NIK: *****
- PIN: ******

### Foreman/Inspector
- Masuk melalui halaman pemilihan peran tanpa perlu login

## Fitur Utama
- Manajemen personil (grup, foreman, inspectors)
- Pembuatan laporan QCFP dengan format standar
- Penyimpanan laporan secara lokal (offline)
- Berbagi laporan via WhatsApp
- Menyimpan laporan sebagai gambar di galeri