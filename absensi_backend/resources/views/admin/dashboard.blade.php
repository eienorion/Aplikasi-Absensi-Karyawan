<!DOCTYPE html>
<html lang="id">
<head>
    <meta charset="UTF-8">
    <title>Dashboard Admin</title>
    <meta name="viewport" content="width=device-width, initial-scale=1.0">

    <style>
        * {
            box-sizing: border-box;
        }

        :root {
            --bg-dark: #0A0F1E;
            --surface-dark: #0D1328;
            --accent: #2D6BE4;
            --accent-light: #5B8FEF;
            --text-primary: #FFFFFF;
            --text-muted: rgba(255, 255, 255, 0.45);
            --text-soft: rgba(255, 255, 255, 0.25);
            --card-border: rgba(255, 255, 255, 0.08);

            --green: #3CC99A;
            --green-bg: rgba(60, 201, 154, 0.10);
            --green-border: rgba(60, 201, 154, 0.20);

            --amber: #F4B347;
            --amber-bg: rgba(244, 179, 71, 0.10);
            --amber-border: rgba(244, 179, 71, 0.20);

            --blue: #5B8FEF;
            --blue-bg: rgba(91, 143, 239, 0.10);
            --blue-border: rgba(91, 143, 239, 0.20);
        }

        body {
            margin: 0;
            min-height: 100vh;
            font-family: Arial, sans-serif;
            background: var(--bg-dark);
            color: var(--text-primary);
        }

        .page {
            width: 100%;
            min-height: 100vh;
            padding: 24px;
        }

        .topbar {
            display: flex;
            align-items: center;
            justify-content: space-between;
            margin-bottom: 36px;
        }

        .brand {
            display: inline-flex;
            align-items: center;
            gap: 8px;
            padding: 8px 12px;
            background: var(--surface-dark);
            border: 1px solid var(--card-border);
            border-radius: 999px;
        }

        .brand-icon {
            width: 24px;
            height: 24px;
            background: var(--accent);
            border-radius: 7px;
            display: flex;
            align-items: center;
            justify-content: center;
            font-size: 13px;
        }

        .brand-text {
            font-size: 13px;
            font-weight: 700;
            letter-spacing: -0.2px;
        }

        .logout-button {
            width: 38px;
            height: 38px;
            border-radius: 12px;
            border: 1px solid var(--card-border);
            background: var(--surface-dark);
            color: var(--text-muted);
            cursor: pointer;
            font-size: 15px;
        }

        .logout-button:hover {
            color: #FFFFFF;
            border-color: rgba(255, 255, 255, 0.16);
        }

        .container {
            max-width: 1080px;
            margin: 0 auto;
        }

        .eyebrow {
            font-size: 11px;
            letter-spacing: 1.5px;
            font-weight: 700;
            color: var(--accent);
            margin-bottom: 8px;
        }

        .hero {
            margin-bottom: 28px;
        }

        .hero h1 {
            margin: 0;
            font-size: 34px;
            line-height: 1.1;
            letter-spacing: -1px;
            font-weight: 700;
        }

        .hero p {
            margin: 10px 0 0;
            color: var(--text-muted);
            font-size: 14px;
            line-height: 1.6;
        }

        .admin-chip {
            display: inline-flex;
            align-items: center;
            gap: 7px;
            padding: 7px 12px;
            border-radius: 999px;
            background: var(--blue-bg);
            border: 1px solid var(--blue-border);
            color: var(--blue);
            font-size: 12px;
            font-weight: 700;
            margin-bottom: 20px;
        }

        .section-label {
            margin: 28px 0 12px;
            font-size: 11px;
            letter-spacing: 1.2px;
            font-weight: 700;
            color: var(--text-muted);
        }

        .stats-grid {
            display: grid;
            grid-template-columns: repeat(3, 1fr);
            gap: 14px;
        }

        .stat-card {
            padding: 18px;
            background: var(--surface-dark);
            border: 1px solid var(--card-border);
            border-radius: 16px;
        }

        .stat-top {
            display: flex;
            align-items: center;
            justify-content: space-between;
            margin-bottom: 18px;
        }

        .stat-icon {
            width: 42px;
            height: 42px;
            border-radius: 13px;
            display: flex;
            align-items: center;
            justify-content: center;
            font-size: 19px;
        }

        .stat-icon.green {
            background: var(--green-bg);
            border: 1px solid var(--green-border);
            color: var(--green);
        }

        .stat-icon.blue {
            background: var(--blue-bg);
            border: 1px solid var(--blue-border);
            color: var(--blue);
        }

        .stat-icon.amber {
            background: var(--amber-bg);
            border: 1px solid var(--amber-border);
            color: var(--amber);
        }

        .stat-label {
            margin: 0;
            color: var(--text-muted);
            font-size: 13px;
        }

        .stat-number {
            margin-top: 6px;
            font-size: 34px;
            line-height: 1;
            font-weight: 800;
            letter-spacing: -1px;
        }

        .stat-number.green {
            color: var(--green);
        }

        .stat-number.blue {
            color: var(--blue);
        }

        .stat-number.amber {
            color: var(--amber);
        }

        .menu-grid {
            display: grid;
            grid-template-columns: repeat(2, 1fr);
            gap: 14px;
        }

        .menu-card {
            width: 100%;
            padding: 18px;
            background: var(--surface-dark);
            border: 1px solid var(--card-border);
            border-radius: 16px;
            display: flex;
            align-items: center;
            gap: 14px;
            text-decoration: none;
            color: var(--text-primary);
            transition: 0.18s ease;
        }

        .menu-card:hover {
            transform: translateY(-2px);
            border-color: rgba(91, 143, 239, 0.35);
            background: #101832;
        }

        .menu-icon {
            width: 46px;
            height: 46px;
            flex: 0 0 46px;
            border-radius: 14px;
            display: flex;
            align-items: center;
            justify-content: center;
            font-size: 20px;
        }

        .menu-icon.green {
            background: var(--green-bg);
            border: 1px solid var(--green-border);
            color: var(--green);
        }

        .menu-icon.blue {
            background: var(--blue-bg);
            border: 1px solid var(--blue-border);
            color: var(--blue);
        }

        .menu-icon.amber {
            background: var(--amber-bg);
            border: 1px solid var(--amber-border);
            color: var(--amber);
        }

        .menu-content {
            flex: 1;
        }

        .menu-title {
            font-size: 15px;
            font-weight: 700;
            letter-spacing: -0.2px;
            margin-bottom: 4px;
        }

        .menu-subtitle {
            font-size: 13px;
            color: var(--text-muted);
            line-height: 1.4;
        }

        .menu-arrow {
            color: rgba(255, 255, 255, 0.20);
            font-size: 18px;
        }

        .footer {
            margin-top: 34px;
            text-align: center;
            color: var(--text-soft);
            font-size: 12px;
        }

        form {
            margin: 0;
        }

        @media (max-width: 760px) {
            .page {
                padding: 20px;
            }

            .stats-grid {
                grid-template-columns: 1fr;
            }

            .menu-grid {
                grid-template-columns: 1fr;
            }

            .hero h1 {
                font-size: 28px;
            }
        }
    </style>
