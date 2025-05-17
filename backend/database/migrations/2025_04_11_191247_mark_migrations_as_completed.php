<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;
use Illuminate\Support\Facades\DB;

return new class extends Migration
{
    public function up(): void
    {
        // Get the current max batch number
        $batch = DB::table('migrations')->max('batch') + 1;
        
        // Get list of migration files that might cause conflicts
        $migrations = [
            '2025_04_11_180900_create_products_table',
            '2025_04_11_180945_create_categories_table'
        ];
        
        // Check if any of these migrations are not yet in the migrations table
        foreach ($migrations as $migration) {
            $exists = DB::table('migrations')
                ->where('migration', $migration)
                ->exists();
                
            if (!$exists) {
                DB::table('migrations')->insert([
                    'migration' => $migration,
                    'batch' => $batch
                ]);
            }
        }
        
        // Also look for and mark any *create_brands_table migration
        $brandMigration = DB::select("SELECT * FROM migrations WHERE migration LIKE '%create_brands_table'");
        if (empty($brandMigration)) {
            DB::table('migrations')->insert([
                'migration' => '2025_04_11_180930_create_brands_table',
                'batch' => $batch
            ]);
        }
    }

    public function down(): void
    {
        // Remove the migration entries if needed
        DB::table('migrations')
            ->whereIn('migration', [
                '2025_04_11_180900_create_products_table',
                '2025_04_11_180945_create_categories_table',
                '2025_04_11_180930_create_brands_table'
            ])
            ->delete();
    }
};