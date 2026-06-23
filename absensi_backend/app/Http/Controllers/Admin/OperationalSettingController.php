<?php

namespace App\Http\Controllers\Admin;

use App\Http\Controllers\Controller;
use App\Models\OperationalSetting;
use Illuminate\Http\Request;

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

    public function edit()
    {
        $setting = $this->getSetting();

        return view('admin.operational-setting', compact('setting'));
    }

    public function update(Request $request)
    {
        $request->validate([
            'open_time' => ['required', 'date_format:H:i'],
            'close_time' => ['required', 'date_format:H:i'],
            'note' => ['nullable', 'string', 'max:255'],
        ]);

        $setting = $this->getSetting();

        $setting->update([
            'open_time' => $request->open_time,
            'close_time' => $request->close_time,
            'is_active' => $request->has('is_active'),
            'note' => $request->note,
        ]);

        return redirect()
            ->route('admin.operational.edit')
            ->with('success', 'Jam operasional berhasil diperbarui');
    }
}