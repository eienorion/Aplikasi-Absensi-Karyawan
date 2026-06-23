<?php

use Illuminate\Support\Facades\Route;
use App\Http\Controllers\AdminAuthController;
use App\Http\Controllers\AdminDashboardController;
use App\Http\Controllers\Api\AttendanceController;
use App\Http\Controllers\GoogleAuthController;
use App\Http\Controllers\Admin\OperationalSettingController;

Route::get('/', function () {
    return redirect()->route('admin.login');
});

Route::get('/google/redirect', [GoogleAuthController::class, 'redirect']);
Route::get('/google/callback', [GoogleAuthController::class, 'callback']);

Route::get('/admin/login', [AdminAuthController::class, 'showLogin'])->name('admin.login');
Route::post('/admin/login', [AdminAuthController::class, 'login'])->name('admin.login.post');
Route::post('/admin/logout', [AdminAuthController::class, 'logout'])->name('admin.logout');

Route::middleware('auth')->prefix('admin')->name('admin.')->group(function () {
    Route::get('/dashboard', [AdminDashboardController::class, 'dashboard'])->name('dashboard');
    Route::get('/attendances', [AdminDashboardController::class, 'attendances'])->name('attendances');
    Route::get('/attendances/export', [AttendanceController::class, 'export'])->name('attendances.export');
    Route::get('/operational-setting', [OperationalSettingController::class, 'edit'])
    ->name('operational.edit');

Route::put('/operational-setting', [OperationalSettingController::class, 'update'])
    ->name('operational.update');
});