<?php

use App\Http\Controllers\AuthController;
use App\Http\Controllers\BrandController;
use App\Http\Controllers\CategoryController;
use App\Http\Controllers\ProductController;
use App\Http\Controllers\SlideshowController;
use App\Http\Controllers\CartController;
use App\Http\Controllers\OrderController; // Add this line
use App\Http\Controllers\PaymentController; // Add this line
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Route;

// Route::get('/user', function (Request $request) {
//     return $request->user();
// })->middleware('auth:sanctum');

// Authentication
 
Route::group([
    'middleware' => ['api', 'cors'],
    'prefix' => 'auth'
], function ($router) {
    Route::post('/register', [AuthController::class, 'register'])->name('register');
    Route::post('/login', [AuthController::class, 'login'])->name('login');
    Route::post('/logout', [AuthController::class, 'logout'])->middleware('auth:api')->name('logout');
    Route::post('/refresh', [AuthController::class, 'refresh'])->middleware('auth:api')->name('refresh');
    Route::post('/me', [AuthController::class, 'me'])->middleware('auth:api')->name('me');
});

Route::get('public/active-slideshows', [SlideshowController::class, 'getActiveSlides']);

// Admin-only routes - protected by admin middleware
Route::middleware(['auth:api', 'admin'])->group(function () {
    // Brand routes
    Route::apiResource('brands', BrandController::class);
    
    // Category routes
    Route::apiResource('categories', CategoryController::class);
    
    // Product routes
    Route::apiResource('products', ProductController::class);
    
    // Slideshow routes
    Route::apiResource('slideshows', SlideshowController::class);
    
    // Admin dashboard route
    Route::get('/dashboard', function() {
        return response()->json([
            'stats' => [
                'users' => 100,
                // Other stats...
            ]
        ]);
    });
});

// Admin order routes
Route::middleware(['auth:api', 'admin'])->prefix('admin')->group(function () {
    // Order management
    Route::get('/orders', [OrderController::class, 'allOrders']);
    Route::get('/orders/{id}', [OrderController::class, 'adminShowOrder']);
    Route::patch('/orders/{id}/status', [OrderController::class, 'updateStatus']);
});


// PUBLIC ROUTES - No authentication required, no prefix
// Product display routes for all users (root level)
Route::get('/products', [ProductController::class, 'index']);
Route::get('/products/{product}', [ProductController::class, 'show']);

// Public routes for brands and categories (root level)
Route::get('/brands', [BrandController::class, 'index']);
Route::get('/categories', [CategoryController::class, 'index']);
Route::get('/slideshows', [SlideshowController::class, 'index']);

// Order routes
Route::prefix('orders')->middleware('auth:api')->group(function () {
    Route::get('/', [OrderController::class, 'index']);
    Route::post('/create', [OrderController::class, 'store']);
    Route::get('/{id}', [OrderController::class, 'show']);
    Route::patch('/{id}/status', [OrderController::class, 'updateUserOrderStatus']);
});

// Payment routes
Route::prefix('payments')->group(function () {
    // Public webhook endpoint 
    Route::post('/webhook', [PaymentController::class, 'handleWebhook']);
    
    // Routes that require authentication
    Route::middleware('auth:api')->group(function () {
        Route::get('/intent/{orderId}', [PaymentController::class, 'createIntent']);
        Route::get('/success', [PaymentController::class, 'success']);
        Route::get('/failed', [PaymentController::class, 'failed']);
    });
});


// Cart Routes

Route::prefix('cart')->middleware('auth:api')->group(function () {
    Route::get('/', [CartController::class, 'getCart']);
    Route::post('/add', [CartController::class, 'addToCart']);
    Route::put('/items/{id}', [CartController::class, 'updateCartItem']);
    Route::delete('/items/{id}', [CartController::class, 'removeCartItem']);
    Route::delete('/clear', [CartController::class, 'clearCart']);
});


