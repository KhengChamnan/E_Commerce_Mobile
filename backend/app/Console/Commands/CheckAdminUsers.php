<?php

namespace App\Console\Commands;

use Illuminate\Console\Command;
use App\Models\User;
use App\Models\Order;

class CheckAdminUsers extends Command
{
    protected $signature = 'check:admins';
    protected $description = 'Check for admin users and orders in the database';

    public function handle()
    {
        $this->info('Checking for admin users...');
        
        $admins = User::where('role', 'admin')->get();
        
        if ($admins->count() === 0) {
            $this->error('No admin users found in the database!');
        } else {
            $this->info('Found ' . $admins->count() . ' admin users:');
            $headers = ['ID', 'Name', 'Email', 'Role'];
            $rows = [];
            
            foreach ($admins as $admin) {
                $rows[] = [
                    $admin->id,
                    $admin->name,
                    $admin->email,
                    $admin->role
                ];
            }
            
            $this->table($headers, $rows);
        }
        
        $this->info('Checking for orders...');
        $orders = Order::all();
        
        if ($orders->count() === 0) {
            $this->error('No orders found in the database!');
        } else {
            $this->info('Found ' . $orders->count() . ' orders:');
            $headers = ['ID', 'User ID', 'Order Number', 'Total', 'Status', 'Payment'];
            $rows = [];
            
            foreach ($orders as $order) {
                $rows[] = [
                    $order->id,
                    $order->user_id,
                    $order->order_number,
                    $order->total_amount,
                    $order->status,
                    $order->payment_status
                ];
            }
            
            $this->table($headers, $rows);
        }
        
        $this->info('Operation completed.');
    }
} 