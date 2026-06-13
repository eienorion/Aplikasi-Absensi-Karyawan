<?php

namespace App\Exports;

use App\Models\Attendance;
use Maatwebsite\Excel\Concerns\FromQuery;
use Maatwebsite\Excel\Concerns\ShouldAutoSize;
use Maatwebsite\Excel\Concerns\WithHeadings;
use Maatwebsite\Excel\Concerns\WithMapping;

class AttendancesExport implements FromQuery, WithHeadings, WithMapping, ShouldAutoSize
{
    private ?int $month;
    private ?int $year;
    private int $rowNumber = 0;

    public function __construct(?int $month = null, ?int $year = null)
    {
        $this->month = $month;
        $this->year = $year;
    }

    public function query()
    {
        $query = Attendance::query()
            ->with('user')
            ->orderBy('attendance_date', 'asc')
            ->orderBy('attendance_time', 'asc');

        if ($this->month) {
            $query->whereMonth('attendance_date', $this->month);
        }

        if ($this->year) {
            $query->whereYear('attendance_date', $this->year);
        }

        return $query;
    }

    public function headings(): array
    {
        return [
            'No',
            'Nama Karyawan',
            'Email',
            'Jenis Absensi',
            'Tanggal',
            'Jam',
            'Latitude',
            'Longitude',
            'Status',
            'Link Foto',
            'Folder Foto',
        ];
    }

    public function map($attendance): array
    {
        $this->rowNumber++;

        return [
            $this->rowNumber,
            $attendance->user->name ?? '-',
            $attendance->user->email ?? '-',
            $attendance->attendance_type,
            $attendance->attendance_date,
            $attendance->attendance_time,
            $attendance->latitude,
            $attendance->longitude,
            $attendance->status,
            $attendance->photo_url ?? '-',
            $attendance->photo_folder ?? '-',
        ];
    }
}