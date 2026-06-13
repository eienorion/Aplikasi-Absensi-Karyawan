<!DOCTYPE html>
<html lang="id">
<head>
    <meta charset="UTF-8">
    <title>Rekap Absensi</title>
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
        }

        .container {
            padding: 32px;
        }

        .filter {
            background: white;
            padding: 16px;
            border-radius: 12px;
            margin-bottom: 20px;
        }

        input, select {
            padding: 10px;
            margin-right: 8px;
            border: 1px solid #d1d5db;
            border-radius: 8px;
        }

        button, .button {
            background: #16a34a;
            color: white;
            padding: 10px 14px;
            border: none;
            border-radius: 8px;
            text-decoration: none;
            cursor: pointer;
        }

        .button-secondary {
            background: #2563eb;
        }

        table {
            width: 100%;
            background: white;
            border-collapse: collapse;
            border-radius: 12px;
            overflow: hidden;
        }

        th, td {
            padding: 12px;
            border-bottom: 1px solid #e5e7eb;
            text-align: left;
            font-size: 14px;
        }

        th {
            background: #dcfce7;
        }

        a {
            color: #166534;
        }

        .pagination {
            margin-top: 20px;
        }
    </style>
</head>
<body>
    <div class="navbar">
        <strong>Rekap Absensi</strong>
        <a href="{{ route('admin.dashboard') }}" style="color:white;">Dashboard</a>
    </div>

    <div class="container">
        <h2>Data Rekap Absensi</h2>

        <div class="filter">
            <form method="GET" action="{{ route('admin.attendances') }}">
                <select name="month">
                    <option value="">Semua Bulan</option>
                    @for ($i = 1; $i <= 12; $i++)
                        <option value="{{ $i }}" {{ request('month') == $i ? 'selected' : '' }}>
                            {{ $i }}
                        </option>
                    @endfor
                </select>

                <input 
                    type="number" 
                    name="year" 
                    placeholder="Tahun" 
                    value="{{ request('year') }}"
                >

                <button type="submit">Filter</button>

                <a 
                    class="button button-secondary" 
                    href="{{ route('admin.attendances.export', request()->only('month', 'year')) }}"
                >
                    Export Excel
                </a>
            </form>
        </div>

        <table>
            <thead>
                <tr>
                    <th>No</th>
                    <th>Nama</th>
                    <th>Email</th>
                    <th>Jenis</th>
                    <th>Tanggal</th>
                    <th>Jam</th>
                    <th>Lokasi</th>
                    <th>Status</th>
                    <th>Foto</th>
                </tr>
            </thead>
            <tbody>
                @forelse ($attendances as $attendance)
                    <tr>
                        <td>{{ $loop->iteration }}</td>
                        <td>{{ $attendance->user->name ?? '-' }}</td>
                        <td>{{ $attendance->user->email ?? '-' }}</td>
                        <td>{{ $attendance->attendance_type }}</td>
                        <td>{{ $attendance->attendance_date }}</td>
                        <td>{{ $attendance->attendance_time }}</td>
                        <td>{{ $attendance->latitude }}, {{ $attendance->longitude }}</td>
                        <td>{{ $attendance->status }}</td>
                        <td>
                            @if ($attendance->photo_url)
                                <a href="{{ $attendance->photo_url }}" target="_blank">Lihat Foto</a>
                            @else
                                -
                            @endif
                        </td>
                    </tr>
                @empty
                    <tr>
                        <td colspan="9" style="text-align:center;">
                            Belum ada data absensi.
                        </td>
                    </tr>
                @endforelse
            </tbody>
        </table>

        <div class="pagination">
            {{ $attendances->links() }}
        </div>
    </div>
</body>
</html>