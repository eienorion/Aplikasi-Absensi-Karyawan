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

    public function user()
    {
        return $this->belongsTo(User::class);
    }
}