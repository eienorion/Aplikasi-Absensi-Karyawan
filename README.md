# Aplikasi Absensi Karyawan

Aplikasi Absensi Karyawan adalah sistem absensi berbasis **mobile** dan **web** yang digunakan untuk mencatat kehadiran karyawan secara digital. Aplikasi mobile digunakan oleh karyawan untuk melakukan absensi masuk dan pulang menggunakan foto selfie serta lokasi terkini, sedangkan web admin digunakan oleh admin untuk melihat rekap absensi, memantau data kehadiran, dan melakukan export data ke Excel.

## Teknologi yang Digunakan

### Mobile App

* Flutter
* Dart
* Image Picker
* Geolocator
* HTTP API
* Screenshot Watermark

### Backend & Web Admin

* Laravel
* PHP
* MySQL
* Laravel Excel
* Google Drive API

## Fitur Aplikasi

### Fitur Karyawan

* Register akun karyawan
* Login karyawan
* Absensi masuk
* Absensi pulang
* Pengambilan foto selfie
* Pengambilan lokasi latitude dan longitude
* Watermark pada foto absensi
* Penyimpanan data absensi ke database

### Fitur Admin

* Login admin melalui web
* Dashboard admin
* Melihat total karyawan
* Melihat total data absensi
* Melihat absensi hari ini
* Melihat rekap absensi karyawan
* Filter data absensi berdasarkan bulan dan tahun
* Melihat link foto absensi
* Export data absensi ke Excel

## Struktur Project

```bash
Aplikasi-Absensi-Karyawan/
├── absensi_mobile/        # Project Flutter untuk karyawan
└── absensi_backend/       # Project Laravel untuk backend API dan web admin
```

## Alur Sistem

```text
Karyawan → Flutter Mobile App → Laravel API → MySQL
                                      ↓
                                Google Drive

Admin → Laravel Web Admin → Rekap Absensi → Export Excel
```

## Instalasi Backend Laravel

Masuk ke folder backend:

```bash
cd absensi_backend
```

Install dependency Laravel:

```bash
composer install
```

Copy file environment:

```bash
copy .env.example .env
```

Generate application key:

```bash
php artisan key:generate
```

Atur konfigurasi database pada file `.env`:

```env
DB_CONNECTION=mysql
DB_HOST=127.0.0.1
DB_PORT=3306
DB_DATABASE=absensi_mobile
DB_USERNAME=root
DB_PASSWORD=
```

Jalankan migration:

```bash
php artisan migrate
```

Jalankan server Laravel:

```bash
php artisan serve
```

Backend dapat diakses melalui:

```text
http://127.0.0.1:8000
```

## Konfigurasi Google Drive API

Tambahkan konfigurasi berikut pada file `.env`:

```env
GOOGLE_CLIENT_ID=
GOOGLE_CLIENT_SECRET=
GOOGLE_REDIRECT_URI=http://127.0.0.1:8000/google/callback
GOOGLE_REFRESH_TOKEN=
GOOGLE_DRIVE_FOLDER_ID=
```

Catatan:

* Jangan mengunggah file `.env` ke GitHub.
* Jangan mengunggah file `credentials.json` ke GitHub.
* Simpan token dan credential hanya pada environment lokal atau server.

## Route Backend API

Beberapa endpoint API yang digunakan aplikasi mobile:

```text
POST /api/register
POST /api/login
POST /api/attendances
GET  /api/attendances
GET  /api/attendances/summary
GET  /api/attendances/export
```

## Akses Web Admin

Halaman login admin:

```text
http://127.0.0.1:8000/admin/login
```

Contoh akun admin untuk pengembangan:

```text
Email    : admin@gmail.com
Password : admin123
```

## Instalasi Flutter

Masuk ke folder mobile:

```bash
cd absensi_mobile
```

Install dependency Flutter:

```bash
flutter pub get
```

Jalankan aplikasi:

```bash
flutter run
```

## Konfigurasi Base URL Flutter

Pada file Flutter, sesuaikan `baseUrl` dengan lingkungan yang digunakan.

Untuk Android Emulator:

```dart
static const String baseUrl = 'http://10.0.2.2:8000/api';
```

Untuk Flutter Web atau browser lokal:

```dart
static const String baseUrl = 'http://127.0.0.1:8000/api';
```

Untuk HP asli yang terhubung satu jaringan dengan laptop:

```dart
static const String baseUrl = 'http://IP-LAPTOP:8000/api';
```

Contoh:

```dart
static const String baseUrl = 'http://192.168.1.10:8000/api';
```

Jika menggunakan HP asli, jalankan Laravel dengan perintah:

```bash
php artisan serve --host=0.0.0.0 --port=8000
```

## Export Excel

Export data absensi dapat dilakukan melalui web admin pada halaman rekap absensi. Admin dapat melakukan filter berdasarkan bulan dan tahun, kemudian menekan tombol export untuk mengunduh file Excel.

Format file export:

```text
rekap_absensi.xlsx
```

atau jika menggunakan filter:

```text
rekap_absensi_2026_06.xlsx
```

## Keamanan

File berikut tidak boleh diunggah ke GitHub:

```text
.env
credentials.json
GOOGLE_REFRESH_TOKEN
GOOGLE_CLIENT_SECRET
```

Gunakan `.env.example` sebagai contoh konfigurasi tanpa menyimpan data sensitif.

## Cara Menjalankan Project Setelah Clone

### Backend Laravel

```bash
cd absensi_backend
composer install
copy .env.example .env
php artisan key:generate
php artisan migrate
php artisan serve
```

### Mobile Flutter

```bash
cd absensi_mobile
flutter pub get
flutter run
```

## Status Pengembangan

Project ini masih dalam tahap pengembangan. Beberapa fitur yang dapat dikembangkan selanjutnya:

* Riwayat absensi karyawan
* Validasi radius lokasi kerja
* Manajemen data karyawan
* Dashboard admin yang lebih lengkap
* Export laporan berdasarkan rentang tanggal
* Deployment backend ke hosting atau VPS

## Lisensi

Project ini dibuat untuk kebutuhan pembelajaran dan pengembangan aplikasi absensi karyawan.
