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
    Schema::create('operational_settings', function (Blueprint $table) {
        $table->id();
        $table->time('open_time')->default('08:00:00');
        $table->time('close_time')->default('21:00:00');
        $table->boolean('is_active')->default(true);
        $table->string('note')->nullable();
        $table->timestamps();
    });
}

    /**
     * Reverse the migrations.
     */
    public function down(): void
    {
        Schema::dropIfExists('operational_settings');
    }
};
