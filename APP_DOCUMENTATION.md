# Dokumentasi Aplikasi QCFP Report

## Gambaran Umum
Aplikasi QCFP (Quality Control Field Procedure) Report adalah aplikasi mobile berbasis Flutter yang dirancang untuk membantu tim quality control dalam pencatatan laporan harian. Aplikasi ini berjalan secara offline dan mendukung berbagai fitur seperti manajemen personil, pencatatan material, dan pembagian laporan.

## Struktur Aplikasi

### 1. Arsitektur
Aplikasi menggunakan arsitektur Clean Architecture dengan pembagian:
- **Presentation Layer**: UI dan BLoC untuk manajemen state
- **Domain Layer**: Entitas bisnis dan use cases
- **Data Layer**: Model data, repositories dan data sources

### 2. Manajemen State
Menggunakan BLoC Pattern (Business Logic Component) dengan flutter_bloc package.

### 3. Penyimpanan Data
Menggunakan Hive untuk penyimpanan data lokal yang memungkinkan aplikasi berfungsi secara offline.

## Peran Pengguna

### Admin
- Mengelola semua data personil
- Mengedit grup, memindahkan personil antar grup
- Menambahkan personil baru
- Melihat semua laporan

### Foreman
- Membuat dan mengedit laporan
- Melihat laporan yang dibuat
- Berbagi laporan via WhatsApp
- Menyimpan laporan sebagai gambar

### Inspector
- Memiliki akses yang sama dengan Foreman
- Dapat membuat dan melihat laporan

## Komponen Utama Laporan

### 1. Header
- Tanggal
- Shift (1, 2, atau 3)

### 2. Personil
- Foreman (dengan status: hadir, sakit, izin, cuti)
- Inspektor 1-3 (dengan status: hadir, sakit, izin, cuti)
- Personil Lembur (opsional)

### 3. Safety & Peralatan
- Status Safety Talk
- Status Alat Ukur, Senter, HP, Kamera

### 4. Data Material
- **Total UD (Usage Decision)**: HCF, HSF, HLF, dll (bundle dan tonase)
- **Total Shipment HR**: HCF, HSF, HLF, dll (bundle dan tonase)
- **Total Inspeksi Pre-Delivery**: Berbagai tipe coil, plate, dan slitting

### 5. Reinspeksi
- Status reinspeksi dan jumlah dalam bundle
- Detail sudah dan belum reinspeksi
- Kendala, tindak lanjut, dan remark

## Fitur Teknis

### 1. Berbagi Laporan
- Menggunakan `share_plus` package untuk berbagi ke WhatsApp
- Format berbagi sebagai gambar (JPG)

### 2. Penyimpanan Gambar
- Menyimpan laporan sebagai gambar ke galeri perangkat
- Menggunakan `image_gallery_saver` package

### 3. Sistem Grup
- 4 grup dengan foreman dan inspektor tetap
- Pemilihan foreman akan mengisi otomatis inspektor yang terkait
- Status kehadiran dapat diperbarui

### 4. Validasi Data
- Validasi input untuk memastikan semua data yang diperlukan terisi
- Validasi tipe data untuk input numerik

## Panduan Pengembangan Lanjutan

### 1. Menambahkan Material Baru
Untuk menambahkan jenis material baru:
1. Tambahkan properti di `ReportModel` dan `Report` entity
2. Perbarui UI di `ReportFormScreen`
3. Perbarui logika di `ReportBloc`

### 2. Mengubah Grup Personil
Untuk mengubah struktur grup personil:
1. Modifikasi data default di `LocalDataSource`
2. Perbarui UI di `PersonnelManagementScreen`
3. Pastikan pemilihan foreman tetap bekerja dengan benar

### 3. Fitur Sinkronisasi (Future Enhancement)
Untuk menambahkan sinkronisasi ke cloud:
1. Tambahkan `RemoteDataSource`
2. Implementasikan logika sinkronisasi di repository
3. Tambahkan state management untuk status sinkronisasi