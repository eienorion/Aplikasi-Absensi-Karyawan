<!DOCTYPE html>
<html lang="id">
<head>
    <meta charset="UTF-8">
    <title>Dashboard Admin</title>
    <style>
        body {
            font-family: Arial, sans-serif;
            background: #f3f4f6;
            margin: 0;
        }

        .navbar {
            background: #166534;
            color: white;
            padding: 16px 32px;
            display: flex;
            justify-content: space-between;
            align-items: center;
        }

        .container {
            padding: 32px;
        }

        .cards {
            display: flex;
            gap: 16px;
            margin-bottom: 24px;
        }

        .card {
            background: white;
            padding: 24px;
            border-radius: 14px;
            flex: 1;
            box-shadow: 0 8px 18px rgba(0,0,0,0.06);
        }

        .number {
            font-size: 32px;
            font-weight: bold;
            color: #166534;
        }

        a.button, button {
            display: inline-block;
            background: #16a34a;
            color: white;
            padding: 12px 16px;
            border-radius: 8px;
            text-decoration: none;
            border: none;
            cursor: pointer;
        }

        form {
            display: inline;
        }
    </style>
</head>
<body>
    <div class="navbar">
        <strong>Dashboard Admin Absensi</strong>

        <form method="POST" action="{{ route('admin.logout') }}">
            @csrf
            <button type="submit">Logout</button>
        </form>
    </div>

    <div class="container">
        <h2>Selamat Datang, {{ auth()->user()->name }}</h2>

        <div class="cards">
            <div class="card">
                <p>Total Karyawan</p>
                <div class="number">{{ $totalKaryawan }}</div>
            </div>

            <div class="card">
                <p>Total Absensi</p>
                <div class="number">{{ $totalAbsensi }}</div>
            </div>

            <div class="card">
                <p>Absensi Hari Ini</p>
                <div class="number">{{ $absensiHariIni }}</div>
            </div>
        </div>

        <a class="button" href="{{ route('admin.attendances') }}">
            Lihat Rekap Absensi
        </a>
    </div>
</body>
</html>