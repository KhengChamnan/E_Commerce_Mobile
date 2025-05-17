<?php

namespace App\Console\Commands;

use Illuminate\Console\Command;
use Illuminate\Support\Facades\Schema;
use Illuminate\Database\Schema\Blueprint;

class RecreateOrdersTables extends Command
{
    protected $signature = 'orders:recreate';
    protected $description = 'Recreate the orders and order_items tables if they do not exist';

    public function handle()
    {
        $this->info('Checking orders tables...');

        // Check and recreate orders table
        if (!Schema::hasTable('orders')) {
            $this->info('Recreating orders table...');
            
            Schema::create('orders', function (Blueprint $table) {
                $table->id();
                $table->foreignId('user_id')->constrained();
                $table->string('order_number')->unique();
                $table->decimal('total_amount', 10, 2);
                $table->decimal('shipping_cost', 8, 2)->default(0);
                $table->string('status')->default('pending'); // pending, processing, completed, cancelled
                $table->string('payment_status')->default('unpaid'); // unpaid, paid, refunded
                $table->text('shipping_address')->nullable();
                $table->string('phone')->nullable();
                $table->string('transaction_id')->nullable();
                $table->timestamps();
            });
            
            $this->info('Orders table created successfully.');
        } else {
            $this->info('Orders table already exists.');
        }

        // Check and recreate order_items table
        if (!Schema::hasTable('order_items')) {
            $this->info('Recreating order_items table...');
            
            Schema::create('order_items', function (Blueprint $table) {
                $table->id();
                $table->foreignId('order_id')->constrained()->onDelete('cascade');
                $table->foreignId('product_id')->constrained();
                $table->string('product_name');
                $table->decimal('price', 10, 2);
                $table->integer('quantity');
                $table->timestamps();
            });
            
            $this->info('Order_items table created successfully.');
        } else {
            $this->info('Order_items table already exists.');
        }

        $this->info('Operation completed.');
    }
} 