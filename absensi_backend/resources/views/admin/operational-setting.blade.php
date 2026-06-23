<!DOCTYPE html>
<html lang="id">
<head>
    <meta charset="UTF-8">
    <title>Pengaturan Jam Operasional</title>
    <meta name="viewport" content="width=device-width, initial-scale=1.0">

    <style>
        * {
            box-sizing: border-box;
        }

        body {
            margin: 0;
            min-height: 100vh;
            font-family: Arial, sans-serif;
            background: #0A0F1E;
            color: #FFFFFF;
        }

        .page {
            width: 100%;
            min-height: 100vh;
            padding: 28px;
        }

        .top-bar {
            display: flex;
            justify-content: space-between;
            align-items: center;
            margin-bottom: 34px;
        }

        .brand {
            display: inline-flex;
            align-items: center;
            gap: 10px;
            padding: 8px 12px;
            background: #0D1328;
            border: 1px solid rgba(255, 255, 255, 0.08);
            border-radius: 999px;
        }

        .brand-icon {
            width: 24px;
            height: 24px;
            background: #2D6BE4;
            border-radius: 7px;
            display: flex;
            align-items: center;
            justify-content: center;
            font-size: 13px;
        }

        .brand-text {
            font-size: 13px;
            font-weight: 600;
        }

        .back-link {
            color: rgba(255, 255, 255, 0.45);
            text-decoration: none;
            font-size: 13px;
        }

        .badge {
            display: inline-flex;
            align-items: center;
            gap: 7px;
            padding: 7px 12px;
            border-radius: 999px;
            font-size: 12px;
            font-weight: 600;
            color: #5B8FEF;
            background: rgba(91, 143, 239, 0.10);
            border: 1px solid rgba(91, 143, 239, 0.20);
        }

        .container {
            max-width: 720px;
            margin: 0 auto;
        }

        .eyebrow {
            font-size: 11px;
            letter-spacing: 1.5px;
            font-weight: 700;
            color: #2D6BE4;
            margin-bottom: 8px;
        }

        h1 {
            font-size: 34px;
            line-height: 1.12;
            letter-spacing: -1px;
            margin: 0;
            font-weight: 700;
        }

        .subtitle {
            margin-top: 12px;
            color: rgba(255, 255, 255, 0.45);
            font-size: 14px;
            line-height: 1.6;
        }

        .card {
            margin-top: 30px;
            background: #0D1328;
            border: 1px solid rgba(255, 255, 255, 0.08);
            border-radius: 18px;
            padding: 22px;
        }

        .success {
            margin-bottom: 18px;
            padding: 13px 15px;
            border-radius: 12px;
            color: #3CC99A;
            background: rgba(60, 201, 154, 0.10);
            border: 1px solid rgba(60, 201, 154, 0.20);
            font-size: 13px;
            font-weight: 600;
        }

        .error {
            margin-bottom: 18px;
            padding: 13px 15px;
            border-radius: 12px;
            color: #F4B347;
            background: rgba(244, 179, 71, 0.10);
            border: 1px solid rgba(244, 179, 71, 0.20);
            font-size: 13px;
        }

        .form-grid {
            display: grid;
            grid-template-columns: 1fr 1fr;
            gap: 14px;
        }

        .field {
            margin-bottom: 16px;
        }

        label {
            display: block;
            margin-bottom: 8px;
            font-size: 11px;
            letter-spacing: 0.8px;
            font-weight: 700;
            color: rgba(255, 255, 255, 0.45);
        }

        input[type="time"],
        input[type="text"] {
            width: 100%;
            height: 48px;
            padding: 0 14px;
            border-radius: 12px;
            border: 1px solid rgba(255, 255, 255, 0.10);
            outline: none;
            background: rgba(255, 255, 255, 0.05);
            color: #FFFFFF;
            font-size: 14px;
        }

        input[type="time"]:focus,
        input[type="text"]:focus {
            border-color: #2D6BE4;
        }

        .switch-box {
            margin-top: 6px;
            padding: 15px;
            border-radius: 14px;
            background: rgba(255, 255, 255, 0.04);
            border: 1px solid rgba(255, 255, 255, 0.08);
            display: flex;
            align-items: center;
            gap: 12px;
        }

        .switch-box input {
            width: 18px;
            height: 18px;
            accent-color: #3CC99A;
        }

        .switch-title {
            font-size: 14px;
            font-weight: 600;
        }

        .switch-desc {
            margin-top: 2px;
            font-size: 12px;
            color: rgba(255, 255, 255, 0.45);
        }

        .preview {
            margin-top: 18px;
            padding: 16px;
            border-radius: 14px;
            background: rgba(91, 143, 239, 0.10);
            border: 1px solid rgba(91, 143, 239, 0.20);
            display: flex;
            align-items: center;
            justify-content: space-between;
            gap: 14px;
        }

        .preview-label {
            font-size: 12px;
            color: rgba(255, 255, 255, 0.45);
        }

        .preview-value {
            margin-top: 3px;
            font-size: 18px;
            font-weight: 700;
            color: #FFFFFF;
        }

        .preview-pill {
            padding: 7px 12px;
            border-radius: 999px;
            color: #3CC99A;
            background: rgba(60, 201, 154, 0.10);
            border: 1px solid rgba(60, 201, 154, 0.20);
            font-size: 12px;
            font-weight: 700;
            white-space: nowrap;
        }

        .actions {
            display: flex;
            justify-content: flex-end;
            gap: 10px;
            margin-top: 24px;
        }

        .btn {
            height: 46px;
            padding: 0 18px;
            border: none;
            border-radius: 12px;
            cursor: pointer;
            font-size: 14px;
            font-weight: 700;
        }

        .btn-primary {
            background: #2D6BE4;
            color: white;
        }

        .btn-secondary {
            background: rgba(255, 255, 255, 0.05);
            color: rgba(255, 255, 255, 0.60);
            border: 1px solid rgba(255, 255, 255, 0.08);
            text-decoration: none;
            display: inline-flex;
            align-items: center;
        }

        @media (max-width: 640px) {
            .page {
                padding: 22px;
            }

            .form-grid {
                grid-template-columns: 1fr;
            }

            h1 {
                font-size: 28px;
            }

            .preview {
                align-items: flex-start;
                flex-direction: column;
            }
        }
    </style>
