<?php

namespace App\Console\Commands;

use Illuminate\Console\Command;
use Illuminate\Support\Facades\Schema;
use Illuminate\Database\Schema\Blueprint;

class RecreateSessionsTable extends Command
{
    protected $signature = 'sessions:recreate';
    protected $description = 'Recreate the sessions table if it does not exist';

    public function handle()
    {
        $this->info('Checking sessions table...');

        // Check if sessions table exists
        if (!Schema::hasTable('sessions')) {
            $this->info('Recreating sessions table...');
            
            Schema::create('sessions', function (Blueprint $table) {
                $table->string('id')->primary();
                $table->foreignId('user_id')->nullable()->index();
                $table->string('ip_address', 45)->nullable();
                $table->text('user_agent')->nullable();
                $table->text('payload');
                $table->integer('last_activity')->index();
            });
            
            $this->info('Sessions table created successfully.');
        } else {
            $this->info('Sessions table already exists.');
        }

        $this->info('Operation completed.');
    }
} 