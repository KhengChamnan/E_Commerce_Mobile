<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    /**
     * Run the migrations.
     */
    public function up(): void
    {
        Schema::table('slideshows', function (Blueprint $table) {
            $table->boolean('enable')->default(true);
            $table->string('link')->nullable();
            $table->integer('ssorder')->default(0);
        });
    }

    /**
     * Reverse the migrations.
     */
    public function down(): void
    {
        Schema::table('slideshows', function (Blueprint $table) {
            $table->dropColumn(['enable', 'link', 'ssorder']);
        });
    }
};
