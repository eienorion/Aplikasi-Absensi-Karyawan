<?php

namespace App\Http\Controllers;

use App\Models\Attendance;
use App\Models\User;
use Illuminate\Http\Request;

class AdminDashboardController extends Controller
{
    public function dashboard()
    {
        if (auth()->user()->role !== 'admin') {
            abort(403);
        }

        $totalKaryawan = User::where('role', 'karyawan')->count();
        $totalAbsensi = Attendance::count();
        $absensiHariIni = Attendance::whereDate('attendance_date', today())->count();

        return view('admin.dashboard', compact(
            'totalKaryawan',
            'totalAbsensi',
            'absensiHariIni'
        ));
    }

    public function attendances(Request $request)
    {
        if (auth()->user()->role !== 'admin') {
            abort(403);
        }

        $query = Attendance::with('user')
            ->orderBy('attendance_date', 'desc')
            ->orderBy('attendance_time', 'desc');

        if ($request->filled('month')) {
            $query->whereMonth('attendance_date', $request->month);
        }

        if ($request->filled('year')) {
            $query->whereYear('attendance_date', $request->year);
        }

        $attendances = $query->paginate(10)->withQueryString();

        return view('admin.attendances', compact('attendances'));
    }
}