<?php

use App\Http\Controllers\Api\AuthController;
use App\Http\Controllers\Api\AttendanceController;
use Illuminate\Support\Facades\Route;

Route::post('/register', [AuthController::class, 'register']);
Route::post('/login', [AuthController::class, 'login']);

Route::post('/attendances', [AttendanceController::class, 'store']);
Route::get('/attendances', [AttendanceController::class, 'index']);
Route::get('/attendances/summary', [AttendanceController::class, 'summary']);
Route::get('/attendances/export', [AttendanceController::class, 'export']);