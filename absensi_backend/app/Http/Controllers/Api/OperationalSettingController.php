<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use App\Models\OperationalSetting;
use Carbon\Carbon;

class OperationalSettingController extends Controller
{
    private function getSetting(): OperationalSetting
    {
        return OperationalSetting::firstOrCreate(
            ['id' => 1],
            [
                'open_time' => '08:00:00',
                'close_time' => '21:00:00',
                'is_active' => true,
                'note' => 'Jam operasional Apotek Bunut',
            ]
        );
    }

    private function isOperationalNow(
        string $openTime,
        string $closeTime,
        bool $isActive
    ): bool {
        if (!$isActive) {
            return false;
        }

        $now = Carbon::now('Asia/Jakarta');

        $nowMinutes = ((int) $now->format('H')) * 60 + ((int) $now->format('i'));

        [$openHour, $openMinute] = explode(':', substr($openTime, 0, 5));
        [$closeHour, $closeMinute] = explode(':', substr($closeTime, 0, 5));

        $openMinutes = ((int) $openHour) * 60 + ((int) $openMinute);
        $closeMinutes = ((int) $closeHour) * 60 + ((int) $closeMinute);

        if ($openMinutes <= $closeMinutes) {
            return $nowMinutes >= $openMinutes && $nowMinutes <= $closeMinutes;
        }

        return $nowMinutes >= $openMinutes || $nowMinutes <= $closeMinutes;
    }

    public function show()
    {
        $setting = $this->getSetting();

        $openTime = substr($setting->open_time, 0, 5);
        $closeTime = substr($setting->close_time, 0, 5);

        $isOperationalNow = $this->isOperationalNow(
            $setting->open_time,
            $setting->close_time,
            (bool) $setting->is_active
        );

        return response()->json([
            'message' => 'Pengaturan operasional berhasil diambil',
            'data' => [
                'open_time' => $openTime,
                'close_time' => $closeTime,
                'is_active' => (bool) $setting->is_active,
                'is_operational_now' => $isOperationalNow,
                'status_text' => $isOperationalNow ? 'Operasional' : 'Tutup',
                'note' => $setting->note,
            ],
        ]);
    }
}