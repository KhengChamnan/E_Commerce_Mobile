<?php

use Illuminate\Support\Facades\Route;
use App\Http\Controllers\AdminController;
use App\Http\Controllers\WebAuthController;
use Illuminate\Http\Request;

// Public routes (accessible without login)
Route::get('/admin/login', [WebAuthController::class, 'showLoginForm'])->name('admin.login');
Route::post('/store-token', [WebAuthController::class, 'storeToken'])->name('store.token');
Route::get('/logout', [WebAuthController::class, 'logout'])->name('admin.logout');

// Protected admin routes (require login)
Route::middleware(['admin.auth'])->group(function () {
    // Redirect root to admin dashboard
    Route::get('/', function() {
        return redirect('/admins');
    });
    
    // Admin panel routes
    Route::get('/admins', [AdminController::class, 'dashboard']);
    Route::get('/dashboard', [AdminController::class, 'dashboard']);
    Route::get('/products', [AdminController::class, 'products']);
    Route::get('/categories', [AdminController::class, 'categories']);
    Route::get('/brands', [AdminController::class, 'brands']);
    Route::get('/slideshows', [AdminController::class, 'slideshows']);
    Route::get('/orders', [AdminController::class, 'orders']); 
});

// Fallback - if route not found, redirect to login
Route::fallback(function () {
    return redirect()->route('admin.login');
});