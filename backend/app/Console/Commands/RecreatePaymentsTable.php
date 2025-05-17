<?php

namespace App\Console\Commands;

use Illuminate\Console\Command;
use Illuminate\Support\Facades\Schema;
use Illuminate\Database\Schema\Blueprint;

class RecreatePaymentsTable extends Command
{
    protected $signature = 'payments:recreate';
    protected $description = 'Recreate the payments table if it does not exist';

    public function handle()
    {
        $this->info('Checking payments table...');

        // Check if payments table exists
        if (!Schema::hasTable('payments')) {
            $this->info('Recreating payments table...');
            
            Schema::create('payments', function (Blueprint $table) {
                $table->id();
                $table->foreignId('order_id')->constrained();
                $table->string('transaction_id');
                $table->decimal('amount', 10, 2);
                $table->string('currency')->default('USD');
                $table->string('payment_method')->default('Stripe');
                $table->string('status'); // success, failed, pending
                $table->json('response_data')->nullable();
                $table->timestamps();
            });
            
            $this->info('Payments table created successfully.');
        } else {
            $this->info('Payments table already exists.');
        }

        $this->info('Operation completed.');
    }
} 