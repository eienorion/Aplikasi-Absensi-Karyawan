<!DOCTYPE html>
<html lang="id">
<head>
    <meta charset="UTF-8">
    <title>Login Admin</title>
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
            --text-hint: rgba(255, 255, 255, 0.20);
            --input-bg: rgba(255, 255, 255, 0.05);
            --input-border: rgba(255, 255, 255, 0.10);
            --card-border: rgba(255, 255, 255, 0.08);
            --amber: #F4B347;
            --amber-bg: rgba(244, 179, 71, 0.10);
            --amber-border: rgba(244, 179, 71, 0.20);
        }

        body {
            margin: 0;
            min-height: 100vh;
            background: var(--bg-dark);
            color: var(--text-primary);
            font-family: Arial, sans-serif;
        }

        .page {
            min-height: 100vh;
            padding: 24px;
            display: flex;
            align-items: center;
            justify-content: center;
        }

        .login-card {
            width: 100%;
            max-width: 430px;
        }

        .brand {
            display: flex;
            align-items: center;
            gap: 12px;
            margin-bottom: 46px;
        }

        .brand-icon {
            width: 42px;
            height: 42px;
            border-radius: 12px;
            background: var(--accent);
            display: flex;
            align-items: center;
            justify-content: center;
            font-size: 21px;
        }

        .brand-title {
            font-size: 16px;
            font-weight: 700;
            letter-spacing: -0.3px;
        }

        .brand-subtitle {
            font-size: 12px;
            color: var(--text-muted);
            margin-top: 3px;
        }

        .eyebrow {
            color: var(--accent);
            font-size: 11px;
            font-weight: 700;
            letter-spacing: 1.5px;
            margin-bottom: 8px;
        }

        h1 {
            margin: 0;
            font-size: 34px;
            line-height: 1.12;
            letter-spacing: -1px;
            font-weight: 700;
        }

        .desc {
            margin-top: 12px;
            color: var(--text-muted);
            font-size: 14px;
            line-height: 1.6;
        }

        .form-box {
            margin-top: 34px;
        }

        label {
            display: block;
            margin-bottom: 8px;
            font-size: 11px;
            letter-spacing: 0.8px;
            color: var(--text-muted);
            font-weight: 700;
        }

        .field {
            margin-bottom: 16px;
        }

        .input-wrap {
            position: relative;
        }

        .input-icon {
            position: absolute;
            top: 50%;
            left: 15px;
            transform: translateY(-50%);
            color: rgba(255, 255, 255, 0.25);
            font-size: 15px;
        }

        input {
            width: 100%;
            height: 50px;
            border-radius: 12px;
            border: 1px solid var(--input-border);
            background: var(--input-bg);
            outline: none;
            color: var(--text-primary);
            padding: 0 14px 0 42px;
            font-size: 14px;
        }

        input::placeholder {
            color: var(--text-hint);
        }

        input:focus {
            border-color: var(--accent);
        }

        .error-box {
            margin-bottom: 18px;
            padding: 13px 15px;
            border-radius: 12px;
            color: var(--amber);
            background: var(--amber-bg);
            border: 1px solid var(--amber-border);
            font-size: 13px;
            line-height: 1.5;
        }

        .submit-btn {
            width: 100%;
            height: 50px;
            margin-top: 12px;
            border: none;
            border-radius: 12px;
            background: var(--accent);
            color: white;
            font-size: 14px;
            font-weight: 700;
            cursor: pointer;
        }

        .submit-btn:hover {
            background: var(--accent-light);
        }

        .bottom-link {
            margin-top: 24px;
            text-align: center;
            color: var(--text-muted);
            font-size: 13px;
        }

        .bottom-link a {
            color: var(--accent-light);
            text-decoration: none;
            font-weight: 700;
        }

        .footer {
            margin-top: 42px;
            text-align: center;
            color: rgba(255, 255, 255, 0.15);
            font-size: 12px;
        }
    </style>
</head>
<body>
    <main class="page">
        <section class="login-card">
            <div class="brand">
                <div class="brand-icon">💊</div>
                <div>
                    <div class="brand-title">Apotek Bunut</div>
                    <div class="brand-subtitle">Sistem Absensi Karyawan</div>
                </div>
            </div>

            <div class="eyebrow">ADMIN PANEL</div>
            <h1>Masuk ke<br>dashboard admin</h1>
            <p class="desc">
                Gunakan username dan password admin untuk mengelola data absensi.
            </p>

            <form class="form-box" method="POST" action="{{ route('admin.login.post') }}">
                @csrf

                @if ($errors->any())
                    <div class="error-box">
                        @foreach ($errors->all() as $error)
                            <div>{{ $error }}</div>
                        @endforeach
                    </div>
                @endif

                <div class="field">
                    <label>USERNAME</label>
                    <div class="input-wrap">
                        <span class="input-icon">👤</span>
                        <input
                            type="text"
                            name="username"
                            placeholder="Username"
                            value="{{ old('username') }}"
                            required
                            autofocus
                        >
                    </div>
                </div>

                <div class="field">
                    <label>PASSWORD</label>
                    <div class="input-wrap">
                        <span class="input-icon">🔒</span>
                        <input
                            type="password"
                            name="password"
                            placeholder="Password"
                            required
                        >
                    </div>
                </div>

                <button type="submit" class="submit-btn">
                    Masuk
                </button>

            </form>

            <div class="footer">
                Apotek Bunut • Admin Dashboard v1.0
            </div>
        </section>
    </main>
</body>
</html>