</head>
<body>
    <main class="page">
        <div class="top-bar">
            <div class="brand">
                <div class="brand-icon">💊</div>
                <div class="brand-text">Apotek Bunut</div>
            </div>

            <a href="{{ route('admin.dashboard') }}" class="back-link">
                Kembali ke Dashboard
            </a>
        </div>

        <div class="container">
            <div class="badge">⚙ Pengaturan Web Admin</div>

            <div style="height: 22px;"></div>

            <div class="eyebrow">JAM OPERASIONAL</div>
            <h1>Atur jam operasional aplikasi mobile</h1>
            <p class="subtitle">
                Jam ini akan digunakan oleh aplikasi mobile untuk menampilkan status
                operasional pada halaman utama karyawan.
            </p>

            <div class="card">
                @if (session('success'))
                    <div class="success">
                        {{ session('success') }}
                    </div>
                @endif

                @if ($errors->any())
                    <div class="error">
                        @foreach ($errors->all() as $error)
                            <div>{{ $error }}</div>
                        @endforeach
                    </div>
                @endif

                <form action="{{ route('admin.operational.update') }}" method="POST">
                    @csrf
                    @method('PUT')

                    <div class="form-grid">
                        <div class="field">
                            <label>JAM BUKA</label>
                            <input
                                type="time"
                                name="open_time"
                                value="{{ old('open_time', substr($setting->open_time, 0, 5)) }}"
                                required
                            >
                        </div>

                        <div class="field">
                            <label>JAM TUTUP</label>
                            <input
                                type="time"
                                name="close_time"
                                value="{{ old('close_time', substr($setting->close_time, 0, 5)) }}"
                                required
                            >
                        </div>
                    </div>

                    <div class="field">
                        <label>CATATAN</label>
                        <input
                            type="text"
                            name="note"
                            value="{{ old('note', $setting->note) }}"
                            placeholder="Contoh: Jam operasional Apotek Bunut"
                        >
                    </div>

                    <div class="switch-box">
                        <input
                            type="checkbox"
                            name="is_active"
                            id="is_active"
                            {{ $setting->is_active ? 'checked' : '' }}
                        >
                        <div>
                            <label for="is_active" class="switch-title">
                                Aktifkan Jam Operasional
                            </label>
                            <div class="switch-desc">
                                Jika dimatikan, aplikasi mobile akan menampilkan status tutup.
                            </div>
                        </div>
                    </div>

                    <div class="preview">
                        <div>
                            <div class="preview-label">Jam operasional saat ini</div>
                            <div class="preview-value">
                                {{ substr($setting->open_time, 0, 5) }}
                                -
                                {{ substr($setting->close_time, 0, 5) }}
                            </div>
                        </div>

                        <div class="preview-pill">
                            {{ $setting->is_active ? 'Aktif' : 'Nonaktif' }}
                        </div>
                    </div>

                    <div class="actions">
                        <a href="{{ route('admin.dashboard') }}" class="btn btn-secondary">
                            Batal
                        </a>
                        <button type="submit" class="btn btn-primary">
                            Simpan Pengaturan
                        </button>
                    </div>
                </form>
            </div>
        </div>
    </main>
</body>
</html>