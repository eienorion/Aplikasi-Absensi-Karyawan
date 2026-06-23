<!DOCTYPE html>
<html lang="id">
<head>
    <meta charset="UTF-8">
    <title>Rekap Absensi</title>
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
            --input-bg: rgba(255, 255, 255, 0.05);
            --input-border: rgba(255, 255, 255, 0.10);
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

            --red: #FF6B6B;
            --red-bg: rgba(255, 107, 107, 0.10);
            --red-border: rgba(255, 107, 107, 0.20);
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

        .back-link {
            color: var(--text-muted);
            text-decoration: none;
            font-size: 13px;
            padding: 10px 14px;
            border-radius: 12px;
            background: var(--surface-dark);
            border: 1px solid var(--card-border);
        }

        .back-link:hover {
            color: #FFFFFF;
            border-color: rgba(255, 255, 255, 0.16);
        }

        .container {
            max-width: 1180px;
            margin: 0 auto;
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

        .hero {
            margin-bottom: 28px;
        }

        .eyebrow {
            font-size: 11px;
            letter-spacing: 1.5px;
            font-weight: 700;
            color: var(--accent);
            margin-bottom: 8px;
        }

        h1 {
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

        .section-label {
            margin: 28px 0 12px;
            font-size: 11px;
            letter-spacing: 1.2px;
            font-weight: 700;
            color: var(--text-muted);
        }

        .filter-card {
            background: var(--surface-dark);
            border: 1px solid var(--card-border);
            border-radius: 16px;
            padding: 18px;
            margin-bottom: 18px;
        }

        .filter-form {
            display: flex;
            flex-wrap: wrap;
            gap: 12px;
            align-items: end;
        }

        .field {
            display: flex;
            flex-direction: column;
            gap: 7px;
        }

        label {
            font-size: 11px;
            letter-spacing: 0.8px;
            font-weight: 700;
            color: var(--text-muted);
        }

        select,
        input {
            height: 46px;
            min-width: 160px;
            padding: 0 14px;
            border-radius: 12px;
            border: 1px solid var(--input-border);
            background: var(--input-bg);
            color: var(--text-primary);
            outline: none;
            font-size: 14px;
        }

        select:focus,
        input:focus {
            border-color: var(--accent);
        }

        select option {
            background: #0D1328;
            color: #FFFFFF;
        }

        .btn {
            height: 46px;
            padding: 0 16px;
            border: none;
            border-radius: 12px;
            cursor: pointer;
            font-size: 14px;
            font-weight: 700;
            text-decoration: none;
            display: inline-flex;
            align-items: center;
            justify-content: center;
            gap: 7px;
            white-space: nowrap;
        }

        .btn-primary {
            background: var(--accent);
            color: #FFFFFF;
        }

        .btn-primary:hover {
            background: var(--accent-light);
        }

        .btn-success {
            background: var(--green);
            color: #06130F;
        }

        .btn-success:hover {
            opacity: 0.9;
        }

        .btn-secondary {
            background: rgba(255, 255, 255, 0.05);
            color: var(--text-muted);
            border: 1px solid var(--card-border);
        }

        .table-card {
            background: var(--surface-dark);
            border: 1px solid var(--card-border);
            border-radius: 16px;
            overflow: hidden;
        }

        .table-header {
            padding: 16px 18px;
            display: flex;
            align-items: center;
            justify-content: space-between;
            gap: 12px;
            border-bottom: 1px solid var(--card-border);
        }

        .table-title {
            font-size: 15px;
            font-weight: 700;
            letter-spacing: -0.2px;
        }

        .table-subtitle {
            margin-top: 3px;
            font-size: 12px;
            color: var(--text-muted);
        }

        .table-count {
            padding: 7px 12px;
            border-radius: 999px;
            color: var(--blue);
            background: var(--blue-bg);
            border: 1px solid var(--blue-border);
            font-size: 12px;
            font-weight: 700;
            white-space: nowrap;
        }

        .table-wrapper {
            width: 100%;
            overflow-x: auto;
        }

        table {
            width: 100%;
            min-width: 1120px;
            border-collapse: collapse;
        }

        th {
            padding: 14px 14px;
            text-align: left;
            font-size: 11px;
            letter-spacing: 0.8px;
            text-transform: uppercase;
            color: var(--text-muted);
            background: rgba(255, 255, 255, 0.03);
            border-bottom: 1px solid var(--card-border);
            white-space: nowrap;
        }

        td {
            padding: 14px;
            font-size: 13px;
            border-bottom: 1px solid rgba(255, 255, 255, 0.06);
            color: rgba(255, 255, 255, 0.82);
            vertical-align: middle;
        }

        tr:hover td {
            background: rgba(255, 255, 255, 0.025);
        }

        .name {
            font-weight: 700;
            color: var(--text-primary);
            margin-bottom: 3px;
        }

        .email {
            color: var(--text-muted);
            font-size: 12px;
        }

        .badge {
            display: inline-flex;
            align-items: center;
            gap: 6px;
            padding: 6px 10px;
            border-radius: 999px;
            font-size: 12px;
            font-weight: 700;
            white-space: nowrap;
        }

        .badge-green {
            color: var(--green);
            background: var(--green-bg);
            border: 1px solid var(--green-border);
        }

        .badge-amber {
            color: var(--amber);
            background: var(--amber-bg);
            border: 1px solid var(--amber-border);
        }

        .badge-blue {
            color: var(--blue);
            background: var(--blue-bg);
            border: 1px solid var(--blue-border);
        }

        .badge-red {
            color: var(--red);
            background: var(--red-bg);
            border: 1px solid var(--red-border);
        }

        .lateness-note {
    margin-top: 5px;
    color: var(--text-muted);
    font-size: 11px;
    line-height: 1.4;
}

        .location {
            color: var(--text-muted);
            font-size: 12px;
            line-height: 1.5;
            max-width: 190px;
        }

        .photo-link {
            display: inline-flex;
            align-items: center;
            gap: 6px;
            padding: 7px 10px;
            border-radius: 10px;
            color: var(--blue);
            background: var(--blue-bg);
            border: 1px solid var(--blue-border);
            text-decoration: none;
            font-size: 12px;
            font-weight: 700;
            white-space: nowrap;
        }

        .photo-link:hover {
            background: rgba(91, 143, 239, 0.16);
        }

        .empty-row {
            text-align: center;
            padding: 42px 16px;
            color: var(--text-muted);
        }

        .pagination {
            margin-top: 18px;
            display: flex;
            align-items: center;
            justify-content: center;
            gap: 10px;
            flex-wrap: wrap;
        }

        .page-btn {
            padding: 10px 14px;
            border-radius: 12px;
            text-decoration: none;
            font-size: 13px;
            font-weight: 700;
            background: var(--surface-dark);
            color: var(--text-muted);
            border: 1px solid var(--card-border);
        }

        .page-btn:hover {
            color: #FFFFFF;
            border-color: rgba(255, 255, 255, 0.16);
        }

        .page-btn.disabled {
            opacity: 0.45;
            pointer-events: none;
        }

        .page-info {
            color: var(--text-muted);
            font-size: 13px;
        }

        .footer {
            margin-top: 34px;
            text-align: center;
            color: var(--text-soft);
            font-size: 12px;
        }

        @media (max-width: 760px) {
            .page {
                padding: 20px;
            }

            h1 {
                font-size: 28px;
            }

            .filter-form {
                flex-direction: column;
                align-items: stretch;
            }

            select,
            input,
            .btn {
                width: 100%;
            }

            .table-header {
                flex-direction: column;
                align-items: flex-start;
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

            <a href="{{ route('admin.dashboard') }}" class="back-link">
                Dashboard
            </a>
        </div>

        <div class="container">
            <div class="admin-chip">
                <span>📋</span>
                <span>Rekap Absensi</span>
            </div>

            <section class="hero">
                <div class="eyebrow">DATA KEHADIRAN</div>
                <h1>Rekap absensi<br>karyawan</h1>
                <p>
                    Lihat data absensi masuk dan pulang karyawan berdasarkan bulan dan tahun,
                    termasuk lokasi, status, dan foto absensi.
                </p>
            </section>

            <div class="section-label">FILTER DATA</div>

            <section class="filter-card">
                <form class="filter-form" method="GET" action="{{ route('admin.attendances') }}">
                    @php
                        $months = [
                            1 => 'Januari',
                            2 => 'Februari',
                            3 => 'Maret',
                            4 => 'April',
                            5 => 'Mei',
                            6 => 'Juni',
                            7 => 'Juli',
                            8 => 'Agustus',
                            9 => 'September',
                            10 => 'Oktober',
                            11 => 'November',
                            12 => 'Desember',
                        ];
                    @endphp

                    <div class="field">
                        <label>BULAN</label>
                        <select name="month">
                            <option value="">Semua Bulan</option>
                            @foreach ($months as $number => $monthName)
                                <option value="{{ $number }}" {{ request('month') == $number ? 'selected' : '' }}>
                                    {{ $monthName }}
                                </option>
                            @endforeach
                        </select>
                    </div>

                    <div class="field">
                        <label>TAHUN</label>
                        <input
                            type="number"
                            name="year"
                            placeholder="Contoh: 2026"
                            value="{{ request('year') }}"
                        >
                    </div>

                    <button type="submit" class="btn btn-primary">
                        🔎 Filter
                    </button>

                    <a class="btn btn-success"
                       href="{{ route('admin.attendances.export', request()->only('month', 'year')) }}">
                        📥 Export Excel
                    </a>

                    <a class="btn btn-secondary" href="{{ route('admin.attendances') }}">
                        Reset
                    </a>
                </form>
            </section>

            <div class="section-label">TABEL ABSENSI</div>

            <section class="table-card">
                <div class="table-header">
                    <div>
                        <div class="table-title">Data Rekap Absensi</div>
                        <div class="table-subtitle">
                            Menampilkan data absensi terbaru berdasarkan filter aktif.
                        </div>
                    </div>

                    <div class="table-count">
                        {{ $attendances->total() }} data
                    </div>
                </div>

                <div class="table-wrapper">
                    <table>
                        <thead>
                            <tr>
                                <th>No</th>
                                <th>Karyawan</th>
                                <th>Jenis</th>
                                <th>Tanggal</th>
                                <th>Jam</th>
                                <th>Ketepatan</th>
                                <th>Lokasi</th>
                                <th>Status</th>
                                <th>Foto</th>
                            </tr>
                        </thead>
                        <tbody>
                            @forelse ($attendances as $attendance)
                                @php
                                    $type = strtolower($attendance->attendance_type);
                                    $status = strtolower($attendance->status);
                                @endphp

                                <tr>
                                    <td>
                                        {{ $attendances->firstItem() + $loop->index }}
                                    </td>

                                    <td>
                                        <div class="name">
                                            {{ $attendance->user->name ?? '-' }}
                                        </div>
                                        <div class="email">
                                            {{ $attendance->user->email ?? '-' }}
                                        </div>
                                    </td>

                                    <td>
                                        @if ($type === 'masuk')
                                            <span class="badge badge-green">
                                                ● Masuk
                                            </span>
                                        @elseif ($type === 'pulang')
                                            <span class="badge badge-amber">
                                                ● Pulang
                                            </span>
                                        @else
                                            <span class="badge badge-blue">
                                                ● {{ $attendance->attendance_type }}
                                            </span>
                                        @endif
                                    </td>

                                    <td>
                                        {{ $attendance->attendance_date }}
                                    </td>

                                    <td>
    {{ substr($attendance->attendance_time, 0, 5) }}
</td>

<td>
    @php
        $punctuality = $attendance->punctuality_status;
        $punctualityMinutes = $attendance->punctuality_minutes;
    @endphp

    @if ($punctuality === 'Tepat Waktu')
        <span class="badge badge-green">
            ✓ Tepat Waktu
        </span>
    @elseif ($punctuality === 'Terlambat')
        <span class="badge badge-amber">
            ! Terlambat
        </span>

        @if ($punctualityMinutes > 0)
            <div class="lateness-note">
                {{ $punctualityMinutes }} menit
            </div>
        @endif
    @elseif ($punctuality === 'Operasional Nonaktif')
        <span class="badge badge-blue">
            Operasional Nonaktif
        </span>
    @else
        <span class="badge badge-blue">
            Tidak Dihitung
        </span>
    @endif
</td>

<td>
    <div class="location">
        Lat: {{ $attendance->latitude }}<br>
        Lng: {{ $attendance->longitude }}
    </div>
</td>

                                    <td>
                                        @if ($status === 'valid')
                                            <span class="badge badge-green">
                                                ✓ Valid
                                            </span>
                                        @elseif ($status === 'invalid')
                                            <span class="badge badge-red">
                                                ! Invalid
                                            </span>
                                        @else
                                            <span class="badge badge-blue">
                                                {{ $attendance->status }}
                                            </span>
                                        @endif
                                    </td>

                                    <td>
                                        @if ($attendance->photo_url)
                                            <a class="photo-link"
                                               href="{{ $attendance->photo_url }}"
                                               target="_blank">
                                                🖼 Lihat Foto
                                            </a>
                                        @else
                                            <span style="color: var(--text-muted);">-</span>
                                        @endif
                                    </td>
                                </tr>
                            @empty
                                <tr>
                                    <td colspan="9" class="empty-row">
                                        Belum ada data absensi.
                                    </td>
                                </tr>
                            @endforelse
                        </tbody>
                    </table>
                </div>
            </section>

            @php
                $paginator = $attendances->appends(request()->query());
            @endphp

            @if ($paginator->hasPages())
                <div class="pagination">
                    @if ($paginator->onFirstPage())
                        <span class="page-btn disabled">Sebelumnya</span>
                    @else
                        <a class="page-btn" href="{{ $paginator->previousPageUrl() }}">
                            Sebelumnya
                        </a>
                    @endif

                    <span class="page-info">
                        Halaman {{ $paginator->currentPage() }} dari {{ $paginator->lastPage() }}
                    </span>

                    @if ($paginator->hasMorePages())
                        <a class="page-btn" href="{{ $paginator->nextPageUrl() }}">
                            Selanjutnya
                        </a>
                    @else
                        <span class="page-btn disabled">Selanjutnya</span>
                    @endif
                </div>
            @endif

            <div class="footer">
                Apotek Bunut • Sistem Absensi v1.0
            </div>
        </div>
    </main>
</body>
</html>