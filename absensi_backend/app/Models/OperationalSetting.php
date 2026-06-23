<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;

class OperationalSetting extends Model
{
    protected $fillable = [
        'open_time',
        'close_time',
        'is_active',
        'note',
    ];

    protected $casts = [
        'is_active' => 'boolean',
    ];
}