<?php

namespace App\Providers;

use Illuminate\Support\ServiceProvider;
use Illuminate\Support\Facades\Route;
use App\Http\Middleware\CheckIsAdmin;
use App\Services\StripeService; // Change this line
use App\Http\Middleware\AdminAuthentication;

class AppServiceProvider extends ServiceProvider
{
    /**
     * Register any application services.
     */
    public function register(): void
    {
        // Replace PayWayService with StripeService
        $this->app->singleton(StripeService::class, function ($app) {
            return new StripeService();
        });
    }

    /**
     * Bootstrap any application services.
     */
    public function boot(): void
    {
        // Register the admin middleware
        Route::aliasMiddleware('admin', CheckIsAdmin::class);
        Route::aliasMiddleware('admin.auth', AdminAuthentication::class);
    }
}