</head>
<body>
    <main class="page">
        <div class="topbar">
            <div class="brand">
                <div class="brand-icon">💊</div>
                <div class="brand-text">Apotek Bunut</div>
            </div>

            <form method="POST" action="{{ route('admin.logout') }}">
                @csrf
                <button type="submit" class="logout-button" title="Logout">
                    ⎋
                </button>
            </form>
        </div>

        <div class="container">
            <div class="admin-chip">
                <span>⚙</span>
                <span>Dashboard Admin</span>
            </div>

            <section class="hero">
                <div class="eyebrow">SELAMAT DATANG</div>
                <h1>Halo,<br>{{ auth()->user()->name }}</h1>
                <p>
                    Kelola data absensi karyawan, rekap kehadiran, dan pengaturan
                    operasional Apotek Bunut dari halaman admin.
                </p>
            </section>

            <div class="section-label">RINGKASAN DATA</div>

            <section class="stats-grid">
                <div class="stat-card">
                    <div class="stat-top">
                        <div class="stat-icon green">👥</div>
                    </div>
                    <p class="stat-label">Total Karyawan</p>
                    <div class="stat-number green">{{ $totalKaryawan }}</div>
                </div>

                <div class="stat-card">
                    <div class="stat-top">
                        <div class="stat-icon blue">📋</div>
                    </div>
                    <p class="stat-label">Total Absensi</p>
                    <div class="stat-number blue">{{ $totalAbsensi }}</div>
                </div>

                <div class="stat-card">
                    <div class="stat-top">
                        <div class="stat-icon amber">🕒</div>
                    </div>
                    <p class="stat-label">Absensi Hari Ini</p>
                    <div class="stat-number amber">{{ $absensiHariIni }}</div>
                </div>
            </section>

            <div class="section-label">MENU ADMIN</div>

            <section class="menu-grid">
                <a class="menu-card" href="{{ route('admin.attendances') }}">
                    <div class="menu-icon blue">📄</div>
                    <div class="menu-content">
                        <div class="menu-title">Lihat Rekap Absensi</div>
                        <div class="menu-subtitle">
                            Lihat data absensi, filter bulan/tahun, dan export Excel.
                        </div>
                    </div>
                    <div class="menu-arrow">›</div>
                </a>

                <a class="menu-card" href="{{ route('admin.operational.edit') }}">
                    <div class="menu-icon green">⏰</div>
                    <div class="menu-content">
                        <div class="menu-title">Jam Operasional</div>
                        <div class="menu-subtitle">
                            Atur jam buka dan tutup yang tampil di aplikasi mobile.
                        </div>
                    </div>
                    <div class="menu-arrow">›</div>
                </a>
            </section>

            <div class="footer">
                Apotek Bunut • Sistem Absensi v1.0
            </div>
        </div>
    </main>
</body>
</html>