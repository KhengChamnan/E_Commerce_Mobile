<?php

namespace App\Console\Commands;

use Illuminate\Console\Command;
use Illuminate\Support\Facades\Schema;
use Illuminate\Database\Schema\Blueprint;

class RecreateCache extends Command
{
    protected $signature = 'cache:recreate';
    protected $description = 'Recreate the cache and cache_locks tables if they do not exist';

    public function handle()
    {
        $this->info('Checking cache tables...');

        // Check if cache table exists
        if (!Schema::hasTable('cache')) {
            $this->info('Recreating cache table...');
            
            Schema::create('cache', function (Blueprint $table) {
                $table->string('key')->primary();
                $table->mediumText('value');
                $table->integer('expiration');
            });
            
            $this->info('Cache table created successfully.');
        } else {
            $this->info('Cache table already exists.');
        }

        // Check if cache_locks table exists
        if (!Schema::hasTable('cache_locks')) {
            $this->info('Recreating cache_locks table...');
            
            Schema::create('cache_locks', function (Blueprint $table) {
                $table->string('key')->primary();
                $table->string('owner');
                $table->integer('expiration');
            });
            
            $this->info('Cache_locks table created successfully.');
        } else {
            $this->info('Cache_locks table already exists.');
        }

        $this->info('Operation completed.');
    }
} 