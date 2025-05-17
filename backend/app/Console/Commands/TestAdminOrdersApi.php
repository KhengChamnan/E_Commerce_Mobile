<?php

namespace App\Console\Commands;

use Illuminate\Console\Command;
use Illuminate\Support\Facades\Http;
use App\Models\User;
use PHPOpenSourceSaver\JWTAuth\Facades\JWTAuth;

class TestAdminOrdersApi extends Command
{
    protected $signature = 'test:admin-orders-api';
    protected $description = 'Test the admin orders API';

    public function handle()
    {
        $this->info('Testing Admin Orders API...');
        
        // First, let's find an admin user
        $admin = User::where('role', 'admin')->first();
        
        if (!$admin) {
            $this->error('No admin user found in the database!');
            return;
        }
        
        $this->info('Using admin user: ' . $admin->email);
        
        // Generate a token for the admin
        $token = JWTAuth::fromUser($admin);
        
        if (!$token) {
            $this->error('Failed to generate token for admin user');
            return;
        }
        
        $this->info('Successfully generated JWT token');
        
        // Get the base URL from config
        $baseUrl = env('APP_URL', 'http://localhost:8000');
        $this->info('Using base URL: ' . $baseUrl);
        
        // Test the admin orders API endpoint
        try {
            $this->info('Testing GET /api/admin/orders endpoint...');
            
            $response = Http::withHeaders([
                'Authorization' => 'Bearer ' . $token,
                'Accept' => 'application/json',
            ])->get($baseUrl . '/api/admin/orders');
            
            $this->info('Response Status: ' . $response->status());
            
            if ($response->successful()) {
                $data = $response->json();
                $this->info('Response data:');
                $this->info(json_encode($data, JSON_PRETTY_PRINT));
                
                if (isset($data['orders']) && is_array($data['orders'])) {
                    $this->info('Number of orders returned: ' . count($data['orders']));
                } else {
                    $this->warn('No orders array found in the response');
                }
            } else {
                $this->error('API request failed: ' . $response->body());
            }
        } catch (\Exception $e) {
            $this->error('Exception: ' . $e->getMessage());
        }
        
        $this->info('Test completed.');
    }
} 