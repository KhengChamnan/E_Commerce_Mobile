<?php

namespace Database\Seeders;

use App\Models\User;  // Add this import
use Illuminate\Support\Facades\Hash;  // Add this import
use Illuminate\Database\Console\Seeds\WithoutModelEvents;
use Illuminate\Database\Seeder;

class AdminUserSeeder extends Seeder
{
    /**
     * Run the database seeds.
     */
    public function run(): void
    {
        User::create([
            'name' => 'Vicheka',
            'email' => 'vicheka@gmail.com',
            'password' => Hash::make('Vichekathong1'),
            'role' => 'admin',
        ]);
        
        $this->command->info('Admin user created!');

    }
}
