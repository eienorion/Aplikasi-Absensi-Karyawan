<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;

class Attendance extends Model
{
    protected $fillable = [
        'user_id',
        'attendance_type',
        'attendance_date',
        'attendance_time',
        'latitude',
        'longitude',
        'photo_path',
        'photo_url',
        'photo_drive_id',
        'photo_folder',
        'status',
    ];

    protected $appends = [
        'punctuality_status',
        'punctuality_minutes',
    ];

    private static $operationalSettingCache = null;

    public function user()
    {
        return $this->belongsTo(User::class);
    }

    private function getOperationalSettingData(): array
    {
        if (self::$operationalSettingCache !== null) {
            return self::$operationalSettingCache;
        }

        $setting = OperationalSetting::first();

        if (!$setting) {
            self::$operationalSettingCache = [
                'open_time' => '08:00',
                'close_time' => '21:00',
                'is_active' => true,
            ];

            return self::$operationalSettingCache;
        }

        self::$operationalSettingCache = [
            'open_time' => substr($setting->open_time, 0, 5),
            'close_time' => substr($setting->close_time, 0, 5),
            'is_active' => (bool) $setting->is_active,
        ];

        return self::$operationalSettingCache;
    }

    private function timeToMinutes(?string $time): int
    {
        if (!$time) {
            return 0;
        }

        $time = substr($time, 0, 5);
        $parts = explode(':', $time);

        $hour = (int) ($parts[0] ?? 0);
        $minute = (int) ($parts[1] ?? 0);

        return ($hour * 60) + $minute;
    }

    public function getPunctualityStatusAttribute(): string
    {
        $attendanceType = strtolower((string) $this->attendance_type);

        // Untuk sementara, keterlambatan hanya dihitung dari Absensi Masuk.
        if ($attendanceType !== 'masuk') {
            return 'Tidak Dihitung';
        }

        $setting = $this->getOperationalSettingData();

        if (!$setting['is_active']) {
            return 'Operasional Nonaktif';
        }

        // Toleransi keterlambatan 10 menit.
        $toleranceMinutes = 10;

        $attendanceMinutes = $this->timeToMinutes($this->attendance_time);
        $openMinutes = $this->timeToMinutes($setting['open_time']);

        $maximumOnTimeMinutes = $openMinutes + $toleranceMinutes;

        return $attendanceMinutes <= $maximumOnTimeMinutes
            ? 'Tepat Waktu'
            : 'Terlambat';
    }

    public function getPunctualityMinutesAttribute(): int
    {
        $attendanceType = strtolower((string) $this->attendance_type);

        // Hanya Absensi Masuk yang dihitung keterlambatannya.
        if ($attendanceType !== 'masuk') {
            return 0;
        }

        $setting = $this->getOperationalSettingData();

        if (!$setting['is_active']) {
            return 0;
        }

        // Toleransi keterlambatan 10 menit.
        $toleranceMinutes = 10;

        $attendanceMinutes = $this->timeToMinutes($this->attendance_time);
        $openMinutes = $this->timeToMinutes($setting['open_time']);

        $maximumOnTimeMinutes = $openMinutes + $toleranceMinutes;

        return max(0, $attendanceMinutes - $maximumOnTimeMinutes);
    }
}