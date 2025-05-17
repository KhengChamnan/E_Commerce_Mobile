<?php

require __DIR__.'/vendor/autoload.php';

$app = require_once __DIR__.'/bootstrap/app.php';
$kernel = $app->make(Illuminate\Contracts\Console\Kernel::class);
$kernel->bootstrap();

use Illuminate\Support\Facades\Schema;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\DB;

// Check if cache table exists
if (!Schema::hasTable('cache')) {
    echo "Recreating cache table...\n";
    
    Schema::create('cache', function (Blueprint $table) {
        $table->string('key')->primary();
        $table->mediumText('value');
        $table->integer('expiration');
    });
    
    echo "Cache table created successfully.\n";
} else {
    echo "Cache table already exists.\n";
}

// Check if cache_locks table exists
if (!Schema::hasTable('cache_locks')) {
    echo "Recreating cache_locks table...\n";
    
    Schema::create('cache_locks', function (Blueprint $table) {
        $table->string('key')->primary();
        $table->string('owner');
        $table->integer('expiration');
    });
    
    echo "Cache_locks table created successfully.\n";
} else {
    echo "Cache_locks table already exists.\n";
}

echo "Operation completed.\n"; 