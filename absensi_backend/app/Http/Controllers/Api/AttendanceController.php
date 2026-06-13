<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use App\Models\Attendance;
use Illuminate\Http\Request;
use App\Models\User;
use App\Services\GoogleDriveService;
use Illuminate\Support\Facades\Storage;
use App\Exports\AttendancesExport;
use Maatwebsite\Excel\Facades\Excel;

class AttendanceController extends Controller
{
    public function store(Request $request, GoogleDriveService $googleDrive)
{
    $validated = $request->validate([
        'user_id' => 'required|exists:users,id',
        'attendance_type' => 'required|in:Masuk,Pulang',
        'latitude' => 'required|numeric',
        'longitude' => 'required|numeric',
        'photo' => 'nullable|image|max:5120',
    ]);

    $user = User::findOrFail($validated['user_id']);

    $photoPath = null;
    $photoUrl = null;
    $photoDriveId = null;
    $photoFolder = null;

    if ($request->hasFile('photo')) {
        $upload = $googleDrive->uploadAttendancePhoto(
            $request->file('photo'),
            $user->name,
            $validated['attendance_type']
        );

        $photoPath = $upload['path'];
        $photoUrl = $upload['url'];
        $photoDriveId = $upload['drive_id'];
        $photoFolder = $upload['folder'];
    }

    $attendance = Attendance::create([
        'user_id' => $validated['user_id'],
        'attendance_type' => $validated['attendance_type'],
        'attendance_date' => now()->toDateString(),
        'attendance_time' => now()->format('H:i:s'),
        'latitude' => $validated['latitude'],
        'longitude' => $validated['longitude'],
        'photo_path' => $photoPath,
        'photo_url' => $photoUrl,
        'photo_drive_id' => $photoDriveId,
        'photo_folder' => $photoFolder,
        'status' => 'valid',
    ]);

    return response()->json([
        'message' => 'Absensi berhasil disimpan',
        'attendance' => $attendance,
    ], 201);
}

    public function index(Request $request)
    {
        $query = Attendance::with('user')->latest();

        if ($request->filled('month')) {
            $query->whereMonth('attendance_date', $request->month);
        }

        if ($request->filled('year')) {
            $query->whereYear('attendance_date', $request->year);
        }

        if ($request->filled('user_id')) {
            $query->where('user_id', $request->user_id);
        }

        return response()->json([
            'message' => 'Data absensi berhasil diambil',
            'data' => $query->get(),
        ]);
    }

    public function summary()
    {
        $today = now()->toDateString();

        return response()->json([
            'total_absensi' => Attendance::count(),
            'absensi_hari_ini' => Attendance::whereDate('attendance_date', $today)->count(),
            'masuk_hari_ini' => Attendance::whereDate('attendance_date', $today)
                ->where('attendance_type', 'Masuk')
                ->count(),
            'pulang_hari_ini' => Attendance::whereDate('attendance_date', $today)
                ->where('attendance_type', 'Pulang')
                ->count(),
        ]);
    }
    public function export(Request $request)
{
    $month = $request->filled('month') ? (int) $request->month : null;
    $year = $request->filled('year') ? (int) $request->year : null;

    $fileName = 'rekap_absensi';

    if ($month && $year) {
        $fileName .= '_' . $year . '_' . str_pad($month, 2, '0', STR_PAD_LEFT);
    }

    $fileName .= '.xlsx';

    return Excel::download(new AttendancesExport($month, $year), $fileName);
}
}